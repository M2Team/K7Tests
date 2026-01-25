function Invoke-ShouldEqualFile {
    param(
        $ActualValue,
        $ExpectedValue,
        [switch]$Negate)

    $ExpectedHash = (Get-FileHash -Algorithm SHA256 $ExpectedValue).Hash
    $ActualHash = (Get-FileHash -Algorithm SHA256 $ActualValue).Hash

    if ($Negate) {
        return [pscustomobject]@{
            Succeeded      = $ExpectedHash -ine $ActualHash
            FailureMessage = "Expected file '$ActualValue' ($ActualHash) to not equal file '$ExpectedValue' ($ExpectedHash)"
        }
    }
    else {
        return [pscustomobject]@{
            Succeeded      = $ExpectedHash -ieq $ActualHash
            FailureMessage = "Expected file '$ActualValue' ($ActualHash) to equal file '$ExpectedValue' ($ExpectedHash)"
        }
    }
}

Add-ShouldOperator EqualFile -InternalName "Invoke-ShouldEqualFile" -Test ${Function:Invoke-ShouldEqualFile}

function Compress-7zArchive {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Program,
        [Parameter(Mandatory)]
        [string]$InputFile,
        [Parameter(Mandatory)]
        [string]$CompressedFile,
        [Parameter()]
        $CompressOptions = @(),
        [Parameter()]
        [int]$ExpectedExitCode = 0
    )

    $CompressArgs = @("a") + $CompressOptions + @(
        $CompressedFile
        $InputFile
    )

    Write-Verbose ((@($Program) + $CompressArgs) -join " ") -Verbose:$VerbosePreference

    $Output = & $Program @CompressArgs 2>&1
    $ExitCode = $LASTEXITCODE
    $Output | Write-Verbose -Verbose:$VerbosePreference
    $ExitCode | Should -Be $ExpectedExitCode
}

function Expand-7zArchive {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Program,
        [Parameter()]
        [switch]$WithFullPath,
        [Parameter(Mandatory)]
        [string]$CompressedFile,
        [Parameter(Mandatory)]
        [string]$ExtractedDir,
        [Parameter()]
        $ExpandOptions = @(),
        [Parameter()]
        [int]$ExpectedExitCode = 0
    )

    $Operation = if ($WithFullPath) { "x" } else { "e" }
    $ExpandArgs = @($Operation) + $ExpandOptions + @(
        $CompressedFile,
        "-o$ExtractedDir"
    )

    Write-Verbose ((@($Program) + $ExpandArgs) -join " ") -Verbose:$VerbosePreference

    $Output = & $Program @ExpandArgs 2>&1
    $ExitCode = $LASTEXITCODE
    $Output | Write-Verbose -Verbose:$VerbosePreference
    $ExitCode | Should -Be $ExpectedExitCode
}

function Invoke-Roundtrip {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Program,
        [Parameter(Mandatory)]
        [string]$InputFile,
        [Parameter(Mandatory)]
        [string]$CompressedFile,
        [Parameter(Mandatory)]
        [string]$ExtractedDir,
        [Parameter()]
        $CompressOptions = @(),
        [Parameter()]
        $ExpandOptions = @()
    )

    Compress-7zArchive `
        -Program $Program `
        -InputFile $InputFile `
        -CompressedFile $CompressedFile `
        -CompressOptions $CompressOptions `
        -Verbose:$VerbosePreference

    Expand-7zArchive `
        -Program $Program `
        -CompressedFile $CompressedFile `
        -ExtractedDir $ExtractedDir `
        -ExpandOptions $ExpandOptions `
        -Verbose:$VerbosePreference
}

function Compare-TestDirFile {
    param(
        [Parameter(Mandatory)]
        [string]$ExpectedDir,
        [Parameter(Mandatory)]
        [string]$ActualDir
    )

    Get-ChildItem $ExpectedDir | ForEach-Object {
        $Expected = Get-Item $_
        $Actual = Get-Item "$ActualDir/$($_.Name)"
        $Actual | Should -EqualFile $Expected
    }
}

function Compare-TestDirMtime {
    param(
        [Parameter(Mandatory)]
        [string]$ExpectedDir,
        [Parameter(Mandatory)]
        [string]$ActualDir
    )

    Get-ChildItem $ExpectedDir | ForEach-Object {
        $Expected = Get-Item $_
        $Actual = Get-Item "$ActualDir/$($_.Name)"

        $MtimeDiff = $Actual.LastWriteTime - $Expected.LastWriteTime
        $MtimeDiff | Should -BeLessThan ([timespan]::FromSeconds(1))
        $MtimeDiff | Should -BeGreaterThan ([timespan]::FromSeconds(-1))
    }
}

function Compare-TestDir {
    param(
        [Parameter(Mandatory)]
        [string]$ExpectedDir,
        [Parameter(Mandatory)]
        [string]$ActualDir
    )

    Compare-TestDirFile -ExpectedDir $ExpectedDir -ActualDir $ActualDir
    Compare-TestDirMtime -ExpectedDir $ExpectedDir -ActualDir $ActualDir
}
