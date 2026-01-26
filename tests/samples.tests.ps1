param(
    [Parameter(Mandatory)]
    [string]$Program,
    [Parameter(Mandatory)]
    [string]$AssetsDir
)

BeforeDiscovery {
    Import-Module -Force "$PSScriptRoot/../helpers.psm1" -Verbose:$false
}

Describe "NanaZip-specific container tests" -Tag "NanaZip" {
    . $PSScriptRoot/../fixtures/testdir.ps1

    It "parses the archive" -ForEach @(
        @{ InputFile = "$AssetsDir/TestData/NanaZip.Tests.Samples/Electron.Sample.asar" }
        # @{ InputFile = "$AssetsDir/TestData/NanaZip.Tests.Samples/ROMFS.Sample.img" }
        @{ InputFile = "$AssetsDir/TestData/NanaZip.Tests.Samples/WebAssembly.Sample.wasm" }
        @{ InputFile = "$AssetsDir/TestData/NanaZip.Tests.Samples/ZealFS.V1.Sample.img" }
    ) {
        $Output = & $Program t $InputFile 2>&1
        $ExitCode = $LASTEXITCODE
        $Output | Write-Verbose -Verbose:$VerbosePreference
        $ExitCode | Should -Be 0
    }
}
