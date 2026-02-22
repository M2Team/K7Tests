param(
    [Parameter(Mandatory)]
    [string]$Program,
    [Parameter(Mandatory)]
    [string]$AssetsDir
)

BeforeDiscovery {
    Import-Module -Force "$PSScriptRoot/../helpers.psm1" -Verbose:$false
}

Describe "DEB extraction tests" -Tag "NanaZip" -ForEach @(
    @{ InputFile = "$AssetsDir/TestData/Deb/Artificial-gzip.deb" }
    @{ InputFile = "$AssetsDir/TestData/Deb/Artificial-xz.deb" }
    @{ InputFile = "$AssetsDir/TestData/Deb/Artificial-zstd.deb" }
    @{ InputFile = "$AssetsDir/TestData/Deb/Artificial-none.deb" }
) {
    . $PSScriptRoot/../fixtures/testdir.ps1

    It "decompresses DEB packages" {
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
