@setlocal
@echo off

pushd "%~dp0"
MSYS2\find.exe 7-Zip/ MSYS2/ -type f -print | MSYS2\sort.exe | MSYS2\xargs.exe -d '\n' MSYS2\sha256sum.exe -t > Assets.sha256
popd

@endlocal