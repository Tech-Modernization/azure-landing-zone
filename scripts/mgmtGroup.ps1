function New-MgmtGroup
{

    $file = (Get-ChildItem -Path "./mgmtGroup" | Where-Object {$_.Extension -eq ".json"})
    $loadVars = Get-Content -Path $file.FullName | ConvertFrom-Json
    $mgmtGroups = (Get-AzManagementGroup).DisplayName
    Write-Host "List of Management Groups" + $mgmtGroups
    Write-Host "JSON Object Set ..... +" $loadVars.MgmtGroup.GroupName

    foreach($obj in $loadVars.MgmtGroup.GroupName){
        if ($mgmtGroups -notcontains $obj.name) {
            if($obj.parent -eq $null) {
                Write-Host "Creating New Management Group"
                New-AzManagementGroup -GroupName $obj.name

             if($obj.subscriptionId -ne $null) {
                 Write-Host "Moving $($obj.subscriptionName) to $($obj.Name)"
                 New-AzManagementGroupSubscription -GroupName $obj.name -SubscriptionId $obj.subscriptionId

             }
            }
            else
            {
                $mgmtGroups = (Get-AzManagementGroup).DisplayName
                if($mgmtGroups -notcontains $obj.parent) {
                    Write-Host "Creating Parent Management Group"
                    New-AzManagementGroup -GroupName $obj.name
                }
                Write-Host "Creating New Management Group Child"
                $parentObject = Get-AzManagementGroup -GroupName $obj.parent
                New-AzManagementGroup -GroupName $obj.Name -ParentObject $parentObject

                if($obj.subscriptionId -ne $null) {
                    Write-Host "Moving $($obj.subscriptionName) to $($obj.Name) Group"
                    New-AzManagementGroupSubscription -GroupName $obj.name -SubscriptionId $obj.subscriptionId

                }
            }
        }

    }
}
Install-Module Az.Resources -Force -AllowClobber -RequiredVersion 1.13.0
Import-Module Az.Resources
Get-Module Az.Resources
#New-MgmtGroup