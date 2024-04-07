#include "ffilesystem.h"

#include <cstddef> // size_t
#include <iostream>

#include <filesystem>


std::string Ffs::canonical(std::string_view path, bool strict)
{
  // also expands ~ and normalizes path

  if (path.empty()) FFS_UNLIKELY
    return {};
    // need this for macOS otherwise it returns the current working directory instead of empty string

  auto ex = std::filesystem::path(Ffs::expanduser(path));

  std::error_code ec;

  if (!ex.is_absolute() && (!std::filesystem::exists(ex, ec) || ec)){
    // handles differences in ill-defined behaviour of std::filesystem::weakly_canonical() on non-existant paths
    // canonical(path, false) is distinct from resolve(path, false) for non-existing paths.
    return Ffs::normal(ex.generic_string());
  }

  auto c = strict
    ? std::filesystem::canonical(ex, ec)
    : std::filesystem::weakly_canonical(ex, ec);

  if(!ec) FFS_LIKELY
    return c.generic_string();

  std::cerr << "ERROR:ffilesystem:canonical: " << ec.message() << "\n";
  return {};
}


std::string Ffs::resolve(std::string_view path, bool strict)
{
  // expands ~ like canonical
  // empty path returns current working directory, which is distinct from canonical that returns empty string
  if(path.empty()) FFS_UNLIKELY
    return Ffs::get_cwd();

  auto ex = std::filesystem::path(Ffs::expanduser(path));

  std::error_code ec;

  if (!ex.is_absolute() && (!std::filesystem::exists(ex, ec) || ec)){
    // handles differences in ill-defined behaviour of std::filesystem::weakly_canonical() on non-existant paths
    // canonical(path, false) is distinct from resolve(path, false) for non-existing paths.
    auto cwd = std::filesystem::current_path(ec);
    if(!ec) FFS_LIKELY
      ex = cwd / ex;
    else
      std::cerr << "ERROR:ffilesystem:resolve: current_path: " << ec.message() << "\n";
  }

  auto c = strict
    ? std::filesystem::canonical(ex, ec)
    : std::filesystem::weakly_canonical(ex, ec);

  if(!ec) FFS_LIKELY
    return c.generic_string();

  std::cerr << "ERROR:ffilesystem:resolve: " << ec.message() << "\n";
  return {};
}


bool Ffs::equivalent(std::string_view path1, std::string_view path2)
{
  // non-existant paths are not equivalent
  std::error_code ec;
  return std::filesystem::equivalent(Ffs::expanduser(path1), Ffs::expanduser(path2), ec) && !ec;
}


std::string Ffs::which(std::string_view name)
// find full path to executable name on Path
{
  std::string n(name);

  if (Ffs::is_absolute(n))
    return Ffs::is_exe(n) ? n : std::string();

  const char pathsep = fs_pathsep();

  std::string path = Ffs::get_env("PATH");
  if (path.empty()) FFS_UNLIKELY
  {
    std::cerr << "ERROR:ffilesystem:which: Path environment variable not set\n";
    return {};
  }

  // Windows gives priority to cwd, so check that first
  if(fs_is_windows())
    path = Ffs::get_cwd() + pathsep + path;

  std::string::size_type start = 0;
  std::string::size_type end = path.find_first_of(pathsep, start);
  std::string p;

  while (end != std::string::npos) {
    p = path.substr(start, end - start) + "/" + n;
    if (FS_TRACE) std::cout << "TRACE:ffilesystem:which: " << p << "\n";
    if (Ffs::is_exe(p))
      return p;

    start = end + 1;
    end = path.find_first_of(pathsep, start);
  }

  p = path.substr(start) + "/" + n;
  if(Ffs::is_exe(p))
    return p;

  return {};
}


std::string Ffs::make_absolute(std::string_view path, std::string_view base)
{
  std::string out = Ffs::expanduser(path);

  if (Ffs::is_absolute(out))
    return out;

  return Ffs::join(Ffs::expanduser(base), out);
}
