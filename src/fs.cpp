// functions from C++17 filesystem

#include <iostream>
#include <algorithm>
#include <cstring>
#include <fstream>
#include <filesystem>
#include <regex>

namespace fs = std::filesystem;

extern "C" size_t filesep(char*);
extern "C" size_t as_posix(char*);
extern "C" bool is_dir(const char*);
extern "C" size_t get_homedir(char*);
extern "C" size_t expanduser(const char*, char*);


extern "C" size_t as_posix(char* path){
  // also remove duplicated separators
    std::string s(path);

    std::replace(s.begin(), s.end(), '\\', '/');

    std::regex r("/{2,}");
    s = std::regex_replace(s, r, "/");

    strcpy(path, s.c_str());

    return strlen(path);
}


extern "C" bool sys_posix() {
  char sep[2];

  filesep(sep);
  return sep[0] == '/';
}

extern "C" size_t filesep(char* sep) {
  fs::path p("/");

  std::strcpy(sep, p.make_preferred().string().c_str());
  return strlen(sep);
}


extern "C" size_t file_name(const char* path, char* filename) {
  fs::path p(path);

  std::strcpy(filename, p.filename().string().c_str());
  return strlen(filename);
}


extern "C" size_t stem(const char* path, char* fstem) {
  fs::path p(path);

  std::strcpy(fstem, p.stem().string().c_str());
  return strlen(fstem);
}


extern "C" size_t parent(const char* path, char* fparent) {
  fs::path p(path);

  if(p.has_parent_path()){
    std::strcpy(fparent, p.parent_path().string().c_str());
  }
  else{
    std::strcpy(fparent, ".");
  }

  return strlen(fparent);
}


extern "C" size_t suffix(const char* path, char* fsuffix) {
  fs::path p(path);

  std::strcpy(fsuffix, p.extension().string().c_str());
  return strlen(fsuffix);
}


extern "C" size_t with_suffix(const char* path, const char* new_suffix, char* swapped) {
  fs::path p(path);

  std::strcpy(swapped, p.replace_extension(new_suffix).string().c_str());
  return strlen(swapped);
}



extern "C" size_t normal(const char* path, char* normalized) {
  fs::path p(path);

  std::strcpy(normalized, p.lexically_normal().string().c_str());

  return as_posix(normalized);
}


extern "C" bool is_symlink(const char* path) {
  return fs::is_symlink(path);
}

extern "C" void create_symlink(const char* target, const char* link) {

  if(strlen(target) == 0) {
    std::cerr << "pathlib:create_symlink: target path must not be empty" << std::endl;
    exit(EXIT_FAILURE);
  }
  if(strlen(link) == 0) {
    std::cerr << "pathlib:create_symlink: link path must not be empty" << std::endl;
    exit(EXIT_FAILURE);
  }

  if (is_dir(target)) {
    fs::create_directory_symlink(target, link);
  }
  else {
    fs::create_symlink(target, link);
  }
}

extern "C" void create_directory_symlink(const char* target, const char* link) {
  fs::create_directory_symlink(target, link);
}

extern "C" bool create_directories(const char* path) {

  if(strlen(path) == 0) {
    std::cerr << "pathlib:mkdir:create_directories: cannot mkdir empty directory name" << std::endl;
    exit(EXIT_FAILURE);
  }

  auto s = fs::status(path);

  if(fs::exists(s)) {
    if(is_dir(path)) return true;

    std::cerr << "pathlib:mkdir:create_directories: " << path << " already exists but is not a directory" << std::endl;
    exit(EXIT_FAILURE);
  }

  auto ok = fs::create_directories(path);

  if( !ok ) {
    // old MacOS return false even if directory was created
    if(is_dir(path)) {
      return true;
    }
    else
    {
      std::cerr << "pathlib:mkdir:create_directories: " << path << " could not be created" << std::endl;
      exit(EXIT_FAILURE);
    }
  }

  return ok;
}


extern "C" size_t root(const char* path, char* result) {
  fs::path p(path);
  fs::path r;

#ifdef _WIN32
  r = p.root_name();
#else
  r = p.root_path();
#endif

  std::strcpy(result, r.string().c_str());

  return strlen(result);
}

extern "C" bool exists(const char* path) {
  return fs::exists(path);
}

extern "C" bool is_absolute(const char* path) {
  fs::path p(path);
  return p.is_absolute();
}

extern "C" bool is_file(const char* path) {
  return fs::is_regular_file(path);
}

extern "C" bool is_dir(const char* path) {
  if(std::strlen(path) == 0) return false;

  fs::path p(path);

#ifdef _WIN32
  if (p.root_name() == p) return true;
#endif

  return fs::is_directory(p);
}

extern "C" bool fs_remove(const char* path) {
  return fs::remove(path);
}

extern "C" size_t canonical(char* path, bool strict){
  // does NOT expand tilde ~

  if( (strlen(path) == 0) ) {
    path = NULL;
    return 0;
  }

  char ex[4096];
  expanduser(path, ex);

  // std::cout << "TRACE:canonical: input: " << path << " expanded: " << ex << std::endl;

  fs::path p;

  if(strict){
    p = fs::canonical(ex);
  }
  else {
    p = fs::weakly_canonical(ex);
  }

  // std::cout << "TRACE:canonical: " << p << std::endl;

  std::strcpy(path, p.string().c_str());
  return as_posix(path);
}


extern "C" bool equivalent(const char* path1, const char* path2) {
  // check existance to avoid error if not exist
  fs::path p1(path1);
  fs::path p2(path2);

  if (! (fs::exists(p1) & fs::exists(p2)) ) return false;

  return fs::equivalent(p1, p2);
}

extern "C" bool copy_file(const char* source, const char* destination, bool overwrite) {

  if(strlen(source) == 0) {
    std::cerr << "pathlib:copy_file: source path must not be empty" << std::endl;
    exit(EXIT_FAILURE);
  }
  if(strlen(destination) == 0) {
    std::cerr << "pathlib:copy_file: destination path must not be empty" << std::endl;
    exit(EXIT_FAILURE);
  }

  fs::path d(destination);

  auto opt = fs::copy_options::none;

  if (overwrite) {

// WORKAROUND: Windows MinGW GCC 11, Intel oneAPI Linux: bug with overwrite_existing failing on overwrite
  if(fs::exists(d)) fs::remove(d);

  opt |= fs::copy_options::overwrite_existing;
  }

  return fs::copy_file(source, d, opt);
}


extern "C" size_t relative_to(const char* a, const char* b, char* result) {

  // library bug handling
  if( (strlen(a) == 0) | (strlen(b) == 0) ) {
    // undefined case, avoid bugs with MacOS
    result = NULL;
    return 0;
  }

  fs::path a1(a);
  fs::path b1(b);

  if(a1.is_absolute() != b1.is_absolute()) {
    // cannot be relative, avoid bugs with MacOS
    result = NULL;
    return 0;
  }

  auto r = fs::relative(a1, b1);

  std::strcpy(result, r.string().c_str());
  return as_posix(result);
}


extern "C" bool touch(const char* path) {

  if(strlen(path) == 0) {
    std::cerr << "pathlib:touch: cannot touch empty file name" << std::endl;
    exit(EXIT_FAILURE);
  }

  fs::path p(path);

  auto s = fs::status(p);

  if (fs::exists(s) & !fs::is_regular_file(s)) return false;

  if(!fs::is_regular_file(s)) {
    std::ofstream ost;
    ost.open(p);
    ost.close();
    // ensure user can access file, as default permissions may be mode 600 or such
    fs::permissions(p, fs::perms::owner_read & fs::perms::owner_write, fs::perm_options::add);
  }

  if (!fs::is_regular_file(p)) return false;
  // here p because we want to check the new file

  std::error_code ec;

  fs::last_write_time(p, std::filesystem::file_time_type::clock::now(), ec);
  if(ec) {
    std::cerr << "pathlib:touch: " << path << " was created, but modtime was not updated: " << ec.message() << std::endl;
    return false;
  }

  return true;

}


extern "C" size_t get_tempdir(char* path) {
  std::strcpy(path, fs::temp_directory_path().string().c_str());
  return as_posix(path);
}


extern "C" uintmax_t file_size(const char* path) {
  fs::path p(path);

  if (!fs::is_regular_file(p)) {
    std::cerr << "pathlib:file_size: " << path << " is not a regular file" << std::endl;
    return -1;
  }

  return fs::file_size(p);
}


extern "C" size_t get_cwd(char* path) {
  std::strcpy(path, fs::current_path().string().c_str());
  return as_posix(path);
}


extern "C" bool is_exe(const char* path) {
  fs::path p(path);

  auto s = fs::status(p);

  if (!fs::is_regular_file(s)) {
    std::cerr << "pathlib:is_exe: " << path << " is not a regular file" << std::endl;
    return false;
  }

  auto i = s.permissions() & (fs::perms::owner_exec | fs::perms::group_exec | fs::perms::others_exec);
  auto isexe = i != fs::perms::none;

  // std::cout << "TRACE:is_exe: " << p << " " << isexe << std::endl;

  return isexe;
}


extern "C" size_t get_homedir(char* path) {

#ifdef _WIN32
  std::strcpy(path, fs::path(getenv("USERPROFILE")).string().c_str());
#else
  std::strcpy(path, fs::path(getenv("HOME")).string().c_str());
#endif

  return as_posix(path);
}


extern "C" size_t expanduser(const char* path, char* result){

  std::string p(path);

  // std::cout << "TRACE:expanduser: path: " << p << " length: " << strlen(path) << std::endl;

  if( p.length() == 0 ) {
    result = NULL;
    return 0;
  }

  if(p.front() != '~') {
    strcpy(result, path);
    return as_posix(result);
  }

  char h[4096];
  get_homedir(h);

  std::string s(h);

  // std::cout << "TRACE:expanduser: home: " << s << std::endl;

  if( s.length() == 0 ) {
    strcpy(result, path);
    return as_posix(result);
  }

  fs::path home(s);

  // std::cout << "TRACE:expanduser: path(home) " << home << std::endl;

// drop duplicated separators
  std::regex r("/{2,}");

  std::replace(p.begin(), p.end(), '\\', '/');
  p = std::regex_replace(p, r, "/");

  // std::cout << "TRACE:expanduser: path deduped " << p << std::endl;

  if (p.length() == 1) {
    // ~ alone
    strcpy(result, home.string().c_str());
    return as_posix(result);
  }
  else if (p.length() == 2) {
    // ~/ alone
    strcpy(result, (home.string() + "/").c_str());
    return as_posix(result);
  }

  // std::cout << "TRACE:expanduser: trailing path: " << p1 << std::endl;

  strcpy(result, (home / p.substr(2)).string().c_str());

  // std::cout << "TRACE:expanduser: result " << result << std::endl;

  return as_posix(result);
}

extern "C" bool chmod_exe(const char* path) {
  // make path owner executable, if it's a file

  fs::path p(path);

  if(!fs::is_regular_file(p)) {
    std::cerr << "pathlib:chmod_exe: " << p << " is not a regular file" << std::endl;
    return false;
  }

  std::error_code ec;

  fs::permissions(p, fs::perms::owner_exec, fs::perm_options::add, ec);

  if(ec) {
    std::cerr << "ERROR:pathlib:chmod_exe: " << p << ": " << ec.message() << std::endl;
    return false;
  }

  return true;

}

extern "C" bool chmod_no_exe(const char* path) {
  // make path not executable, if it's a file

  fs::path p(path);

  if(!fs::is_regular_file(p)) {
    std::cerr << "pathlib:chmod_no_exe: " << p << " is not a regular file" << std::endl;
    return false;
  }

  std::error_code ec;

  fs::permissions(p, fs::perms::owner_exec, fs::perm_options::remove, ec);

  if(ec) {
    std::cerr << "ERROR:pathlib:chmod_no_exe: " << p << ": " << ec.message() << std::endl;
    return false;
  }

  return true;

}
