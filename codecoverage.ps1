$config = New-PesterConfiguration
$config.Run.Path = "$env:SYSTEM_DEFAULTWORKINGDIRECTORY/TERRAFORM.TESTS.PS1"
$config.CodeCoverage.Enabled = $true
$config.Output.Verbosity = "Detailed"
Invoke-Pester -Configuration $config
