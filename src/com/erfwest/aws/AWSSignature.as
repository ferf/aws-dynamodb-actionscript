/**
 * AWSSignature
 * 
 * An Actionscript 3 implementation of Amazon's Signature Version 4 signing
 * process.
 * 
 * Copyright (c) 2014 Frank Erf
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package com.erfwest.aws
{
	import com.hurlant.crypto.hash.HMAC;
	import com.hurlant.util.Hex;
	
	import flash.utils.ByteArray;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.http.HTTPService;
	import mx.utils.Base64Encoder;
	import mx.utils.SHA256;
	
	import spark.collections.Sort;
	import spark.collections.SortField;
	
	public class AWSSignature
	{
		public static function signRequestWithToken(service:HTTPService,body:String,
										   awsHost:String, awsRegion:String, awsService:String,
										   sessionToken:AWSSessionToken,
										   timestamp:String,authParmsInRequest:Boolean=false):void
		{
			signRequest(service,body,awsHost,awsRegion,awsService,sessionToken.accessKeyID,sessionToken.secretAccessKey,
					    sessionToken.sessionToken,timestamp);
		}

		public static function signRequest(service:HTTPService,body:String,
										   awsHost:String, awsRegion:String, awsService:String,
										   amazonDeveloperId:String,amazonSecretAccessKey:String,
										   sessionToken:String,
										   timestamp:String,authParmsInRequest:Boolean=false):void
		{
			// AWS Signature Version 4
			
			// Step 1 : Create the canonical request
			
			var canonicalRequest:String = "";
			var hmac:HMAC = new HMAC(new com.hurlant.crypto.hash.SHA256());
			var requestBytes:ByteArray = new ByteArray();
			var payloadBytes:ByteArray = new ByteArray();
			var keyBytes:ByteArray = new ByteArray();
			var hmacBytes:ByteArray;
			
			var headerResult:Object = AWSSignature.getCanonicalHeaders(service.headers);
			var canonicalHeaders:String = headerResult.canonicalHeaders;
			var headerString:String = headerResult.headerString;
			
			var credentialScope:String = timestamp.substr(0,8)+"/"+awsRegion+"/"+awsService+"/aws4_request";
			
			// Process the request parameters
			if (authParmsInRequest) {
				service.request["X-Amz-Algorithm"] = "AWS4-HMAC-SHA256";
				service.request["X-Amz-Credential"] = amazonDeveloperId + "/" + credentialScope;
				service.request["X-Amz-Date"] = timestamp;
				service.request["X-Amz-SignedHeaders"] = headerString;
				service.request["AWSAccessKeyID"] = amazonDeveloperId;
				service.request["SignatureVersion"] = "4";
				service.request["Timestamp"] = timestamp;
			}
			
			var canonicalQuery:String = "";
			var canonicalParams:String = "";
			if (service.url.indexOf("?") == -1) {
				if (body) canonicalQuery = body
				else canonicalQuery = AWSSignature.getCanonicalRequest(service.request);
			}
			else {
				var rawParams:String = service.url.substr(service.url.indexOf("?")+1);
				var pattern:RegExp =  new RegExp("&","g");
				canonicalParams = rawParams;//.replace(pattern,"&amp;");
			}
			
			// Hash the payload
			//if (body == null) body = "";
			payloadBytes.writeUTFBytes(canonicalQuery);
			
			// Form the canonical request
			canonicalRequest = service.method + "\n/\n"+canonicalParams+"\n" + canonicalHeaders + "\n";
			canonicalRequest += headerString + "\n";
			canonicalRequest += SHA256.computeDigest(payloadBytes);
			
			// Hash the canonical request string
			requestBytes.clear();
			requestBytes.writeUTFBytes(canonicalRequest);
			var canonicalHash:String = SHA256.computeDigest(requestBytes);
			
			// Task 2 : Create the string to be signed
			var stringToSign:String = "AWS4-HMAC-SHA256\n" + timestamp + "\n" + credentialScope + "\n" + canonicalHash;
			
			// Task 3a : Calculate the signing key
			keyBytes.clear();
			keyBytes.writeUTFBytes("AWS4" + amazonSecretAccessKey);
			requestBytes.clear();
			requestBytes.writeUTFBytes(timestamp.substr(0,8));
			var kDate:ByteArray = hmac.compute(keyBytes, requestBytes);
			
			requestBytes.clear();
			requestBytes.writeUTFBytes(awsRegion);
			var kRegion:ByteArray = hmac.compute(kDate, requestBytes);
			
			requestBytes.clear();
			requestBytes.writeUTFBytes(awsService);
			var kService:ByteArray = hmac.compute(kRegion, requestBytes);
			
			requestBytes.clear();
			requestBytes.writeUTFBytes("aws4_request");
			var kSigning:ByteArray = hmac.compute(kService, requestBytes);
			
			requestBytes.clear();
			requestBytes.writeUTFBytes(stringToSign);
			
			// Task 3b : Calculate the signature
			var sigBytes:ByteArray = hmac.compute(kSigning, requestBytes);
			var signature:String = Hex.fromArray(sigBytes);

			var authString:String = "AWS4-HMAC-SHA256 Credential=" + amazonDeveloperId + "/"+credentialScope+
				",SignedHeaders="+headerString+",Signature=" + signature;
			
			// The request signature string.
			if (authParmsInRequest) {
				service.request["Signature"] = signature;
			}
			else {
				service.headers.Authorization = authString;
			}
		}
		
		private static function getCanonicalRequest(request:Object):String
		{
			var canonicalQuery:String = "";
			var requestCollection:ArrayCollection = new ArrayCollection();
			
			for (var key:String in request) {
				var urlEncodedKey:String = encodeURIComponent(decodeURIComponent(key));
				var value:String = request[key];
				var urlEncodedValue:String = encodeURIComponent(decodeURIComponent(value.replace(/\+/g, "%20")));
				requestCollection.addItem({name : urlEncodedKey, value : urlEncodedValue});
			}
			if (requestCollection.length > 0) {
				var sort:Sort = new Sort();
				requestCollection.sort = sort;
				sort.compareFunction = compareParams;
				requestCollection.refresh();
				
				for (var i:int = 0; i < requestCollection.length; i++)
				{
					var pair:Object = requestCollection.getItemAt(i);
					canonicalQuery += pair.name + "=" + pair.value;
					if (i < requestCollection.length-1) canonicalQuery += "&";
				}
			}			
			return canonicalQuery;
		}
		
		private static function compareParams(p1:Object,p2:Object,fields:Object = null):int
		{
			var name1:String = p1.name;
			var name2:String = p2.name;
			var val1:String = p1.value;
			var val2:String = p2.value;
			
			if (name1 == name2) return (val1 < val2) ? -1 : ((val1 == val2) ? 0 : 1);
			
			return (name1 < name2) ? -1 : ((name1 == name2) ? 0 : 1);
		}
		
	    private static function getCanonicalHeaders(headers:Object):Object
		{
			var result:Object = new Object();
			var headerString:String = "";
			var canonicalHeaders:String = "";
			
			var headerCollection:ArrayCollection = new ArrayCollection();
			
			// Process the headers.
			for (var key:String in headers )
			{
				// Ignore the "Signature" request header.
				if (key != "Signature")
				{
					var urlEncodedKey:String = encodeURIComponent(decodeURIComponent(key));
					var headerNameBytes:ByteArray = new ByteArray();
					var valueBytes:ByteArray = new ByteArray();
					var value:String = headers[key];
					var urlEncodedValue:String = encodeURIComponent(decodeURIComponent(value.replace(/\+/g, "%20")));
					
					// Use the byte values, not the string values.
					headerNameBytes.writeUTFBytes(key);
					valueBytes.writeUTFBytes(value);
					headerCollection.addItem( { name : headerNameBytes , value : valueBytes } );
				}
			}
			
			// Sort the headers and add the canonical headers and list of signed
			// headers to the canonical request
			headerCollection.sort = new Sort();
			var sortName:SortField = new SortField("name");
			sortName.setStyle("locale","en-US");
			var sortValue:SortField = new SortField("value");
			sortValue.setStyle("locale","en-US");
			headerCollection.sort.fields = [ sortName, sortValue ];
			headerCollection.refresh();
			
			for (var i:int = 0; i < headerCollection.length; i++)
			{
				var pair:Object = headerCollection.getItemAt(i);				
				canonicalHeaders += pair.name.toString().toLowerCase() + ":" + pair.value;				
				headerString += pair.name.toString().toLowerCase();				
				if (i < headerCollection.length-1) headerString += ";";				
				canonicalHeaders += "\n";
			}
			
			result.headerString = headerString;
			result.canonicalHeaders = canonicalHeaders;
			return result;
		}
		
		public static function signRequestV2(service:HTTPService,body:String,
										   awsHost:String, awsService:String,
										   amazonDeveloperId:String,amazonSecretAccessKey:String,
										   sessionToken:String,
										   timestamp:String):void
		{
			// AWS Signature Version 2
			
			// Step 1 : Create the canonical request
			
			var canonicalRequest:String = "";
			var hmac:HMAC = new HMAC(new com.hurlant.crypto.hash.SHA256());
			var requestBytes:ByteArray = new ByteArray();
			var payloadBytes:ByteArray = new ByteArray();
			var keyBytes:ByteArray = new ByteArray();
			var hmacBytes:ByteArray;
			
			// Process the request parameters
			service.request["AWSAccessKeyId"] = amazonDeveloperId;
			service.request["SignatureMethod"] = "HmacSHA256";
			service.request["SignatureVersion"] = "2";
			service.request["Timestamp"] = timestamp;
			
			var canonicalQuery:String = AWSSignature.getCanonicalRequest(service.request);
			
			// Form the canonical request
			canonicalRequest = service.method + "\n" + awsHost + "\n/\n" + canonicalQuery;
			
			// Task 3a : Calculate the signing key
			keyBytes.clear();
			keyBytes.writeUTFBytes(amazonSecretAccessKey);
			requestBytes.clear();
			requestBytes.writeUTFBytes(canonicalRequest);
			var sigBytes:ByteArray = hmac.compute(keyBytes, requestBytes);
			
			// The request signature string.
			sigBytes.position = 0;
			var encoder:Base64Encoder = new Base64Encoder();
			encoder.encodeBytes(sigBytes);
			var signature:String = encoder.toString();
			var encodedSig:String = encodeURIComponent(signature);
			service.request["Signature"] = encodedSig;
		}
		/*
		...
		
		// Somewhere in your code you'll call the following to generate request signature and perform the search.
		generateSignature();
		AmazonSearch.send();
		*/
	}
}