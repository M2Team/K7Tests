@setlocal
@echo off

pushd "%~dp0Assets\"
MSYS2\sha256sum.exe -c Assets.sha256
popd

@endlocal