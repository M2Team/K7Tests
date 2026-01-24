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

function Invoke-Roundtrip {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$NanaZip,
        [Parameter(Mandatory)]
        [string]$InputFile,
        [Parameter(Mandatory)]
        [string]$CompressedFile,
        [Parameter(Mandatory)]
        [string]$ExtractedDir,
        [Parameter(Mandatory)]
        $CompressOptions
    )

    $CompressArgs = @("a") + $CompressOptions + @(
        $CompressedFile
        $InputFile
    )

    Write-Verbose ((@($NanaZip) + $CompressArgs) -join " ") -Verbose:$VerbosePreference

    $Output = & $NanaZip @CompressArgs 2>&1
    $ExitCode = $LASTEXITCODE
    $Output | Write-Verbose -Verbose:$VerbosePreference
    $ExitCode | Should -Be 0

    $Output = & $NanaZip e $CompressedFile "-o$ExtractedDir" 2>&1
    $ExitCode = $LASTEXITCODE
    $Output | Write-Verbose -Verbose:$VerbosePreference
    $ExitCode | Should -Be 0
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
