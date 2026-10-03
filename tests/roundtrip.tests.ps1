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
    . $PSScriptRoot/../fixtures/roundtrip.ps1

    It "compresses and decompresses" -ForEach $Roundtrip {
        Test-Roundtrip `
            -Extension $Extension `
            -CompressOptions $CompressOptions `
            -ExpandOptions $ExpandOptions
    }

    It "compresses and decompresses (extended)" -Tag "Slow" -ForEach $RoundtripSlow {
        Test-Roundtrip `
            -Extension $Extension `
            -CompressOptions $CompressOptions `
            -ExpandOptions $ExpandOptions
    }
}
