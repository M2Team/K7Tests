param(
    [Parameter(Mandatory)]
    [string]$NanaZip,
    [Parameter(Mandatory)]
    [string]$InputDir
)

BeforeDiscovery {
    Import-Module -Force "$PSScriptRoot/../helpers.psm1" -Verbose:$false
}

Describe "Fast-LZMA2 codec tests" -Tag "7-Zip-zstd" {
    . $PSScriptRoot/../fixtures/testdir.ps1

    It "compresses and decompresses the deadly sample" {
        # https://github.com/conor42/fast-lzma2/issues/9
        Invoke-Roundtrip `
            -Program $NanaZip `
            -InputFile "$InputDir/hg19.fa.dk.bin" `
            -CompressedFile "$TestDrive/compressed/test.7z" `
            -ExtractedDir "$TestDrive/extracted" `
            -CompressOptions @("-m0=FLZMA2", "-mx=5") `
            -Verbose:$VerbosePreference
        Compare-TestDirFile `
            -ExpectedDir "$InputDir/hg19.fa.dk.bin" `
            -ActualDir "$TestDrive/extracted"
    }
}
