#Requires -Modules AnyPackage.Appx

Describe Get-Package {
    Context 'with no parameters' {
        It 'should return results' {
            Get-Package |
            Should -Not -BeNullOrEmpty
        }
    }

    Context 'with -Name parameter' {
        It 'should return Microsoft.WindowsStore' {
            Get-Package -Name Microsoft.WindowsStore |
            Should -Not -BeNullOrEmpty
        }
    }
}
