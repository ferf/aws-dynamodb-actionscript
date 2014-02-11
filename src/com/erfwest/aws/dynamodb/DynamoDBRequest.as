/**
 * DynamoDBRequest
 * 
 * An Actionscript 3 implementation of a base class for encoding/decoding
 * requests to Amazon's DynamoDB web services
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
	import mx.collections.ArrayCollection;
	import mx.utils.ObjectUtil;
	
	/** 
	 * The base result class used to return all results from DynamoDB service calls.  This
	 * class decodes all responses into a simple object format that mirrors the hierarchy
	 * of the DynamoDB responses.
	 * 
	 * @see DynamoDBWebService
	 * @see http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_Operations.html
	 */ 
	public class DynamoDBRequest
	{
		protected var _requestData:Object;
		private var _rawResponse:Object;
		private var _decodedResponse:Object;
		private var _serviceName:String;
		
		/**
		 * Creates a new DynamoDBRequest.
		 * 
		 * @param serviceName The AWS service name.  This is provided by the
		 *                    inheriting request object.
		 */
		public function DynamoDBRequest(serviceName:String)
		{
			_requestData = new Object();
			_serviceName = serviceName;
		}
		
		/**
		 * The AWS service name for the request.  This is specified by the
		 * inheriting request object.
		 */
		public function get serviceName():String
		{
			return _serviceName;
		}
		
		/**
		 * The request data formatted for the DynamoDB service.
		 */
		public function get requestData():Object
		{
			return _requestData;
		}
		
		/**
		 * The DynamoDB response in simple object format.  The high level properties in the 
		 * decoded response correspond to the top level named nodes in a DynamoDB response.  
		 * For example, a GetItem response would include Item and (optionally) ConsumedCapacity 
		 * as the top level properties.  The Item value would in turn contain a property for 
		 * each value returned from the GetItem call.  Each associated value in the Item is a 
		 * simple value (String, Number, or Array) and does not include the DynamoDB data type 
		 * information.
		 */
		public function get decodedResponse():Object
		{
			return _decodedResponse;
		}
		
		/**
		 * The DynamoDB response in it's raw format that includes all DynamoDB type
		 * information.
		 */
		public function get rawResponse():Object
		{
			return _rawResponse;
		}
		
		/**
		 * Decodes a the response object from DynamoDB. The resulting response is stored internally
		 * and can be retrieved using decodedResponse property.  This method should only be called
		 * by other aws DynamoDB classes.
		 * 
		 * @param response The raw response object to be decoded.
		 */
		public function decodeResponse(response:Object):void {
			_rawResponse = response;
			_decodedResponse = decodeGenericObject(response);
		}
		
		/**
		 * Converts an AWS response item into a normalized key/value
		 * object by removing the data type information and converting
		 * the values to the appropriate data type.
		 */
		private function decodeItem(item:Object):Object
		{
			var result:Object = new Object();
			var properties:Array = ObjectUtil.getClassInfo(item).properties;
			
			for each (var key:String in properties) {
				var valObject:Object = item[key];
				if (valObject.hasOwnProperty("S")) {
					result[key] = valObject.S;
				}
				else if (valObject.hasOwnProperty("SS")) {
					result[key] = valObject.SS;	
				}
				else if (valObject.hasOwnProperty("N")) {
					result[key] = Number(valObject.N);
				}
				else if (valObject.hasOwnProperty("NS")) {
					var strArray:Array = valObject.NS;
					result[key] = new Array(strArray.length);
					for (var i:int = 0; i < strArray.length; ++i) {
						result[key][i] = Number(strArray[i]);
					}
				}
				else if (valObject.hasOwnProperty("B")) {
					result[key] = valObject.B;							
				}
				else if (valObject.hasOwnProperty("BS")) {
					result[key] = valObject.BS;
				}
			}
			
			return result;
		}
		
		/**
		 * Converts an AWS response object into a normalized key/value object.
		 * AWS Item, Key, Attributes, ItemCollectionKey, and LastEvaluatedKey
		 * objects are decoded into simple objects without type information.
		 */
		private function decodeGenericObject(item:Object, key:String = "",forceItem:Boolean = false):Object
		{
			var result:Object;
			if (key == "Key" || key == "Item" || key == "ItemCollectionKey" || 
				key == "Attributes" || key == "LastEvaluatedKey") {
				result = decodeItem(item);
			}
			else if (key == "Responses") {
				result = new Object();
				var tables:Array = ObjectUtil.getClassInfo(item).properties;
				for each (var table:String in tables) {
					result[table] = decodeGenericObject(item[table],table,true);
				}
			}
			else if (key == "Keys" || key == "Items" || forceItem) {
				result = new ArrayCollection();
				for each (var obj1:Object in item) {
					result.addItem(decodeItem(obj1));
				}
			}
			else if (item is Object) {
				result = new Object();
				var properties:Array = ObjectUtil.getClassInfo(item).properties;			
				for each (var key:String in properties) {
					var valObject:Object = item[key];
					result[key] = decodeGenericObject(valObject,key);
				}
			}
			else if (item is Array) {
				result = new ArrayCollection();
				for each (var obj2:Object in valObject) {
					result.addItem(decodeGenericObject(obj2));
				}
			}
			else {
				result = item;
			}
			return result;
			
		}
		
		public function toString():String
		{
			return ObjectUtil.toString(_decodedResponse);
		}
	}
}