#include "ffilesystem.h"

#include <string>  // IWYU pragma: keep
#include <string_view>

#include <iostream>
#include <system_error>         // for error_code
#include <vector>  // IWYU pragma: keep

#ifdef HAVE_CXX_FILESYSTEM
#include <filesystem>
#else
#include <cerrno>
#include <sys/types.h>

#ifdef _WIN32
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#else
#include <unistd.h>
#include <sys/stat.h>  // mkdir
#endif

#endif


bool fs_mkdir(std::string_view path)
{
 // for clarity
  if(path.empty()){
    std::cerr << "ERROR:Ffs:mkdir empty path\n";
    return false;
  }

  std::error_code ec;

#ifdef HAVE_CXX_FILESYSTEM

  if (std::filesystem::create_directories(path, ec) || (!ec)) FFS_LIKELY
    return true;

#else

  std::string buf;
  std::string p(path);

  // ERROR_PATH_NOT_FOUND if relative directory
  if(fs_is_windows() && !fs_is_absolute(p))
    p = fs_absolute(p, false);

  const std::vector<std::string> parts = fs_split(p);

  // if first part is root
  if(fs_slash_first(p))
    buf.push_back('/');

  // iterate over parts
  bool ok = false;

  for(const auto& p : parts){
    buf.append(p).push_back('/');
    if(fs_trace) std::cout << "TRACE:mkdir " << buf << "\n";
    // create directory
#ifdef _WIN32
    // https://learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-createdirectorya
    ok = CreateDirectoryA(buf.data(), nullptr) != 0;
    if(!ok){
      const auto err = GetLastError();
      // ERROR_PATH_NOT_FOUND if relative directory, thus we absolute() before loop.
      // ERROR_ACCESS_DENIED is OK if it's not the last part
      ok = err == ERROR_ALREADY_EXISTS || (err == ERROR_ACCESS_DENIED && p != parts.back());
    }
#else
  // https://www.man7.org/linux/man-pages/man2/mkdir.2.html
   ok = mkdir(buf.data(), S_IRWXU) == 0 || errno == EEXIST || (errno == EACCES && p != parts.back());
#endif
  if(!ok)  FFS_UNLIKELY
    break;
  }

  if(ok)  FFS_LIKELY
    return true;

#endif

  fs_print_error(path, "mkdir", ec);
  return false;
}
