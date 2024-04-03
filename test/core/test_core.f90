program test_filesystem

use, intrinsic :: iso_fortran_env, only : stderr=>error_unit
use filesystem

implicit none

logical :: ok = .true.

call test_setter_getter()
print '(a)', "OK: getter setter"

if (test_separator() /= 0) then
  write(stderr,'(a)') "ERROR: filesystem: separator"
  ok = .false.
else
  print '(a)', "OK: filesystem: separator"
endif

call test_normal()
print '(a)', "OK: filesystem: normal"

call test_join()
print '(a)', "OK: test_join"

call test_filename()
print '(a)', "OK: filesystem: filename"

call test_stem()
print '(a)', "OK: filesystem: stem"

if(test_parent() /= 0) then
  write(stderr,'(a)') "ERROR: Parent tests failed"
  ok = .false.
else
  print '(a)', "OK: filesystem: parent"
endif

call test_suffix()
print '(a)', "OK: filesystem: suffix"

call test_with_suffix()
print '(a)', "OK: filesystem: with_suffix"

call test_root()
print '(a)', "OK: filesystem: root"

call test_is_dir()
print '(a)', "OK: filesystem: is_dir"

call test_is_subdir()
print '(a)', "OK: filesystem: is_subdir"

call test_absolute()
print '(a)', "OK: filesystem: absolute"

if (.not. ok) error stop "Core tests failed"

print '(a)', "PASS: Ffilesystem core tests"

contains


subroutine test_setter_getter()

type(path_t) :: p1

p1 = path_t("a/b/c")

if (p1%path(2,3) /= "/b") error stop "getter start,end"
if (p1%path(3,3) /= "b") error stop "getter same"
if (p1%path(2) /= "/b/c") error stop "getter start only"

end subroutine


integer function test_separator() result (c)

type(path_t) :: p

character(:), allocatable :: b

character :: sep

c = 0

sep = pathsep()

if(is_windows() .and. .not. sep == ";") then
  write(stderr,*) "ERROR: pathsep: ", sep
  c = c+1
endif

if(.not. is_windows() .and. .not. sep == ":") then
  write(stderr,*) "ERROR: pathsep: ", sep
  c = c+1
endif

b = as_posix("")
if (b /= "") then
  write(stderr,*) "ERROR: as_posix empty: " // b, len_trim(b)
  c = c+1
endif

if(.not. is_windows()) return

b = as_posix("a" // char(92) // "b")
if (b /= "a/b") then
  write(stderr,*) "ERROR: as_posix(a" // char(92) // "b): " // b
  c = c+1
endif

p = path_t("a" // char(92) // "b")
p = p%as_posix()
b = p%path()
if (b /= "a/b") then
  write(stderr,*) "ERROR: %as_posix(a" // char(92) // "b): " // b
  c = c+1
endif

end function


subroutine test_normal()

character(:), allocatable :: p

p = normal("")
if(p /= "") error stop "normal empty: " // p

p = normal("a")
if(p /= "a") error stop "normal a: " // p

p = normal("a/")
if(p /= "a") error stop "normal a/: " // p

p = normal("a//")
if(p /= "a") error stop "normal a//: " // p

p = normal("./a")
if(p /= "a") error stop "normal ./a: " // p

p = normal("./a/")
if(p /= "a") error stop "normal ./a/: " // p

p = normal("../a")
if(p /= "../a") error stop "normal ../a: " // p

p = normal("a/b/")
if(p /= "a/b") error stop "normal(a/b/): " // p

p = normal("a/b/.")
if(p /= "a/b") error stop "normal(a/b/.): " // p

p = normal("a/b/..")
if(p /= "a") error stop "normal(a/b/..): " // p

p = normal("a/b/../")
if(p /= "a") error stop "normal(a/b/../): " // p


end subroutine test_normal


subroutine test_join()

type(path_t) :: p1,p2

character(:), allocatable :: p

p = join("", "")
if(p /= "") error stop "join empty: " // p

p = join("a", "")
if(p /= "a") error stop "join a: " // p

p = join("", "b")
if(p /= "b") error stop "join b: " // p

p = join("a/b/" , "c/")
if(p /= "a/b/c") error stop "join(a/b, c/): " // p

p = join("/", "")
if(p /= "/") error stop "join(/,): " // p

p = join("", "/")
if(p /= "/") error stop "join('',/): " // p

p = join("a", "b//")
if(p /= "a/b") error stop "join(a, b//): " // p

p = join("a//", "b//")
if(p /= "a/b") error stop "join(a//, b//): " // p

p = join("a/b/../", "c")
if(p /= "a/c") error stop "join(a/b/../, c): " // p


p1 = path_t("a/b")

p2 = p1%join("c/d")
if (p2%path() /= "a/b/c/d") error stop "%join c/d: " // p2%path()

p = join("a/b", "c/d")
if (p /= "a/b/c/d") error stop "join(c/d): " // p

end subroutine test_join


subroutine test_filename()

type(path_t) :: p1, p2

if(file_name("") /= "") error stop "filename empty: " // file_name("")
print '(a)', "PASS:filename:empty"

p1 = path_t("a/b/c")
p2 = path_t("a")
if (p1%file_name() /= "c") error stop "file_name failed: " // p1%file_name()
if (p2%file_name() /= "a") error stop "file_name idempotent failed: " // p2%file_name()

if(file_name("file/") /= "") error stop "file_name trailing separator should be empty " // file_name("file/")

if(file_name("file_name") /= "file_name") then
  write(stderr,*) "ERROR: file_name plain filename: " // file_name("file_name")
  error stop
endif
if(file_name(".file_name") /= ".file_name") then
  write(stderr,*) "ERROR: file_name leading dot filename: " // file_name(".file_name")
  error stop
endif
if(file_name("./file_name") /= "file_name") error stop "file_name leading dot filename cwd: " // file_name("./file_name")
if(file_name("file_name.txt") /= "file_name.txt") error stop "file_name leading dot filename w/ext"
if(file_name("./file_name.txt") /= "file_name.txt") error stop "file_name leading dot filename w/ext and cwd"
if(file_name("../file_name.txt") /= "file_name.txt") then
  write(stderr, *) "file_name leading dot filename w/ext up ", file_name("../file_name.txt")
  error stop
endif

if(is_windows()) then
  if(file_name("c:\my\path") /= "path") error stop "file_name windows: " // file_name("c:\my\path")
endif

end subroutine test_filename


subroutine test_suffix()

type(path_t) :: p1, p2

if(suffix("") /= "") error stop "suffix empty"

p1 = path_t("suffix_name.a.b")

if (p1%suffix() /= ".b") error stop "%suffix failed: " // p1%suffix()
p2 = path_t(p1%suffix())
if (p2%suffix() /= "") error stop "suffix nest failed on " // p2%path()
p2 = path_t(p2%suffix())
if (p2%suffix() /= "") error stop "suffix idempotent failed"

if(len_trim(suffix(".suffix")) /= 0) error stop "suffix leading dot filename: " // suffix(".suffix")
if(len_trim(suffix("./.suffix")) /= 0) error stop "suffix leading dot filename cwd: " // suffix("./.suffix")
if(suffix(".suffix.txt") /= ".txt") error stop "suffix leading dot filename w/ext"
if(suffix("./.suffix.txt") /= ".txt") error stop "suffix leading dot filename w/ext and cwd"
if(suffix("../.suffix.txt") /= ".txt") error stop "suffix leading dot filename w/ext up"

end subroutine test_suffix


subroutine test_stem()

type(path_t) :: p1, p2

if(stem("") /= "") error stop "stem empty: " // stem("")

p1 = path_t("stem.a.b")
if (p1%stem() /= "stem.a") error stop "%stem failed: " // p1%stem()
p2 = path_t(p1%stem())
if (p2%stem() /= "stem") error stop "stem nest failed: " // p2%stem()

if (stem("stem") /= "stem") error stop "stem idempotent failed: " // stem("stem")

if(stem(".stem") /= ".stem") error stop "stem leading dot filename idempotent: " // stem(".stem")
if(stem("./.stem") /= ".stem") error stop "stem leading dot filename cwd: " // stem("./.stem")
if(stem(".stem.txt") /= ".stem") error stop "stem leading dot filename w/ext"
if(stem("./.stem.txt") /= ".stem") error stop "stem leading dot filename w/ext and cwd"
if(stem("../.stem.txt") /= ".stem") then
  write(stderr,*) "stem leading dot filename w/ext up ", stem("../.stem.txt")
  error stop
endif

end subroutine test_stem


integer function test_parent() result (i)

type(path_t) :: p1, p2
character(:), allocatable :: p

i = 0

p = parent("")
if(p /= "") then
  write(stderr, *) "ERROR: parent empty: " // p, len(p)
  i = i+1
endif

p = parent("/")
if (p /= "/") then
  write(stderr, '(a)') "parent(/) idempotent failed: " // p
  i = i+1
endif

p = parent(".")
if(p /= ".") then
  write(stderr, '(a)') "parent(.) idempotent failed: " // p
  i = i+1
endif

p = parent("a")
if(p /= ".") then
  i = i + 1
  write(stderr, '(a)') "parent(a): " // p
endif

p = parent("a/")
if(p /= ".") then
  i = i + 1
  write(stderr, '(a)') "parent(a/): " // p
endif

p = parent(".")
if(p /= ".") then
  i = i + 1
  write(stderr, '(a)') "parent(.): " // p
endif

p = parent("./")
if(p /= ".") then
  i = i + 1
  write(stderr, '(a)') "parent(./): " // p
endif

p = parent("..")
if(p /= ".") then
  i = i + 1
  write(stderr, '(a)') "parent(..): " // p
endif

p = parent("../")
if(p /= ".") then
  i = i + 1
  write(stderr, '(a)') "parent(../): " // p
endif

p1 = path_t("a/b/c")
p = p1%parent()
if (len_trim(p) /= 3 .or. p /= "a/b") then
  write(stderr, '(a,i0)') "parent failed: " // trim(p) // " expected a/b length: ", len_trim(p)
  i = i+1
endif
p2 = path_t(p1%parent())
if (p2%parent() /= "a") then
  i = i + 1
  write(stderr, '(a)') "parent nest failed: " // p2%parent()
endif
p2 = path_t("a")
if (p2%parent() /= ".") then
  i = i + 1
  write(stderr, '(a)') "parent idempotent failed. Expected '.', but got: " // p2%parent()
endif

p = parent("ab/.parent")
if(p /= "ab") then
  i = i + 1
  write(stderr, '(a)') "parent leading dot filename cwd: " // p
endif

p = parent("ab/.parent.txt")
if(p /= "ab") then
  i = i + 1
  write(stderr, '(a)') "parent leading dot filename w/ext: " // p
endif

p = parent("a/b/../.parent.txt")
if(p /= "a/b/..") then
  write(stderr,*) "parent leading dot filename w/ext up ",  p
  i = i+1
endif

if(is_windows()) then
  p = parent("c:\a\b\..\.parent.txt")
  if(p /= "c:/a/b/..") then
    write(stderr, '(a)') "parent leading dot filename w/ext up " // p
    i = i+1
  endif

  p = parent("x:/")
  !! Python also may give either result
  if(all(p /= [character(3) :: "x:", "x:/"])) then
    write(stderr, '(a)') "parent(x:/): " // p
    i = i+1
  endif
endif

end function


subroutine test_with_suffix()

type(path_t) :: p1, p2
character(:), allocatable :: b

if(with_suffix("", ".h5") /= ".h5") error stop "with_suffix empty: " // with_suffix("", ".h5")
if(with_suffix("foo.h5", "") /= "foo") error stop "with_suffix foo.h5 to empty: " // with_suffix("foo.h5", "")
if(with_suffix(".h5", "") /= ".h5") error stop "with_suffix .h5 to .h5"
if(with_suffix(".h5", ".h5") /= ".h5.h5") then
  write(stderr,*) "ERROR: with_suffix .h5.h5: " // with_suffix(".h5", ".h5")
  error stop
endif

b = with_suffix('c:/a/hi.nc', '.h5')
if(b /= 'c:/a/hi.h5') then
  write(stderr,'(2a)') "ERROR: with_suffix c:/a/hi.nc to .h5: ", b
  error stop
endif

p1 = path_t("my/file.h5")
p2 = p1%with_suffix(".hdf5")

if (p2%path() /= "my/file.hdf5") error stop "%with_suffix failed: " // p2%path()
if (p2%path() /= with_suffix("my/file.h5", ".hdf5")) error stop "with_suffix() failed: " // p2%path()

end subroutine test_with_suffix


subroutine test_root()

character(:), allocatable :: r

if(root("") /= "") error stop "root empty"

allocate(character(max_path()) :: r)

if(is_windows()) then
  r = root("/etc")
  if(r /= "/") then
    write(stderr,'(a,i0)') "ERROR: windows root /etc failed: "// r // " length: ", len_trim(r)
    error stop
  endif

  r = root("c:/etc")
  if(r /= "c:/") then
    write(stderr, '(a)') "ERROR: windows root c:/etc failed: " // r
    error stop
  endif
else
  r = root("c:/etc")
  if(r /= "") error stop "unix root c:/etc failed : " // r

  r = root("/etc")
  if(r /= "/") error stop "unix root /etc failed: " // r
endif

deallocate(r)

end subroutine test_root


subroutine test_is_dir()
character(:), allocatable :: r
integer :: i
type(path_t) :: p1,p2

allocate(character(max_path()) :: r)


if(is_dir("")) error stop "is_dir empty should be false"

r = get_cwd()
if(.not. is_dir(r)) then
  write(stderr, '(a)') "is_dir(get_cwd()) failed on " // r
  error stop
endif

if(is_windows()) then
  r = root(get_cwd())
  print '(3A,i0)', "root(get_cwd()) = ", r, " length = ", len_trim(r)
  if(.not. is_dir(r)) error stop "is_dir('" // r // "') failed"
else
  if(.not. is_dir("/")) error stop "is_dir('/') failed"
endif

p1 = path_t(".")

if(.not. p1%is_dir()) error stop "did not detect '.' as directory"
if(p1%is_file()) error stop "detected '.' as file"
call assert_is_dir(".")

if(.not. p1%is_readable()) error stop "%is_readable failed on '.'"
if(.not. is_readable(p1%path())) error stop "is_readable failed on '.'"

p2 = path_t('test-filesystem.h5')
open(newunit=i, file=p2%path(), status='replace')
close(i)

if (p2%is_dir()) error stop "detected file as directory"
call p2%remove()

if(is_dir("not-exist-dir")) error stop "not-exist-dir should not exist"

deallocate(r)

end subroutine test_is_dir


subroutine test_is_subdir()

type(path_t) :: p1

p1 = path_t("a/b/c")

if (.not. p1%is_subdir("a/b")) error stop "a/b/c is subdir of a/b"
if (.not. p1%is_subdir("a/b/")) error stop "a/b/c is subdir of a/b/"
if (.not. p1%is_subdir("a")) error stop "a/b/c is subdir of a"

if(p1%is_subdir("a/b/c")) error stop "a/b/c is not subdir of a/b/c"
if(p1%is_subdir("a/b/c/")) error stop "a/b/c/ is not subdir of a/b/c"

p1 = path_t("a/b/c/d/..")

if (.not. p1%is_subdir("a/b/")) error stop "a/b/c/d/.. is subdir of a/b/"

if (is_subdir("a/b", "c")) error stop "c is not subdir of a/b"
if (is_subdir("/a/b", "c")) error stop "c is not subdir of /a/b"
if (is_subdir("a/b", "/c")) error stop "/c is not subdir of a/b"
if (is_subdir("b", "a/b")) error stop "a/b is not subdir of b"

if (is_subdir("/a/b", "/c")) error stop "/c is not subdir of /a/b"
if (is_subdir("/a/b", "/a/b")) error stop "/a/b is not subdir of /a/b"
if (is_subdir("/a/b", "/a/b/")) error stop "/a/b/ is not subdir of /a/b"
if (is_subdir("/a/b/", "/a/b")) error stop "/a/b is not subdir of /a/b/"
if (is_subdir("/a/b", "b")) error stop "b is not subdir of /a/b"
if (is_subdir("/a/b", "a/b")) error stop "a/b is not subdir of /a/b"

end subroutine test_is_subdir


subroutine test_absolute()

type(path_t) :: p1
p1 = path_t("")
if (p1%is_absolute()) error stop "blank is not absolute"

if (is_windows()) then
  if (.not. is_absolute("J:/")) error stop "J:/ on Windows should be absolute"
  if (.not. is_absolute("j:/")) error stop "j:/ on Windows should be absolute"
  if (is_absolute("/")) error stop "/ on Windows is not absolute"
else
  if (.not. is_absolute("/")) error stop "/ on Unix should be absolute"
  if (is_absolute("j:/")) error stop "j:/ on Unix is not absolute"
endif

end subroutine test_absolute


end program
