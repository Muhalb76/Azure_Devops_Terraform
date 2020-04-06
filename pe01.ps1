###################################
#
#          IIS install
# 
###################################


#Define CSS for table
$header = @"
<style>
  TABLE {border-width: 2px; border-style: solid; border-color: black; border-collapse: collapse;}
  TH {border-width: 1px; padding: 5px; border-style: solid; border-color: black; background-color: cyan; text-align: left}
  TD {border-width: 1px; padding: 5px; border-style: solid; border-color: black; text-align: left}
</style>
"@

#Install IIS

$IISFeatures = "Web-WebServer","Web-Common-Http","Web-Default-Doc","Web-Dir-Browsing","Web-Http-Errors","Web-Static-Content","Web-Http-Redirect","Web-Health","Web-Http-Logging","Web-Custom-Logging","Web-Log-Libraries","Web-ODBC-Logging","Web-Request-Monitor","Web-Http-Tracing","Web-Performance","Web-Stat-Compression","Web-Security","Web-Filtering","Web-Basic-Auth","Web-Client-Auth","Web-Digest-Auth","Web-Cert-Auth","Web-IP-Security","Web-Windows-Auth","Web-App-Dev","Web-Net-Ext","Web-Net-Ext45","Web-Asp-Net","Web-Asp-Net45","Web-ISAPI-Ext","Web-ISAPI-Filter","Web-Mgmt-Tools","Web-Mgmt-Console"
Install-WindowsFeature -Name $IISFeatures

#Install-WindowsFeature -name Web-Server
#Install-WindowsFeature -name IIS-WebServerRole
#Install-WindowsFeature -name IIS-WebServerManagementTools

#Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole
#Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServer
#Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerManagementTools

#Enable-WindowsOptionalFeature -Online -FeatureName IIS-CommonHttpFeatures
#Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpErrors
#Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpRedirect
#Enable-WindowsOptionalFeature -Online -FeatureName IIS-ApplicationDevelopment

#Enable-WindowsOptionalFeature -online -FeatureName NetFx4Extended-ASPNET45
#Enable-WindowsOptionalFeature -Online -FeatureName IIS-NetFxExtensibility45

#Enable-WindowsOptionalFeature -Online -FeatureName IIS-HealthAndDiagnostics
#Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpLogging
#Enable-WindowsOptionalFeature -Online -FeatureName IIS-LoggingLibraries
#Enable-WindowsOptionalFeature -Online -FeatureName IIS-RequestMonitor
#Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpTracing
#Enable-WindowsOptionalFeature -Online -FeatureName IIS-Security
#Enable-WindowsOptionalFeature -Online -FeatureName IIS-RequestFiltering
#Enable-WindowsOptionalFeature -Online -FeatureName IIS-Performance

#Enable-WindowsOptionalFeature -Online -FeatureName IIS-IIS6ManagementCompatibility
#Enable-WindowsOptionalFeature -Online -FeatureName IIS-Metabase
#Enable-WindowsOptionalFeature -Online -FeatureName IIS-ManagementConsole
#Enable-WindowsOptionalFeature -Online -FeatureName IIS-BasicAuthentication
#Enable-WindowsOptionalFeature -Online -FeatureName IIS-WindowsAuthentication
#Enable-WindowsOptionalFeature -Online -FeatureName IIS-StaticContent
#Enable-WindowsOptionalFeature -Online -FeatureName IIS-DefaultDocument
#Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebSockets
#Enable-WindowsOptionalFeature -Online -FeatureName IIS-ApplicationInit
#Enable-WindowsOptionalFeature -Online -FeatureName IIS-ISAPIExtensions
#Enable-WindowsOptionalFeature -Online -FeatureName IIS-ISAPIFilter
#Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpCompressionStatic

Enable-WindowsOptionalFeature -Online -FeatureName IIS-ASPNET45

# If you need classic ASP (not recommended)
#Enable-WindowsOptionalFeature -Online -FeatureName IIS-ASP


# The following optional components require 
# Chocolatey OR Web Platform Installer to install


# Install UrlRewrite Module for Extensionless Urls (optional)
###  & "C:\Program Files\Microsoft\Web Platform Installer\WebpiCmd-x64.exe" /install /Products:UrlRewrite2 /AcceptEULA /SuppressPostFinish
#choco install urlrewrite -y
    
# Install WebDeploy for Deploying to IIS (optional)
### & "C:\Program Files\Microsoft\Web Platform Installer\WebpiCmd-x64.exe" /install /Products:WDeployNoSMO /AcceptEULA /SuppressPostFinish
# choco install webdeploy -y

# Disable Loopback Check on a Server - to get around no local Logins on Windows Server
# New-ItemProperty HKLM:\System\CurrentControlSet\Control\Lsa -Name "DisableLoopbackCheck" -Value "1" -PropertyType dword








#Query Azure Instance Metadata service
$metadata = Invoke-RestMethod -Headers @{"Metadata"="true"} -URI http://169.254.169.254/metadata/instance?api-version=2017-08-01 -Method get

#Create object containing data to render 
$body = New-Object System.Collections.ArrayList
$body.Add([pscustomobject] @{"Heading" = "Server Name"; "Data" = $metadata.compute.name}) | Out-Null
$body.Add([pscustomobject] @{"Heading" = "Azure Location"; "Data" = $metadata.compute.location}) | Out-Null
$body.Add([pscustomobject] @{"Heading" = "Resource Group"; "Data" = $metadata.compute.resourceGroupName}) | Out-Null
$body.Add([pscustomobject] @{"Heading" = "Private IP"; "Data" = $metadata.network.interface.ipv4.ipAddress.privateIpAddress}) | Out-Null

#Convert object to HTML and overwrite existing index
$HTML = $body | ConvertTo-Html -Title "WebServer Details"-Head $header
$HTML | Out-File -FilePath "C:\inetpub\wwwroot\index.html" -Force

#################################################
#
#       Winlogbeat install
#
#################################################


New-Item -Path 'D:\Winlogbeat' -ItemType Directory
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$client = New-Object system.net.WebClient
$client.DownloadFile("https://artifacts.elastic.co/downloads/beats/winlogbeat/winlogbeat-7.6.1-windows-x86_64.zip","d:\Winlogbeat\winlogbeat.zip")                           

expand-Archive -Path 'D:\Winlogbeat\winlogbeat.zip' -DestinationPath 'C:\Program Files\'

Rename-Item -Path "C:\Program Files\winlogbeat-7.6.1-windows-x86_64" -NewName "C:\Program Files\winlogbeat"


. "C:\Program Files\winlogbeat\install-service-winlogbeat.ps1"

$winlogsvc = Get-Service -Name winlogbeat     

    if( $winlogsvc.Status -ne [System.ServiceProcess.ServiceControllerStatus]::Running)
    {
        $winlogsvc.Start()
    }

    
#################################################
#
#       Filebeat install
#
#################################################
New-Item -Path 'D:\filebeat' -ItemType Directory
New-Item -Path 'C:\Program Files\ssl' -ItemType Directory
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$client = New-Object system.net.WebClient
$client.DownloadFile("https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.6.2-windows-x86_64.zip","d:\filebeat\winlogbeat.zip")                           

expand-Archive -Path 'D:\filebeat\winlogbeat.zip' -DestinationPath 'C:\Program Files\'

Rename-Item -Path "C:\Program Files\filebeat-7.6.2-windows-x86_64" -NewName "C:\Program Files\filebeat"


. "C:\Program Files\filebeat\install-service-filebeat.ps1"

$filebeatsvc = Get-Service -Name Filebeat     

    if( $filebeatsvc.Status -ne [System.ServiceProcess.ServiceControllerStatus]::Running)
    {
        $filebeatsvc.Start()
    }
