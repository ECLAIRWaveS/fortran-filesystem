#include "ffilesystem.h"

#include <string>
#include <vector>
#include <iostream>

#include <cctype>


std::string fs_parent(std::string_view path)
{
  std::string p;
#ifdef HAVE_CXX_FILESYSTEM
  // have to drop_slash on input to get expected parent path -- necessary for AppleClang
  p = std::filesystem::path(fs_drop_slash(path)).parent_path().generic_string();

  // remove repeated path seperators from p string
  p.erase(std::unique(p.begin(), p.end(), [](char a, char b){ return a == '/' && b == '/'; }), p.end());

  if(FS_TRACE) std::cout << "TRACE:parent(" << path << ") => " << p << "\n";

// 30.10.7.1 [fs.path.generic] dot-dot in the root-directory refers to the root-directory itself.
// On Windows, a drive specifier such as "C:" or "z:" is treated as a root-name.
// On Cygwin, a path that begins with two successive directory separators is a root-name.
// Otherwise (for POSIX-like systems other than Cygwin), the implementation-defined root-name
// is an unspecified string which does not appear in any pathnames.

#else

  std::vector<std::string> parts = fs_split(path);

  if(parts.empty())
    return ".";

  if (fs_is_windows() && parts.size() == 1 && parts[0].length() == 2 && std::isalpha(parts[0][0]) && parts[0][1] == ':')
    return parts[0] + "/";

  // drop last part
  parts.pop_back();

  // rebuild path
  // preserve leading slash
  if (path[0] == '/')
    p = "/";

  for (const auto& part : parts){
    if(!part.empty())
      p += part + "/";
  }

  if(p.length() > 1 && p.back() == '/')
    p.pop_back();

#endif

  // handle "/" and other no parent cases
  if (p.empty()){
    if (!path.empty() && path.front() == '/')
      return "/";
    else
      return ".";
  }

  if (fs_is_windows() && p.length() == 2 && std::isalpha(p[0]) && p[1] == ':')
    p += "/";

  return p;
}
