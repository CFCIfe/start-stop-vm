using namespace System.Net
# Input bindings are passed in via param block.
param($Timer)

Set-AzContext -SubscriptionId ""
$RgName = ""

$vms = Get-AzVM -ResourceGroupName $RgName -Status

$vms | ForEach-Object -Parallel {
   if ($_.PowerState -eq 'VM running'){
      Write-Warning "Could not Stop VM - $($_.Name) as it is running"
   }
   elseif ($_.PowerState -eq 'VM deallocated') {
      Start-AzVM -Name $_.Name -ResourceGroupName $_.ResourceGroupName
      Write-Warning "Started VM - $($_.Name)"
   }
   Start-Sleep 1
} -ThrottleLimit 10 #Number of VM's