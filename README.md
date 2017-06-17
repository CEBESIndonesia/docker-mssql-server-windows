# cebes/mssql-server-windows

A clone of microsoft/mssql-server-windows docker image with automated attach database files.

This image behaves the same as the original microsoft/mssql-server-windows image.
However when the option ```attach_dbs``` is omitted, it will try to attach all database files in the shared volume of the container ```C:\Databases```.

When ```attach_dbs``` is specified it will not automate, it will respect the ```attach_dbs``` value and only attach those files.

The only thing you need to do, is to make a shared volume, and make sure it is named ```C:\Databases``` on the container side.

When ```attach_dbs``` is omitted the original database names are not used, the name of the db will be the same as de filenames of the ```mdf``` files. Mostly this will be the case, so not really a problem I think.

Make sure the chosen password is according to SQL Server password policy, otherwise connecting to SQL Server will fail.

&nbsp;

**Example 1. Specifying a attach_dbs option:**
```powershell
docker run -d --name mssql -p 1433:1433 -e sa_password=cCH4qFSfg47reuzB -e ACCEPT_EULA=Y -v C:/Databases/:C:/Databases/ -e attach_dbs="[{'dbName':'AdventureWorks','dbFiles':['C:\\Databases\\AdventureWorks.mdf','C:\\Databases\\AdventureWorks_log.ldf']}]" cebes/mssql-server-windows
```

&nbsp;

**Example 2. Omitting the attach_dbs option:**
```powershell
docker run -d --name mssql -p 1433:1433 -e sa_password=cCH4qFSfg47reuzB -e ACCEPT_EULA=Y -v C:/Databases/:C:/Databases/ cebes/mssql-server-windows
```

&nbsp;

**To get the IP address:**
```powershell
docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' mssql
```

&nbsp;

**Look at the databases using Microsoft SQL Server Management Studio**

Start Microsoft SQL Server Management Studio
Logon with IP returned from inspect and Port, for example ```172.29.135.101,1433```
Use the ```sa_password``` specified when running the container

&nbsp;

To see the modified **start.ps1**, and **Dockerfile**, **[find it on Github](https://github.com/CEBESIndonesia/docker-mssql-server-windows)**

To pull the **docker image**, **[find it on Docker Hub](https://hub.docker.com/r/cebes/mssql-server-windows/)**