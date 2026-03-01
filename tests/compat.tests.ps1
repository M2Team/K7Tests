param(
    [Parameter(Mandatory)]
    [string]$Program,
    [Parameter(Mandatory)]
    [string]$AssetsDir
)

BeforeDiscovery {
    Import-Module -Force "$PSScriptRoot/../helpers.psm1" -Verbose:$false
}

Describe "regression tests" -ForEach @(
    @{ InputFile = "$AssetsDir/TestData/Executables" }
) {
    . $PSScriptRoot/../fixtures/testdir.ps1

    Context "with 7za" -Tag "Slow" -ForEach @(
        @{ SevenZipAlone = "$AssetsDir/7-Zip/7za920.exe"; MaxCompat = "920" }
        @{ SevenZipAlone = "$AssetsDir/7-Zip/7za1604x64.exe"; MaxCompat = "1604" }
        @{ SevenZipAlone = "$AssetsDir/7-Zip/7za1900x64.exe"; MaxCompat = "1900" }
        @{ SevenZipAlone = "$AssetsDir/7-Zip/7za2301x64.exe"; MaxCompat = "2301" }
        @{ SevenZipAlone = "$AssetsDir/7-Zip/7za2501x64.exe"; MaxCompat = "2501" }
        @{ SevenZipAlone = "$AssetsDir/7-Zip/7za2600x64.exe"; MaxCompat = "2600" }
    ) {
        It "decompresses old archives" -ForEach @(
            @{ Extension = ".zip" }
            @{ Extension = ".zip"; CompressOptions = @("-mm=Copy") }
            @{ Extension = ".zip"; CompressOptions = @("-mm=Deflate") }
            @{ Extension = ".zip"; CompressOptions = @("-mm=Deflate64") }
            @{ Extension = ".7z" }
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
            Compare-TestDir `
                -ExpectedDir "$InputFile" `
                -ActualDir "$TestDrive/extracted"
        }

        It "creates compatible archives" -ForEach @(
            @{ Extension = ".zip" }
            @{ Extension = ".zip"; CompressOptions = @("-mm=Copy") }
            @{ Extension = ".zip"; CompressOptions = @("-mm=Deflate") }
            @{ Extension = ".zip"; CompressOptions = @("-mm=Deflate64") }
            @{ Extension = ".7z" }
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
                -ExpandOptions $ExpandOptions `
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
                -ExpandOptions $ExpandOptions `
                -Verbose:$VerbosePreference
            Compare-TestDir `
                -ExpectedDir "$InputFile" `
                -ActualDir "$TestDrive/extracted"
        }
    }
}
