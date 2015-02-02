##########################################################
# CloneVM using vmware powercli.
# Update the script from Jase McCarty
# ########################################################
# The example of CSV file as follow:
# basevm,datastore,vmhost,custspec,vmname,ipaddress,subnet,gateway,vlan,pdns,sdns,ipaddress2,subnet2,gateway2,vlan2,pdns2,sdns2
# template,DS1,1vmhost1,vmspec,win2k8,10.1.1.1,255.255.255.0,10.1.1.254,VLAN10,8.8.8.8,4.4.4.4,20.1.1.1,255.255.255.0,20.1.1.254,VLAN20,8.8.8.8,4.4.4.4
#
##########################################################
#$Connect-VIServer 10.1.1.1


$vmlist = Import-CSV C:\20140101.csv
foreach ($item in $vmlist) {

$basevm = $item.basevm
$datastore = $item.datastore
$vmhost = $item.vmhost
$custspec = $item.custspec
$vmname = $item.vmname
$ipaddr = $item.ipaddress
$subnet = $item.subnet
$gateway = $item.gateway
$vlan = $item.vlan
$pdns = $item.pdns
$sdns = $item.sdns
$ipaddr2 = $item.ipaddress2
$subnet2 = $item.subnet2
$gateway2 = $item.gateway2
$vlan2 = $item.vlan2
$pdns2 = $item.pdns2
$sdns2 = $item.sdns2

#Get the Specification and set the Nic Mapping 
Get-OSCustomizationSpec $custspec | Get-OSCustomizationNicMapping |Where-Object  {$_.Position -match "1" } | Set-OSCustomizationNicMapping -IpMode UseStaticIp -IpAddress $ipaddr -SubnetMask $subnet -DefaultGateway $gateway -Dns $pdns,$sdns
Get-OSCustomizationSpec $custspec | Get-OSCustomizationNicMapping |Where-Object  {$_.Position -match "2" } | Set-OSCustomizationNicMapping -IpMode UseStaticIp -IpAddress $ipaddr2 -SubnetMask $subnet2  -DefaultGateway $gateway2 -Dns $pdns2,$sdns2

#Clone the BaseVM with the adjusted Customization Specification
New-VM -Name $vmname -Datastore $datastore -VMHost $vmhost -OSCustomizationSpec $custspec -Template $basevm

#Set the Network Name
Get-VM -Name $vmname | Get-NetworkAdapter -NAME "*1"| Set-NetworkAdapter -NetworkName $vlan -StartConnected:$true -Confirm:$false
Get-VM -Name $vmname | Get-NetworkAdapter -NAME "*2"| Set-NetworkAdapter -NetworkName $vlan2 -StartConnected:$true -Confirm:$false

#Remove the NicMapping 
#Get-OSCustomizationSpec $custspec | Get-OSCustomizationNicMapping | Set-OSCustomizationNicMapping -IpMode UseDhcp 
}
