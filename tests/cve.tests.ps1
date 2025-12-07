param(
    [Parameter(Mandatory)]
    [string]$NanaZip,
    [Parameter(Mandatory)]
    [string]$InputDir
)

BeforeDiscovery {
    Import-Module -Force "$PSScriptRoot/../helpers.psm1" -Verbose:$false
}

Describe "CVE tests" {
    . $PSScriptRoot/../fixtures/testdir.ps1

    It "is immune to CVE-2024-11477" {
        $Output = & $NanaZip x "$InputDir/CVE-2024-11477.zstd" "-o$TestDrive/extracted" 2>&1
        $ExitCode = $LASTEXITCODE
        $Output | Write-Verbose -Verbose:$VerbosePreference
        $ExitCode | Should -Be 2 -Because "2 means extraction error is handled"
    }

    Context "CVE-2025-11011" {
        BeforeEach {
            # This value is baked into the test data and cannot be changed.
            $DroppedFile = "C:\Users\Public\Documents\CVE-2025-11001.txt"
            # The prepared CVE-2025-11011 payload creates a file at $DroppedFile.
            # Since this test involves a path outside of TestDrive, it requires
            # some extra scrutiny when it comes to the test environment prep, to
            # avoid false negatives if the destination path is not writable.
            Remove-Item $DroppedFile -Force -ErrorAction SilentlyContinue
            $DroppedFile | Should -Not -Exist -Because "test path should be clean"
            New-Item -ItemType File -Path $DroppedFile
            $DroppedFile | Should -Exist -Because "test directory should be writable"
            Remove-Item $DroppedFile -Force
            $DroppedFile | Should -Not -Exist -Because "test path should be clean"
        }

        AfterEach {
            Remove-Item $DroppedFile -Force -ErrorAction SilentlyContinue
        }

        It "is immune to CVE-2025-11011" {
            $Output = & $NanaZip x "$InputDir/CVE-2025-11001.zip" "-o$TestDrive/extracted" 2>&1
            $Output | Write-Verbose -Verbose:$VerbosePreference

            $DroppedFile | Should -Not -Exist
        }
    }

    It "is immune to CVE-2025-55188" {
        $Output = & $NanaZip x "$InputDir/CVE-2025-55188.tar" "-o$TestDrive/extracted" 2>&1
        $Output | Write-Verbose -Verbose:$VerbosePreference

        (Get-Item TestDrive:/extracted/link).Target | Should -Not -BeLike "..*"
    }
}
