<#
	MAINTAINER Hayke Geuskens - PT CEBES Indonesia
	Modified script from the original microsoft start.ps1
	The script sets the sa password, accepts the ACCEPT_EULA attaches the databases and starts the SQL Service
	The format for attach_dbs is:
	[
		{
			'dbName': 'mydb',
			'dbFiles': ['C:\\Databases\\mydb.mdf',
			'C:\\Databases\\mydb_log.ldf']
		},
		{
			'dbName': 'AdventureWorks',
			'dbFiles': ['C:\\Databases\\AdventureWorks.mdf',
			'C:\\Databases\\AdventureWorks_log.ldf']
		}
	]
	If attach_dbs is omitted, it will attach all databases from the shared volume C:\Databases
#>

param(
	[Parameter(Mandatory=$false)]
	[string]$sa_password,

	[Parameter(Mandatory=$false)]
	[string]$ACCEPT_EULA,

	[Parameter(Mandatory=$false)]
	[string]$attach_dbs
)

if($ACCEPT_EULA -ne "Y" -And $ACCEPT_EULA -ne "y"){
	Write-Verbose "ERROR: You must accept the End User License Agreement before this container can start."
	Write-Verbose "Set the environment variable ACCEPT_EULA to 'Y' if you accept the agreement."
    exit 1
}

Write-Verbose "Starting SQL Server"
start-service MSSQLSERVER

if($sa_password -ne "_")
{
	Write-Verbose "Changing SA login credentials"
    $sqlcmd = "ALTER LOGIN sa with password=" + "'" + $sa_password + "'" + ";ALTER LOGIN sa ENABLE;"
    & sqlcmd -Q $sqlcmd
}

$attach_dbs_cleaned = $attach_dbs.TrimStart('\\').TrimEnd('\\')
$dbs = $attach_dbs_cleaned | ConvertFrom-Json

if ($null -ne $dbs -And $dbs.Length -gt 0)
{
	Write-Verbose "Attaching $($dbs.Length) database(s)"

	Foreach($db in $dbs)
	{
		$files = @();

		Foreach($file in $db.dbFiles)
		{
			$files += "(FILENAME = N'$($file)')";
			Write-Verbose "Attaching database: $($file)"
		}

		$files = $files -join ","
		$sqlcmd = "sp_detach_db $($db.dbName);CREATE DATABASE $($db.dbName) ON $($files) FOR ATTACH ;"

		Write-Verbose "Invoke-Sqlcmd -Query $($sqlcmd)"
		& sqlcmd -Q $sqlcmd
	}
}
else 
{
	$attach_folder = "C:\\Databases"
	Write-Verbose "Attaching database(s) in $($attach_folder))"

	foreach ($file in Get-ChildItem $attach_folder) 
	{
		if ($file.Extension -eq '.mdf') 
		{
			Write-Verbose "Attaching database: $($file.name))"

			$files = @();
			$files += "(FILENAME = N'$($file.FullName)')";
		
			$logfile = $attach_folder + "\" + $file.BaseName + "_log.ldf"
			$files += "(FILENAME = N'$($logfile)')";

			$files = $files -join ","
			$sqlcmd = "sp_detach_db $($file.BaseName);CREATE DATABASE $($file.BaseName) ON $($files) FOR ATTACH ;"

			Write-Verbose "Invoke-Sqlcmd -Query $($sqlcmd)"
			& sqlcmd -Q $sqlcmd
		}
	}
}

Write-Verbose "Started SQL Server."
$lastCheck = (Get-Date).AddSeconds(-2)

while ($true) 
{
	Get-EventLog -LogName Application -Source "MSSQL*" -After $lastCheck | Select-Object TimeGenerated, EntryType, Message	
	$lastCheck = Get-Date
	Start-Sleep -Seconds 2
}

