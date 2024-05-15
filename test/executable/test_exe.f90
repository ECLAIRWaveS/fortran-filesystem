program test_exe

use, intrinsic :: iso_fortran_env, only : stderr=>error_unit
use filesystem

implicit none


call test_not_exist()
print '(a)', "PASSED: test_not_exist"

call test_is_exe()
print '(a)', "PASSED: test_exist"

contains

subroutine test_not_exist()

character(:), allocatable :: s1

!> empty file
if(is_file("")) error stop "ERROR:test_exe: is_file('') should be false"
if(is_exe("")) error stop "ERROR:test_exe: is_exe('') should be false"

s1 = get_permissions("")
if(len_trim(s1) /= 0) error stop "ERROR:test_exe: get_permissions('') should be empty: " // s1

!> not exist file
s1 = "not-exist-file"
if (is_file(s1)) error stop "ERROR:test_exe: not-exist-file should not exist."
if (is_exe(s1)) error stop "ERROR:test_exe: non-exist-file cannot be executable"
if(len_trim(get_permissions(s1)) /= 0) error stop "ERROR:test_exe: get_permissions('not-exist') should be empty"

end subroutine test_not_exist


subroutine test_is_exe()

character(*), parameter :: noexe = "test_noexe"

character(:), allocatable :: exe
integer :: i

allocate(character(max_path()) :: exe)

call get_command_argument(0, exe, status=i)
if(i/=0) error stop "ERROR:test_exe: get_command_argument(0) failed"

print '(a)', "test_is_exe: touch(" // noexe // ")"
call touch(noexe)

print '(a)', "set_permissions(" // trim(noexe) // ", executable=.false.)"
call set_permissions(noexe, executable=.false.)

if(is_exe(parent(exe))) then
  write(stderr, '(a)') "ERROR:test_exe: directory" // parent(exe) // " should not be executable"
  error stop
endif

print '(a)', "permissions: " // trim(exe) // " = " // get_permissions(exe)

if (.not. is_exe(exe)) then
  write(stderr,'(a)') "ERROR:test_exe: " // trim(exe) // " is not executable."
  error stop
endif

print '(a)', "permissions: " // trim(noexe) // " = " // get_permissions(noexe)

if (is_exe(noexe)) then
  if(is_windows()) then
    write(stderr,'(a)') "XFAIL:test_exe: " // trim(noexe) // " is executable on Windows."
  else
    write(stderr,'(a)') "ERROR:test_exe: " // trim(noexe) // " is executable and should not be."
    error stop
  endif
endif

print '(a)', "remove(" // trim(noexe) // ")"
call remove(noexe)

end subroutine test_is_exe

end program
