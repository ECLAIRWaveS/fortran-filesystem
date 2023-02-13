program test_env

use, intrinsic :: iso_fortran_env, only : stderr=>error_unit
use filesystem, only : path_t, get_cwd, exists, get_tempdir, get_homedir, temp_filename

implicit none

call test_exists()
print *, "OK fs: exists"

if (len_trim(get_homedir()) == 0) error stop "get_homedir failed"
print *, "OK: get_homedir: " // get_homedir()

if (len_trim(get_tempdir()) == 0) error stop "get_tempdir failed"
print *, "OK: get_tempdir: " // get_tempdir()

if (len_trim(temp_filename()) == 0) error stop "temp_filename failed"
print *, "OK: temp_filename: " // temp_filename()



contains


subroutine test_exists()

type(path_t) :: p1

if(exists("")) error stop "empty does not exist"

p1 = path_t(get_cwd())

if(.not. p1%exists()) error stop "%exists() failed"
if(.not. exists(get_cwd())) error stop "exists(get_cwd) failed"

end subroutine test_exists


end program
