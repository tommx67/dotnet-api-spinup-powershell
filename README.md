NewDotNetApi.ps1 script is a script for quickly creating a new Dotnet Api solution and project. It also scaffolds Models, a database context, and a set of Controllers based on a SQL Server Database. In order for the script to be run properly, it must be run with 4 parameters:

$SolutionName The name of the Solution for the new project
$ApiName The name of the project itself
$ConnectionStringName An identifier for the Connection String which should follow this convention: ConnectionStrings:<ConnectionStringName>
$ConnectionString The actual connection String to the Database.


An example of how to run this script:

DotnetApiScaffoldingScript.ps1 "ApiTestSolution" "ApiTest" "ConnectionString:ApiDatabaseConnectionString" "server=ApiTestDatabaseServer;User Id=ApiData;Catalog=ApiTestDatabase;Password=ApiPassword;"

This script is a first draft. Updates will split it into smaller units that can be run individually or from a batch file.
