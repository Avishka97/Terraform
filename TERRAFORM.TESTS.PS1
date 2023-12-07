Describe 'Terraform Blog Demo Tests' -Tag 'unittest' {
    BeforeAll -ErrorAction Stop {
    $artifactDownloadPath = "$env:SYSTEM_DEFAULTWORKINGDIRECTORY" # Replace 'artifactName' with the actual name of your artifact
    $artifactFilePath = Join-Path -Path $artifactDownloadPath -ChildPath "terraform.plan"

    # Check if the file exists before attempting to parse it
    if (Test-Path -Path $artifactFilePath) {
        try {
            # Parse plan file and pull out provided variables
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


 Context 'Unit' -Tag Unit {
        BeforeAll {
            $ResourceGroupAddress  = 'azurerm_resource_group.main'
            $VirtualNetworkAddress = 'azurerm_virtual_network.main'
            $VmsSubnetAddress      = 'azurerm_subnet.internal'
            $VirtualMachineAddress = 'azurerm_windows_virtual_machine.main'
            $VmNicAddress          = 'azurerm_network_interface.main'

            $ResourceGroupPlan  = ($Plan.resource_changes | Where-Object { $_.address -eq $ResourceGroupAddress })[0]
            $VirtualNetworkPlan = ($Plan.resource_changes | Where-Object { $_.address -eq $VirtualNetworkAddress })[0]
            $VmsSubnetPlan      = ($Plan.resource_changes | Where-Object { $_.address -eq $VmsSubnetAddress})[0]
            $VirtualMachinePlan = ($Plan.resource_changes | Where-Object { $_.address -eq $VirtualMachineAddress})[0]
            $VmNicPlan          = ($Plan.resource_changes | Where-Object { $_.address -eq $VmNicAddress})[0]
        }

         #Region Resource Group Tests
        It 'Will create resource_group' {            
            $ResourceGroupPlan.change.actions[0] | Should -Be 'create'
        }
        
        It 'Will create resource_group with correct name' {
            Write-Host "ResourceGroupPlan : $ResourceGroupPlan.change.after.name"
            Write-Host "Variables: $Variables.resource_group_name.value"            

            $ResourceGroupPlan.change.after.name | Should -Be $Variables.resource_group_name.value
        }
        
        It 'Will create resource_group in correct region' {
            $ResourceGroupPlan.change.after.location | Should -Be $Variables.location.value
        }
        #EndRegion Resource Group Tests

        #Region Virtual Network Tests
        It 'Will create virtual_network' {
            $VirtualNetworkPlan.change.actions[0] | Should -Be 'create'
        }
        
        It 'Will create virtual_network in correct region' {
            $VirtualNetworkPlan.change.after.location | Should -Be $Variables.location.value
        }

        It 'Will create virtual_network with correct address_space' {
            $VirtualNetworkPlan.change.after.address_space | Should -Be $Variables.vnet.value.address_space
        }

        It 'Will create virtual_network in correct resource group' {
            $VirtualNetworkPlan.change.after.resource_group_name | Should -Be $Variables.resource_group_name.value
        }
        #EndRegion Virtual Network Tests

        #Region Vms Subnet Tests
        It 'Will create subnet' {
            $VmsSubnetPlan.change.actions[0] | Should -Be 'create'
        }

        It 'Will assign correct subnet IP Range' {
            $VariableAddressPrefixes = $Variables.subnet.value.vms.address_prefixes
            $VmsSubnetPlan.change.after.address_prefixes | Should -Be $VariableAddressPrefixes
        }
        #EndRegion Vms Subnet Tests

        #Region Virtual Machine Tests
        It 'Will create vm' {
            $VirtualMachinePlan.change.actions[0] | Should -Be 'create'
        }

        It 'Will create vm in correct resource group' {
            $VirtualMachinePlan.change.after.resource_group_name | Should -Be $Variables.resource_group_name.value
        }

        It 'Will create vm in correct region' {
            $VirtualMachinePlan.change.after.location | Should -Be $Variables.location.value
        }

        It 'Will assign vm correct administrator username' {
            $VirtualMachinePlan.change.after.admin_username | Should -Be $Variables.admin_username.value
        }

        It 'Will assign vm correct administrator password' {
            $VirtualMachinePlan.change.after.admin_password | Should -Be $Variables.admin_password.value
        }

        #EndRegion Virtual Machine Tests

        #Region NIC Tests        
        It 'Will create vm_nic' {
            $VmNicPlan.change.actions[0] | Should -Be 'create'
        }

        It 'Will create vm_nic in correct resource group' {
            $VmNicPlan.change.after.resource_group_name | Should -Be $Variables.resource_group_name.value
        }

        It 'Will create vm_nic in correct region' {
            $VmNicPlan.change.after.location | Should -Be $Variables.location.value
        }

        It 'Will assign dynamic address allocation' {
            $VmNicPlan.change.after.ip_configuration.private_ip_address_allocation | Should -Be 'dynamic'
        }

        It 'Will assign an IPv4 address to vm_nic' {
            $VmNicPlan.change.after.ip_configuration.private_ip_address_version | Should -Be 'IPv4'
        }
        #EndRegion NIC Tests

    }
}





Pester Integration Test Script

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

