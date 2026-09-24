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
    function Test-XxhsumHash {
        param(
            [Parameter(Mandatory)]
            [string]$File,
            [Parameter(Mandatory)]
            [string]$Algorithm,
            [Parameter(Mandatory)]
            [string]$ReferenceAlgorithm
        )

        Write-Verbose "Algorithm = $Algorithm, ReferenceAlgorithm = $ReferenceAlgorithm"
        Write-Verbose "File = $File"

        $Expected = & "$AssetsDir/Hashes/xxhsum.exe" $ReferenceAlgorithm $File
        $LASTEXITCODE | Should -Be 0
        $Expected -match "([a-f0-9]+)  .*" | Should -BeTrue
        $Expected = $Matches[1]

        $Output = & $Program h "-scrc$Algorithm" -slfh -ba -bd $File 2>&1
        $ExitCode = $LASTEXITCODE
        $Output | Write-Verbose -Verbose:$VerbosePreference

        $ExitCode | Should -Be 0
        $Output | Should -Be $Expected
    }

    function Test-OpensslHash {
        param(
            [Parameter(Mandatory)]
            [string]$File,
            [Parameter(Mandatory)]
            [string]$Algorithm,
            [Parameter(Mandatory)]
            [string]$ReferenceAlgorithm
        )

        Write-Verbose "Algorithm = $Algorithm, ReferenceAlgorithm = $ReferenceAlgorithm"
        Write-Verbose "File = $File"

        $Expected = & "$AssetsDir/OpenSSL/openssl.exe" dgst "-$ReferenceAlgorithm" $File
        $LASTEXITCODE | Should -Be 0
        $Expected -match ".*= ([a-f0-9]+)" | Should -BeTrue
        $Expected = $Matches[1]

        $Output = & $Program h "-scrc$Algorithm" -slfh -ba -bd $File 2>&1
        $ExitCode = $LASTEXITCODE
        $Output | Write-Verbose -Verbose:$VerbosePreference

        $ExitCode | Should -Be 0
        $Output | Should -Be $Expected
    }
}

Describe "hash tests" -ForEach @(
    foreach ($File in (Get-ChildItem -Path "$AssetsDir/TestData/Canterbury" -File -Recurse)) {
        @{ File = $File }
    }
    foreach ($File in (Get-ChildItem -Path "$AssetsDir/TestData/Artificial" -File -Recurse)) {
        @{ File = $File }
    }
) {
    . $PSScriptRoot/../fixtures/testdir.ps1

    It "matches xxhsum hashes" -ForEach @(
        @{ Algorithm = "XXH64"; ReferenceAlgorithm = "-H1" }
    ) {
        Test-XxhsumHash `
            -File $File `
            -Algorithm $Algorithm `
            -ReferenceAlgorithm $ReferenceAlgorithm
    }

    It "matches xxhsum hashes (ZS)" -Tag "7-Zip-zstd" -ForEach @(
        @{ Algorithm = "XXH32"; ReferenceAlgorithm = "-H0" }
    ) {
        Test-XxhsumHash `
            -File $File `
            -Algorithm $Algorithm `
            -ReferenceAlgorithm $ReferenceAlgorithm
    }

    It "matches xxhsum hashes (NanaZip)" -Tag "NanaZip" -ForEach @(
        @{ Algorithm = "XXH3_128bits"; ReferenceAlgorithm = "-H2" }
        @{ Algorithm = "XXH3_64bits"; ReferenceAlgorithm = "-H3" }
    ) {
        Test-XxhsumHash `
            -File $File `
            -Algorithm $Algorithm `
            -ReferenceAlgorithm $ReferenceAlgorithm
    }

    It "matches openssl hashes" -ForEach @(
        @{ Algorithm = "MD5"; ReferenceAlgorithm = "MD5" }
        @{ Algorithm = "SHA1"; ReferenceAlgorithm = "SHA1" }
        @{ Algorithm = "SHA256"; ReferenceAlgorithm = "SHA256" }
        @{ Algorithm = "SHA384"; ReferenceAlgorithm = "SHA384" }
        @{ Algorithm = "SHA512"; ReferenceAlgorithm = "SHA512" }
        @{ Algorithm = "SHA3-256"; ReferenceAlgorithm = "SHA3-256" }
    ) {
        Test-OpensslHash `
            -File $File `
            -Algorithm $Algorithm `
            -ReferenceAlgorithm $ReferenceAlgorithm
    }

    It "matches openssl hashes (ZS)" -Tag "7-Zip-zstd" -ForEach @(
        @{ Algorithm = "SHA3-384"; ReferenceAlgorithm = "SHA3-384" }
        @{ Algorithm = "SHA3-512"; ReferenceAlgorithm = "SHA3-512" }
    ) {
        Test-OpensslHash `
            -File $File `
            -Algorithm $Algorithm `
            -ReferenceAlgorithm $ReferenceAlgorithm
    }

    It "matches openssl hashes (NanaZip)" -Tag "NanaZip" -ForEach @(
        @{ Algorithm = "SM3"; ReferenceAlgorithm = "SM3" }
        @{ Algorithm = "BLAKE2b"; ReferenceAlgorithm = "BLAKE2b512" }
        @{ Algorithm = "RIPEMD-160"; ReferenceAlgorithm = "RIPEMD-160" }
        @{ Algorithm = "SHA224"; ReferenceAlgorithm = "SHA224" }
        @{ Algorithm = "SHA3-224"; ReferenceAlgorithm = "SHA3-224" }
    ) {
        Test-OpensslHash `
            -File $File `
            -Algorithm $Algorithm `
            -ReferenceAlgorithm $ReferenceAlgorithm
    }
}
