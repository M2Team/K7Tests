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

Describe "operation tests" {
    . $PSScriptRoot/../fixtures/testdir.ps1

    It "adds to archive" -ForEach @(
        @{ Extension = ".zip"; CompressOptions = @() }
        @{ Extension = ".7z"; CompressOptions = @() }
        @{ Extension = ".wim"; CompressOptions = @() }
        @{ Extension = ".tar"; CompressOptions = @() }
        @{ Extension = ".cbz"; CompressOptions = @("-tzip") }
        @{ Extension = ".cb7"; CompressOptions = @("-t7z") }
    ) {
        Compress-7zArchive `
            -Program $Program `
            -InputFile "$InputDir/cantrbry/" `
            -CompressedFile "$TestDrive/compressed/test$Extension" `
            -CompressOptions $CompressOptions `
            -Verbose:$VerbosePreference
        Compress-7zArchive `
            -Program $Program `
            -InputFile "$InputDir/artificl/" `
            -CompressedFile "$TestDrive/compressed/test$Extension" `
            -CompressOptions $CompressOptions `
            -Verbose:$VerbosePreference
        Expand-7zArchive `
            -Program $Program `
            -WithFullPath `
            -CompressedFile "$TestDrive/compressed/test$Extension" `
            -ExtractedDir "$TestDrive/extracted" `
            -Verbose:$VerbosePreference
        Compare-TestDir `
            -ExpectedDir "$InputDir/cantrbry" `
            -ActualDir "$TestDrive/extracted/cantrbry"
        Compare-TestDir `
            -ExpectedDir "$InputDir/artificl" `
            -ActualDir "$TestDrive/extracted/artificl"
    }

    It "deletes from archive" -ForEach @(
        @{ Extension = ".zip"; CompressOptions = @() }
        @{ Extension = ".7z"; CompressOptions = @() }
        @{ Extension = ".wim"; CompressOptions = @() }
        @{ Extension = ".tar"; CompressOptions = @() }
        @{ Extension = ".cbz"; CompressOptions = @("-tzip") }
        @{ Extension = ".cb7"; CompressOptions = @("-t7z") }
    ) {
        Compress-7zArchive `
            -Program $Program `
            -InputFile "$InputDir/cantrbry/" `
            -CompressedFile "$TestDrive/compressed/test$Extension" `
            -CompressOptions $CompressOptions `
            -Verbose:$VerbosePreference
        & $Program d "$TestDrive/compressed/test$Extension" "cantrbry/*.html"
        & $Program d "$TestDrive/compressed/test$Extension" "cantrbry/*.xls" -r
        Expand-7zArchive `
            -Program $Program `
            -CompressedFile "$TestDrive/compressed/test$Extension" `
            -ExtractedDir "$TestDrive/extracted" `
            -Verbose:$VerbosePreference
        "$TestDrive/extracted/cantrbry/cp.html" | Should -Not -Exist
        "$TestDrive/extracted/cantrbry/kennedy.xls" | Should -Not -Exist
    }

    It "renames archive member" -ForEach @(
        @{ Extension = ".zip"; CompressOptions = @() }
        @{ Extension = ".7z"; CompressOptions = @() }
        @{ Extension = ".wim"; CompressOptions = @() }
        @{ Extension = ".tar"; CompressOptions = @() }
        @{ Extension = ".cbz"; CompressOptions = @("-tzip") }
        @{ Extension = ".cb7"; CompressOptions = @("-t7z") }
    ) {
        Compress-7zArchive `
            -Program $Program `
            -InputFile "$InputDir/cantrbry/" `
            -CompressedFile "$TestDrive/compressed/test$Extension" `
            -CompressOptions $CompressOptions `
            -Verbose:$VerbosePreference
        & $Program rn "$TestDrive/compressed/test$Extension" "cantrbry/cp.html" "cantrbry/cp.html.1"
        & $Program rn "$TestDrive/compressed/test$Extension" "cantrbry/kennedy.xls" "folder/kennedy.zip"
        Expand-7zArchive `
            -Program $Program `
            -WithFullPath `
            -CompressedFile "$TestDrive/compressed/test$Extension" `
            -ExtractedDir "$TestDrive/extracted" `
            -Verbose:$VerbosePreference
        "$TestDrive/extracted/cantrbry/cp.html" | Should -Not -Exist
        "$TestDrive/extracted/cantrbry/cp.html.1" | Should -Exist
        "$TestDrive/extracted/cantrbry/kennedy.xls" | Should -Not -Exist
        "$TestDrive/extracted/folder/kennedy.zip" | Should -Exist
    }
}
