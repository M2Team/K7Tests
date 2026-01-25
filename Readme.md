K7Tests
=======

These tests require PowerShell 7. To start the tests:

```
.\run.ps1 -Program K7C.exe
```

You can specify `-Path`, `-Tag` and `-ExcludeTag` to limit the test suite.

To check the input files' integrity:

```
sha256sum -c inputs.sha256
```

To regenerate the input file SHA256 list (using an Unix shell):

```
find inputs/ -type f -print | sort | xargs -d '\n' sha256sum > inputs.sha256
```
