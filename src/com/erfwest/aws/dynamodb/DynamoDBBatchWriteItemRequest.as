/**
 * DynamoDBBatchWriteItemRequest
 * 
 * An Actionscript 3 implementation of Amazon's DynamoDB BatchWriteItem web service
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
	 * Used to send and receive the results of DynamoDB BatchWriteItem service calls.  
	 * Requests are sent using the DynamoDBWebService.signAndPost method.  
	 * 
	 * The BatchWriteItem service will write/delete the items specified in the addPutRequest
	 * and addDeleteRequest methods.
	 * 
	 * @see DynamoDBWebService#signAndPost
	 * @see http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_BatchWriteItem.html
	 */ 
	public class DynamoDBBatchWriteItemRequest extends DynamoDBRequest
	{
		/** 
		 * Creates a DynamoDBBatchWriteItemRequest.  Unlike simple DynamoDB requests, this one
		 * requires additional information to be supplied via the addPutRequest and
		 * addDeleteRequest methods.
		 * 
		 * @param returnCapacity    Flag indicating type of consumed capacity to be returned.
		 *                          One of CONSUMED_CAPACITY_NONE, CONSUMED_CAPACITY_TOTAL or
		 *                          CONSUMED_CAPACITY_INDEXES.  Default is null (none).
		 * @param returnMetrics     Flag indicating type of metrics to be returned.  One of
		 *                          METRICS_NONE or METRICS_SIZE. Default is null (none).
		 */ 
		public function DynamoDBBatchWriteItemRequest(returnCapacity:String = null,returnMetrics:String = null)
		{
			super("DynamoDB_20120810.BatchWriteItem");
			if (returnCapacity != null) _requestData.ReturnConsumedCapacity = returnCapacity;
			if (returnMetrics != null) _requestData.ReturnItemCollectionMetrics = returnMetrics;
		}
		
		/**
		 * Gets the array of requests for the specfied table.  If the array for the
		 * specified table does not yet exist it is created.
		 */
		private function getRequestsForTable(tableName:String):Array
		{
			var table:Array;
			if (_requestData.hasOwnProperty("RequestItems")) {
				table = _requestData.RequestItems[tableName];
			}
			else {
				_requestData.RequestItems = new Object();
			}
			if (!table) {
				table = new Array();
				_requestData.RequestItems[tableName] = table;
			}
			return table;
		}
		
		/**
		 * Adds a Put request to the batch update.
		 * 
		 * @param tableName Name of table that item is to be added to.
		 * @param item      The item to be added.
		 */
		public function addPutRequest(tableName:String,item:DynamoDBItem):void
		{
			var table:Array = getRequestsForTable(tableName);
			var putRequest:Object = new Object();
			putRequest.PutRequest = new Object();
			putRequest.PutRequest.Item = item.attributes;
			table.push(putRequest);			
		}
		
		/**
		 * Adds a Delete request to the batch update.
		 * 
		 * @param tableName Name of table that item is to be removed to.
		 * @param key       Key of the item to be removed.
		 */
		public function addDeleteRequest(tableName:String,key:DynamoDBItem):void
		{
			var table:Array = getRequestsForTable(tableName);
			var deleteRequest:Object = new Object();
			deleteRequest.DeleteRequest = new Object();
			deleteRequest.DeleteRequest.Key = key.attributes;
			table.push(deleteRequest);			
		}
	}
}