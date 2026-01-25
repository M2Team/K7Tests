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

Describe "operation tests" @(
    @{ Extension = ".zip" }
    @{ Extension = ".7z" }
    @{ Extension = ".wim" }
    @{ Extension = ".tar" }
    @{ Extension = ".cbz"; CompressOptions = @("-tzip") }
    @{ Extension = ".cb7"; CompressOptions = @("-t7z") }
) {
    . $PSScriptRoot/../fixtures/testdir.ps1

    It "adds to archive" -ForEach {
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
            -ExpandOptions $ExpandOptions `
            -Verbose:$VerbosePreference
        Compare-TestDir `
            -ExpectedDir "$InputDir/cantrbry" `
            -ActualDir "$TestDrive/extracted/cantrbry"
        Compare-TestDir `
            -ExpectedDir "$InputDir/artificl" `
            -ActualDir "$TestDrive/extracted/artificl"
    }

    It "deletes from archive" {
        Compress-7zArchive `
            -Program $Program `
            -InputFile "$InputDir/cantrbry/" `
            -CompressedFile "$TestDrive/compressed/test$Extension" `
            -CompressOptions $CompressOptions `
            -Verbose:$VerbosePreference
        & $Program d "$TestDrive/compressed/test$Extension" "cantrbry/*.html"
        & $Program d "$TestDrive/compressed/test$Extension" "*.xls" -r
        Expand-7zArchive `
            -Program $Program `
            -CompressedFile "$TestDrive/compressed/test$Extension" `
            -ExtractedDir "$TestDrive/extracted" `
            -ExpandOptions $ExpandOptions `
            -Verbose:$VerbosePreference
        "$TestDrive/extracted/cantrbry/cp.html" | Should -Not -Exist
        "$TestDrive/extracted/cantrbry/kennedy.xls" | Should -Not -Exist
    }

    It "renames archive member" {
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
            -ExpandOptions $ExpandOptions `
            -Verbose:$VerbosePreference
        "$TestDrive/extracted/cantrbry/cp.html" | Should -Not -Exist
        "$TestDrive/extracted/cantrbry/cp.html.1" | Should -Exist
        "$TestDrive/extracted/cantrbry/kennedy.xls" | Should -Not -Exist
        "$TestDrive/extracted/folder/kennedy.zip" | Should -Exist
    }

    It "updates archive" -ForEach {
        Compress-7zArchive `
            -Program $Program `
            -InputFile "$InputDir/artificl/*" `
            -CompressedFile "$TestDrive/compressed/test$Extension" `
            -CompressOptions $CompressOptions `
            -Verbose:$VerbosePreference
        Push-Location "$TestDrive/scratch"
        try {
            Copy-Item "$InputDir/cantrbry/alice29.txt" "random.txt" -Force
            & $Program u "$TestDrive/compressed/test$Extension" "random.txt"
        }
        finally {
            Pop-Location
        }
        Expand-7zArchive `
            -Program $Program `
            -CompressedFile "$TestDrive/compressed/test$Extension" `
            -ExtractedDir "$TestDrive/extracted" `
            -ExpandOptions $ExpandOptions `
            -Verbose:$VerbosePreference
        "$TestDrive/extracted/random.txt" | `
            Should -EqualFile "$InputDir/cantrbry/alice29.txt"
    }
}
