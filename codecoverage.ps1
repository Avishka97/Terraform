$config = New-PesterConfiguration
$config.Run.Path = "$(System.DefaultWorkingDirectory)/TERRAFORM.TESTS.PS1"
$config.CodeCoverage.Enabled = $true
Invoke-Pester -Configuration $config
