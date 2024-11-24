# PIE: Peyton's Image Editor

## Setup

This will try to download and setup cimgui, sokol, and LibRaw

```
make app
v -cc gcc -d vsl_vcl_dlopencl watch run .
v -cc gcc -showcc -d vsl_vcl_dlopencl watch run .
```

vsl_vcl_dlopencl tells vsl to use dynamically linked opencl

## Misc

- Install clang (https://github.com/vovkos/llvm-package-windows/releases/clang-18.1.8)
  - `$env:Path += ';C:\Users\phcre\Downloads\clang-18.1.8-windows-amd64-msvc17-libcmt\bin'`
  - `$env:Path += ';C:\mingw64-old\bin'`

### Updating & Wrapping cimgui

- `make cimgui`
- Add `#define CIMGUI_DEFINE_ENUMS_AND_STRUCTS` to `cimgui.h` before `#ifdef CIMGUI_DEFINE_ENUMS_AND_STRUCTS`
- `c2v.exe wrapper '.\thirdparty\cimgui\cimgui.h'` or `v translate wrapper '.\thirdparty\cimgui\cimgui.h'`

### Updating & Wrapping LibRaw

- `make libraw`
- Run c2v to wrap libraw header
  - `./c2v.exe wrapper '.\thirdparty\LibRaw\libraw\libraw.h'`

### References

- raw files: https://www.imatest.com/docs/raw/
- https://github.com/ProjectPhysX/OpenCL-Wrapper
- https://github.com/morousg/simple-opencl
