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
	20150318	Guoyu Wang
	[+] Updated the VMhost Cluster
#>

$Report = @()

$VMhosts = Get-VMhost

ForEach ($VMhost in $VMhosts)
	{
		
		Get-VMHost $VMhost | Where-object { $_.PowerState -eq "PoweredOn"} 
		
		$HostArray = "" | Select Cluster, HostName, NumCpu, HostCpuUsed, CpuOver, MemoryTotalGB, HostMemUsed, MemOver
		
		$ClusterName = Get-VMHost $VMhost | Get-Cluster
		
		$HostArray.Cluster =  $ClusterName.Name
		
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
			$HostArray.CpuOver = "Normal"
		}
		
		elseif ($HostArray.NumCpu -eq $HostArray.HostCpuUsed )
		{
			$HostArray.CpuOver = "Warning"
		}		
		else
		{
			$HostArray.CpuOver = "Error"
		}
		
		if ($HostArray.MemoryTotalGB -gt $HostArray.HostMemUsed )
		{
			$HostArray.MemOver = "Normal"
		}
		
		elseif ($HostArray.MemoryTotalGB -eq $HostArray.HostMemUsed )
		{
			$HostArray.MemOver = "Warning"
		}
		else
		{
			$HostArray.MemOver = "Error"
		}
		
		$Report += $HostArray
		
	}

$Now = get-date  -Format "yyyy-MM-dd_hh_mm_ss"

$FilePath = (Get-location).Path

$FileName = $FilePath+"\"+$Now+".html"
	
$Report | Sort-Object -property @{Expression="Cluster";Descending=$false}, @{Expression="HostName";Descending=$false} |  ConvertTo-Html  -Title "VMHost Resource over allocation details" -Body "<H3>VMHost Resource over allocation details</H3><H3>$Now</H3>"  > $FileName.html




