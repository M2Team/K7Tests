param(
    [Parameter(Mandatory)]
    [string]$Program,
    [Parameter(Mandatory)]
    [string]$InputDir,
    [Parameter(Mandatory)]
    [string]$BinDir
)

BeforeDiscovery {
    Import-Module -Force "$PSScriptRoot/../helpers.psm1" -Verbose:$false
}

Describe "regression tests" -ForEach @(
    @{ InputFile = "$InputDir/executables" }
) {
    . $PSScriptRoot/../fixtures/testdir.ps1

    Context "with 7za" -Tag "slow" -ForEach @(
        @{ SevenZipAlone = "$BinDir/7za920.exe"; MaxCompat = "920" }
        @{ SevenZipAlone = "$BinDir/7za1604x64.exe"; MaxCompat = "1604" }
        @{ SevenZipAlone = "$BinDir/7za1900x64.exe"; MaxCompat = "1900" }
        @{ SevenZipAlone = "$BinDir/7za2301x64.exe"; MaxCompat = "2301" }
        @{ SevenZipAlone = "$BinDir/7za2501x64.exe"; MaxCompat = "2501" }
    ) {
        It "decompresses old archives" -ForEach @(
            @{ Extension = ".zip"; CompressOptions = @() }
            @{ Extension = ".zip"; CompressOptions = @("-mm=Copy") }
            @{ Extension = ".zip"; CompressOptions = @("-mm=Deflate") }
            @{ Extension = ".zip"; CompressOptions = @("-mm=Deflate64") }
            @{ Extension = ".7z"; CompressOptions = @() }
            @{ Extension = ".7z"; CompressOptions = @("-m0=LZMA") }
            @{ Extension = ".7z"; CompressOptions = @("-m0=LZMA2") }
            @{ Extension = ".7z"; CompressOptions = @("-m0=Copy") }
        ) {
            Compress-7zArchive `
                -Program $SevenZipAlone `
                -InputFile "$InputFile/*" `
                -CompressedFile "$TestDrive/compressed/test$Extension" `
                -CompressOptions $CompressOptions `
                -Verbose:$VerbosePreference
            Expand-7zArchive `
                -Program $Program `
                -CompressedFile "$TestDrive/compressed/test$Extension" `
                -ExtractedDir "$TestDrive/extracted" `
                -Verbose:$VerbosePreference
            Compare-TestDirFile `
                -ExpectedDir "$InputFile" `
                -ActualDir "$TestDrive/extracted"
            Compare-TestDirMtime `
                -ExpectedDir "$InputFile" `
                -ActualDir "$TestDrive/extracted"
        }

        It "creates compatible archives" -ForEach @(
            @{ Extension = ".zip"; CompressOptions = @() }
            @{ Extension = ".zip"; CompressOptions = @("-mm=Copy") }
            @{ Extension = ".zip"; CompressOptions = @("-mm=Deflate") }
            @{ Extension = ".zip"; CompressOptions = @("-mm=Deflate64") }
            @{ Extension = ".7z"; CompressOptions = @() }
            @{ Extension = ".7z"; CompressOptions = @("-m0=LZMA") }
            @{ Extension = ".7z"; CompressOptions = @("-m0=LZMA2") }
            @{ Extension = ".7z"; CompressOptions = @("-m0=Copy") }
        ) {
            $CompatOptions = $CompressOptions
            if ($Extension -eq ".7z") {
                # enable all filters, but keep compatibility
                $CompatOptions += @("-myx=9", "-myv=$MaxCompat")
            }
            Compress-7zArchive `
                -Program $Program `
                -InputFile "$InputFile/*" `
                -CompressedFile "$TestDrive/compressed/test$Extension" `
                -CompressOptions $CompatOptions `
                -Verbose:$VerbosePreference
            Expand-7zArchive `
                -Program $SevenZipAlone `
                -CompressedFile "$TestDrive/compressed/test$Extension" `
                -ExtractedDir "$TestDrive/extracted" `
                -Verbose:$VerbosePreference
            Compare-TestDir `
                -ExpectedDir "$InputFile" `
                -ActualDir "$TestDrive/extracted"
        }
    }

    Context "selftest" {
        It "is compatible with itself" {
            Compress-7zArchive `
                -Program $Program `
                -InputFile "$InputFile/*" `
                -CompressedFile "$TestDrive/compressed/test.7z" `
                -CompressOptions @("-myx=9", "-myv=9999") `
                -Verbose:$VerbosePreference
            Expand-7zArchive `
                -Program $Program `
                -CompressedFile "$TestDrive/compressed/test.7z" `
                -ExtractedDir "$TestDrive/extracted" `
                -Verbose:$VerbosePreference
            Compare-TestDir `
                -ExpectedDir "$InputFile" `
                -ActualDir "$TestDrive/extracted"
        }
    }
}
