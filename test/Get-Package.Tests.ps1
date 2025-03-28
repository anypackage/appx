#Requires -Modules AnyPackage.Appx

Describe Get-Package {
    Context 'with no parameters' {
        It 'should return results' -Skip {
            Get-Package |
            Should -Not -BeNullOrEmpty
        }
    }

    Context 'with -Name parameter' {
        It 'should return Microsoft.Paint' -Skip {
            Get-Package -Name Microsoft.Paint |
            Should -Not -BeNullOrEmpty
        }
    }
}
