# AnyPackage.Appx

[![gallery-image]][gallery-site]
[![build-image]][build-site]
[![cf-image]][cf-site]

[gallery-image]: https://img.shields.io/powershellgallery/dt/AnyPackage.Appx
[build-image]: https://img.shields.io/github/actions/workflow/status/anypackage/appx/ci.yml
[cf-image]: https://img.shields.io/codefactor/grade/github/anypackage/appx
[gallery-site]: https://www.powershellgallery.com/packages/AnyPackage.Appx
[build-site]: https://github.com/anypackage/appx/actions/workflows/ci.yml
[cf-site]: https://www.codefactor.io/repository/github/anypackage/appx

`AnyPackage.Appx` is an AnyPackage provider that facilitates managing Appx apps.

## Install AnyPackage.Appx

```powershell
Install-PSResource AnyPackage.Appx
```

## Import AnyPackage.Appx

```powershell
Import-Module AnyPackage.Appx
```

## Sample usages

### Get list of installed packages

```powershell
Get-Package -Name Microsoft.Paint
```
