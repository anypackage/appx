# Copyright (c) Thomas Nieto - All Rights Reserved
# You may use, distribute and modify this code under the
# terms of the MIT license.

using module AnyPackage
using module Appx
using namespace AnyPackage.Provider
using namespace Windows.Management.Deployment
using namespace Microsoft.Windows.Appx.PackageManager.Commands
using namespace Microsoft.Msix.Utils.AppxPackaging
using namespace System.IO

[PackageProvider('Appx', PackageByName = $false, FileExtensions = ('.appx', '.msix', '.msixbundle', '.appinstaller'))]
class AppxProvider : PackageProvider, IFindPackage, IGetPackage, IInstallPackage, IUninstallPackage {
    [string[]] $Members = @()

    [void] FindPackage([PackageRequest] $request) {
        $appx = if ([Path]::GetExtension($request.Path) -eq '.msixbundle') {
            [AppxBundleMetadata]::new($request.Path)
        } else {
            [AppxMetadata]::new($request.Path)
        }

        $metadata = @{ }
        $properties = $appx |
            Get-Member -Type Properties |
            Select-Object -ExpandProperty Name

        foreach ($member in $properties) {
            $metadata[$member] = $appx.$member
        }

        $source = [PackageSourceInfo]::new($request.Path, $request.Path, $request.ProviderInfo)
        $package = [PackageInfo]::new($appx.PackageName, $appx.Version.ToString(), $source, $appx.DisplayName, $null, $metadata, $request.ProviderInfo)
        $request.WritePackage($package)
    }

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

    [void] InstallPackage([PackageRequest] $request) {
        $addAppxPackageParameters = @{
            Path = $request.Path
            ErrorAction = 'Stop'
        }

        Add-AppxPackage @addAppxPackageParameters
    }

    [void] UninstallPackage([PackageRequest] $request) {
        $removeAppxPackageParameters = @{ ErrorAction = 'Stop' }

        if ($request.DynamicParameters.User) {
            $removeAppxPackageParameters['User'] = $request.DynamicParameters.User
        }

        if ($request.DynamicParameters.PreserveRoamableApplicationData) {
            $removeAppxPackageParameters['PreserveRoamableApplicationData'] = $request.DynamicParameters.PreserveRoamableApplicationData
        }

        if ($request.DynamicParameters.PreserveApplicationData) {
            $removeAppxPackageParameters['PreserveApplicationData'] = $request.DynamicParameters.PreserveApplicationData
        }

        Get-Package -Name $request.Name -Provider $request.ProviderInfo |
            ForEach-Object {
                Remove-AppxPackage -Package $_.Metadata['PackageFullName'] @removeAppxPackageParameters
                $request.WritePackage($_)
            }
    }

    [object] GetDynamicParameters([string] $commandName) {
        return $(switch ($commandName) {
                'Get-Package' { return [GetPackageDynamicParameters]::new() }
                'Install-Package' { return [InstallPackageDynamicParameters]::new() }
                'Uninstall-Package' { return [UninstallPackageDynamicParameters]::new() }
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

class UninstallPackageDynamicParameters {
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $User

    [Parameter()]
    [switch] $PreserveRoamableApplicationData

    [Parameter()]
    [switch] $PreserveApplicationData
}

class InstallPackageDynamicParameters {
    [Parameter()]
    [switch] $AllowUnsigned

    [Parameter()]
    [string] $AppInstallerFile

    [Parameter()]
    [switch] $DeferRegistrationWhenPackagesAreInUse

    [Parameter()]
    [string[]] $DependencyPackages

    [Parameter()]
    [string[]] $DependencyPath

    [Parameter()]
    [switch] $DisableDevelopmentMode

    [Parameter()]
    [string] $ExternalLocation

    [Parameter()]
    [string[]] $ExternalPackages

    [Parameter()]
    [switch] $ForceApplicationShutdown

    [Parameter()]
    [switch] $ForceUpdateFromAnyVersion

    [Parameter()]
    [switch] $InstallAllResources

    [Parameter()]
    [switch] $LimitToExistingPackages

    [Parameter()]
    [string] $MainPackage

    [Parameter()]
    [string[]] $OptionalPackages

    [Parameter()]
    [switch] $Register

    [Parameter()]
    [switch] $RegisterByFamilyName

    [Parameter()]
    [string[]] $RelatedPackages

    [Parameter()]
    [switch] $RequiredContentGroupOnly

    [Parameter()]
    [switch] $RetainFilesOnFailure

    [Parameter()]
    [switch] $Stage

    [Parameter()]
    [StubPackageOption] $StubPackageOption

    [Parameter()]
    [switch] $Update

    [Parameter()]
    [AppxVolume] $Volume
}

[guid] $id = '429b9f84-2d16-48bd-aace-f0d6bf5d04e5'
[PackageProviderManager]::RegisterProvider($id, [AppxProvider], $MyInvocation.MyCommand.ScriptBlock.Module)

$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = {
    [PackageProviderManager]::UnregisterProvider($id)
}
