# Copyright (c) Thomas Nieto - All Rights Reserved
# You may use, distribute and modify this code under the
# terms of the MIT license.

using module AnyPackage
using module Appx
using namespace AnyPackage.Provider
using namespace Windows.Management.Deployment
using namespace Microsoft.Windows.Appx.PackageManager.Commands

[PackageProvider('Appx')]
class AppxProvider : PackageProvider, IGetPackage {
    [string[]] $Members = @()
    
    [void] GetPackage([PackageRequest] $request) {
        $getAppxPackageParams = @{ Name = $request.Name }

        if ($request.DynamicParameters.Publisher) {
            $getAppxPackageParams['Publisher'] = $request.DynamicParameters.Publisher
        }

        if ($request.DynamicParameters.PackageTypeFilter) {
            $getAppxPackageParams['PackageTypeFilter'] = $request.DynamicParameters.PackageTypeFilter
        }

        if ($request.DynamicParameters.AppxVolume) {
            $getAppxPackageParams['AppxVolume'] = $request.DynamicParameters.AppxVolume
        }

        if ($request.DynamicParameters.User) {
            $getAppxPackageParams['User'] = $request.DynamicParameters.User
        }

        if ($request.DynamicParameters.AllUsers) {
            $getAppxPackageParams['AllUsers'] = $request.DynamicParameters.AllUsers
        }
        
        foreach ($appx in (Get-AppxPackage @getAppxPackageParams)) {
            if (!$request.IsMatch([PackageVersion]$appx.Version)) {
                continue
            }

            if ($this.Members.Length -eq 0) {
                $this.Members = $appx |
                    Get-Member -MemberType Properties |
                    Select-Object -ExpandProperty Name
            }

            $metadata = @{ }
            foreach ($member in $this.Members) {
                $metadata[$member] = $appx.$member
            }

            $source = [PackageSourceInfo]::new($appx.InstallLocation, $appx.InstallLocation, $request.ProviderInfo)
            $package = [PackageInfo]::new($appx.Name, $appx.Version, $source, '', $null, $metadata, $request.ProviderInfo)
            $request.WritePackage($package)
        }
    }

    [object] GetDynamicParameters([string] $commandName) {
        return $(switch ($commandName) {
                'Get-Package' { return [GetPackageDynamicParameters]::new() }
                default { $null }
            })
    }
}

class GetPackageDynamicParameters {
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $Publisher
    
    [Parameter()]
    [PackageTypes] $PackageTypeFilter

    [Parameter()]
    [AppxVolume] $Volume

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $User

    [Parameter()]
    [switch] $AllUsers
}

[guid] $id = '429b9f84-2d16-48bd-aace-f0d6bf5d04e5'
[PackageProviderManager]::RegisterProvider($id, [AppxProvider], $MyInvocation.MyCommand.ScriptBlock.Module)

$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = {
    [PackageProviderManager]::UnregisterProvider($id)
}
