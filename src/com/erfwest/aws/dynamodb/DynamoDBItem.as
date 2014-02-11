/**
 * DynamoDBItem
 * 
 * An Actionscript 3 implementation of Amazon's DynamoDB AttributeValue object.
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
	 * Used to define data elements to be sent or retrieved from DynamoDB as well as
	 * key values used by queries against DynamoDB.
	 * 
	 * @see DynamoDBWebService
	 * @see http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_Operations.html
	 */ 
	public class DynamoDBItem
	{
		public static const BLOB:String       = "B"; 
		public static const BLOB_SET:String   = "BS"; 
		public static const NUMBER:String     = "N"; 
		public static const NUMBER_SET:String = "NS"; 
		public static const STRING:String     = "S"; 
		public static const STRING_SET:String = "SS"; 
		
		protected var _attributes:Object;
		
		/** 
		 * Creates a new DynamoDBItem.
		 */ 
		public function DynamoDBItem()
		{
			_attributes = new Object();
		}
		
		/** 
		 * Adds an attribute to the item.
		 * 
		 * @param name     Name of the DynamoDB attribute that is part of the item/key. 
		 * @param dataType Data type of the attribute. 
		 * @param value    Value to be associated with this attribute.  For STRING and BLOB 
		 *                 data types this must be a String.  For NUMBER data type this
		 *                 must be a Number.  For and of the SET data types this must be
		 *                 an Array of the corresponding type.
		 *                  
		 */ 
		public function addAttribute(name:String,dataType:String, value:Object):void
		{
			_attributes[name] = new Object();
			_attributes[name][dataType] = value;
		}
		
		/**
		 * Fetches the attributes and values associated with this item in DynamoDB readable
		 * form.  This generally should not be used by classes outside the AWS library.  Results
		 * of DynamoDB queries should be obtained using the DynamoDB...Result classes which return
		 * the results in simple object form.
		 * 
		 * @return The set of DynamoDB attributes associated with this item.
		 */
		public function get attributes():Object
		{
			return _attributes;
		}
	}
}