/**
 * DynamoDBPutItemRequest
 * 
 * An Actionscript 3 implementation of Amazon's DynamoDB PutItem web service
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
	 * Used to send and receive the results of DynamoDB PutItem service calls.  
	 * Requests are sent using the DynamoDBWebService.signAndPost method.  
	 * 
	 * The PutItem service will insert a new item or replace it's contents if a match is 
	 * found.  If a match is found the contents of the existing item are entirely removed 
	 * and replaced with the new data.
	 * 
	 * @see DynamoDBWebService#signAndPost
	 * @see http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_PutItem.html
	 * @see http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_PutItemResult.html
	 */ 
	public class DynamoDBPutItemRequest extends DynamoDBRequest
	{
		/**
		 * Creates a DynamoDBPutItemRequest.
		 * 
		 * @param table             Name of table being updated. 
		 * @param item              Item to be inserted/updated. 
		 * @param expectedConds     Array of conditions (DynamoDBCondition) to be met.
		 * @param returnCapacity    Flag indicating type of consumed capacity to be returned.
		 *                          One of CONSUMED_CAPACITY_NONE, CONSUMED_CAPACITY_TOTAL or
		 *                          CONSUMED_CAPACITY_INDEXES.  Default is null (none).
		 * @param returnMetrics     Flag indicating type of metrics to be returned.  One of
		 *                          METRICS_NONE or METRICS_SIZE. Default is null (none).
		 * @param returnValues      Flag indicating values to be returned.  One of
		 *                          RET_VALUES_NONE, RET_VALUES_ALL_OLD, RET_VALUES_UPDATED_OLD,
		 *                          RET_VALUES_ALL_NEW or RET_VALUES_UPDATED_NEW.  Default is null (none).
		 */
		public function DynamoDBPutItemRequest(table:String,item:DynamoDBItem,expectedConds:Array = null,
											   returnCapacity:String = null, returnMetrics:String = null, 
											   returnValues:String = null)
		{
			super("DynamoDB_20120810.PutItem");
			_requestData.TableName = table;
			_requestData.Item = item.attributes;
			if (expectedConds != null) _requestData.Expected = expectedConds;
			if (returnCapacity != null) _requestData.ReturnConsumedCapacity = returnCapacity;
			if (returnMetrics != null) _requestData.ReturnItemCollectionMetrics = returnMetrics;
			if (returnValues != null) _requestData.ReturnValues = returnValues;
		}
		
		/**
		 * The attributes data returned from the service call.  Value is null if returnValues
		 * option was not specified in the service call.
		 */
		public function get Attributes():Object
		{
			return decodedResponse.Item;
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
		
		/**
		 * The item collection metrics data returned from DynamoDB.  Value is null if returnMetrics option
		 * was not requested by the PutItem service call.
		 * 
		 * @see http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_ItemCollectionMetrics.html
		 */
		public function get ItemCollectionMetrics():Object
		{
			return decodedResponse.ItemCollectionMetrics;
		}
	}
}