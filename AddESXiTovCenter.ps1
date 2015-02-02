##########################################################
# Add_ESXi_To_vCenter.ps1
# Micheal Ken 23/7/2014
# Add ESxi Hosts to the vCenter
##########################################################
#Name,Location,User,Password
#vmware1,MyDatacenter1,root,abcdefg

##########################################################
$vcenter = 10.1.1.10
$Connect-VIServer $vcenter

$vmlist = Import-CSV C:\Host_list.csv
	
foreach ($item in $vmlist) {
$Name = $item.Name
$Location = $item.Location
$User = $item.User
$Password = $item.Password

#ADD ESXi Hosts
Add-VMHost -Server $vcenter -Name $Name -Location $Location -User $User -Password $Password

echo "Host $Name  is added."
#Reference options
#Add-VMHost -Server $myServer -Name MyVMHost1 -Location MyDatacenter1 -Credentials $myCredentials
#Add-VMHost -Server $server -Name MyVMHost1 -Location MyDatacenter1 -Credentials $myCredentials -Port MyVMHostPortNumber1 -Confirm:$false
#Add-VMHost -Server $myServer -Name MyVMHost1 -Location MyDataCenter1 -Credentials $myCredentials -Port MyVMHostPortNumber1 -Force

}

Get-Host -Location $Location
