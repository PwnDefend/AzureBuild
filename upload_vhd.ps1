# The azure documentation didn't work exactly so i knocked up this version
# i had to make a 32 bit vm in azure so here's the script i used to upload it
# mRr3b00t (UK_Daniel_Card)
# use at own risk

#download azcopy - https://docs.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-v10
# copy that to system32 or run from path

$PSVersionTable.PSVersion

Install-Module -Name PowerShellGet -Force

if ($PSVersionTable.PSEdition -eq 'Desktop' -and (Get-Module -Name AzureRM -ListAvailable)) {
    Write-Warning -Message ('Az module not installed. Having both the AzureRM and ' +
      'Az modules installed at the same time is not supported.')
} else {
    Install-Module -Name Az -AllowClobber -Scope AllUsers
}

Add-AzAccount


#variables
#disk path
$diskpath = 'C:\users\Public\Documents\Hyper-V\Virtual hard disks\win1032.vhd'
$location = 'West Europe'
$resourceGroup = 'win10pro32bit'
$DiskName = 'w1032protemplate'

$subs = Get-AzSubscription
$subs.SubscriptionId
Select-AzSubscription  -SubscriptionId $subs.SubscriptionId

$vhdSizeBytes = (Get-Item $DiskName).length

$diskconfig = New-AzDiskConfig -SkuName 'Standard_LRS' -OsType 'Windows' -UploadSizeInBytes $vhdSizeBytes -Location $location -CreateOption 'Upload' -HyperVGeneration V1


New-AzDisk -ResourceGroupName $resourceGroup -DiskName $DiskName -Disk $diskconfig


$diskSas = Grant-AzDiskAccess -ResourceGroupName $resourceGroup -DiskName $DiskName -DurationInSecond 86400 -Access 'Write'

$disk = Get-AzDisk -ResourceGroupName $resourceGroup -DiskName $DiskName

AzCopy.exe copy $DiskName $diskSas.AccessSAS --blob-type PageBlob

Revoke-AzDiskAccess -ResourceGroupName $resourceGroup -DiskName $DiskName
