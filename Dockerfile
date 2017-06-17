FROM microsoft/mssql-server-windows
MAINTAINER Hayke Geuskens - PT CEBES Indonesia

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop';"]

VOLUME C:\\Databases
EXPOSE 1433

# Copy the new start.ps1 script, overrides the base image script
COPY . /
WORKDIR /

# docker build -t cebes/mssql-server-windows .
