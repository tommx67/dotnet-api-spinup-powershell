$SolutionName=$args[0]
$ApiName=$args[1]
$ConnectionStringName=$args[2]
$ConnectionString = $args[3]

if($SolutionName -and $ApiName -and $ConnectionStringName -and $ConnectionString){

#Global Dependencies for this script to work:
#Dotnet must be installed and updated to current version https://dotnet.microsoft.com/en-us/download
#dotnet-ef https://learn.microsoft.com/en-us/ef/core/cli/dotnet
#dotnet-aspnet-codegenerator https://learn.microsoft.com/en-us/aspnet/core/fundamentals/tools/dotnet-aspnet-codegenerator?view=aspnetcore-8.0
#VPN Connection is needed for database scaffolding to work

#First step; Create solution. -o argument defines name of solution and solution directory
dotnet new sln -o $SolutionName
#Switch to solution directory
cd $SolutionName
#Create new project Arguments are largely self explanatory.
dotnet new webapi --use-controllers -o $ApiName --language "C#" --framework "net8.0"
#Add project/directory to solution. Must be done from solution directory.
dotnet sln add $ApiName
#Change directory to app directory that has just been created.
cd $ApiName
# user-secrets init sets up the application for user secrets. 
# User secrets are referenced by a guid in the .csproj file
# User secrets are stored in a local file Secrets.json which Git will ignore. Secrets are similar to 
# Environmental variables in Azure
dotnet user-secrets init
dotnet user-secrets set $ConnectionStringName $ConnectionString

# The following packages set up the application for database and controller scaffolding

dotnet add package Microsoft.EntityFrameworkCore
dotnet add package Microsoft.EntityFrameworkCore.SqlServer
dotnet add package Microsoft.EntityFrameworkCore.Design
dotnet add package Microsoft.EntityFrameworkCore.Tools
dotnet add package Microsoft.VisualStudio.Web.CodeGeneration.Design
dotnet add package Microsoft.AspNetCore.Odata
#dotnet-ef must be installed and should be of the same version of the application
#scaffolding arguments include name of secret containing connection string
#The Nuget library Microsoft.EntityFrameworkCore.SqlServer specifies the database type, in this case, SqlServer
dotnet ef dbcontext scaffold "Name=$ConnectionStringName" Microsoft.EntityFrameworkCore.SqlServer -o Models
$DataContext =(Get-ChildItem -Path Models -Filter "*Context*.cs" -File -Recurse).BaseName

$FileContent=Get-Content "Program.cs"
$Usings = "using $ApiName.Models;`nusing Microsoft.EntityFrameworkCore;"
$ProgramConnString="try
{
    var connectionString = builder.Configuration.GetValue<string>(""$ConnectionStringName"");
    connectionString ??= ""Default Connection"";
    builder.Services.AddDbContext<$DataContext>(
        options => options.UseSqlServer(connectionString));

}
catch (Exception ex)
{
    var exception = ex.Message;
}"
$NewContent=$Usings + "`n"+($FileContent -join "`n")
Set-Content -Path "Program.cs" -Value $NewContent
$fileContent=Get-Content "Program.cs"
$fileContent[10]+=$ProgramConnString
Set-Content -Path "Program.cs" -Value $fileContent

#The remaining code loops through the models in the Models directory and
#Creates controllers for each table in the database.
#It does not create controllers for views,
#Each controller creates a Get,Get(id), Put, Post, Delete for each table it references


Get-ChildItem Models/* -Exclude Vw*  -Filter *.cs | 
Foreach-Object { $scaffoldCmd=
'dotnet-aspnet-codegenerator '+
'-p ' + $ApiName + '.csproj ' +
'controller -name '+ $_.BaseName +
'Controller ' + 
' -api -m ' + 
$_.BaseName + 
' -dc '+ $DataContext + ' -outDir Controllers -namespace ' + $ApiName + '.Controllers'

iex $scaffoldCmd

}
dotnet run --launch-profile https
}
else
{
Write-Output "Script Fails"

}

