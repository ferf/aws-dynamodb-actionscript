/**
 * JSONWebService
 * 
 * An Actionscript 3 implementation of an HTTPService that handles encoding
 * and decoding of JSON service requests.
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

package com.erfwest.utils
{
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	public class JSONWebService extends HTTPService
	{
		private var wsURL:String;
		
		public function JSONWebService(host:String)
		{
			super();
			url = "https://" + host;
			contentType = "application/x-amz-json-1.0";
			//headers.Accept = "application/json";
			resultFormat = HTTPService.RESULT_FORMAT_TEXT;
			method = "POST";
			useProxy = false;
		}
		
		/*
		 * Fetch the most recent decoded JSON response.  This is the same value that is returned
		 * in the resultListener.
		 */
		public function getDecodedResponse(rawResponse:String):Object
		{
			return JSON.parse(rawResponse);
		}

		public function post(jsonData:String):AsyncToken
		{
			addEventListener("result", httpResult);
			addEventListener("fault", httpFault);         
			return send(jsonData);		
		}
		
		protected function httpResult(e:ResultEvent):void
		{
				var response:String = e.result.toString();
				trace (getDecodedResponse(response));
		}
		
		protected function httpFault(e:FaultEvent):void
		{
			trace("httpFault:" + e.fault.faultString);
		}
	}
}