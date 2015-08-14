<#
.SYNOPSIS
Creates Storage Container

.DESCRIPTION
This script creates a new resource group if it does not already exist. It uses ARM tempplate to create storage accounts
in this resource group

.PARAMETER ResourceGroupName
The name of the resource group to use.

.PARAMETER Location
The location of the resource group

.PARAMETER ParametersFile

.EXAMPLE
.\deploy.ps1 -ResourceGroupName ARM-Dev -Location "West US" -ParametersFile .\storageaccts-dev.json
#>

Param
(
    [Parameter (Mandatory = $true)]
    [string] $ResourceGroupName,

    [Parameter (Mandatory = $true)]
    [string] $Location,

    [Parameter (Mandatory = $true)]
    [string] $ParametersFile
)

#publish version of the the powershell cmdlets we are using
(Get-Module Azure).Version

$rg = Get-AzureResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue

if (!$rg)
{
    # Create a new storage account
    Write-Output "";
    Write-Output "Creating Resource Group [$ResourceGroupName] in location [$Location]"


    New-AzureResourceGroup -Name "$ResourceGroupName" -Force -Location $Location -ErrorVariable errorVariable -ErrorAction SilentlyContinue | Out-Null

    if (!($?)) 
    { 
        throw "Cannot create new Resource Group [$ResourceGroupName] in region [$Location]. Error Detail: $errorVariable" 
    }
     
    Write-Output "Resource Group [$ResourceGroupName] was created"  
    
}
else
{
    Write-Output "Resource Group [$ResourceGroupName] already exists"
}

New-AzureResourceGroupDeployment -Name stgdeployment -ResourceGroupName $ResourceGroupName -TemplateFile .\createstorageaccts.json -TemplateParameterFile $ParametersFile