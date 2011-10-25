package massive.mcover.data;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;
import massive.mcover.data.Branch;

class CoverageTest extends AbstractNodeListTest
{	
	var coverage:Coverage;

	public function new() {super();}
	
	@BeforeClass
	override public function beforeClass():Void
	{
		super.beforeClass();
	}
	
	@AfterClass
	override public function afterClass():Void
	{
		super.afterClass();
	}
	
	@Before
	override public function setup():Void
	{
		super.setup();
		coverage = createEmptyCoverage();
	}
	
	@After
	override public function tearDown():Void
	{
		super.tearDown();
	}

	@Test
	public function shouldSortMissingBranchesById()
	{
		var item1 = cast(coverage.getItemByName("item1", NodeMock), NodeMock);
		var item2 = cast(coverage.getItemByName("item2", NodeMock), NodeMock);
		var item3 = cast(coverage.getItemByName("item3", NodeMock), NodeMock);
		
		var item1a = cast(coverage.getItemByName("item1a", NodeMock), NodeMock);
		
		item2.branch.id = 2;
		item3.branch.id = 4;

		var missing = coverage.getMissingBranches();

		Assert.areEqual(0, missing[0].id);
		Assert.areEqual(0, missing[1].id);
		
		Assert.areEqual(2, missing[2].id);
		Assert.areEqual(4, missing[3].id);
	}

	@Test
	public function shouldSortMissingStatementsById()
	{
		var item1 = cast(coverage.getItemByName("item1", NodeMock), NodeMock);
		var item2 = cast(coverage.getItemByName("item2", NodeMock), NodeMock);
		var item3 = cast(coverage.getItemByName("item3", NodeMock), NodeMock);
		
		var item1a = cast(coverage.getItemByName("item1a", NodeMock), NodeMock);
		
		item2.statement.id = 2;
		item3.statement.id = 4;

		var missing = coverage.getMissingStatements();

		Assert.areEqual(0, missing[0].id);
		Assert.areEqual(0, missing[1].id);
		
		Assert.areEqual(2, missing[2].id);
		Assert.areEqual(4, missing[3].id);
	}
	
	@Test
	public function shouldSortClassesById()
	{
		var item1 = cast(coverage.getItemByName("item1", NodeMock), NodeMock);
		var item2 = cast(coverage.getItemByName("item2", NodeMock), NodeMock);
		var item3 = cast(coverage.getItemByName("item3", NodeMock), NodeMock);
		
		var item1a = cast(coverage.getItemByName("item1a", NodeMock), NodeMock);
		
		item2.clazz.id = 2;
		item3.clazz.id = 4;

		var classes = coverage.getClasses();

		Assert.areEqual(0, classes[0].id);
		Assert.areEqual(0, classes[1].id);
		
		Assert.areEqual(2, classes[2].id);
		Assert.areEqual(4, classes[3].id);
	}

	@Test
	public function shouldSortPackagesById()
	{

		var item1 = cast(coverage.getItemByName("item1", Package), Package);
		var item2 = cast(coverage.getItemByName("item2", Package), Package);
		var item3 = cast(coverage.getItemByName("item3", Package), Package);
		
		var item1a = cast(coverage.getItemByName("item1", Package), Package);
		
		item2.id = 2;
		item3.id = 4;
		

		var packages = coverage.getPackages();

		Assert.areEqual(0, packages[0].id);
		Assert.areEqual(2, packages[1].id);
		Assert.areEqual(4, packages[2].id);
	}

	@Test
	public function shouldAppendFilesCountToResults()
	{
		var r = coverage.getResults();
		assertEmptyResult(r);

		var item1 = cast(coverage.getItemByName("item1", NodeMock), NodeMock);
		r = coverage.getResults(false);

		Assert.areEqual(0, r.pc);
		Assert.areEqual(1, r.p);

		item1.results.sc = 1;

		r = coverage.getResults(false);

		Assert.areEqual(1, r.pc);
		Assert.areEqual(1, r.p);	
	}

	@Test
	public function shouldAppendCountsFromStatementResults()
	{
		var statement = NodeMock.createStatement();
		coverage.addStatement(statement);

		var hash:IntHash<Int> = new IntHash();
		hash.set(statement.id, 10);
		coverage.setStatementResultsHash(hash);

		var r = coverage.getResults();

		Assert.areEqual(10, statement.count);
	}

	@Test
	public function shouldAppendCountsFromBranchResults()
	{
		var branch = NodeMock.createBranch();
		coverage.addBranch(branch);

		var hash:IntHash<BranchResult> = new IntHash();

		var result:BranchResult = {id:branch.id, trueCount:5, falseCount:5, total:10};

		hash.set(branch.id, result);
		coverage.setBranchResultsHash(hash);

		var r = coverage.getResults();

		Assert.areEqual(5, branch.trueCount);
		Assert.areEqual(5, branch.falseCount);
		Assert.areEqual(10, branch.totalCount);
	}

	@Test
	public function shouldAddStatementToMethod()
	{
		var block = NodeMock.createStatement();
	

		coverage.addStatement(block);

		var packages = coverage.getPackages();

		Assert.areEqual(1, packages.length);
		Assert.areEqual("package", packages[0].name);
		Assert.areEqual(1, cast(packages[0], Package).itemCount);

		var file = packages[0].getItemByName("file", File);

		Assert.areEqual(1, cast(file, File).itemCount);


		var classes = coverage.getClasses();
		Assert.areEqual(1, classes.length);
		Assert.areEqual("package.class", classes[0].name);
		Assert.areEqual(1, cast(classes[0], Clazz).itemCount);

		var method = cast(classes[0].getItemByName("method", Method), Method);

		Assert.areEqual(block, method.getStatementById(0));
	}

	@Test
	public function shouldAddBranchToMethod()
	{
		var block = NodeMock.createBranch();
	

		coverage.addBranch(block);

		var packages = coverage.getPackages();

		Assert.areEqual(1, packages.length);
		Assert.areEqual("package", packages[0].name);
		Assert.areEqual(1, cast(packages[0], Package).itemCount);

		var file = packages[0].getItemByName("file", File);

		Assert.areEqual(1, cast(file, File).itemCount);


		var classes = coverage.getClasses();
		Assert.areEqual(1, classes.length);
		Assert.areEqual("package.class", classes[0].name);
		Assert.areEqual(1, cast(classes[0], Clazz).itemCount);

		var method = cast(classes[0].getItemByName("method", Method), Method);

		Assert.areEqual(block, method.getBranchById(0));
	}

	@Test
	public function shouldThrowExceptionIfStatementAlreadyExists()
	{
		try
		{
			var block = NodeMock.createStatement();
			coverage.addStatement(block);
			coverage.addStatement(block);
			Assert.fail("Expected exception");
		}
		catch(e:Exception)
		{
			Assert.isTrue(true);
		}
	}

	@Test
	public function shouldThrowExceptionIfBranchAlreadyExists()
	{
		try
		{
			var block = NodeMock.createBranch();
			coverage.addBranch(block);
			coverage.addBranch(block);
			Assert.fail("Expected exception");
		}
		catch(e:Exception)
		{
			Assert.isTrue(true);
		}
	}

	@Test
	public function shouldThrowExcepctionIfStatementHasMissingFields()
	{
		var createMethod = NodeMock.createStatement;
		var addMethod = coverage.addStatement;
		testMissingBlockFieldsThrowError(createMethod, addMethod);
	}


	@Test
	public function shouldThrowExcepctionIfBranchHasMissingFields()
	{
		var createMethod = NodeMock.createBranch;
		var addMethod = coverage.addBranch;		
		testMissingBlockFieldsThrowError(createMethod, addMethod);
	}


	function testMissingBlockFieldsThrowError(createMethod:Int ->Dynamic, addMethod:Dynamic ->Void)
	{
		var block:AbstractBlock;

		try
		{
			block = cast(createMethod(0), AbstractBlock);
			block.id = null;
			addMethod(block);
		}
		catch(e:Exception)
		{
			Assert.isTrue(e.message.indexOf("id") != -1);
		}

		try
		{
			block =  cast(createMethod(0), AbstractBlock);
			block.packageName = null;
			addMethod(block);
		}
		catch(e:Exception)
		{
			Assert.isTrue(e.message.indexOf("packageName") != -1);
		}

		try
		{
			block = cast(createMethod(0), AbstractBlock);
			block.file = null;
			addMethod(block);
		}
		catch(e:Exception)
		{
			Assert.isTrue(e.message.indexOf("file") != -1);
		}

		try
		{
			block =  cast(createMethod(0), AbstractBlock);
			block.qualifiedClassName = null;
			addMethod(block);
		}
		catch(e:Exception)
		{
			Assert.isTrue(e.message.indexOf("qualifiedClassName") != -1);
		}

		try
		{
			block =  cast(createMethod(0), AbstractBlock);
			block.methodName = null;
			addMethod(block);
		}
		catch(e:Exception)
		{
			Assert.isTrue(e.message.indexOf("methodName") != -1);
		}
	}


	@Test
	public function shouldReturnStatementById()
	{
		try
		{
			var item1 = cast(coverage.getItemByName("item1", NodeMock), NodeMock);
			
			item1.statement.id = 1;

			coverage.addStatement(item1.statement);

			var statement = coverage.getStatementById(1);

			Assert.isNotNull(statement);
			Assert.areEqual(item1.statement, statement);


			statement = coverage.getStatementById(2);
			Assert.fail("invalid statement id should throw exception.");
		}
		catch(e:Exception)
		{
			Assert.isTrue(true);
		}
	}

	@Test
	public function shouldReturnBranchById()
	{
		try
		{
			var item1 = cast(coverage.getItemByName("item1", NodeMock), NodeMock);
			item1.branch.id = 1;

			coverage.addBranch(item1.branch);

			var branch = coverage.getBranchById(1);

			Assert.isNotNull(branch);
			Assert.areEqual(item1.branch, branch);


			branch = coverage.getBranchById(2);
			Assert.fail("invalid branch id should throw exception.");
		}
		catch(e:Exception)
		{
			Assert.isTrue(true);
		}
	}

	@Test
	public function shouldGetClassByQualifiedClassName()
	{
		var statement = NodeMock.createStatement();
		statement.qualifiedClassName = "package.class";
		coverage.addStatement(statement);

		var cls = coverage.getClassByName("package.class");
		Assert.isNotNull(cls);
	}

	@Test
	public function shouldReturnNullIfUnknownPackageOrClass()
	{
		var statement = NodeMock.createStatement();
		statement.qualifiedClassName = "package.class";
		coverage.addStatement(statement);

		var cls = coverage.getClassByName("other.class");
		Assert.isNull(cls);

		cls = coverage.getClassByName("package.class2");
		Assert.isNull(cls);
	}

	@Test
	public function shouldGetTopLevelClassByQualifiedClassName()
	{
		var statement = NodeMock.createStatement();
		statement.packageName = "";
		statement.qualifiedClassName = "class";
		coverage.addStatement(statement);

		var cls = coverage.getClassByName("class");
		Assert.isNotNull(cls);
	}


	//////////////////

	override function createEmptyNode():AbstractNode
	{
		return createEmptyNodeList();
	}

	override function createEmptyNodeList():AbstractNodeList
	{
		return createEmptyCoverage();
	}

	function createEmptyCoverage():Coverage
	{
		return new Coverage();
	}




}