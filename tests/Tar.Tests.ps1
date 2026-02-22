param(
    [Parameter(Mandatory)]
    [string]$Program,
    [Parameter(Mandatory)]
    [string]$AssetsDir
)

BeforeDiscovery {
    Import-Module -Force "$PSScriptRoot/../helpers.psm1" -Verbose:$false
}

Describe "compressed tar tests" -Tag "NanaZip" -ForEach @(
    @{ InputFile = "$AssetsDir/TestData/Artificial" }
) {
    . $PSScriptRoot/../fixtures/testdir.ps1

    It "compresses and decompresses" -ForEach @(
        @{ Extension = ".tar.bz2"; Compressor = "bzip2" }
        @{ Extension = ".tbz"; Compressor = "bzip2" }
        @{ Extension = ".tar.gz"; Compressor = "gzip" }
        @{ Extension = ".tgz"; Compressor = "gzip" }
        @{ Extension = ".tlz4"; Compressor = "lz4" }
        @{ Extension = ".tar.lz4"; Compressor = "lz4" }
        @{ Extension = ".tlzma"; Compressor = "lzma" }
        @{ Extension = ".tar.lzma"; Compressor = "lzma" }
        @{ Extension = ".txz"; Compressor = "xz" }
        @{ Extension = ".tar.xz"; Compressor = "xz" }
        @{ Extension = ".tZ"; Compressor = "compress" }
        @{ Extension = ".tar.Z"; Compressor = "compress" }
        @{ Extension = ".tzst"; Compressor = "zstd" }
        @{ Extension = ".tar.zst"; Compressor = "zstd" }
    ) {
        $TarPath = "$AssetsDir/MSYS2/bsdtar.exe"
        $CompressedFile = "$TestDrive/compressed/test$Extension"
        $CompressArgs = @(
            "-c"
            "--$Compressor"
            "-f"
            $CompressedFile
            $InputFile
        )

        Write-Verbose ((@($TarPath) + $CompressArgs) -join " ") -Verbose:$VerbosePreference

        $Output = & $TarPath @CompressArgs 2>&1
        $ExitCode = $LASTEXITCODE
        $Output | Write-Verbose -Verbose:$VerbosePreference
        $ExitCode | Should -Be 0

        Expand-7zArchive `
            -Program $Program `
            -CompressedFile $CompressedFile `
            -ExtractedDir "$TestDrive/extracted" `
            -Verbose:$VerbosePreference
        Compare-TestDir `
            -ExpectedDir "$InputFile" `
            -ActualDir "$TestDrive/extracted"
    }
}
