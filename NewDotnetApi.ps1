#Script accepts one argument which will become the name of the solution and project of the Api

$ApiName=$Args[0]

#Check to make sure ApiName has been supplied
if([string]::IsNullOrWhitespace($apiName))
{
  Write-Output "Api Name cannot be empty"
}

#Need to add logic to filter out invalid Api names

else
{
    #Create solution
    dotnet new sln -o $apiName
    #Switch to solution directory
    cd $apiName
    #Create new project Arguments are largely self explanitory.
    dotnet new webapi --use-controllers -o $apiName --language "C#" --framework "net8.0"
    #Add project/directory to solution. Must be done from solution directory.
    dotnet sln add $apiName
}

#Script concludes in Solution Directory


