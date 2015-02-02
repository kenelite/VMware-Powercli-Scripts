#This is script for Install Windows Pacth on Windows Server 2003/R2
#Prerequest:
#Must run on Windows PowerShell
#Must have access to ESXi host or vCenter Server TCP 902 Port
#Must vCenter Server/ESXi 5.0 and later
#Need VirtualMachine.Interact.ConsoleInteract privilege
#Need VirtualMachine.Interact.GuestControl privilege
#Need GuestOS execute privilege
####################################################################
#vmname,guestuser,guestpassword
#20150101,administrator,123456
###################################################################

$vmlist= Import-CSV "C:\test.csv"

foreach ($item in $vmlist) {

	
#GuestOS Password
			$vmname = $item.vmname
			$guestuser = $item.guestuser
			$guestpass = $item.guestpassword


#Copy shell script to GuestOS
			Copy-VMGuestFile -Destination "C:\Windows\Temp"   -VM $vmname  -LocalToGuest -Source "C:\KB971222-x86.exe" -GuestUser $guestuser -GuestPassword $guestpass
			Write-Host "Copy files finished."
#Define Bat script parameter
			$command1 = "C:\Windows\Temp\KB971222-x86.exe /passive /norestart /log:C:\Windows\Temp\$vmname.log"
			Write-Host "Installing the windows pacth KB971222." 		
			Invoke-VMScript -VM $vmname -ScriptText $command1 -GuestUser $guestuser -GuestPassword $guestpass -ScriptType Bat
						
#Show detail information of this patch.
			Write-Host "Finished install this patch."
 			Write-Host "Show the status of patch KB971222."
			$command2 = "C:\Windows\system32\systeminfo.exe | findstr KB971222" 
			Invoke-VMScript -VM $vmname -ScriptText $command2 -GuestUser $guestuser -GuestPassword $guestpass -ScriptType Bat
			
			
#Reboot VM
#			Write-Host "Then restart the VM."
#			restart-vmguest -vm $vmname
			Write-Host "Done."
				
}
