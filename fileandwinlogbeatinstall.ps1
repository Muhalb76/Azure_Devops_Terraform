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
