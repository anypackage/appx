@{
    RootModule = 'AnyPackage.Appx.psm1'
    ModuleVersion = '0.1.0'
    CompatiblePSEditions = @('Desktop', 'Core')
    GUID = '9fa07ec8-886b-486f-b443-e3539a3545cc'
    Author = 'Thomas Nieto'
    Copyright = '(c) 2025 Thomas Nieto. All rights reserved.'
    Description = 'Appx provider for AnyPackage.'
    PowerShellVersion = '5.1'
    RequiredModules = @(
        @{ ModuleName = 'AnyPackage'; ModuleVersion = '0.9.0' },
        'Appx')
    FunctionsToExport = @()
    CmdletsToExport = @()
    AliasesToExport = @()
    PrivateData = @{
        AnyPackage = @{
            Providers = 'Appx'
        }
        PSData = @{
            Tags = @('AnyPackage', 'Provider', 'Appx', 'Windows')
            LicenseUri = 'https://github.com/anypackage/appx/blob/main/LICENSE'
            ProjectUri = 'https://github.com/anypackage/appx'
        }
    }
    HelpInfoURI = 'https://go.anypackage.dev/help'
}
