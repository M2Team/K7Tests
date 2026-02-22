param(
    [Parameter(Mandatory)]
    [string]$Program,
    [Parameter(Mandatory)]
    [string]$AssetsDir
)

BeforeDiscovery {
    Import-Module -Force "$PSScriptRoot/../helpers.psm1" -Verbose:$false
}

Describe "RPM extraction tests" -Tag "NanaZip" -ForEach @(
    @{ InputFile = "$AssetsDir/TestData/Rpm/Artificial-1.0-1.noarch.w9.gzdio.rpm" }
    @{ InputFile = "$AssetsDir/TestData/Rpm/Artificial-1.0-1.noarch.w9.bzdio.rpm" }
    @{ InputFile = "$AssetsDir/TestData/Rpm/Artificial-1.0-1.noarch.w9.lzdio.rpm" }
    @{ InputFile = "$AssetsDir/TestData/Rpm/Artificial-1.0-1.noarch.w9.xzdio.rpm" }
    @{ InputFile = "$AssetsDir/TestData/Rpm/Artificial-1.0-1.noarch.w19.zstdio.rpm" }
    @{ InputFile = "$AssetsDir/TestData/Rpm/Artificial-1.0-1.noarch.w0.ufdio.rpm" }
) {
    . $PSScriptRoot/../fixtures/testdir.ps1

    It "decompresses RPM packages" {
        Expand-7zArchive `
            -Program $Program `
            -CompressedFile "$InputFile" `
            -ExtractedDir "$TestDrive/extracted" `
            -Verbose:$VerbosePreference
        Compare-TestDirFile `
            -ExpectedDir "$AssetsDir/TestData/Artificial" `
            -ActualDir "$TestDrive/extracted"
    }
}
