#Requires -Version 7

[CmdletBinding()]
param(
    [Parameter()]
    [ValidateSet("", "None", "Normal", "Detailed", "Diagnostic")]
    [string]$Verbosity,
    [Parameter()]
    [string]$NanaZip = "NanaZipC",
    [Parameter()]
    [string[]]$Path = @("$PSScriptRoot/tests"),
    [Parameter()]
    [string[]]$Tag,
    [Parameter()]
    [string[]]$ExcludeTag
)

$ErrorActionPreference = "Stop"

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
    NanaZip  = $NanaZip
    InputDir = "$PSScriptRoot/inputs"
}
$Config.Run.Container = $Container
Invoke-Pester -Configuration $Config
