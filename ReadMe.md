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

## Test tags

The following tags are used by K7Tests:

- `7-Zip-zstd`: Tests that use codecs and features specific to 7-Zip-zstd;
- `NanaZip`: Tests that use codecs and features specific to NanaZip;
- `Output`: Tests that parse command line output and may not work with K7G.exe
  or with non-English locales;
- `Slow`: Tests that take a long time to execute relative to other tests.
