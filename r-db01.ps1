New-Item -Path 'D:\temp\Test Folder' -ItemType Directory

$i= 0
$newdisk = @(get-disk | Where-Object partitionstyle -eq 'raw')
$Labels = @('Data','SQL_Data','SQL_Logs','SQL_Temp','SQL_System')


While ($i -lt $newdisk.count){
$disknum = $newdisk[$i].Number
$dl = get-Disk $disknum | 
Initialize-Disk -PartitionStyle GPT -PassThru | 
New-Partition -AssignDriveLetter -UseMaximumSize
Format-Volume -driveletter $dl.Driveletter -FileSystem NTFS -NewFileSystemLabel $Labels[$i] -Confirm:$false
$i++
}


$sql_data_Drive = Get-Volume -FileSystemLabel "SQL_Data"
Get-Partition -DriveLetter ($sql_data_Drive.DriveLetter) | Set-Partition -NewDriveLetter N

$sql_logs_Drive = Get-Volume -FileSystemLabel "SQL_Logs"
Get-Partition -DriveLetter ($sql_sql_Drive.DriveLetter) | Set-Partition -NewDriveLetter P

$sql_tmp_Drive = Get-Volume -FileSystemLabel "SQL_Temp"
Get-Partition -DriveLetter ($sql_tmp_Drive.DriveLetter) | Set-Partition -NewDriveLetter R

$sql_sys_Drive = Get-Volume -FileSystemLabel "SQL_System"
Get-Partition -DriveLetter ($sql_sys_Drive.DriveLetter) | Set-Partition -NewDriveLetter T

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
