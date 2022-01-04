program test_parts

use pathlib, only : path_t

implicit none (type, external)

type(path_t) :: p1
character(:), allocatable :: pts(:)

p1 = path_t("")
pts = p1%parts()
if (size(pts) /= 0) error stop "empty size"
if (len(pts) /= 0) error stop "empty len"

p1 = path_t("idempotent")
pts = p1%parts()
if (size(pts) /= 1) error stop "idempotent size"
if (len(pts(1)) /= 10) error stop "idempotent len"
if (pts(1) /= "idempotent") error stop "idempotent"

p1 = path_t("a1/b23/c456")
pts = p1%parts()
if(size(pts) /= 3) error stop "no_startend split"
if(len(pts(1)) /= 4) error stop "no_startend len"
if(pts(1) /= "a1") error stop "no_startend 1"
if(pts(2) /= "b23") error stop "no_startend 2"
if(pts(3) /= "c456") error stop "no_startend 3"

p1 = path_t("/a1/b23/c456")
pts = p1%parts()
if(size(pts) /= 4) error stop "start split"
if(len(pts(1)) /= 4) error stop "start len"
if(pts(1) /= "/") error stop "start 1"
if(pts(2) /= "a1") error stop "start 2"
if(pts(3) /= "b23") error stop "start 3"
if(pts(4) /= "c456") error stop "start 4"

p1 = path_t("a1/b23/c456/")
pts = p1%parts()
if(size(pts) /= 3) error stop "end split"
if(len(pts(1)) /= 4) error stop "end len"
if(pts(1) /= "a1") error stop "end 2"
if(pts(2) /= "b23") error stop "end 3"
if(pts(3) /= "c456") error stop "end 4"

p1 = path_t("K:/a1/b23/c456")
pts = p1%parts()
if(size(pts) /= 4) error stop "win split"
if(len(pts(1)) /= 4) error stop "win len"
if(any(pts /= [character(4) :: "K:", "a1", "b23", "c456"])) error stop "win parts"

p1 = path_t("/a1///b23/c456")
pts = p1%parts()
if(size(pts) /= 4) error stop "repeat split"
if(len(pts(1)) /= 4) error stop "repeat len"
if(any(pts /= [character(4) :: "/", "a1", "b23", "c456"])) error stop "repeat parts"

print *, "OK: parts"

end program
