param(
    [Parameter(Mandatory)]
    [string]$Program,
    [Parameter(Mandatory)]
    [string]$AssetsDir
)

BeforeDiscovery {
    Import-Module -Force "$PSScriptRoot/../helpers.psm1" -Verbose:$false
}

Describe "Fast-LZMA2 codec tests" -Tag "7-Zip-zstd" {
    . $PSScriptRoot/../fixtures/testdir.ps1

    It "compresses and decompresses the deadly sample" {
        # https://github.com/conor42/fast-lzma2/issues/9
        Invoke-Roundtrip `
            -Program $Program `
            -InputFile "$AssetsDir/TestData/hg19.fa.dk.bin" `
            -CompressedFile "$TestDrive/compressed/test.7z" `
            -ExtractedDir "$TestDrive/extracted" `
            -CompressOptions @("-m0=FLZMA2", "-mx=5") `
            -Verbose:$VerbosePreference
        Compare-TestDirFile `
            -ExpectedDir "$AssetsDir/TestData/hg19.fa.dk.bin" `
            -ActualDir "$TestDrive/extracted"
    }
}
