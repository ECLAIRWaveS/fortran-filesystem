program test_root

use, intrinsic :: iso_fortran_env, only: stderr => error_unit
use filesystem

implicit none

valgrind : block
character(:), allocatable :: r

if(root("") /= "") error stop "root empty"

if(root("a/b") /= "") error stop "relative root should be empty"
if(root("./a/b") /= "") error stop "relative root ./a should be empty"
if(root("../a/b") /= "") error stop "relative root ../a should be empty"

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

end block valgrind

print '(a)', "OK: root"

end program
