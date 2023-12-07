Describe 'Terraform Blog Demo Tests' -Tag 'integrationtest' {
    BeforeAll -ErrorAction Stop {
        $artifactDownloadPath = "$env:SYSTEM_DEFAULTWORKINGDIRECTORY"
        $artifactFilePath = Join-Path -Path $artifactDownloadPath -ChildPath "terraform.plan"

        if (Test-Path -Path $artifactFilePath) {
            try {
                $Plan = terraform show -json $artifactFilePath | ConvertFrom-Json
                $Variables = $Plan.Variables
                Write-Output "Extracted Variables: $Variables"
            } catch {
                Write-Error "Failed to parse the Terraform plan file."
            }
        } else {
            Write-Error "Terraform plan file not found at $artifactFilePath."
        }
    }

    Context 'Integration' -Tag Integration {
        BeforeAll {
            # Initialize Az module (if not already done)
            if (-not (Get-Module -Name Az -ListAvailable)) {
                Install-Module -Name Az -Force -AllowClobber -Scope CurrentUser
            }

           # Authenticating using service principal with client secret
            $securePassword = ConvertTo-SecureString -String $env:ARM_CLIENT_SECRET -AsPlainText -Force
            $credential = New-Object -TypeName PSCredential -ArgumentList ($env:ARM_CLIENT_ID, $securePassword)
            Connect-AzAccount -Credential $credential -TenantId $env:ARM_TENANT_ID -ServicePrincipal
        }

        # Integration tests for checking resource existence and properties
        It 'Will create and exist resource_group' {
            $resourceGroup = Get-AzResourceGroup -Name $Variables.resource_group_name.value -ErrorAction SilentlyContinue
            $resourceGroup | Should -Not -Be $null
        }

        It 'Will create and exist virtual_network' {
            $virtualNetwork = Get-AzVirtualNetwork -ResourceGroupName $Variables.resource_group_name.value -Name $Variables.vnet.value.name -ErrorAction SilentlyContinue
            $virtualNetwork | Should -Not -Be $null
        }

        It 'Will create and exist subnet' {
            $subnet = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork (Get-AzVirtualNetwork -ResourceGroupName $Variables.resource_group_name.value -Name $Variables.vnet.value.name) -Name $Variables.subnet.value.name -ErrorAction SilentlyContinue
            $subnet | Should -Not -Be $null
        }

        It 'Will create and exist virtual_machine' {
            $virtualMachine = Get-AzVM -ResourceGroupName $Variables.resource_group_name.value -Name $Variables.virtual_machine.value.name -ErrorAction SilentlyContinue
            $virtualMachine | Should -Not -Be $null
        }

        It 'Will create and exist network_interface' {
            $networkInterface = Get-AzNetworkInterface -ResourceGroupName $Variables.resource_group_name.value -Name $Variables.vm_nic.value.name -ErrorAction SilentlyContinue
            $networkInterface | Should -Not -Be $null
        }
    }
}
