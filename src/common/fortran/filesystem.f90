module filesystem

use, intrinsic:: iso_c_binding, only: C_BOOL, C_CHAR, C_INT, C_LONG, C_LONG_LONG, C_SIZE_T, C_NULL_CHAR
use, intrinsic:: iso_fortran_env, only: int64, compiler_version, stderr=>error_unit

implicit none
private
public :: get_homedir, canonical, resolve, get_cwd, set_cwd, make_tempdir, which !< utility procedures
public :: normal, expanduser, as_posix, &
is_absolute, is_char_device, is_dir, is_file, is_exe, is_subdir, is_readable, is_writable, is_reserved, &
is_symlink, read_symlink, create_symlink, &
exists, &
join, &
copy_file, mkdir, &
relative_to, proximate_to, &
root, same_file, file_size, space_available, &
file_name, parent, stem, suffix, with_suffix, &
make_absolute, &
assert_is_file, assert_is_dir, &
touch, get_modtime, set_modtime, &
remove, get_tempdir, &
set_permissions, get_permissions, &
fs_cpp, fs_lang, pathsep, is_safe_name, &
is_admin, is_bsd, is_macos, is_windows, is_cygwin, is_wsl, is_mingw, is_linux, is_unix, &
max_path, get_max_path, &
exe_path, lib_path, compiler, compiler_c, &
longname, shortname, getenv, setenv, &
is_alpha

interface get_max_path
!! deprecated
procedure :: max_path
end interface



interface

logical(C_BOOL) function fs_cpp() bind(C)
!! ffilesystem is using C++ backend?
import C_BOOL
end function

integer(C_LONG) function fs_lang() bind(C)
!! C `__STDC_VERSION__` or C++ level of macro `__cplusplus`
import C_LONG
end function

logical(C_BOOL) function is_admin() bind(C, name="fs_is_admin")
!! user running as admin / root / superuser?
import
end function

logical(C_BOOL) function is_bsd() bind(C, name="fs_is_bsd")
!! operating system is BSD-like
import
end function

logical(C_BOOL) function is_macos() bind(C, name="fs_is_macos")
!! operating system is macOS
import
end function

logical(C_BOOL) function is_windows() bind(C, name="fs_is_windows")
!! operating system is Microsoft Windows
import
end function

logical(C_BOOL) function is_cygwin() bind(C, name="fs_is_cygwin")
!! operating system is Cygwin
import
end function

integer(C_INT) function is_wsl() bind(C, name="fs_is_wsl")
!! Windows Subsystem for Linux (WSL) version (0 is not WSL)
import
end function

logical(C_BOOL) function is_mingw() bind(C, name="fs_is_mingw")
!! operating system platform is MinGW
import C_BOOL
end function

logical(C_BOOL) function is_linux() bind(C, name="fs_is_linux")
!! operating system is Linux
import C_BOOL
end function

logical(C_BOOL) function is_unix() bind(C, name="fs_is_unix")
!! operating system is Unix-like
import C_BOOL
end function
integer(C_INT) function fs_get_max_path() bind(c)
import
end function

subroutine fs_as_posix(path) bind(C)
import
character(kind=C_CHAR), intent(inout) :: path(*)
end subroutine

integer(C_SIZE_T) function fs_canonical(path, strict, result, buffer_size) bind(C)
import
character(kind=C_CHAR), intent(in) :: path(*)
logical(C_BOOL), intent(in), value :: strict
character(kind=C_CHAR), intent(out) :: result(*)
integer(C_SIZE_T), intent(in), value :: buffer_size
end function

integer(C_SIZE_T) function fs_resolve(path, strict, result, buffer_size) bind(C)
import
character(kind=C_CHAR), intent(in) :: path(*)
logical(C_BOOL), intent(in), value :: strict
character(kind=C_CHAR), intent(out) :: result(*)
integer(C_SIZE_T), intent(in), value :: buffer_size
end function

logical(C_BOOL) function fs_set_permissions(path, readable, writable, executable) bind(C)
import
character(kind=C_CHAR), intent(in) :: path(*)
integer(C_INT), intent(in), value :: readable, writable, executable
end function

integer(C_SIZE_T) function fs_get_permissions(path, perms, buffer_size) bind(C)
import
character(kind=C_CHAR), intent(in) :: path(*)
character(kind=C_CHAR), intent(out) :: perms(*)
integer(C_SIZE_T), intent(in), value :: buffer_size
end function

logical(C_BOOL) function fs_copy_file(source, dest, overwrite) bind(C)
import
character(kind=c_char), intent(in) :: source(*), dest(*)
logical(C_BOOL), intent(in), value :: overwrite
end function


logical(C_BOOL) function fs_equivalent(path1, path2) bind(C)
import C_BOOL, C_CHAR
character(kind=C_CHAR), intent(in) :: path1(*), path2(*)
end function

logical(C_BOOL) function fs_is_symlink(path) bind(C)
import
character(kind=C_CHAR), intent(in) :: path(*)
end function

integer(C_SIZE_T) function fs_compiler(path, buffer_size) bind(C)
import
character(kind=C_CHAR), intent(out) :: path(*)
integer(C_SIZE_T), intent(in), value :: buffer_size
end function

integer(C_SIZE_T) function fs_read_symlink(path, result, buffer_size) bind(C)
import
character(kind=c_char), intent(in) :: path(*)
character(kind=c_char), intent(out) :: result(*)
integer(C_SIZE_T), intent(in), value :: buffer_size
end function

logical(C_BOOL) function fs_create_symlink(target, link) bind(C)
import
character(kind=C_CHAR), intent(in) :: target(*), link(*)
end function

logical(C_BOOL) function fs_mkdir(path) bind(C)
import
character(kind=C_CHAR), intent(in) :: path(*)
end function

logical(C_BOOL) function fs_remove(path) bind(C)
import
character(kind=C_CHAR), intent(in) :: path(*)
end function

logical(C_BOOL) function fs_exists(path) bind(C)
import
character(kind=C_CHAR), intent(in) :: path(*)
end function

integer(C_SIZE_T) function fs_expanduser(path, result, buffer_size) bind(C)
import
character(kind=c_char), intent(in) :: path(*)
character(kind=c_char), intent(out) :: result(*)
integer(C_SIZE_T), intent(in), value :: buffer_size
end function

integer(C_SIZE_T) function fs_file_name(path, filename, buffer_size) bind(C)
import
character(kind=C_CHAR), intent(in) :: path(*)
character(kind=C_CHAR), intent(out) :: filename(*)
integer(C_SIZE_T), intent(in), value :: buffer_size
end function

logical(C_BOOL) function fs_is_safe_name(filename) bind(C)
import
character(kind=C_CHAR), intent(in) :: filename(*)
end function

integer(C_SIZE_T) function fs_file_size(path) bind(C)
import
character(kind=C_CHAR), intent(in) :: path(*)
end function

integer(C_SIZE_T) function fs_space_available(path) bind(C)
import
character(kind=C_CHAR), intent(in) :: path(*)
end function

integer(C_SIZE_T) function fs_get_cwd(path, buffer_size) bind(C)
import
character(kind=C_CHAR), intent(out) :: path(*)
integer(C_SIZE_T), intent(in), value :: buffer_size
end function

logical(C_BOOL) function fs_set_cwd(path) bind(C)
import
character(kind=C_CHAR), intent(in) :: path(*)
end function

integer(C_SIZE_T) function fs_get_homedir(path, buffer_size) bind(C)
import
character(kind=c_char), intent(out) :: path(*)
integer(C_SIZE_T), intent(in), value :: buffer_size
end function

integer(C_SIZE_T) function fs_get_tempdir(path, buffer_size) bind(C)
import
character(kind=c_char), intent(out) :: path(*)
integer(C_SIZE_T), intent(in), value :: buffer_size
end function

logical(c_bool) function fs_is_absolute(path) bind(C)
import
character(kind=C_CHAR), intent(in) :: path(*)
end function

logical(C_BOOL) function fs_is_char_device(path) bind(C)
import
character(kind=C_CHAR), intent(in) :: path(*)
end function

logical(C_BOOL) function fs_is_file(path) bind(C)
import
character(kind=C_CHAR), intent(in) :: path(*)
end function

logical(C_BOOL) function fs_is_dir(path) bind(C)
import
character(kind=C_CHAR), intent(in) :: path(*)
end function

logical(c_bool) function fs_is_exe(path) bind(C)
import
character(kind=C_CHAR), intent(in) :: path(*)
end function

logical(c_bool) function fs_is_readable(path) bind(C)
import
character(kind=C_CHAR), intent(in) :: path(*)
end function

logical(c_bool) function fs_is_writable(path) bind(C)
import
character(kind=C_CHAR), intent(in) :: path(*)
end function

logical(c_bool) function fs_is_reserved(path) bind(C)
import
character(kind=C_CHAR), intent(in) :: path(*)
end function

integer(C_SIZE_T) function fs_join(path, other, result, buffer_size) bind(C)
import
character(kind=c_char), intent(in) :: path(*), other(*)
character(kind=c_char), intent(out) :: result(*)
integer(C_SIZE_T), intent(in), value :: buffer_size
end function

logical(C_BOOL) function fs_is_subdir(subdir, dir) bind(C)
import
character(kind=C_CHAR), intent(in) :: subdir(*), dir(*)
end function

integer(C_SIZE_T) function fs_make_absolute(path, base, result, buffer_size) bind(C)
import
character(kind=c_char), intent(in) :: path(*), base(*)
character(kind=c_char), intent(out) :: result(*)
integer(C_SIZE_T), intent(in), value :: buffer_size
end function

integer(C_SIZE_T) function fs_normal(path, result, buffer_size) bind(C)
import
character(kind=C_CHAR), intent(in) :: path(*)
character(kind=C_CHAR), intent(out) :: result(*)
integer(C_SIZE_T), intent(in), value :: buffer_size
end function

integer(C_SIZE_T) function fs_parent(path, result, buffer_size) bind(C)
import
character(kind=C_CHAR), intent(in) :: path(*)
character(kind=C_CHAR), intent(out) :: result(*)
integer(C_SIZE_T), intent(in), value :: buffer_size
end function

integer(C_SIZE_T) function fs_relative_to(base, other, result, buffer_size) bind(C)
import
character(kind=c_char), intent(in) :: base(*), other(*)
character(kind=c_char), intent(out) :: result(*)
integer(C_SIZE_T), intent(in), value :: buffer_size
end function

integer(C_SIZE_T) function fs_proximate_to(base, other, result, buffer_size) bind(C)
import
character(kind=c_char), intent(in) :: base(*), other(*)
character(kind=c_char), intent(out) :: result(*)
integer(C_SIZE_T), intent(in), value :: buffer_size
end function

integer(C_SIZE_T) function fs_which(name, result, buffer_size) bind(C)
import
character(kind=C_CHAR), intent(in) :: name(*)
character(kind=C_CHAR), intent(out) :: result(*)
integer(C_SIZE_T), intent(in), value :: buffer_size
end function

integer(C_SIZE_T) function fs_root(path, result, buffer_size) bind(C)
import
character(kind=C_CHAR), intent(in) :: path(*)
character(kind=C_CHAR), intent(out) :: result(*)
integer(C_SIZE_T), intent(in), value :: buffer_size
end function

integer(C_SIZE_T) function fs_stem(path, result, buffer_size) bind(C)
import
character(kind=C_CHAR), intent(in) :: path(*)
character(kind=C_CHAR), intent(out) :: result(*)
integer(C_SIZE_T), intent(in), value :: buffer_size
end function

integer(C_SIZE_T) function fs_suffix(path, result, buffer_size) bind(C)
import
character(kind=C_CHAR), intent(in) :: path(*)
character(kind=C_CHAR), intent(out) :: result(*)
integer(C_SIZE_T), intent(in), value :: buffer_size
end function

logical(C_BOOL) function fs_touch(path) bind(C)
import
character(kind=c_char), intent(in) :: path(*)
end function

integer(C_LONG_LONG) function fs_get_modtime(path) bind(C)
import
character(kind=C_CHAR), intent(in) :: path(*)
end function

logical(C_BOOL) function fs_set_modtime(path) bind(C)
import
character(kind=C_CHAR), intent(in) :: path(*)
end function

integer(C_SIZE_T) function fs_with_suffix(path, new_suffix, result, buffer_size) bind(C)
import
character(kind=C_CHAR), intent(in) :: path(*), new_suffix
character(kind=C_CHAR), intent(out) :: result(*)
integer(C_SIZE_T), intent(in), value :: buffer_size
end function

integer(C_SIZE_T) function fs_make_tempdir(result, buffer_size) bind(C)
import
character(kind=C_CHAR), intent(out) :: result(*)
integer(C_SIZE_T), intent(in), value :: buffer_size
end function

integer(C_SIZE_T) function fs_shortname(in, out, buffer_size) bind(C)
import
character(kind=C_CHAR), intent(in) :: in(*)
character(kind=C_CHAR), intent(out) :: out(*)
integer(C_SIZE_T), intent(in), value :: buffer_size
end function

integer(C_SIZE_T) function fs_longname(in, out, buffer_size) bind(C)
import
character(kind=C_CHAR), intent(in) :: in(*)
character(kind=C_CHAR), intent(out) :: out(*)
integer(C_SIZE_T), intent(in), value :: buffer_size
end function

integer(C_SIZE_T) function fs_lib_path(path, buffer_size) bind(C)
import
character(kind=C_CHAR), intent(out) :: path(*)
integer(C_SIZE_T), intent(in), value :: buffer_size
end function

integer(C_SIZE_T) function fs_exe_path(path, buffer_size) bind(C)
import
character(kind=C_CHAR), intent(out) :: path(*)
integer(C_SIZE_T), intent(in), value :: buffer_size
end function

logical(C_BOOL) function fs_setenv(name, val) bind(C)
import
character(kind=C_CHAR), intent(in) :: name(*), val(*)
end function

end interface


include "path_type.inc"


contains

!> non-functional API

integer function max_path()
!! returns dynamic MAX_PATH for this computer
!! Maximum path length is dynamically determined for this computer.
!! A fixed length eases sending data to/from C/C++.
!!
!! Physical filesystem maximum filename and path lengths are OS and config dependent.
!! Notional limits:
!! MacOS: 1024 from sys/syslimits.h PATH_MAX
!! Linux: 4096 from https://www.ibm.com/docs/en/spectrum-protect/8.1.13?topic=parameters-file-specification-syntax
!! Windows: 32767 from https://docs.microsoft.com/en-us/windows/win32/fileio/maximum-file-path-limitation?tabs=cmd
max_path = int(fs_get_max_path())
end function


include "path_methods.inc"


function as_posix(path) result(r)
!! force Posix file separator "/"
character(*), intent(in) :: path
character(:), allocatable :: r

character(kind=c_char, len=:), allocatable :: cbuf
integer :: N
N = len_trim(path)
allocate(character(N+1) :: cbuf)
cbuf = trim(path) // C_NULL_CHAR
call fs_as_posix(cbuf)
allocate(character(N) :: r)
r = cbuf(:N)
end function


function canonical(path, strict) result (r)
include "ifc1a.inc"
N = fs_canonical(trim(path) // C_NULL_CHAR, s, cbuf, N)
include "ifc0b.inc"
end function


function resolve(path, strict) result(r)
include "ifc1a.inc"
N = fs_resolve(trim(path) // C_NULL_CHAR, s, cbuf, N)
include "ifc0b.inc"
end function


subroutine set_permissions(path, readable, writable, executable, ok)
!! set owner readable bit for regular file
character(*), intent(in) :: path
logical, intent(in), optional :: readable, writable, executable
logical, intent(out), optional :: ok

logical(C_BOOL) :: s

integer(C_INT) :: r, w, e

r = 0
w = 0
e = 0

if(present(readable)) then
  r = -1
  if(readable) r = 1
endif
if(present(writable)) then
  w = -1
  if(writable) w = 1
endif
if(present(executable)) then
  e = -1
  if(executable) e = 1
endif

s = fs_set_permissions(trim(path) // C_NULL_CHAR, r, w, e)
if(present(ok)) then
  ok = s
elseif (.not. s) then
  write(stderr, '(/,A,L1,1x,L1,1x,L1,1x,A)') "ERROR: set_permissions: failed to set permission ", &
    readable,writable,executable, trim(path)
  error stop
endif
end subroutine


character(9) function get_permissions(path) result (r)
!! get permissions as POSIX string
character(*), intent(in) :: path
character(kind=c_char, len=:), allocatable :: cbuf
integer(C_SIZE_T) :: N
allocate(character(10) :: cbuf)
N = fs_get_permissions(trim(path) // C_NULL_CHAR, cbuf, len(cbuf, kind=C_SIZE_T))
if(N > 9) error stop "Error:Ffilesystem:get_permissions: unexpected length /= 9"
r = cbuf(:N)
end function


subroutine copy_file(src, dest, overwrite, ok)
!! copy single file from src to dest
character(*), intent(in) :: src, dest
logical, intent(in), optional :: overwrite
logical, intent(out), optional :: ok

logical(c_bool) :: ow, s
ow = .false.
if(present(overwrite)) ow = overwrite
s = fs_copy_file(trim(src) // C_NULL_CHAR, trim(dest) // C_NULL_CHAR, ow)
if (present(ok)) then
  ok = s
elseif(.not. s) then
  write(stderr, '(a)') "ERROR:Ffilesystem:copy_file: failed to copy file: " // trim(src) // " to " // trim(dest)
  error stop
endif
end subroutine


subroutine mkdir(path, ok)
!! create a directory, with parents if needed
character(*), intent(in) :: path
logical, intent(out), optional :: ok

logical(C_BOOL) :: s

s = fs_mkdir(trim(path) // C_NULL_CHAR)
if(present(ok)) then
  ok = s
elseif (.not. s) then
  write(stderr,'(a,i0)') "ERROR:Ffilesystem:mkdir: failed to create directory: " // trim(path)
  error stop
endif
end subroutine


function read_symlink(path) result (r)
!! resolve symbolic link--error/empty if not symlink
character(*), intent(in) :: path

include "ifc0a.inc"
N = fs_read_symlink(trim(path) // C_NULL_CHAR, cbuf, N)
include "ifc0b.inc"
end function


subroutine create_symlink(tgt, link, ok)
character(*), intent(in) :: tgt, link
logical, intent(out), optional :: ok

logical(C_BOOL) :: s

s = fs_create_symlink(trim(tgt) // C_NULL_CHAR, trim(link) // C_NULL_CHAR)
if(present(ok)) then
  ok =s
elseif (.not. s) then
  write(stderr,'(a,1x,i0)') "ERROR:Ffilesystem:create_symlink: " // trim(link)
  error stop
endif
end subroutine


logical function exists(path)
!! a file or directory exists
character(*), intent(in) :: path
exists = fs_exists(trim(path) // C_NULL_CHAR)
end function


function expanduser(path) result (r)
!! expand ~ to home directory
character(*), intent(in) :: path

include "ifc0a.inc"
N = fs_expanduser(trim(path) // C_NULL_CHAR, cbuf, N)
include "ifc0b.inc"
end function


function file_name(path) result (r)
!! returns file name without path
character(*), intent(in) :: path

include "ifc0a.inc"
N = fs_file_name(trim(path) // C_NULL_CHAR, cbuf, N)
include "ifc0b.inc"
end function


logical function is_safe_name(filename)
!! is filename a safe name for this filesystem
character(*), intent(in) :: filename

is_safe_name = fs_is_safe_name(trim(filename) // C_NULL_CHAR)
end function


integer(int64) function file_size(path)
!! size of file (bytes)
character(*), intent(in) :: path

file_size = fs_file_size(trim(path) // C_NULL_CHAR)
end function


integer(int64) function space_available(path)
!! returns space available (bytes) on filesystem containing path
character(*), intent(in) :: path

space_available = fs_space_available(trim(path) // C_NULL_CHAR)
end function


logical function is_absolute(path)
!! is path absolute
!! do NOT expanduser() to be consistent with Python etc. filesystem
character(*), intent(in) :: path

is_absolute = fs_is_absolute(trim(path) // C_NULL_CHAR)
end function


logical function is_char_device(path)
!! is path a character device like /dev/null
character(*), intent(in) :: path

is_char_device = fs_is_char_device(trim(path) // C_NULL_CHAR)
end function


logical function is_dir(path)
!! .true.: "path" is a directory OR symlink pointing to a directory
!! .false.: "path" is a broken symlink, does not exist, or is some other type of filesystem entity
character(*), intent(in) :: path

is_dir = fs_is_dir(trim(path) // C_NULL_CHAR)
end function


logical function is_exe(path)
!! is "path" executable?
character(*), intent(in) :: path

is_exe = fs_is_exe(trim(path) // C_NULL_CHAR)
end function


logical function is_readable(path)
!! is "path" readable?
character(*), intent(in) :: path

is_readable = fs_is_readable(trim(path) // C_NULL_CHAR)
end function


logical function is_writable(path)
!! is "path" writable?
character(*), intent(in) :: path

is_writable = fs_is_writable(trim(path) // C_NULL_CHAR)
end function


logical function is_file(path)
!! .true.: "path" is a file OR symlink pointing to a file
!! .false.: "path" is a directory, broken symlink, or does not exist
character(*), intent(in) :: path

is_file = fs_is_file(trim(path) // C_NULL_CHAR)
end function


logical function is_reserved(path)
!! .true.: "path" is a reserved name on this filesystem
character(*), intent(in) :: path

is_reserved = fs_is_reserved(trim(path) // C_NULL_CHAR)
end function


logical function is_symlink(path)
!! .true.: "path" is a symbolic link
!! .false.: "path" is not a symbolic link, or does not exist,
!!           or platform/drive not capable of symlinks
character(*), intent(in) :: path

is_symlink = fs_is_symlink(trim(path) // C_NULL_CHAR)
end function


function join(path, other) result (r)
!! Join path with other path string using posix separators.
!! The paths are treated like strings.
!! Mo path resolution is used, so non-sensical paths are possible for non-sensical input.
character(*), intent(in) :: path, other

include "ifc0a.inc"
N = fs_join(trim(path) // C_NULL_CHAR, trim(other) // C_NULL_CHAR, cbuf, N)
include "ifc0b.inc"
end function


logical function is_subdir(subdir, dir)
!! is subdir a subdirectory of dir
character(*), intent(in) :: subdir, dir

is_subdir = fs_is_subdir(trim(subdir) // C_NULL_CHAR, trim(dir) // C_NULL_CHAR)
end function


function parent(path) result(r)
!! returns parent directory of path
character(*), intent(in) :: path

include "ifc0a.inc"
N = fs_parent(trim(path) // C_NULL_CHAR, cbuf, N)
include "ifc0b.inc"
end function


function normal(path) result (r)
!! lexically normalize path
character(*), intent(in) :: path

include "ifc0a.inc"
N = fs_normal(trim(path) // C_NULL_CHAR, cbuf, N)
include "ifc0b.inc"
end function


function relative_to(base, other) result (r)
!! returns other relative to base
!! if other is not a subpath of base, returns "" empty string
!!
!! reference: C++ filesystem relative
!! https://en.cppreference.com/w/cpp/filesystem/relative
character(*), intent(in) :: base, other

include "ifc0a.inc"
N = fs_relative_to(trim(base) // C_NULL_CHAR, trim(other) // C_NULL_CHAR, cbuf, N)
include "ifc0b.inc"
end function


function proximate_to(base, other) result (r)
!! returns other proximate to base
!! if other is not a subpath of base, returns "" empty string
!!
!! reference: C++ filesystem proximate
!! https://en.cppreference.com/w/cpp/filesystem/proximate
character(*), intent(in) :: base, other

include "ifc0a.inc"
N = fs_proximate_to(trim(base) // C_NULL_CHAR, trim(other) // C_NULL_CHAR, cbuf, N)
include "ifc0b.inc"
end function


function root(path) result (r)
!! returns root of path
character(*), intent(in) :: path

include "ifc0a.inc"
N = fs_root(trim(path) // C_NULL_CHAR, cbuf, N)
include "ifc0b.inc"
end function


logical function same_file(path1, path2)
character(*), intent(in) :: path1, path2

same_file = fs_equivalent(trim(path1) // C_NULL_CHAR, trim(path2) // C_NULL_CHAR)
end function


function stem(path) result (r)
character(*), intent(in) :: path

include "ifc0a.inc"
N = fs_stem(trim(path) // C_NULL_CHAR, cbuf, N)
include "ifc0b.inc"
end function


function suffix(path) result (r)
!! extracts path suffix, including the final "." dot
character(*), intent(in) :: path

include "ifc0a.inc"
N = fs_suffix(trim(path) // C_NULL_CHAR, cbuf, N)
include "ifc0b.inc"
end function


subroutine touch(path)
character(*), intent(in) :: path

if(.not. fs_touch(trim(path) // C_NULL_CHAR)) then
  write(stderr, '(a)') "filesystem:touch: " // trim(path)
  error stop
end if
end subroutine


integer(C_LONG_LONG) function get_modtime(path) result(r)
!! get file modification time as Unix epoch time
character(*), intent(in) :: path

r = fs_get_modtime(trim(path) // C_NULL_CHAR)
end function


logical function set_modtime(path) result(r)
!! get file modification time as Unix epoch time
character(*), intent(in) :: path

r = fs_set_modtime(trim(path) // C_NULL_CHAR)
end function


function with_suffix(path, new) result(r)
!! replace file suffix with new suffix
character(*), intent(in) :: path,new

include "ifc0a.inc"
N = fs_with_suffix(trim(path) // C_NULL_CHAR, trim(new) // C_NULL_CHAR, cbuf, N)
include "ifc0b.inc"
end function


function shortname(path) result(r)
!! convert long path to short
character(*), intent(in) :: path

include "ifc0a.inc"
N = fs_shortname(trim(path) // C_NULL_CHAR, cbuf, N)
include "ifc0b.inc"
end function


function longname(path) result (r)
!! convert short path to long
character(*), intent(in) :: path

include "ifc0a.inc"
N = fs_longname(trim(path) // C_NULL_CHAR, cbuf, N)
include "ifc0b.inc"
end function


function make_tempdir() result (r)
!! make unique temporary directory

include "ifc0a.inc"
N = fs_make_tempdir(cbuf, N)
include "ifc0b.inc"
end function


subroutine setenv(name, val, ok)
character(*), intent(in) :: name, val
logical, intent(out), optional :: ok

logical(C_BOOL) :: s

s = fs_setenv(trim(name) // C_NULL_CHAR, trim(val) // C_NULL_CHAR)
if(present(ok)) then
  ok = s
elseif (.not. s) then
  write(stderr,'(a,1x,i0)') "ERROR:Ffilesystem:setenv: " // trim(name)
  error stop
endif
end subroutine


function getenv(name) result(r)
!! get environment variable
character(*), intent(in) :: name
character(:), allocatable :: r
integer :: i, L

call get_environment_variable(name, length=L, status=i)
if (i/=0) then
  r = ""
  return
endif

allocate(character(L) :: r)
call get_environment_variable(name, value=r, status=i)
if (i/=0) r = ""
end function


function exe_path() result (r)
!! get full path of main executable

include "ifc0a.inc"
N = fs_exe_path(cbuf, N)
include "ifc0b.inc"
end function
!> one-liner methods calling actual procedures


subroutine assert_is_file(path)
!! throw error if file does not exist
character(*), intent(in) :: path
if (.not. is_file(path)) then
  write(stderr, '(a)') 'File does not exist: ' // path
  error stop
endif
end subroutine


subroutine assert_is_dir(path)
!! throw error if directory does not exist
character(*), intent(in) :: path
if (.not. is_dir(path)) then
  write(stderr, '(a)') 'Directory does not exist: ' // path
  error stop
endif
end subroutine


function which(name) result(r)
!! find executable in PATH
character(*), intent(in) :: name

include "ifc0a.inc"
N = fs_which(trim(name) // C_NULL_CHAR, cbuf, N)
include "ifc0b.inc"
end function


subroutine remove(path)
!! delete the file, symbolic link, or empty directory
character(*), intent(in) :: path

logical(c_bool) :: e
e = fs_remove(trim(path) // C_NULL_CHAR)
if (.not. e) write(stderr, '(a)') "ERROR:ffilesystem:remove: " // trim(path) // " may not have been deleted."
end subroutine


function compiler_c() result(r)
!! get C/C++ compiler name and version
include "ifc0a.inc"
N = fs_compiler(cbuf, N)
include "ifc0b.inc"
end function


character function pathsep()
!! path separater (not file separator)
!! we do this discretely in Fortran as there is a long-standing bug
!! in nvfortran with passing single characters from C to Fortran caller
if (is_windows()) then
  pathsep = ";"
else
  pathsep = ":"
endif
end function


function compiler() result(r)
character(:), allocatable :: r
r = compiler_version()
end function


function lib_path() result (r)
!! get full path of shared library. Empty if not shared library.
include "ifc0a.inc"
N = fs_lib_path(cbuf, N)
include "ifc0b.inc"
end function


function get_cwd() result (r)
!! get current working directory

include "ifc0a.inc"
N = fs_get_cwd(cbuf, N)
include "ifc0b.inc"
end function


logical function set_cwd(path)
!! set current working directory (chdir)
character(*), intent(in) :: path

set_cwd = fs_set_cwd(trim(path) // C_NULL_CHAR)
end function


function get_homedir() result (r)
!! returns home directory, or empty string if not found
!!
!! https://en.wikipedia.org/wiki/Home_directory#Default_home_directory_per_operating_system

include "ifc0a.inc"
N = fs_get_homedir(cbuf, N)
include "ifc0b.inc"
end function


function get_tempdir() result (r)
!! get system temporary directory

include "ifc0a.inc"
N = fs_get_tempdir(cbuf, N)
include "ifc0b.inc"
end function


function make_absolute(path, base) result(r)
!! if path is absolute, return expanded path
!! if path is relative, base / path
!!
!! idempotent iff base is absolute
character(*), intent(in) :: path, base

include "ifc0a.inc"
N = fs_make_absolute(trim(path) // C_NULL_CHAR, trim(base) // C_NULL_CHAR, cbuf, N)
include "ifc0b.inc"
end function


elemental logical function is_alpha(c) result(r)
!! is character alphabetic in the ASCII alphabet
character, intent(in) :: c

r = (c >= 'A' .and. c <= 'Z') .or. (c >= 'a' .and. c <= 'z')
end function

end module filesystem
