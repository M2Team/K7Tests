K7Tests
=======

These tests require PowerShell 7. To start the tests:

```
.\run.ps1 -Program K7C.exe
```

To regenerate the input SHA256 list:

```
find inputs/ -type f -print | sort | xargs -d '\n' sha256sum > inputs.sha256
```

To check the inputs:

```
sha256sum -c inputs.sha256
```
