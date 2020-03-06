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
Get-Partition -DriveLetter ($sql_data_Drive.DriveLetter) | Set-Partition -NewDriveLetter S

$sql_logs_Drive = Get-Volume -FileSystemLabel "SQL_Logs"
Get-Partition -DriveLetter ($sql_sql_Drive.DriveLetter) | Set-Partition -NewDriveLetter N

$sql_tmp_Drive = Get-Volume -FileSystemLabel "SQL_Temp"
Get-Partition -DriveLetter ($sql_tmp_Drive.DriveLetter) | Set-Partition -NewDriveLetter R

$sql_sys_Drive = Get-Volume -FileSystemLabel "SQL_System"
Get-Partition -DriveLetter ($sql_sys_Drive.DriveLetter) | Set-Partition -NewDriveLetter T
