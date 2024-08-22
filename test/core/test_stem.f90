program test_stem

use, intrinsic :: iso_fortran_env, only : stderr=>error_unit
use filesystem

implicit none


valgrind : block
character(:), allocatable :: s1

if(stem("") /= "") error stop "stem empty: " // stem("")

s1 = stem("stem.a.b")
if (s1 /= "stem.a") error stop "%stem failed: " // s1
s1 = stem(s1)
if (s1 /= "stem") error stop "stem nest failed: " // s1

if (stem("stem") /= "stem") error stop "stem idempotent failed: " // stem("stem")

if(stem(".stem") /= ".stem") error stop "stem leading dot filename idempotent: " // stem(".stem")
if(stem("./.stem") /= ".stem") error stop "stem leading dot filename cwd: " // stem("./.stem")
if(stem(".stem.txt") /= ".stem") error stop "stem leading dot filename w/ext"
if(stem("./.stem.txt") /= ".stem") error stop "stem leading dot filename w/ext and cwd"
if(stem("../.stem.txt") /= ".stem") then
    write(stderr,*) "stem leading dot filename w/ext up ", stem("../.stem.txt")
    error stop
end if

if (stem("stem.") /= "stem") error stop "stem trailing dot filename idempotent: " // stem("stem.")
if (stem("a/..") /= "..") error stop "stem parent directory: " // stem("a/..")
if (stem("a/../") /= "") error stop "stem parent directory trailing slash: " // stem("a/../")
if (stem("a/.") /= ".") error stop "stem parent directory ." // stem("a/.")

end block valgrind

end program
