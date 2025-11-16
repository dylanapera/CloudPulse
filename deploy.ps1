# CloudPulse Infrastructure Deployment
param(
    [string]$ResourceGroupName = "rg-cloudpulse-dev",
    [string]$Location = "australiaeast"
)

Write-Host "Deploying CloudPulse Infrastructure..." -ForegroundColor Cyan

# Create resource group
Write-Host "Creating resource group: $ResourceGroupName"
az group create --name $ResourceGroupName --location $Location

# SQL password (encrypted via .bicep secure keyword)
$adminPassword = Read-Host "Enter SQL admin password" -AsSecureString


# Deploy Bicep template
Write-Host "Deploying Bicep template..."
az deployment group create `
    --resource-group $ResourceGroupName `
    --template-file .\Infrastructure\main.bicep `

Write-Host "Deployment complete!" -ForegroundColor Green
