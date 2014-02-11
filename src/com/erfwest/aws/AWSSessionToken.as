/**
 * AWSSessionToken
 * 
 * An Actionscript 3 implementation of Amazon's STS GetSessionToken service
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
	import flash.globalization.DateTimeFormatter;
	
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.AbstractOperation;
	import mx.rpc.http.SerializationFilter;
	import mx.utils.ObjectUtil;
	import mx.utils.StringUtil;
	
	import com.erfwest.utils.JSONWebService;
	
	public class AWSSessionToken
	{
		private var onResult:Function;
		private var onFault:Function;
		
		private var _sessionToken:String;
		private var _secretAccessKey:String;
		private var _expiration:Date;
		private var _accessKeyID:String;
		
		public function AWSSessionToken(successFunction:Function = null, failFunction:Function = null)
		{
			refreshToken(successFunction, failFunction);
		}
		
		public function refreshToken(successFunction:Function = null, failFunction:Function = null, duration:Number = 900) :void
		{
			var service:JSONWebService = new JSONWebService("sts.amazonaws.com");
			service.serializationFilter = new MyFilter();
				
			service.url = "https://sts.amazonaws.com?Action=GetSessionToken&Version=2011-06-15";
			service.method = "GET";
			service.headers["host"] = "sts.amazonaws.com";
			var timestamp:String = AWSSessionToken.getTimeStamp();
			service.headers["X-Amz-Date"] = timestamp;
			service.headers["User-Agent"] = "CNCCookbook/AdobeAir";
			AWSSignature.signRequest(service,null,"sts.amazonaws.com","us-east-1","sts",
				"AKIAIQHL4CLIXK6BWXSA","geSN8Z+IhvAmaYEBVxmCWkThKCv5Qq7Cio11R14G",null,timestamp);
			service.headers["Accept-Encoding"] = "identity";
			service.addEventListener("result", httpResult);
			service.addEventListener("fault", httpFault);         
			service.send();			
		}
		
		public static function getTimeStamp(date:Date = null, longform:Boolean = false):String
		{
			var formatter:DateTimeFormatter = new DateTimeFormatter("en_US");
			
			if (date == null)
				date = new Date();
			
			if (longform) {
				formatter.setDateTimePattern("yyyy-MM-dd'T'HH:mm:ss");				
			}
			else {
				formatter.setDateTimePattern("yyyyMMdd'T'HHmmss'Z'");
			}
			date.setTime(date.getTime() + (date.getTimezoneOffset() * 60 * 1000));
			var timestamp:String = formatter.format(date);
			
			return timestamp;
		}
		
		public function isExpired():Boolean
		{
			var now:Date = new Date();
			return (_expiration == null || now > _expiration);
		}
		
		public function get sessionToken():String
		{
			return _sessionToken;
		}
		
		public function get secretAccessKey():String
		{
			return _secretAccessKey;
		}
		
		public function get accessKeyID():String
		{
			return _accessKeyID;
		}
		
		private function httpResult(e:ResultEvent):void
		{
			var formatter:DateTimeFormatter = new DateTimeFormatter("en_US");
			formatter.setDateTimePattern("yyyyMMDD'T'HHmmss'Z'");
			
			var response:XML = XML(e.result);
			_sessionToken = response.*::GetSessionTokenResult.*::Credentials.*::SessionToken;
			_secretAccessKey = response.*::GetSessionTokenResult.*::Credentials.*::SecretAccessKey;
			_expiration = new Date(Date.parse(response.*::GetSessionTokenResult.*::Credentials.*::Expiration));
			_accessKeyID = response.*::GetSessionTokenResult.*::Credentials.*::AccessKeyId;
			
			if (onResult != null) onResult();
		}
		
		private function httpFault(e:FaultEvent):void
		{
			trace("httpFault:" + e.fault.faultString);
			if (onFault != null) onFault(e.fault);
		}
	}
}

import mx.rpc.http.AbstractOperation;
import mx.rpc.http.SerializationFilter;
import mx.utils.ObjectUtil;
import mx.utils.StringUtil;

class MyFilter extends SerializationFilter
{
	public function MyFilter()
	{
		super();
	}
	
	override public function serializeParameters(operation:AbstractOperation, params:Array):Object
	{
		return params;
	}
	
	override public function serializeBody(operation:AbstractOperation, obj:Object):Object
	{
		var s:String = "";
		var classinfo:Object = ObjectUtil.getClassInfo(obj);
		for each (var p:* in classinfo.properties)
		{
			var val:* = obj[p];
			if (val != null)
			{
				if (s.length > 0)
					s += "&";
				s += StringUtil.substitute("{0}={1}",p,val);
			}
		}
		return s;
	}
}
