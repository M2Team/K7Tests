@setlocal
@echo off

pushd "%~dp0"
MSYS2\sha256sum.exe -c Assets.sha256
popd

@endlocal