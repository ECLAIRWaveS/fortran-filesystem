#include "ffilesystem.h"

#include <string>
#include <iostream>
#include <system_error>         // for error_code

#ifndef HAVE_CXX_FILESYSTEM
// preferred import order for stat()
#include <sys/types.h>
#include <sys/stat.h>  // mkdir

#ifdef _WIN32
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#else
#include <unistd.h>
#endif

#endif


bool fs_mkdir(std::string_view path)
{
#ifdef HAVE_CXX_FILESYSTEM

  std::error_code ec;
  // old MacOS return false even if directory was created
  if (std::filesystem::create_directories(path, ec) || (!ec && fs_is_dir(path))) FFS_LIKELY
    return true;

  std::cerr << "ERROR:Ffs:mkdir(" << path << ") " << ec.message() << "\n";
  return false;

#else

 if(fs_is_dir(path))
    return true;

  std::string buf = fs_normal(path);
  if(buf.empty())  FFS_UNLIKELY
    return false;

  // iterate over path components
  std::string::size_type pos = 0;
  // start at 0, then prefix increment to not find initial '/'
  do {
    pos = buf.find('/', ++pos);
    // must be string to avoid destroyed temporary
    std::string subdir = buf.substr(0, pos);
    if(FS_TRACE) std::cout << "TRACE:mkdir " << subdir << " pos " << pos << "\n";

#ifdef _WIN32
  // https://learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-createdirectorya
    if (CreateDirectoryA(subdir.data(), nullptr) == 0 && GetLastError() != ERROR_ALREADY_EXISTS)
#else
    if (mkdir(subdir.data(), S_IRWXU) && !(errno == EEXIST || errno == EACCES))
#endif
    {  FFS_UNLIKELY
      fs_print_error(subdir, "mkdir");
      return false;
    }
  } while (pos != std::string::npos);

  if(fs_is_dir(path))  FFS_LIKELY
    return true;

  fs_print_error(path, "mkdir: not created");
  return false;


#endif
}
