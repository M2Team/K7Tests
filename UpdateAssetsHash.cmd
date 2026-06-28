@setlocal
@echo off

pushd "%~dp0Assets\"
set LC_ALL=C
MSYS2\find.exe 7-Zip/ Fuzzing/ MSYS2/ NanaZip/ TestData/ -type f -print | MSYS2\sort.exe | MSYS2\xargs.exe -d '\n' MSYS2\sha256sum.exe -t > Assets.sha256
popd

@endlocal