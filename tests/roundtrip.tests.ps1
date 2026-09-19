param(
    [Parameter(Mandatory)]
    [string]$Program,
    [Parameter(Mandatory)]
    [string]$AssetsDir
)

BeforeDiscovery {
    Import-Module -Force "$PSScriptRoot/../helpers.psm1" -Verbose:$false
}

BeforeAll {
    function Test-Roundtrip {
        param(
            [Parameter(Mandatory)]
            [string]$Extension,
            [Parameter()]
            $CompressOptions = @(),
            [Parameter()]
            $ExpandOptions = @()
        )

        Write-Verbose "Extension = $Extension"
        if ($CompressOptions) {
            Write-Verbose "CompressOptions = $CompressOptions"
        }
        if ($ExpandOptions) {
            Write-Verbose "ExpandOptions = $ExpandOptions"
        }
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

Describe "roundtrip container tests" -ForEach @(
    @{ InputFile = "$AssetsDir/TestData/Canterbury" }
    @{ InputFile = "$AssetsDir/TestData/Artificial" }
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
        @{ Extension = ".zip"; CompressOptions = @("-psecret"); ExpandOptions = @("-psecret") }
        @{ Extension = ".7z"; CompressOptions = @("-psecret"); ExpandOptions = @("-psecret") }
        @{ Extension = ".cbz"; CompressOptions = @("-tzip", "-psecret"); ExpandOptions = @("-psecret") }
        @{ Extension = ".cb7"; CompressOptions = @("-t7z", "-psecret"); ExpandOptions = @("-psecret") }
    ) {
        Test-Roundtrip `
            -Extension $Extension `
            -CompressOptions $CompressOptions `
            -ExpandOptions $ExpandOptions
    }

    It "compresses and decompresses (extended)" -Tag "Slow" -ForEach @(
        foreach ($CompressionLevel in 0, 1, 3, 5, 7, 9) {
            @{ Extension = ".zip"; CompressOptions = @("-mx=$CompressionLevel") }
        }
        foreach ($FastBytes in 3, 32, 258) {
            @{ Extension = ".zip"; CompressOptions = @("-mm=Deflate", "-mfb=$FastBytes") }
        }
        foreach ($FastBytes in 3, 32, 257) {
            @{ Extension = ".zip"; CompressOptions = @("-mm=Deflate64", "-mfb=$FastBytes") }
        }
        foreach ($Passes in 1, 5, 15) {
            @{ Extension = ".zip"; CompressOptions = @("-mm=Deflate", "-mpass=$Passes") }
        }
        foreach ($DictionarySize in "16", "100000b", "900k", "1m") {
            @{ Extension = ".zip"; CompressOptions = @("-mm=BZip2", "-md=$DictionarySize") }
        }
        foreach ($Passes in 1, 5, 10) {
            @{ Extension = ".zip"; CompressOptions = @("-mm=BZip2", "-mpass=$Passes") }
        }
        foreach ($MemorySize in "20", "256m") {
            @{ Extension = ".zip"; CompressOptions = @("-mm=PPMd", "-mmem=$MemorySize") }
        }
        foreach ($Order in 2, 8, 16) {
            @{ Extension = ".zip"; CompressOptions = @("-mm=PPMd", "-mo=$Order") }
        }
        foreach ($Threads in "off", "on", "1", "2") {
            @{ Extension = ".zip"; CompressOptions = @("-mmt=$Threads") }
        }
        foreach ($EncryptionMethod in "ZipCrypto", "AES128", "AES192", "AES256") {
            @{ Extension = ".zip"; CompressOptions = @("-mem=$EncryptionMethod", "-psecret"); ExpandOptions = @("-psecret") }
        }
        foreach ($CompressionLevel in 0..9) {
            @{ Extension = ".7z"; CompressOptions = @("-mx=$CompressionLevel") }
        }
        foreach ($AnalysisLevel in 0, 1, 3, 5, 7, 9) {
            @{ Extension = ".7z"; CompressOptions = @("-myx=$AnalysisLevel") }
        }
        foreach ($CompatibilityVersion in "1600", "2300", "9999") {
            @{ Extension = ".7z"; CompressOptions = @("-myv=$CompatibilityVersion") }
        }
        foreach ($Filter in "Delta", "BCJ", "BCJ2", "ARM64", "ARM", "ARMT", "RISCV", "IA64", "PPC", "SPARC") {
            @{ Extension = ".7z"; CompressOptions = @("-myfa=$Filter") }
            @{ Extension = ".7z"; CompressOptions = @("-myfd=$Filter") }
        }
        foreach ($MemoryLimit in "p60", "256m", "1g") {
            @{ Extension = ".7z"; CompressOptions = @("-mmemuse=$MemoryLimit") }
        }
        foreach ($SolidMode in "off", "on", "1f", "1m") {
            @{ Extension = ".7z"; CompressOptions = @("-ms=$SolidMode") }
        }
        @{ Extension = ".7z"; CompressOptions = @("-ms=e", "-mqs=on") }
        foreach ($SortByType in "off", "on") {
            @{ Extension = ".7z"; CompressOptions = @("-mqs=$SortByType") }
        }
        foreach ($Filter in "off", "on", "Delta:1", "BCJ", "BCJ2", "ARM64", "ARM", "ARMT", "RISCV", "IA64", "PPC", "SPARC") {
            @{ Extension = ".7z"; CompressOptions = @("-mf=$Filter") }
        }
        foreach ($SectionSize in "1m", "9m", "32m") {
            @{ Extension = ".7z"; CompressOptions = @("-mf=BCJ2:d=$SectionSize") }
        }
        foreach ($CompressHeaders in "off", "on") {
            @{ Extension = ".7z"; CompressOptions = @("-mhc=$CompressHeaders") }
        }
        foreach ($EncryptHeaders in "off", "on") {
            @{ Extension = ".7z"; CompressOptions = @("-mhe=$EncryptHeaders", "-psecret"); ExpandOptions = @("-psecret") }
        }
        @{ Extension = ".7z"; CompressOptions = @("-m0=BCJ2", "-m1=LZMA:d=21", "-m2=LZMA:d=19", "-m3=LZMA:d=19", "-mb0:1", "-mb0s1:2", "-mb0s2:3") }
        foreach ($Threads in "off", "on", "1", "2") {
            @{ Extension = ".7z"; CompressOptions = @("-mmt=$Threads") }
        }
        foreach ($FilterThreads in "off", "on") {
            @{ Extension = ".7z"; CompressOptions = @("-mmtf=$FilterThreads") }
        }
        foreach ($Mode in 0, 1) {
            @{ Extension = ".7z"; CompressOptions = @("-m0=LZMA:a=$Mode") }
            @{ Extension = ".7z"; CompressOptions = @("-m0=LZMA2:a=$Mode") }
        }
        foreach ($DictionarySize in "64k", "1m", "32m") {
            @{ Extension = ".7z"; CompressOptions = @("-m0=LZMA:d=$DictionarySize") }
            @{ Extension = ".7z"; CompressOptions = @("-m0=LZMA2:d=$DictionarySize") }
        }
        foreach ($MatchFinder in "bt2", "bt3", "bt4", "bt5", "hc4", "hc5") {
            @{ Extension = ".7z"; CompressOptions = @("-m0=LZMA:mf=$MatchFinder") }
            @{ Extension = ".7z"; CompressOptions = @("-m0=LZMA2:mf=$MatchFinder") }
        }
        foreach ($FastBytes in 5, 32, 273) {
            @{ Extension = ".7z"; CompressOptions = @("-m0=LZMA:fb=$FastBytes") }
            @{ Extension = ".7z"; CompressOptions = @("-m0=LZMA2:fb=$FastBytes") }
        }
        foreach ($MatchFinderCycles in 0, 32, 256) {
            @{ Extension = ".7z"; CompressOptions = @("-m0=LZMA:mc=$MatchFinderCycles") }
            @{ Extension = ".7z"; CompressOptions = @("-m0=LZMA2:mc=$MatchFinderCycles") }
        }
        foreach ($LiteralContextBits in 0, 3, 8) {
            @{ Extension = ".7z"; CompressOptions = @("-m0=LZMA:lc=$LiteralContextBits") }
        }
        foreach ($LiteralContextBits in 0, 3, 4) {
            @{ Extension = ".7z"; CompressOptions = @("-m0=LZMA2:lc=$LiteralContextBits") }
        }
        foreach ($LiteralPositionBits in 0, 2, 4) {
            @{ Extension = ".7z"; CompressOptions = @("-m0=LZMA:lc=0:lp=$LiteralPositionBits") }
            @{ Extension = ".7z"; CompressOptions = @("-m0=LZMA2:lc=0:lp=$LiteralPositionBits") }
        }
        foreach ($PositionBits in 0, 2, 4) {
            @{ Extension = ".7z"; CompressOptions = @("-m0=LZMA:pb=$PositionBits") }
            @{ Extension = ".7z"; CompressOptions = @("-m0=LZMA2:pb=$PositionBits") }
        }
        foreach ($ChunkSize in "1m", "4m", "16m") {
            @{ Extension = ".7z"; CompressOptions = @("-m0=LZMA2:d=1m:c=$ChunkSize") }
        }
        foreach ($MemorySize in "20", "16m", "64m") {
            @{ Extension = ".7z"; CompressOptions = @("-m0=PPMd:mem=$MemorySize") }
        }
        foreach ($Order in 2, 6, 32) {
            @{ Extension = ".7z"; CompressOptions = @("-m0=PPMd:o=$Order") }
        }
        foreach ($DeltaOffset in 1, 4, 256) {
            @{ Extension = ".7z"; CompressOptions = @("-m0=Delta:$DeltaOffset", "-m1=LZMA2") }
        }
    ) {
        Test-Roundtrip `
            -Extension $Extension `
            -CompressOptions $CompressOptions `
            -ExpandOptions $ExpandOptions
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
        Test-Roundtrip `
            -Extension $Extension `
            -CompressOptions $CompressOptions `
            -ExpandOptions $ExpandOptions
    }
}
