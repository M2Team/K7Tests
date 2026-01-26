param(
    [Parameter(Mandatory)]
    [string]$Program,
    [Parameter(Mandatory)]
    [string]$AssetsDir
)

BeforeDiscovery {
    Import-Module -Force "$PSScriptRoot/../helpers.psm1" -Verbose:$false
}

Describe "operation tests" -ForEach @(
    @{ Extension = ".zip" }
    @{ Extension = ".7z" }
    @{ Extension = ".wim" }
    @{ Extension = ".tar" }
    @{ Extension = ".cbz"; CompressOptions = @("-tzip") }
    @{ Extension = ".cb7"; CompressOptions = @("-t7z") }
) {
    . $PSScriptRoot/../fixtures/testdir.ps1

    It "adds to archive" {
        Compress-7zArchive `
            -Program $Program `
            -InputFile "$AssetsDir/TestData/Canterbury/" `
            -CompressedFile "$TestDrive/compressed/test$Extension" `
            -CompressOptions $CompressOptions `
            -Verbose:$VerbosePreference
        Compress-7zArchive `
            -Program $Program `
            -InputFile "$AssetsDir/TestData/Artificial/" `
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
            -ExpectedDir "$AssetsDir/TestData/Canterbury" `
            -ActualDir "$TestDrive/extracted/Canterbury"
        Compare-TestDir `
            -ExpectedDir "$AssetsDir/TestData/Artificial" `
            -ActualDir "$TestDrive/extracted/Artificial"
    }

    It "deletes from archive" {
        Compress-7zArchive `
            -Program $Program `
            -InputFile "$AssetsDir/TestData/Canterbury/" `
            -CompressedFile "$TestDrive/compressed/test$Extension" `
            -CompressOptions $CompressOptions `
            -Verbose:$VerbosePreference
        & $Program d "$TestDrive/compressed/test$Extension" "Canterbury/*.html"
        & $Program d "$TestDrive/compressed/test$Extension" "*.xls" -r
        Expand-7zArchive `
            -Program $Program `
            -CompressedFile "$TestDrive/compressed/test$Extension" `
            -ExtractedDir "$TestDrive/extracted" `
            -ExpandOptions $ExpandOptions `
            -Verbose:$VerbosePreference
        "$TestDrive/extracted/Canterbury/cp.html" | Should -Not -Exist
        "$TestDrive/extracted/Canterbury/kennedy.xls" | Should -Not -Exist
    }

    It "renames archive member" {
        Compress-7zArchive `
            -Program $Program `
            -InputFile "$AssetsDir/TestData/Canterbury/" `
            -CompressedFile "$TestDrive/compressed/test$Extension" `
            -CompressOptions $CompressOptions `
            -Verbose:$VerbosePreference
        & $Program rn "$TestDrive/compressed/test$Extension" "Canterbury/cp.html" "Canterbury/cp.html.1"
        & $Program rn "$TestDrive/compressed/test$Extension" "Canterbury/kennedy.xls" "folder/kennedy.zip"
        Expand-7zArchive `
            -Program $Program `
            -WithFullPath `
            -CompressedFile "$TestDrive/compressed/test$Extension" `
            -ExtractedDir "$TestDrive/extracted" `
            -ExpandOptions $ExpandOptions `
            -Verbose:$VerbosePreference
        "$TestDrive/extracted/Canterbury/cp.html" | Should -Not -Exist
        "$TestDrive/extracted/Canterbury/cp.html.1" | Should -Exist
        "$TestDrive/extracted/Canterbury/kennedy.xls" | Should -Not -Exist
        "$TestDrive/extracted/folder/kennedy.zip" | Should -Exist
    }

    It "updates archive" {
        Compress-7zArchive `
            -Program $Program `
            -InputFile "$AssetsDir/TestData/Artificial/*" `
            -CompressedFile "$TestDrive/compressed/test$Extension" `
            -CompressOptions $CompressOptions `
            -Verbose:$VerbosePreference
        Push-Location "$TestDrive/scratch"
        try {
            Copy-Item "$AssetsDir/TestData/Canterbury/alice29.txt" "random.txt" -Force
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
            Should -EqualFile "$AssetsDir/TestData/Canterbury/alice29.txt"
    }
}
