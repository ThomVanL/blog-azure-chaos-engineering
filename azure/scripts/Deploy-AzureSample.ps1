<#
.SYNOPSIS
    Deploys the sample to Azure.

.DESCRIPTION
    Deploys the sample to Azure.

.EXAMPLE
    PS C:\> .\Deploy-AzureSample.ps1
#>
[CmdletBinding()]
param (
)

#Requires -Modules @{ ModuleName="Az"; ModuleVersion="4.6.1" }
#Requires -Version 7

if (!(Get-AzContext)) {
    Connect-AzAccount
}

$context = Get-AzContext
if ($context) {
    $templateFile = Join-Path -Path $PSScriptRoot -ChildPath ".."  -AdditionalChildPath "template", "azuredeploy.json"
    $templateParametersFile = Join-Path -Path $PSScriptRoot -ChildPath ".."  -AdditionalChildPath "template", "azuredeploy.parameters.json"
    Write-Host -ForegroundColor Yellow "🚀 Starting subscription level deployment.."
    New-AzDeployment -Name "thomasvanlaere.com-Blog-Azure-Chaos-Engineering" -TemplateFile $templateFile -TemplateParameterFile $templateParametersFile -Location "westeurope" -Verbose

    $newSp = New-AzADServicePrincipal -Scope "/subscriptions/$($context.Subscription.Id)" -Role "Contributor" -DisplayName "thomasvanlaere.com-Blog-Azure-Chaos-Engineering" -ErrorVariable newSpError
    if (!$newSpError) {
        $newSpSecret = ConvertFrom-SecureString -SecureString $newSp.Secret -AsPlainText
        Write-Host = "Service principal - client ID: $($newSp.ApplicationId)"
        Write-Host = "Service principal - client secret: $($newSpSecret)"
    }
    else {
        Write-Error "❗️ Could not create service principal!"
    }
}
else {
    Write-Error -Message "Not connected to Azure."
}
