param(
    [Parameter(Mandatory)]
    [string]$NanaZip,
    [Parameter(Mandatory)]
    [string]$InputDir
)

BeforeDiscovery {
    Import-Module -Force "$PSScriptRoot/../helpers.psm1" -Verbose:$false
}

Describe "NanaZip-specific container tests" -Tag "NanaZip" {
    . $PSScriptRoot/../fixtures/testdir.ps1

    It "parses the archive" -ForEach @(
        @{ InputFile = "$InputDir/NanaZip.Tests.Samples/Electron.Sample.asar" }
        # @{ InputFile = "$InputDir/NanaZip.Tests.Samples/ROMFS.Sample.img" }
        @{ InputFile = "$InputDir/NanaZip.Tests.Samples/WebAssembly.Sample.wasm" }
        @{ InputFile = "$InputDir/NanaZip.Tests.Samples/ZealFS.V1.Sample.img" }
    ) {
        $Output = & $NanaZip t $InputFile 2>&1
        $ExitCode = $LASTEXITCODE
        $Output | Write-Verbose -Verbose:$VerbosePreference
        $ExitCode | Should -Be 0
    }
}
