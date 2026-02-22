# NanaZip Test Suite (K7Tests) Binary Assets

## 7-Zip

7-Zip is a file archiver with a high compression ratio.

Read https://www.7-zip.org for more information.

We use 7-Zip command line binaries of various versions and architectures.

### Contents used in NanaZip Test Suite (K7Tests)

- 7za920.exe from 7za.exe in https://www.7-zip.org/a/7za920.zip
- 7za1604x64.exe from x64/7za.exe in https://www.7-zip.org/a/7z1604-extra.7z
- 7za1900x64.exe from x64/7za.exe in https://www.7-zip.org/a/7z1900-extra.7z
- 7za2301x64.exe from x64/7za.exe in https://www.7-zip.org/a/7z2301-extra.7z
- 7za2501x64.exe from x64/7za.exe in https://www.7-zip.org/a/7z2501-extra.7z
- 7za2600x64.exe from x64/7za.exe in https://www.7-zip.org/a/7z2600-extra.7z
- 7za2601x64.exe from x64/7za.exe in https://www.7-zip.org/a/7z2601-extra.7z

## Fuzzing

Set of fuzzing corpora and dictionaries for NanaZip-specific formats, prepared
by Jaroslav Lobačevski.

For use with special fuzzing-enabled builds of NanaZip.

## MSYS2

MSYS2 is a collection of tools and libraries providing you with an easy-to-use
environment for building, installing and running native Windows software.

Read https://www.msys2.org for more information.

Due to MSYS2 is huge, we only include x64 binaries of some useful commands.

### Contents used in NanaZip Test Suite (K7Tests)

Links:
- https://github.com/msys2/msys2-installer/releases/download/2025-12-13/msys2-base-x86_64-20251213.tar.xz
- https://mirror.msys2.org/msys/x86_64/bsdtar-3.8.5-1-x86_64.pkg.tar.zst

Here are the commands included in this repository:

- find
- sha256sum
- sort
- xargs
- bsdtar
- gzip

## TestData/Artificial

Taken from https://corpus.canterbury.ac.nz/resources/artificl.zip.

Read https://corpus.canterbury.ac.nz for more information.

## TestData/Canterbury

Taken from https://corpus.canterbury.ac.nz/resources/cantrbry.zip

Read https://corpus.canterbury.ac.nz for more information.

## TestData/Executables/7z*

7-Zip executables taken from historical releases:
https://www.7-zip.org/download.html

## TestData/Executables/Ping*.efi

Taken from the EDK2 UDK 2017:
https://github.com/tianocore/edk2/releases/tag/vUDK2017

## TestData/Executables/rufus-4.6_arm.exe

The Rufus 4.6 ARM binary: https://github.com/pbatard/rufus/releases/tag/v4.6

## TestData/Executables/sudo-*.exe

Binaries of Debian's Sudo package, renamed with .exe extension to force enable
the analysis of file data and the use of compression filters:
https://packages.debian.org/sid/sudo

## TestData/NanaZip.Codecs.Samples/Electron.Sample.asar

Unknown origin.

## TestData/NanaZip.Codecs.Samples/ROMFS.Sample.img

Extracted from C file from:
https://github.com/apache/nuttx/blob/nuttx-3.15/examples/romfs/romfs_testdir.h

## TestData/NanaZip.Codecs.Samples/WebAssembly.Sample.wasm

Simple "Hello World" WebAssembly WASI Application created by Kenji Mouri.

## TestData/NanaZip.Codecs.Samples/ZealFS.V1.Sample.img

Simple image with folders created by Kenji Mouri.

## TestData/CVE-2024-11477.zstd

Taken from the PoC available here:
https://github.com/TheN00bBuilder/cve-2024-11477-writeup

## TestData/CVE-2025-11001.zip

Created from the CVE-2025-11001 PoC script here:
https://github.com/pacbypass/CVE-2025-11001

## TestData/CVE-2025-55188.tar

Taken from the CVE-2025-55188 PoC available here:
https://github.com/lunbun/CVE-2025-55188

## TestData/hg19.fa.dk.bin

This is a 32MiB slice starting from offset 2816MiB of the uncompressed file
`hg19.fa` obtained from the `hg19.fa.gz` genome sequence downloaded from here:
https://hgdownload.cse.ucsc.edu/goldenPath/hg19/bigZips/initial

The MD5 sum of the compressed source file:

```
806c02398f5ac5da8ffd6da2d1d5d1a9  hg19.fa.gz
```

## TestData/Deb

These are Debian package files generated from the Artificial corpus described
above. Use the following command from a machine with dpkg-deb to recreate them:

```
cd Assets/TestData/Deb/Build
cp ../../Artificial/* .
for i in gzip xz zstd none
do
    rm -f ../Artificial-$i.deb
    SOURCE_DATE_EPOCH=1630368000 dpkg-deb -b -Z$i --nocheck . ../Artificial-$i.deb
done
```

## TestData/Rpm

These are RPM package files generated from the Artificial corpus described
above. Use the following command from a machine with rpmbuild to recreate them:

```
cd Assets/TestData/Rpm/Build
cp ../../Artificial/* .
for i in w9.gzdio w9.bzdio w9.lzdio w9.xzdio w19.zstdio w0.ufdio
do
    rm -f ../Artificial-1.0-1.noarch.$i.rpm
    SOURCE_DATE_EPOCH=1630368000 \
        rpmbuild -bb \
        --define "_sourcedir $(pwd)" \
        --define "_binary_payload $i" \
        --define "clamp_mtime_to_source_date_epoch 1" \
        --define "use_source_date_epoch_as_buildtime 1" \
        Artificial.spec
    cp -f $HOME/rpmbuild/RPMS/noarch/Artificial-1.0-1.noarch.rpm ../Artificial-1.0-1.noarch.$i.rpm
done
```
