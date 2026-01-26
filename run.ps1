#Requires -Version 7

[CmdletBinding()]
param(
    [Parameter()]
    [ValidateSet("", "None", "Normal", "Detailed", "Diagnostic")]
    [string]$Verbosity,
    [Parameter()]
    [string]$Program = "NanaZipC",
    [Parameter()]
    [string[]]$Path = @("$PSScriptRoot/tests"),
    [Parameter()]
    [string[]]$Tag,
    [Parameter()]
    [string[]]$ExcludeTag
)

function Install-ModuleWithSuitableVersion {
    param(
        [Parameter(Mandatory)]
        [string]$ModuleName,
        [Parameter(Mandatory)]
        [version]$MinimumVersion
    )

    $Module = Get-Module -ListAvailable -Name $ModuleName |
        Where-Object { $_.Version -ge $MinimumVersion } |
        Sort-Object Version -Descending |
        Select-Object -First 1
    if (-not $Module) {
        $RepoName = 'PSGallery'
        $OriginalPolicy = $null
        $RepoPolicyChanged = $false
        try {
            $Repo = Get-PSRepository -Name $RepoName -ErrorAction SilentlyContinue
            if ($null -ne $Repo -and $Repo.InstallationPolicy -ne 'Trusted') {
                $OriginalPolicy = $Repo.InstallationPolicy
                Set-PSRepository -Name $RepoName -InstallationPolicy Trusted
                $RepoPolicyChanged = $true
            }

            Install-Module -Name $ModuleName -MinimumVersion $MinimumVersion -Force
        }
        finally {
            if ($RepoPolicyChanged) {
                Set-PSRepository -Name $RepoName -InstallationPolicy $OriginalPolicy
            }
        }
    }
}

$ErrorActionPreference = "Stop"

$Policies = Get-ItemProperty `
    -ErrorAction SilentlyContinue `
    -LiteralPath HKLM:\SOFTWARE\Policies\M2Team\NanaZip
if ($null -ne $Policies.AllowedHandlers ||
    $null -ne $Policies.BlockedHandlers ||
    $null -ne $Policies.AllowedCodecs ||
    $null -ne $Policies.BlockedCodecs) {
    throw "Detected handler/codec policies, aborting"
}

Install-ModuleWithSuitableVersion -ModuleName Pester -MinimumVersion 5.0.0
Import-Module Pester -MinimumVersion 5.0.0 -Verbose:$false

$Config = New-PesterConfiguration
if ($Verbosity) {
    $Config.Output.Verbosity = $Verbosity
}
if ($Tag.Length) {
    $Config.Filter.Tag = $Tag
}
if ($ExcludeTag.Length) {
    $Config.Filter.ExcludeTag = $ExcludeTag
}

$Container = New-PesterContainer -Path $Path -Data @{
    Program  = $Program
    AssetsDir = "$PSScriptRoot/Assets"
}
$Config.Run.Container = $Container
Invoke-Pester -Configuration $Config
