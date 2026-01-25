param(
    [Parameter(Mandatory)]
    [string]$Program,
    [Parameter(Mandatory)]
    [string]$InputDir,
    [Parameter()]
    [string]$BinDir
)

BeforeDiscovery {
    Import-Module -Force "$PSScriptRoot/../helpers.psm1" -Verbose:$false
}

Describe "roundtrip container tests" -ForEach @(
    @{ InputFile = "$InputDir/cantrbry" }
    @{ InputFile = "$InputDir/artificl" }
) {
    . $PSScriptRoot/../fixtures/testdir.ps1

    It "compresses and decompresses" -ForEach @(
        @{ Extension = ".zip" }
        @{ Extension = ".zip"; CompressOptions = @("-mm=Copy") }
        @{ Extension = ".zip"; CompressOptions = @("-mm=Deflate") }
        @{ Extension = ".zip"; CompressOptions = @("-mm=Deflate64") }
        @{ Extension = ".zip"; CompressOptions = @("-mm=BZip2") }
        @{ Extension = ".zip"; CompressOptions = @("-mm=LZMA") }
        @{ Extension = ".zip"; CompressOptions = @("-mm=PPMd") }
        @{ Extension = ".7z" }
        @{ Extension = ".7z"; CompressOptions = @("-m0=LZMA") }
        @{ Extension = ".7z"; CompressOptions = @("-m0=LZMA2") }
        @{ Extension = ".7z"; CompressOptions = @("-m0=PPMd") }
        @{ Extension = ".7z"; CompressOptions = @("-m0=BZip2") }
        @{ Extension = ".7z"; CompressOptions = @("-m0=Deflate") }
        @{ Extension = ".7z"; CompressOptions = @("-m0=Copy") }
        @{ Extension = ".wim" }
        @{ Extension = ".tar" }
        @{ Extension = ".tar"; CompressOptions = @("-mm=gnu") }
        @{ Extension = ".tar"; CompressOptions = @("-mm=pax") }
        @{ Extension = ".tar"; CompressOptions = @("-mm=posix") }
    ) {
        Invoke-Roundtrip `
            -Program $Program `
            -InputFile "$InputFile/*" `
            -CompressedFile "$TestDrive/compressed/test$Extension" `
            -ExtractedDir "$TestDrive/extracted" `
            -CompressOptions $CompressOptions `
            -ExpandOptions $ExpandOptions `
            -Verbose:$VerbosePreference
        Compare-TestDir `
            -ExpectedDir "$InputFile" `
            -ActualDir "$TestDrive/extracted"
    }

    It "compresses and decompresses (7-Zip-zstd)" -Tag "7-Zip-zstd" -ForEach @(
        @{ Extension = ".zip"; CompressOptions = @("-mm=zstd") }
        @{ Extension = ".7z"; CompressOptions = @("-m0=FLZMA2") }
        @{ Extension = ".7z"; CompressOptions = @("-m0=zstd") }
        @{ Extension = ".7z"; CompressOptions = @("-m0=Brotli") }
        @{ Extension = ".7z"; CompressOptions = @("-m0=LZ4") }
        @{ Extension = ".7z"; CompressOptions = @("-m0=LZ5") }
        @{ Extension = ".7z"; CompressOptions = @("-m0=Lizard") }
    ) {
        Invoke-Roundtrip `
            -Program $Program `
            -InputFile "$InputFile/*" `
            -CompressedFile "$TestDrive/compressed/test$Extension" `
            -ExtractedDir "$TestDrive/extracted" `
            -CompressOptions $CompressOptions `
            -ExpandOptions $ExpandOptions `
            -Verbose:$VerbosePreference
        Compare-TestDir `
            -ExpectedDir "$InputFile" `
            -ActualDir "$TestDrive/extracted"
    }
}
