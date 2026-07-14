#Requires -Version 7

[CmdletBinding()]
param(
    [Parameter()]
    [ValidateSet("", "None", "Normal", "Detailed", "Diagnostic")]
    [string]$Verbosity,
    [Parameter()]
    [string]$Program = "NanaZipC",
    [Parameter(Position = 0)]
    [string[]]$Path = @("$PSScriptRoot/tests"),
    [Parameter()]
    [string[]]$Tag,
    [Parameter()]
    [string[]]$ExcludeTag
)

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
    Program   = $Program
    AssetsDir = "$PSScriptRoot/Assets"
}
$Config.Run.Container = $Container
Invoke-Pester -Configuration $Config
