/**
 * DynamoDBWebService
 * 
 * An Actionscript 3 implementation of an http service for sending/receiving
 * requests to Amazon's DynamoDB web service.
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

package com.erfwest.aws.dynamodb
{
	
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.utils.UIDUtil;
	
	import com.erfwest.aws.AWSSessionToken;
	import com.erfwest.aws.AWSSignature;
	
	import com.erfwest.utils.JSONWebService;
	
	/** 
	 * Use the DynamoDBWebService to process requests against Amazon's DynamoDB
	 * NoSQL service. 
	 */ 
	public class DynamoDBWebService extends JSONWebService
	{
		public static const RETURN_CAPACITY_NONE:String = "NONE";
		public static const RETURN_CAPACITY_TOTAL:String = "TOTAL";
		public static const RETURN_CAPACITY_INDEXES:String = "INDEXES";
		
		public static const METRICS_NONE:String = "NONE";
		public static const METRICS_SIZE:String = "SIZE";
		
		public static const RET_VALUES_NONE:String = "NONE";
		public static const RET_VALUES_ALL_OLD:String = "ALL_OLD";
		public static const RET_VALUES_ALL_NEW:String = "ALL_NEW";
		public static const RET_VALUES_UPDATED_OLD:String = "UPDATED_NEW";
		public static const RET_VALUES_UPDATED_NEW:String = "UPDATED_OLD";
		
		private var _accessKey:String;
		private var _secretKey:String;
		private var _securityToken:AWSSessionToken;
		
		private var awsHost:String;
		private var awsRegion:String;
		
		/** 
		 * Creates a new DynamoDBWebService.
		 * 
		 * @param accessKey The public access key that will be used to access this service. 
		 * @param secretKey The secret key associated with the accessKey that will be used
		 *                  to sign requests made to the service.
		 * @param region The AWS region of the DynamoDB service being utilized.
		 * 
		 */ 
		public function DynamoDBWebService(accessKey:String, secretKey:String, region:String = "us-east-1")
		{
			awsRegion = region;
			awsHost = "dynamodb."+region+".amazonaws.com";
			_accessKey = accessKey;
			_secretKey = secretKey;
			super(awsHost);
		}
		
		
		/**
		 * POSTs a request to the DynamoDB service.  The request is signed using the credentials
		 * provided in the constructor then POSTed.
		 *
		 * @param request The request to be posted.
		 * @param resultListener    Function to be called on success.  Function signature is
		 *                          onResult(returnedAttributes:DynamoDBGetItemResult, UID:String).  
		 *                          The UID will match the UID returned from this call.
		 * @param faultListener     Function to be called on failure.  Function signature is
		 *                          onResult(event:FaultEvent, UID:String).  The UID
		 *                          will match the UID returned from this call.
		 * 
		 * @return UID              Unique identifier for this service call that will be returned
		 *                          to the resultListener.
		 */
		public function signAndPost(request:DynamoDBRequest, resultListener:Function=null, faultListener:Function=null):String
		{
			var timestamp:String = AWSSessionToken.getTimeStamp();
			headers = new Object();
			headers["x-amz-date"] = timestamp;
			headers["host"] = awsHost;
			headers["x-amz-target"] = request.serviceName;
			var jsonData:String = JSON.stringify(request.requestData);
			AWSSignature.signRequest(this,jsonData,awsHost,awsRegion,"dynamodb",
				_accessKey,_secretKey,null,timestamp);
			var token:AsyncToken = post(jsonData);
			token.UID = mx.utils.UIDUtil.createUID();
			token.request = request;
			token.faultListener = faultListener;
			token.resultListener = resultListener;
			return token.UID;
		}
		
		/**
		 * Decodes the AWS response then calls the result handler provided
		 * in the signAndPost method.
		 */
		override protected function httpResult(e:ResultEvent):void
		{
			var token:AsyncToken = e.token;
			var result:DynamoDBRequest = token.request;
			result.decodeResponse(getDecodedResponse(e.result.toString()));
			if (token.resultListener != null) {
				token.resultListener(result,token.UID);
			}
		}
		
		override protected function httpFault(e:FaultEvent):void
		{
			trace("httpFault:" + e.fault.faultString);
			var token:AsyncToken = e.token;
			if (token != null) {
				if (token.faultListener != null) {
					var response:String = e.fault.toString();
					token.faultListener(e,token.UID);				
				}
			}
		}
	}
}