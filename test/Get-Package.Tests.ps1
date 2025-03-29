#Requires -Modules Appx

Describe Get-Package {
    Context 'with no parameters' {
        It 'should return results' {
            Get-Package |
            Should -Not -BeNullOrEmpty
        }
    }

    Context 'with -Name parameter' {
        It 'should return Microsoft.Paint' {
            Get-Package -Name Microsoft.Paint |
            Should -Not -BeNullOrEmpty
        }
    }
}
