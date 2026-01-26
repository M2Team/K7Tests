# NanaZip Test Suite (K7Tests)

Test suite for NanaZip and related functionalities.

## Usage


> [!NOTE]
> These tests require PowerShell 7 or later.
> Also, Pester should be installed, use `Install-Module -Name Pester -Force` if
> you have not install it for your PowerShell instance.

To start the tests:

```
.\run.ps1 -Program K7C.exe
```

You can specify `-Path`, `-Tag` and `-ExcludeTag` to limit the test suite.

Use `VerifyAssetsHash.cmd` to check the third-party binaries integrity.

Use `UpdateAssetsHash.cmd` to regenerate the third-party binaries SHA256 list.
