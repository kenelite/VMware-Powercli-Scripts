<#
.SYNOPSIS
	Return VMHost Resource over allocation details for all the VMHost.
.DESCRIPTION
	
.INPUTS
	System.String
.EXAMPLE
	.\GetVMHostOverAllocation.ps1
.LINK

.NOTES
	20150316	Guoyu Wang
	[+] Created
#>

$Report = @()

$VMhosts = Get-VMhost

ForEach ($VMhost in $VMhosts)
	{
		
		Get-VMHost $VMhost | Where-object { $_.PowerState -eq "PoweredOn"} 
		
		$HostArray = "" | Select HostName, NumCpu, HostCpuUsed, CpuOver, MemoryTotalGB, HostMemUsed, MemOver
		
		$HostArray.HostName = $VMHost.Name
		
		if ( $Host.HyperthreadingActive -eq "True" )
		{
			$HostArray.NumCpu = $VMhost.NumCpu * 2
		}
		else
		{
			$HostArray.NumCpu = $VMhost.NumCpu
		}
		
		
		$HostArray.MemoryTotalGB = [int]$VMhost.MemoryTotalGB 
		$HostArray.HostCpuUsed = 0
		$HostArray.HostMemUsed = 0
		
		$VMs = Get-VMhost $VMhost  | Get-VM | Where-object { $_.PowerState -eq "PoweredOn"} 
		
		
		
		ForEach ($VM in $VMs)
			{
			
			$HostArray.HostCpuUsed += [int]$VM.NumCpu
			$HostArray.HostMemUsed += [int]$VM.MemoryGB
			
			}
			
		if ($HostArray.NumCpu -gt $HostArray.HostCpuUsed )
		{
			$HostArray.CpuOver = "False"
		}
		else
		{
			$HostArray.CpuOver = "True"
		}
		
		if ($HostArray.MemoryTotalGB -gt $HostArray.HostMemUsed )
		{
			$HostArray.MemOver = "False"
		}
		else
		{
			$HostArray.MemOver = "True"
		}
		
		$Report += $HostArray
		
	}

$Now = get-date  -Format "yyyy-MM-dd_hh_mm_ss"
	
$Report | Sort-Object HostName |  ConvertTo-Html  -Title "VMHost Resource over allocation details" -Body "<H3>VMHost Resource over allocation details</H3><H3>$Now</H3>"  > C:\$Now.html

Invoke-Item C:\$Now.html