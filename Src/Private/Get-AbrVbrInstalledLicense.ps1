
function Get-AbrVbrInstalledLicense {
    <#
    .SYNOPSIS
    Used by As Built Report to retrieve Veeam VBR Infrastructure Installed Licenses
    .DESCRIPTION
    .NOTES
        Version:        0.1.0
        Author:         Jonathan Colon
        Twitter:        @jcolonfzenpr
        Github:         rebelinux
    .EXAMPLE
    .LINK
    #>
    [CmdletBinding()]
    param (

    )

    begin {
        Write-PscriboMessage "Discovering Veeam V&R License information from $System."
    }

    process {
        try {
            if ((Get-VBRInstalledLicense).count -gt 0) {
                Section -Style Heading3 'License Information' {
                    Paragraph "The following section provides a summary of the Veeam License Information"
                    BlankLine
                    try {
                        Section -Style Heading4 'Installed License Information' {
                            $OutObj = @()
                            try {
                                $Licenses = Get-VBRInstalledLicense
                                foreach ($License in $Licenses) {
                                    Write-PscriboMessage "Discovered $($License.Edition) license."
                                    $inObj = [ordered] @{
                                        'Licensed To' = $License.LicensedTo
                                        'Edition' = $License.Edition
                                        'Type' = $License.Type
                                        'Status' = $License.Status
                                        'Expiration Date' = Switch ($License.ExpirationDate) {
                                            "" {"-"; break}
                                            $Null {'-'; break}
                                            default {$License.ExpirationDate.ToLongDateString()}
                                        }
                                        'Support Id' = $License.SupportId
                                        'Support Expiration Date' = Switch ($License.SupportExpirationDate) {
                                            "" {"-"; break}
                                            $Null {'-'; break}
                                            default {$License.SupportExpirationDate.ToLongDateString()}
                                        }
                                        'Auto Update Enabled' = ConvertTo-TextYN $License.AutoUpdateEnabled
                                        'Free Agent Instance' = ConvertTo-TextYN $License.FreeAgentInstanceConsumptionEnabled
                                        'Cloud Connect' = $License.CloudConnect
                                    }
                                    $OutObj += [pscustomobject]$inobj
                                }
                            }
                            catch {
                                Write-PscriboMessage -IsWarning $_.Exception.Message
                            }

                            $TableParams = @{
                                Name = "License Information - $(((Get-VBRServerSession).Server).ToString().ToUpper().Split(".")[0])"
                                List = $true
                                ColumnWidths = 40, 60
                            }
                            if ($Report.ShowTableCaptions) {
                                $TableParams['Caption'] = "- $($TableParams.Name)"
                            }
                            $OutObj | Table @TableParams
                            try {
                                Section -Style Heading5 'Instance License Usage' {
                                    $OutObj = @()
                                    try {
                                        $Licenses = Get-VBRInstalledLicense | Select-Object -ExpandProperty InstanceLicenseSummary
                                        foreach ($License in $Licenses) {
                                            Write-PscriboMessage "Discovered $($Licenses.LicensedInstancesNumber) Instance licenses."
                                            $inObj = [ordered] @{
                                                'Instances Capacity' = $License.LicensedInstancesNumber
                                                'Used Instances' = $License.UsedInstancesNumber
                                                'New Instances' = $License.NewInstancesNumber
                                                'Rental Instances' = $License.RentalInstancesNumber
                                            }
                                            $OutObj += [pscustomobject]$inobj
                                        }
                                    }
                                    catch {
                                        Write-PscriboMessage -IsWarning $_.Exception.Message
                                    }

                                    $TableParams = @{
                                        Name = "Instance Information - $(((Get-VBRServerSession).Server).ToString().ToUpper().Split(".")[0])"
                                        List = $false
                                        ColumnWidths = 25, 25, 25, 25
                                    }
                                    if ($Report.ShowTableCaptions) {
                                        $TableParams['Caption'] = "- $($TableParams.Name)"
                                    }
                                    $OutObj | Table @TableParams
                                    try {
                                        Section -Style Heading5 'Per Instance Type License Usage' {
                                            $OutObj = @()
                                            try {
                                                $Licenses = (Get-VBRInstalledLicense | Select-Object -ExpandProperty InstanceLicenseSummary).Object
                                                foreach ($License in $Licenses) {
                                                    Write-PscriboMessage "Discovered $($Licenses.Type) Instance licenses."
                                                    $inObj = [ordered] @{
                                                        'Type' = $License.Type
                                                        'Count' = $License.Count
                                                        'Multiplier' = $License.Multiplier
                                                        'Used Instances' = $License.UsedInstancesNumber
                                                    }
                                                    $OutObj += [pscustomobject]$inobj
                                                }
                                            }
                                            catch {
                                                Write-PscriboMessage -IsWarning $_.Exception.Message
                                            }

                                            $TableParams = @{
                                                Name = "Per Instance Type Information - $(((Get-VBRServerSession).Server).ToString().ToUpper().Split(".")[0])"
                                                List = $false
                                                ColumnWidths = 25, 25, 25, 25
                                            }
                                            if ($Report.ShowTableCaptions) {
                                                $TableParams['Caption'] = "- $($TableParams.Name)"
                                            }
                                            $OutObj | Table @TableParams
                                        }
                                    }
                                    catch {
                                        Write-PscriboMessage -IsWarning $_.Exception.Message
                                    }
                                }
                            }
                            catch {
                                Write-PscriboMessage -IsWarning $_.Exception.Message
                            }
                            try {
                                Section -Style Heading5 'CPU Socket License Usage' {
                                    $OutObj = @()
                                    try {
                                        $Licenses = Get-VBRInstalledLicense | Select-Object -ExpandProperty SocketLicenseSummary
                                        foreach ($License in $Licenses) {
                                            Write-PscriboMessage "Discovered $($Licenses.LicensedSocketsNumber) CPU Socket licenses."
                                            $inObj = [ordered] @{
                                                'Licensed Sockets' = $License.LicensedSocketsNumber
                                                'Used Sockets Licenses' = $License.UsedSocketsNumber
                                                'Remaining Sockets Licenses' = $License.RemainingSocketsNumber
                                            }
                                            $OutObj += [pscustomobject]$inobj
                                        }
                                    }
                                    catch {
                                        Write-PscriboMessage -IsWarning $_.Exception.Message
                                    }

                                    $TableParams = @{
                                        Name = "CPU Socket Usage Information - $(((Get-VBRServerSession).Server).ToString().ToUpper().Split(".")[0])"
                                        List = $false
                                        ColumnWidths = 33, 33, 34
                                    }
                                    if ($Report.ShowTableCaptions) {
                                        $TableParams['Caption'] = "- $($TableParams.Name)"
                                    }
                                    $OutObj | Table @TableParams
                                }
                            }
                            catch {
                                Write-PscriboMessage -IsWarning $_.Exception.Message
                            }
                            try {
                                Section -Style Heading5 'Capacity License Usage' {
                                    $OutObj = @()
                                    if ((Get-VBRServerSession).Server) {
                                        try {
                                            $Licenses = Get-VBRInstalledLicense | Select-Object -ExpandProperty CapacityLicenseSummary
                                            foreach ($License in $Licenses) {
                                                Write-PscriboMessage "Discovered $($Licenses.LicensedCapacityTb) Capacity licenses."
                                                $inObj = [ordered] @{
                                                    'Licensed Capacity in Tb' = $License.LicensedCapacityTb
                                                    'Used Capacity in Tb' = $License.UsedCapacityTb
                                                }
                                                $OutObj += [pscustomobject]$inobj
                                            }
                                        }
                                        catch {
                                            Write-PscriboMessage -IsWarning $_.Exception.Message
                                        }

                                        $TableParams = @{
                                            Name = "Capacity License Usage Information - $(((Get-VBRServerSession).Server).ToString().ToUpper().Split(".")[0])"
                                            List = $false
                                            ColumnWidths = 50, 50
                                        }
                                        if ($Report.ShowTableCaptions) {
                                            $TableParams['Caption'] = "- $($TableParams.Name)"
                                        }
                                        $OutObj | Table @TableParams
                                    }
                                }
                            }
                            catch {
                                Write-PscriboMessage -IsWarning $_.Exception.Message
                            }
                        }
                    }
                    catch {
                        Write-PscriboMessage -IsWarning $_.Exception.Message
                    }
                }
            }
        }
        catch {
            Write-PscriboMessage -IsWarning $_.Exception.Message
        }
    }

    end {}

}