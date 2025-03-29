#Requires -Modules AnyPackage.Appx

Describe Get-Package {
    Context 'with no parameters' {
        It 'should return results' {
            Get-Package |
                Should -Not -BeNullOrEmpty
        }
    }

    Context 'with -Name parameter' {
        It 'should return Microsoft.WindowsFeedbackHub' {
            Get-Package -Name Microsoft.WindowsFeedbackHub |
                Should -Not -BeNullOrEmpty
        }

        It 'should return with wildcards' {
            Get-Package -Name Microsoft* |
                Should -Not -BeNullOrEmpty
        }
    }
}
