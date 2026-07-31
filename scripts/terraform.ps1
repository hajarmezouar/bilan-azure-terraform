[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("fmt", "init", "validate", "plan", "apply", "output")]
    [string]$Action
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$RepositoryRoot = Split-Path -Parent $PSScriptRoot
$TerraformDirectory = Join-Path $RepositoryRoot "terraform/environments/nonprod"
$PlanDirectory = Join-Path $RepositoryRoot ".plans"
$PlanFile = Join-Path $PlanDirectory "nonprod.tfplan"

function Assert-Command {
    param([Parameter(Mandatory = $true)][string]$Name)

    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Required command '$Name' was not found."
    }
}

function Get-ActiveSubscriptionId {
    Assert-Command "az"

    $SubscriptionId = az account show --query id --output tsv

    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($SubscriptionId)) {
        throw "Azure authentication is unavailable. Run 'az login' and select the assigned subscription."
    }

    return $SubscriptionId.Trim()
}

function Invoke-Terraform {
    param([Parameter(Mandatory = $true)][string[]]$Arguments)

    & terraform "-chdir=$TerraformDirectory" @Arguments

    if ($LASTEXITCODE -ne 0) {
        throw "Terraform command failed: terraform $($Arguments -join ' ')"
    }
}

Assert-Command "terraform"

switch ($Action) {
    "fmt" {
        & terraform fmt -recursive $RepositoryRoot

        if ($LASTEXITCODE -ne 0) {
            throw "Terraform formatting failed."
        }
    }
    "init" {
        Invoke-Terraform @("init", "-input=false")
    }
    "validate" {
        Invoke-Terraform @("validate")
    }
    "plan" {
        $SubscriptionId = Get-ActiveSubscriptionId
        New-Item -ItemType Directory -Path $PlanDirectory -Force | Out-Null

        Invoke-Terraform @(
            "plan",
            "-input=false",
            "-var=subscription_id=$SubscriptionId",
            "-out=$PlanFile"
        )
    }
    "apply" {
        if (-not (Test-Path -LiteralPath $PlanFile -PathType Leaf)) {
            throw "Saved plan not found at '$PlanFile'. Run 'make terraform-plan' and review it before applying."
        }

        Invoke-Terraform @("apply", "-input=false", $PlanFile)
    }
    "output" {
        Invoke-Terraform @("output")
    }
}
