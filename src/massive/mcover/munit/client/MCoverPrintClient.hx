/****
* Copyright 2011 Massive Interactive. All rights reserved.
* 
* Redistribution and use in source and binary forms, with or without modification, are
* permitted provided that the following conditions are met:
* 
*    1. Redistributions of source code must retain the above copyright notice, this list of
*       conditions and the following disclaimer.
* 
*    2. Redistributions in binary form must reproduce the above copyright notice, this list
*       of conditions and the following disclaimer in the documentation and/or other materials
*       provided with the distribution.
* 
* THIS SOFTWARE IS PROVIDED BY MASSIVE INTERACTIVE ``AS IS'' AND ANY EXPRESS OR IMPLIED
* WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
* FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL MASSIVE INTERACTIVE OR
* CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
* CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
* SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
* ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
* NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
* ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
* 
* The views and conclusions contained in the software and documentation are those of the
* authors and should not be interpreted as representing official policies, either expressed
* or implied, of Massive Interactive.
****/

package massive.mcover.munit.client;

import massive.munit.ITestResultClient;

import massive.munit.AssertionException;
import massive.munit.ITestResultClient;
import massive.munit.TestResult;
import massive.munit.util.MathUtil;
import massive.haxe.util.ReflectUtil;
import massive.munit.util.Timer;

import massive.mcover.MCover;
import massive.mcover.CoverageLogger;
import massive.mcover.client.PrintClient;
import massive.mcover.data.Clazz;

/**
 * Decorates other ITestResultClient's, adding behavior to include code coverage results
 * 
 * @author Dominic De Lorenzo
 */


class MCoverPrintClient extends massive.munit.client.PrintClient
{
	/**
	 * Default id of this client.
	 */
	public inline static var DEFAULT_ID:String = "MCoverClient";

	var logger:CoverageLogger;
	var coverClient:massive.mcover.client.PrintClient;
	var coveredClasses:Hash<Clazz>;
	
	/**
	 * 
	 * @param	includeIgnoredReport				flag to pass through to PrintClient
	 */
	public function new(?includeIgnoredReport:Bool = false)
	{
		super(includeIgnoredReport);
		id = DEFAULT_ID;
		
		coveredClasses = new Hash();
		try
		{
			logger = MCover.getLogger();
			coverClient = new massive.mcover.client.PrintClient();
			
			coverClient.includeMissingBlocks = false;
			logger.addClient(coverClient);
		}
		catch(e:Dynamic)
		{
			trace(e);
			throw new massive.mcover.Exception("Unable to initialize MCover Reporter", e);
		}
	}


	/**
	 * Called when all tests are complete.
	 *  
	 * @param	testCount		total number of tests run
	 * @param	passCount		total number of tests which passed
	 * @param	failCount		total number of tests which failed
	 * @param	errorCount		total number of tests which were erroneous
	 * @param	ignoreCount		total number of ignored tests
	 * @param	time			number of milliseconds taken for all tests to be executed
	 * @return	collated test result data if any
	 */
	override public function reportFinalStatistics(testCount:Int, passCount:Int, failCount:Int, errorCount:Int, ignoreCount:Int, time:Float):Dynamic
	{

		printCoverage();
		logger.report();

		var classes = logger.coverage.getClasses();

		for(cls in classes)
		{
			if(coveredClasses.exists(cls.name)) continue;
			printMissingClassBlocks(cls, true);

		}

		print(newline + coverClient.output + newline);

		return super.reportFinalStatistics(testCount, passCount, failCount, errorCount, ignoreCount, time);
	}


	//////////

	override private function checkForNewTestClass(result:TestResult):Void
	{
		if (result.className != currentTestClass)
		{
			printCoverage();
			printExceptions();
			currentTestClass = result.className;
			logger.currentTest = currentTestClass;
			print(newline + "Class: " + currentTestClass + " ");
		}
	}

	function printCoverage()
	{
		if(logger.currentTest == null) return;

		logger.reportCurrentTest(true);
		
		var s:String = currentTestClass;

		if(s.substr(-4) == "Test")
		{
			s = s.substr(0, s.length-4);

			var cls = logger.coverage.getClassByName(s);

			if(cls != null)
			{
				printClassCoverage(cls);
				
			}
		}
	}

	function printClassCoverage(cls:Clazz)
	{
		coveredClasses.set(cls.name, cls);
		print(" " +cls.getPercentage() + "%");
		printMissingClassBlocks(cls);

	}

	function printMissingClassBlocks(cls:Clazz, ?includeHeader:Bool=false)
	{

		if(cls.getPercentage() == 100) return;

		print(newline);
		
		
		var statements = cls.getMissingStatements();

		if(statements.length > 0)
		{
			if(includeHeader)
			{
				print("Coverage: Other missing statements:" + newline);
			}

			for(block in statements)
			{
				print(newline + "     ! " + block.toString());
			}
		}

		var branches = cls.getMissingBranches();

		if(branches.length > 0)
		{
			if(includeHeader)
			{
				print(newline + newline);
				print("Coverage: Other missing branches:" + newline);
			}


			for(block in branches)
			{
				print(newline + "     ! " + block.toString());
			}
		}
		print(newline);

	}
}