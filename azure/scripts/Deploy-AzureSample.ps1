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
    $deployment = New-AzDeployment -Name "thomasvanlaere.com-Blog-Azure-Chaos-Engineering" -TemplateFile $templateFile -TemplateParameterFile $templateParametersFile -Location "westeurope" -Verbose

    if ($deployment.Outputs){
        Write-Host -ForegroundColor Yellow "👉 Trigger website A.."
        Invoke-WebRequest -Uri ("https://{0}" -f $deployment.Outputs["regionAAppServiceUrl"].Value)
        Write-Host -ForegroundColor Yellow "👉 Trigger website B.."
        Invoke-WebRequest -Uri ("https://{0}" -f $deployment.Outputs["regionBAppServiceUrl"].Value)
    } else {
        Write-Warning -Message "No ARM template outputs found."
    }

    Write-Host -ForegroundColor Yellow "👉 Creating Azure AD Service Principal.."
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
