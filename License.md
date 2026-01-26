# NanaZip Test Suite (K7Tests) License

For giving the maximum respect for the upstream projects and following the
philosophy about open-source software from Kenji Mouri (MouriNaruto), the one
of the M2-Team founders.

The source code of NanaZip Test Suite (K7Tests) (not including the binaries
from third-party) is distributed under the MIT License.

The binaries from the third-party is distributed under the original license used
in the third-party binaries.

This permission notice shall be included in all copies or substantial portions
of the Software.

### The philosophy about open-source software from Kenji Mouri (MouriNaruto)

- The source code from the third-party projects should be distributed under 
  their original licenses to give the maximum respect for the upstream 
  projects.

- Don't make your software open source if you don't want your source code or
  ideas used in proprietary software. Because they always have the way to cross
  restrictions if they really want to do, even you distributed your source code
  under the strictest copyleft license, they can use clean room to resolve it.

- I prefer permissive licenses because using copyleft licenses will make you
  feel anxious in most cases because you always need to worry about someone
  using your source code in proprietary software. So, I choose to give the
  maximum respect to users, and I also hope people can try their best to treat
  others kindly.

### The MIT License

```
The MIT License (MIT)

Copyright (c) M2-Team and Contributors. All rights reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

### The third-party binaries used in NanaZip Test Suite (K7Tests)

#### Test data information

The Canterbury Corpus (`inputs/cantrbry`) and Artificial Corpus
(`inputs/artificl`) are compiled by the University of Canterbury:
https://corpus.canterbury.ac.nz

`inputs/hg19.fa.dk.bin` is a 32MiB slice starting from offset 2816MiB of the
uncompressed file `hg19.fa` obtained from the `hg19.fa.gz` genome sequence
downloaded from here:
https://hgdownload.cse.ucsc.edu/goldenPath/hg19/bigZips/initial

MD5 sum of the compressed source file:

```806c02398f5ac5da8ffd6da2d1d5d1a9  hg19.fa.gz```

`inputs/CVE-2024-11477.zstd` is taken from the PoC available here:
https://github.com/TheN00bBuilder/cve-2024-11477-writeup

`inputs/CVE-2025-11001.zip` is created from the CVE-2025-11001 PoC script here:
https://github.com/pacbypass/CVE-2025-11001

`inputs/CVE-2025-55188.tar` is taken from the CVE-2025-55188 PoC available here:
https://github.com/lunbun/CVE-2025-55188

`inputs/executables/7z*` are 7-Zip executables taken from historical releases:
https://www.7-zip.org/download.html

`inputs/executables/Ping*.efi` are taken from the EDK2 UDK 2017:
https://github.com/tianocore/edk2/releases/tag/vUDK2017

`inputs/executables/rufus-4.6_arm.exe` is the Rufus 4.6 ARM binary:
https://github.com/pbatard/rufus/releases/tag/v4.6

`inputs/executables/sudo-*.exe` are binaries of Debian's Sudo package:
https://packages.debian.org/sid/sudo
