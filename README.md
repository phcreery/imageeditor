# v image editor

## Setup

This will try to download and setup cimgui, sokol, and LibRaw

```
make app
v -cc gcc -showcc -d vsl_vcl_dlopencl watch run .
```

## Misc

### Updating & Wrapping LibRaw

- Install clang (https://github.com/vovkos/llvm-package-windows/releases/clang-18.1.8)
  - `$env:Path += ';C:\Users\phcre\Downloads\clang-18.1.8-windows-amd64-msvc17-libcmt\bin'`
- Run c2v to wrap libraw header
  - `./c2v.exe wrapper 'C:\Users\phcre\Documents\v\imageeditor\thirdparty\LibRaw\libraw\libraw.h'`

### Sources

- raw files: https://www.imatest.com/docs/raw/
