# NanaZip Test Suite (K7Tests)

Test suite for NanaZip and related functionalities.

## Usage

These tests require PowerShell 7 and Pester. To start the tests:

```
.\run.ps1 -Program K7C.exe
```

You can specify `-Path`, `-Tag` and `-ExcludeTag` to limit the test suite.

Use `VerifyAssetsHash.cmd` to check the third-party binaries integrity.

Use `UpdateAssetsHash.cmd` to regenerate the third-party binaries SHA256 list.
