<#
.SYNOPSIS
	Clone VM with VMware vCenter 5.x , Setup the VM's IP Address , Startup VM.
.DESCRIPTION

.PARAMETER ComputerName
.INPUTS
	System.String
.OUTPUTS
	
.EXAMPLE
	.\CloneRHEL6
.EXAMPLE

.NOTES


#>

$Guestuser = Read-Host "Please input username of  guest OS:" 
$Guestpassword = Read-Host  -AsSecureString "Please input password of  guest OS:" 
$Guestpass = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Guestpassword))
	
$FilePath = (Get-Location).Path
$Script = $FilePath+"\"+"example-tmp.sh"


$EmailFrom = "vcenter@example.cn"
$EmailTo = "admin@example.cn"
$Subject = "VM  deploy task is finished  from VMware vCenter"
$Body = "Please check all the Configuration information"
$SmtpServer = "email.example.cn"
$Attachment = @()
 



If($args.Count -eq 0){

	Write-Host "Usage:  .\CloneRHEL6.ps1 20150101.csv"
	EXIT
  
}

Else {  
 
	$Now = Get-Date  -Format "yyyyMMddhhmmss"
	$FileName = $FilePath+"\"+$Now+"-utf8.csv"
	Get-Content   $args   |  Out-File  $FileName  -Encoding utf8
	$VMlist = Import-CSV $FileName  

 }


Foreach ($Item in $VMlist) {

	$Basevm = $Item.Basevm
	$Datastore = $Item.Datastore
	$VMhost = $Item.VMhost
	$Custspec = $Item.Custspec
	$VMname = $Item.VMname

	$Memory = $Item.Memory
	$Cpu = $Item.Cpu
	$Disk1 = $Item.Disk1
	$Disk2 = $Item.Disk2

	$IPaddr = $Item.IPaddress
	$Subnet = $Item.Subnet
	$Gateway = $Item.Gateway
	$VLAN = $Item.VLAN

	$IPaddr2 = $Item.IPaddress2
	$Subnet2 = $Item.Subnet2
	$Gateway2 = $Item.Gateway2
	$VLAN2 = $Item.VLAN2

	$Note = $Item.Note

	#Get the Specification and set the Nic Mapping (Apply 2 DNS/WINS if 2 are present)
	Get-OSCustomizationSpec $Custspec | Get-OSCustomizationNicMapping | Where-Object  {$_.Position -match "1" } | Set-OSCustomizationNicMapping -IpMode UseStaticIp -IpAddress $Ipaddr -SubnetMask $Subnet -DefaultGateway $Gateway
	Get-OSCustomizationSpec $Custspec | Get-OSCustomizationNicMapping | Where-Object  {$_.Position -match "2" } | Set-OSCustomizationNicMapping -IpMode UseStaticIp -IpAddress $Ipaddr2 -SubnetMask $Subnet2  -DefaultGateway $gateway2

	#Clone the Basevm with the adjusted Customization Specification
	New-VM -Name $VMname -Datastore $Datastore -VMhost $VMhost  -OSCustomizationSpec $Custspec -Template $Basevm  -Notes $Note

	#Change CPU and Memory size
	Set-VM -VM $VMname -MemoryGB $Memory -NumCpu $Cpu -Confirm:$false

	#Change Disk size
	Get-VM $VMname |   Get-Harddisk | Where-Object {$_.Name -match "Hard disk 1"}     | Set-HardDisk -CapacityGB $Disk1 -Confirm:$false
	Get-VM $VMname |   Get-Harddisk | Where-Object {$_.Name -match "Hard disk 2"}     | Set-HardDisk -CapacityGB $Disk2 -Confirm:$false


	#Set the Network Name (I often match PortGroup names with the VLAN name)
	Get-VM -Name $Vmname | Get-NetworkAdapter -NAME "*1"| Set-NetworkAdapter -NetworkName $Vlan -StartConnected:$true -Confirm:$false
	Get-VM -Name $Vmname | Get-NetworkAdapter -NAME "*2"| Set-NetworkAdapter -NetworkName $Vlan2 -StartConnected:$true -Confirm:$false

	Start-VM $VMname


}

Write-Host  "Finished Clone  VM "

Write-Host  "Sleep 120s for start the VM tools" 

Start-Sleep -s 120

Write-Host  "Changing the VM  hostname and networking "



Foreach ($Item in $VMlist) {

	$VMname = $Item.VMname
	$IPaddr = $Item.IPaddress
	$Gateway = $Item.Gateway
	$Gateway2 = $Item.Gateway2
	

	Copy-VMGuestFile -LocalToGuest -Source $Script  -Destination "/tmp" -VM $VMname -GuestUser $Guestuser  -GuestPassword $Guestpass

	Invoke-VMScript -VM $VMname -ScriptText "sed s/.$// /tmp/example-tmp.sh > /tmp/example.sh && chmod 766 /tmp/example.sh" -GuestUser $Guestuser  -GuestPassword $Guestpass -ScriptType bash

	$Command = "/tmp/example.sh $VMname $IPaddr $Gateway  $Gateway2"

	Invoke-VMScript -VM $VMname -ScriptText $Command -GuestUser $Guestuser  -GuestPassword $Guestpass -ScriptType bash
	
	Copy-VMGuestFile -GuestToLocal -Source "/tmp/$VMname.log" -Destination "$FilePath" -VM $VMname -GuestUser $Guestuser  -GuestPassword $Guestpass

	Write-Host  "Restart the VM  $VMname"

	Restart-VM -VM $VMname -Confirm:$false
	
	$Attachment += "$VMname.log"
	
	
}



Remove-Item $FileName

Send-mailmessage -From $EmailFrom  -To $EmailTo  -Subject $Subject  -Body $Body  -Attachment  $Attachment  -SmtpServer $SmtpServer 


Write-Host  "All task is finished."


