#include "ffilesystem.h"

#include <string_view>
#include <system_error>
#include <iostream>

#ifndef HAVE_CXX_FILESYSTEM
// preferred import order for stat()
#include <sys/types.h>
#include <sys/stat.h>

#if defined(__linux__) && defined(USE_STATX)
#include <fcntl.h>   // AT_* constants for statx()
#endif

#endif

bool fs_equivalent(std::string_view path1, std::string_view path2)
{
  // non-existent paths are not equivalent

  std::error_code ec;

#ifdef HAVE_CXX_FILESYSTEM

  std::filesystem::path p1(path1);
  std::filesystem::path p2(path2);
  if(fs_is_mingw()){
    p1 = p1.lexically_normal();
    p2 = p2.lexically_normal();
  }

  bool e = std::filesystem::equivalent(p1, p2, ec);
  if(!ec)
    return e;

#elif defined(STATX_BASIC_STATS) && defined(USE_STATX)
// https://www.man7.org/linux/man-pages/man2/statx.2.html
  if (FS_TRACE) std::cout << "TRACE: statx() equivalent " << path1 << " " << path2 << "\n";
  struct statx s1;
  struct statx s2;

  if( statx(AT_FDCWD, path1.data(), AT_NO_AUTOMOUNT, STATX_BASIC_STATS, &s1) == 0 &&
      statx(AT_FDCWD, path2.data(), AT_NO_AUTOMOUNT, STATX_BASIC_STATS, &s2) == 0 ) FFS_LIKELY
    return s1.stx_dev_major == s2.stx_dev_major && s1.stx_dev_minor == s2.stx_dev_minor && s1.stx_ino == s2.stx_ino;

#else
  struct stat s1;
  struct stat s2;

  // https://www.boost.org/doc/libs/1_86_0/libs/filesystem/doc/reference.html#equivalent
  if(!stat(path1.data(), &s1) && !stat(path2.data(), &s2))
    return s1.st_dev == s2.st_dev && s1.st_ino == s2.st_ino;
#endif
  fs_print_error(path1, path2, "equivalent", ec);
  return false;
}