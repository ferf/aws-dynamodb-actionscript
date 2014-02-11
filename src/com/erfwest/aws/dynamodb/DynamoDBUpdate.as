/**
 * DynamoDBUpdate
 * 
 * An Actionscript 3 implementation of Amazon's DynamoDB AttributeValueUpdate
 * object
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
	public class DynamoDBUpdate
	{
		protected var _attributes:Object;
		
		public function DynamoDBUpdate()
		{
			_attributes = new Object();
		}
		
		/** 
		 * Adds a PUT update.
		 * 
		 * @param name     Name of the DynamoDB attribute to be set. 
		 * @param dataType Data type of the attribute. 
		 * @param value    Value to be associated with this attribute.  For STRING and BLOB 
		 *                 data types this must be a String.  For NUMBER data type this
		 *                 must be a Number.  For and of the SET data types this must be
		 *                 an Array of the corresponding type.
		 *                  
		 */ 
		public function putAttribute(name:String,dataType:String, value:Object):void
		{
			_attributes[name] = new Object();
			_attributes[name].Action = "PUT";
			_attributes[name].Value = new Object();
			_attributes[name].Value[dataType] = value;
		}
		
		/** 
		 * Adds an ADD update.
		 * 
		 * @param name     Name of the DynamoDB attribute to be set. 
		 * @param dataType Data type of the attribute. Only NUMBER and any SET types are
		 *                 permitted.
		 * @param value    Value to be added to this attribute.  NUMBER types are added
		 *                 arithmatically.  Set types are appended to the set.
		 *                  
		 */ 
		public function addToAttribute(name:String,dataType:String, value:Object):void
		{
			_attributes[name] = new Object();
			_attributes[name].Action = "ADD";
			_attributes[name].Value = new Object();
			_attributes[name].Value[dataType] = value;
		}
		
		/** 
		 * Adds a DELETE update.
		 * 
		 * @param name     Name of the DynamoDB attribute to be deleted. 
		 * @param dataType Data type of the attribute.
		 * @param value    Values to be removed from the SET.  If this attribute
		 *                 is not a SET datatype or all values of the set are to
		 *                 be removed this value should not be specified.
		 *                  
		 */ 
		public function deleteAttribute(name:String,dataType:String, value:Array = null):void
		{
			_attributes[name] = new Object();
			_attributes[name].Action = "DELETE";
			_attributes[name].Value = new Object();
			if (value != null)
				_attributes[name].Value[dataType] = value;
		}		
		
		/**
		 * The attributes and values associated with this item in DynamoDB readable
		 * form.  This generally should not be used by classes outside the AWS library.  Results
		 * of DynamoDB queries should be obtained using the DynamoDB...Result classes which return
		 * the results in simple object form.
		 */
		public function get attributes():Object
		{
			return _attributes;
		}
	}
}