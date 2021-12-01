# Fortran pathlib

[![DOI](https://zenodo.org/badge/433875623.svg)](https://zenodo.org/badge/latestdoi/433875623)
[![ci_cmake](https://github.com/scivision/fortran-pathlib/actions/workflows/ci_cmake.yml/badge.svg)](https://github.com/scivision/fortran-pathlib/actions/workflows/ci_cmake.yml)

Platform independent (Linux, macOS, Windows), object-oriented Fortran filesystem path manipulation library.
Inspired by
[Python pathlib](https://docs.python.org/3/library/pathlib.html)
and
[C++ filesystem](https://en.cppreference.com/w/cpp/filesystem).

Fortran "pathlib" module contains one Fortran type "path" that contains properties and methods.
The "path" type has one property "%path" that contains the path as a string.

```fortran
use pathlib, only : path

type(path) :: p

p%path = "my/path"
```

In all the examples, we assume "p" is a pathlib path type.

Build in CMake (can also use in your project via FetchContent or ExternalProject):

```sh
cmake -B build
cmake --build build
# optional
ctest --test-dir build
```

This creates build/libpathlib.a or similar.

## subroutines

These subroutines are available in the "pathlib" module.

Copy path to dest, overwriting existing file

```fortran
character(*) :: dest = "new/file.ext"

call p%copy_file(dest)
```

Make directory p%path with parent directories if specified

```fortran
p%path = "my/new/dir"
! suppose only directory "my" exists
call p%mkdir()
! now directory my/new/dir exists
```

## path

These methods emit a new "path" object.
It can be a new path object, or reassign to the existing path object.

Expand home directory.

```fortran
! Fortran does not understand tilde "~"

p = p%expanduser()
```

'/' => '\\' for Windows paths

```fortran
p = p%as_windows()
```

 '\\' => '/' for Unix paths

```fortran
p = p%as_posix()
```

Swap file suffix

```fortran
p%path = "my/file.h5"

p = p%with_suffix(".hdf5")

! p%path == "my/file.hdf5"
```

## logical

These methods emit a logical value.

Does directory exist:

```fortran
p%is_directory()
```

Does file exist:

```fortran
p%is_file()
```

Is path absolute:

```fortran
p%is_absolute()
```

## character(:), allocatable

These methods emit a string.

Get file suffix: extracts path suffix, including the final "." dot

```fortran
p%suffix()
```

Get parent directory of path:

```fortran
p%parent()
```

Get file name without path:

```fortran
p%file_name()
```

Get file name without path and suffix:

```fortran
p%stem()
```

Get drive root. E.g. Unix "/"  Windows "c:"
Requires absolute path or will return empty string.

```fortran
p%root()
```

## System

Get home directory, or empty string if not found

```fortran
character(:), allocatable :: homedir

homedir = home()
```

## Future

We'd like to add more advanced methods such as the following.
These methods would be optional if they depend on C++ filesystem.

```fortran
p1%canonical()
p1%resolve()
p1%relative_to(p2)
p1%same_file(p2)
```
