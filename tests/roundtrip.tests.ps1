param(
    [Parameter(Mandatory)]
    [string]$NanaZip,
    [Parameter(Mandatory)]
    [string]$InputDir
)

BeforeDiscovery {
    Import-Module -Force "$PSScriptRoot/../helpers.psm1" -Verbose:$false
}

Describe "roundtrip container tests" -ForEach @(
    @{ InputFile = "$InputDir/cantrbry" }
    @{ InputFile = "$InputDir/artificl" }
) {
    . $PSScriptRoot/../fixtures/testdir.ps1

    It "compresses and decompresses zip" -ForEach @(
        @{ CompressOptions = @() }
        @{ CompressOptions = @("-mm=Copy") }
        @{ CompressOptions = @("-mm=Deflate") }
        @{ CompressOptions = @("-mm=Deflate64") }
        @{ CompressOptions = @("-mm=BZip2") }
        @{ CompressOptions = @("-mm=LZMA") }
        @{ CompressOptions = @("-mm=PPMd") }
    ) {
        Invoke-Roundtrip `
            -NanaZip $NanaZip `
            -InputFile "$InputFile/*" `
            -CompressedFile "$TestDrive/compressed/test.zip" `
            -ExtractedDir "$TestDrive/extracted" `
            -CompressOptions $CompressOptions `
            -Verbose:$VerbosePreference
        Compare-TestDirFile `
            -ExpectedDir "$InputFile" `
            -ActualDir "$TestDrive/extracted"
        Compare-TestDirMtime `
            -ExpectedDir "$InputFile" `
            -ActualDir "$TestDrive/extracted"
    }

    It "compresses and decompresses zip (zstd)" -Tag "7-Zip-zstd" -ForEach @(
        @{ CompressOptions = @("-mm=zstd") }
    ) {
        Invoke-Roundtrip `
            -NanaZip $NanaZip `
            -InputFile "$InputFile/*" `
            -CompressedFile "$TestDrive/compressed/test.zip" `
            -ExtractedDir "$TestDrive/extracted" `
            -CompressOptions $CompressOptions `
            -Verbose:$VerbosePreference
        Compare-TestDirFile `
            -ExpectedDir "$InputFile" `
            -ActualDir "$TestDrive/extracted"
        Compare-TestDirMtime `
            -ExpectedDir "$InputFile" `
            -ActualDir "$TestDrive/extracted"
    }

    It "compresses and decompresses 7z" -ForEach @(
        @{ CompressOptions = @() }
        @{ CompressOptions = @("-m0=LZMA") }
        @{ CompressOptions = @("-m0=LZMA2") }
        @{ CompressOptions = @("-m0=PPMd") }
        @{ CompressOptions = @("-m0=BZip2") }
        @{ CompressOptions = @("-m0=Deflate") }
        @{ CompressOptions = @("-m0=Copy") }
    ) {
        Invoke-Roundtrip `
            -NanaZip $NanaZip `
            -InputFile "$InputFile/*" `
            -CompressedFile "$TestDrive/compressed/test.7z" `
            -ExtractedDir "$TestDrive/extracted" `
            -CompressOptions $CompressOptions `
            -Verbose:$VerbosePreference
        Compare-TestDirFile `
            -ExpectedDir "$InputFile" `
            -ActualDir "$TestDrive/extracted"
        Compare-TestDirMtime `
            -ExpectedDir "$InputFile" `
            -ActualDir "$TestDrive/extracted"
    }

    It "compresses and decompresses 7z (7-Zip ZS)" -Tag "7-Zip-zstd" -ForEach @(
        @{ CompressOptions = @("-m0=FLZMA2") }
        @{ CompressOptions = @("-m0=zstd") }
        @{ CompressOptions = @("-m0=Brotli") }
        @{ CompressOptions = @("-m0=LZ4") }
        @{ CompressOptions = @("-m0=LZ5") }
        @{ CompressOptions = @("-m0=Lizard") }
    ) {
        Invoke-Roundtrip `
            -NanaZip $NanaZip `
            -InputFile "$InputFile/*" `
            -CompressedFile "$TestDrive/compressed/test.7z" `
            -ExtractedDir "$TestDrive/extracted" `
            -CompressOptions $CompressOptions `
            -Verbose:$VerbosePreference
        Compare-TestDirFile `
            -ExpectedDir "$InputFile" `
            -ActualDir "$TestDrive/extracted"
        Compare-TestDirMtime `
            -ExpectedDir "$InputFile" `
            -ActualDir "$TestDrive/extracted"
    }

    It "compresses and decompresses wim" {
        Invoke-Roundtrip `
            -NanaZip $NanaZip `
            -InputFile "$InputFile/*" `
            -CompressedFile "$TestDrive/compressed/test.wim" `
            -ExtractedDir "$TestDrive/extracted" `
            -CompressOptions @() `
            -Verbose:$VerbosePreference
        Compare-TestDirFile `
            -ExpectedDir "$InputFile" `
            -ActualDir "$TestDrive/extracted"
        Compare-TestDirMtime `
            -ExpectedDir "$InputFile" `
            -ActualDir "$TestDrive/extracted"
    }

    It "compresses and decompresses tar" -ForEach @(
        @{ CompressOptions = @("-mm=gnu") }
        @{ CompressOptions = @("-mm=pax") }
        @{ CompressOptions = @("-mm=posix") }
    ) {
        Invoke-Roundtrip `
            -NanaZip $NanaZip `
            -InputFile "$InputFile/*" `
            -CompressedFile "$TestDrive/compressed/test.tar" `
            -ExtractedDir "$TestDrive/extracted" `
            -CompressOptions $CompressOptions `
            -Verbose:$VerbosePreference
        Compare-TestDirFile `
            -ExpectedDir "$InputFile" `
            -ActualDir "$TestDrive/extracted"
        Compare-TestDirMtime `
            -ExpectedDir "$InputFile" `
            -ActualDir "$TestDrive/extracted"
    }
}
