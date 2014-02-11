/**
 * DynamoDBBatchGetItemRequest
 * 
 * An Actionscript 3 implementation of Amazon's DynamoDB BatchGetItem web service
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
	import mx.collections.IList;

	/** 
	 * Used to send and receive the results of DynamoDB BatchGetItem service calls.  
	 * Requests are sent using the DynamoDBWebService.signAndPost method.  
	 * 
	 * The BatchGetItem service will fetch the items specified in the addKey and addKeys
	 * methods.
	 * 
	 * @see DynamoDBWebService#signAndPost
	 * @see http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_BatchGetItem.html
	 * @see http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_BatchGetItemResult.html
	 */ 
	public class DynamoDBBatchGetItemRequest extends DynamoDBRequest
	{
		/** 
		 * Creates a DynamoDBBatchGetItemRequest.  Unlike simple DynamoDB requests, this one
		 * requires additional information to be supplied via the addTable, addKey and/or
		 * addKeys methods.
		 * 
		 * @param returnCapacity    Flag indicating type of consumed capacity to be returned.
		 *                          One of CONSUMED_CAPACITY_NONE, CONSUMED_CAPACITY_TOTAL or
		 *                          CONSUMED_CAPACITY_INDEXES.  Default is null (none).
		 */ 
		public function DynamoDBBatchGetItemRequest(returnCapacity:String = null)
		{
			super("DynamoDB_20120810.BatchGetItem");
			_requestData.RequestItems = new Object();
			if (returnCapacity != null) _requestData.ReturnConsumedCapacity = returnCapacity;
		}
		
		/**
		 * Add a table to the request from which items are to be fetched.  This call is only necessary
		 * if the attributes for this table will be limited by attributesToGet or consistentRead needs
		 * to be set to true.  Otherwise, the addKey and addKeys methods will add tables as needed and
		 * will fetch all attributes for the specified keys without consistent reads.
		 * 
		 * @param tableName       Table to be added to the request.  A table can only be added once.  Successive
		 *                        adds of the same table name will be ignored.
		 * @param attributesToGet An array of Strings indicating the attributes to be fetched for each item.
		 *                        If not specified all attributes are fetched.
		 * @param consistentRead  If true strongly consistent read will be used to fetch.
		 * 
		 * @return The existing table object if present, or a newly created table object.
		 */
		public function addTable(tableName:String,attributesToGet:Array = null,consistentRead:Boolean = false):Object
		{
			var table:Object = _requestData.RequestItems[tableName];
			if (!table) {
				table = new Object();
				if (consistentRead) table.ConsistentRead = consistentRead;
				if (attributesToGet) table.AttributesToGet = attributesToGet;
				table.Keys = new Array();
				_requestData.RequestItems[tableName] = table;
			}
			return table;
		}
		
		/**
		 * Add a key for an item to be fetched and the name of the table to fetch it from.  This will add the
		 * table object to the request if it doesn't already exist.
		 * 
		 * @param tableName Name of table from which item will be fetched.
		 * @param key       Key of the item to fetch.
		 */
		public function addKey(tableName:String,key:DynamoDBItem):void
		{
			var table:Object = _requestData.RequestItems[tableName];
			if (!table) table = addTable(tableName);
			table.Keys.push(key.attributes);
		}
		
		/**
		 * Add a set of keys for items to be fetched and the name of the table to fetch them from.  This will add the
		 * table object to the request if it doesn't already exist.
		 * 
		 * @param tableName Name of table from which items will be fetched.
		 * @param keys      Collection of DynamoDBItem objects containing keys to be fetched.
		 */
		public function addKeys(tableName:String,keys:IList):void
		{
			var table:Object = _requestData.RequestItems[tableName];
			if (!table) table = addTable(tableName);
			for each (var key:DynamoDBItem in keys) {
				table.Keys.push(key.attributes);
			}
		}
		
		public function useUnprocessedKeys():void
		{
			if (UnprocessedKeys != null) {
				// TODO : move unprocessed to keys
			}
		}
		
		/**
		 * The items found from the BatchGetItem request.
		 * 
		 * @return An object containing a property for each table from which items were fetched with name
		 *         equal table name value equal an ArrayList of Objects each of which contains a property
		 *         for each key in table and it's corresponding value.
		 */
		public function get Responses():Object
		{
			return decodedResponse.Responses;
		}
		
		/**
		 * Any keys that were not processed due to an exception such as exceeding throughput.
		 * 
		 * @see http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_ConsumedCapacity.html
		 */
		public function get UnprocessedKeys():Object
		{
			return decodedResponse.UnprocessedKeys;
		}
		
		/**
		 * The consumed capacity data returned from DynamoDB.  Value is null if returnCapacity option
		 * was not requested by the PutItem service call.
		 * 
		 * @see http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_ConsumedCapacity.html
		 */
		public function get ConsumedCapacity():Object
		{
			return decodedResponse.ConsumedCapacity;
		}
	}
}