/**
 * DynamoDBGetItemRequest
 * 
 * An Actionscript 3 implementation of Amazon's DynamoDB GetItem web service
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
	/** 
	 * Used to send and receive the results of DynamoDB GetItem service calls.  
	 * Requests are sent using the DynamoDBWebService.signAndPost method.  
	 * 
	 * The GetItem service will fetch the item specified by the key in the constructor.
	 * 
	 * @see DynamoDBWebService#signAndPost
	 * @see http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_GetItem.html
	 * @see http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_GetItemResult.html
	 */ 
	public class DynamoDBGetItemRequest extends DynamoDBRequest
	{
		/** 
		 * Creates a DynamoDBGetItemRequest.
		 * 
		 * @param table             Name of table being accessed. 
		 * @param key               Primary key of item to fetch. 
		 * @param attributesToFetch Array of attribute names to be fetched. 
		 */ 
		public function DynamoDBGetItemRequest(table:String,key:DynamoDBItem,attributesToFetch:Array = null)
		{
			super("DynamoDB_20120810.GetItem");
			_requestData.TableName = table;
			_requestData.Key = key.attributes;
			_requestData.AttributesToGet = attributesToFetch;
		}
		
		/**
		 * The item data returned from the GetItem service call.  Properties correspond to
		 * key names from the DynamoDB table.  Property values correspond to the data associated
		 * with that key.
		 */
		public function get Item():Object
		{
			return decodedResponse.Item;
		}
		
		/**
		 * The consumed capacity data returned from DynamoDB.  Value is null if returnCapacity
		 * was not requested by the getItem service call.
		 * 
		 * @see http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_ConsumedCapacity.html
		 */
		public function get ConsumedCapacity():Object
		{
			return decodedResponse.ConsumedCapacity;
		}
	}
}