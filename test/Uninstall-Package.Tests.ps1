#Requires -Modules AnyPackage.Appx

Describe Uninstall-Package {
    Context 'with -Name parameter' {
        It 'should uninstall Microsoft.WindowsFeedbackHub' {
            Uninstall-Package -Name Microsoft.WindowsFeedbackHub |
                Should -Not -BeNullOrEmpty
        }
    }
}
