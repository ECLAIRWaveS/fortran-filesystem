program main

use filesystem
use, intrinsic :: iso_fortran_env, only: stderr=> error_unit

implicit none

call test_is_absolute()
print '(a)', "PASS: is_absolute()"

call test_absolute()
print '(a)', "PASS: absolute()"


contains

subroutine test_is_absolute()

if (is_absolute("")) error stop "blank is not absolute"

if (is_windows()) then
  if (.not. is_absolute("J:/")) error stop "J:/ on Windows should be absolute"
  if (.not. is_absolute("j:/")) error stop "j:/ on Windows should be absolute"
  if (is_absolute("/")) error stop "/ on Windows is not absolute"
else
  if (.not. is_absolute("/")) error stop "/ on Unix should be absolute"
  if (is_absolute("j:/")) error stop "j:/ on Unix is not absolute"
end if

end subroutine


subroutine test_absolute()

character(:), allocatable :: in, base, ref, out

in = "rel"

if (is_windows()) then
  base = "j:/foo"
  ref = "j:/foo/rel"
else
  base = "/foo"
  ref = "/foo/rel"
end if

out = absolute(in, base)
if(len_trim(out) == 0) error stop "absolute() has empty output"
if (out /= ref) then
  write(stderr, '(a)') "Mismatch: absolute(" // in //", " // base // ") " // out // " /= " // ref
  error stop
endif

ref = join(get_cwd(), "rel")
out = absolute(in, "")
if(len_trim(out) == 0) error stop "absolute(path, '') has empty output"
if(out /= ref)  then
  write(stderr, '(a)') "absolute(" // in // ", '') =" // out // " /= " // ref
  error stop
endif

ref = get_cwd()
out = absolute("", "")
if(len_trim(out) == 0) error stop "absolute('', '') has empty output"
if(out /= ref) then
  write(stderr, '(a)') "absolute('', ''): " // out // " /= " // ref
  error stop
endif

ref = join(get_cwd(), "rel")
out = absolute("", in)
if(len_trim(out) == 0) error stop "absolute('', path) has empty output"
if(out /= ref) then
  write(stderr,'(a)') "absolute('', " // in //"): " // out // " /= " // ref
  error stop
endif

end subroutine test_absolute

end program
