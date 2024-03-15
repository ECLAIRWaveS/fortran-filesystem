program test_expanduser

use, intrinsic:: iso_fortran_env, only : stderr=>error_unit
use filesystem

implicit none


if(expanduser("") /= "") error stop "expanduser blank failed"
if(expanduser(".") /= ".") error stop "expanduser dot failed: " // expanduser(".")

if(expanduser("~P") /= "~P") error stop "expanduser ~P failed: " // expanduser("~P")

valgrind: block

type(path_t) :: p2, p3
character(:), allocatable :: s1, s2, s3

!> does expanduser() get homedir correctly
s1 = expanduser("~")
if(s1 /= get_homedir()) then
   write(stderr, '(a)') "expanduser ~ failed: " // s1 // " /= " // get_homedir()
   error stop
endif

!> equality of function and method
p2 = path_t("~")
p2 = p2%expanduser()

if(s1 /= p2%path()) then
   write(stderr,'(i0,1x,i0,1x,i0,1x,i0)') len(s1), len(p2%path()), len_trim(s1), len_trim(p2%path())
   write(stderr,'(a)') "expanduser() /= %expanduser(): " // s1 // " /= " // p2%path()
   error stop
endif

!> idempotent
p3 = path_t(p2%path())
p3 = p3%expanduser()
if (p3%path() /= p2%path()) error stop "%expanduser() idempotent failed"
if (s1 /= expanduser(s1)) error stop "expanduser() idempotent failed"

!> separator
s2 = expanduser("~/")
if (s1 /= s2) error stop "expanduser trailing separator failed: " // s1 // " /= " // s2

if (expanduser("~//") /= s2) error stop "expanduser double separator failed: " // &
   expanduser("~//") // " /= " // s2

!> double dot
s2 = expanduser("~/..")
s3 = parent(s1)
if (s2 /= s3) error stop "expanduser ~/.. failed: " // s2 // " /= " // s3

s2 = expanduser("~/../")
s3 = parent(s1)
if (s2 /= s3) error stop "expanduser ~/../ failed: " // s2 // " /= " // s3

!> double dot separator
s2 = expanduser("~//..")
if(s2 /= s3) error stop "expanduser ~//.. failed: " // s2 // " /= " // s3


end block valgrind

print *, "OK: filesystem: expanduser  ", expanduser("~")

end program
