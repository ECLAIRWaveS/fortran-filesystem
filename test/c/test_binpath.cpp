#include <cstdlib>
#include <iostream>
#include <string>
#include <stdexcept>

#ifdef _MSC_VER
#include <crtdbg.h>
#endif

#include "ffilesystem.h"


void test_exe_path(char* argv[])
{
char bin[FS_MAX_PATH];

fs_exe_path(bin, FS_MAX_PATH);
std::string binpath = bin;
  if (binpath.find(argv[2]) == std::string::npos)
    throw std::runtime_error("ERROR:test_binpath: exe_path not found correctly: " + binpath);


std::string bindir = fs_exe_dir();
if(bindir.empty())
  throw std::runtime_error("ERROR:test_binpath: exe_dir not found correctly: " + bindir);

std::string p = fs_parent(binpath);

if(!fs_equivalent(bindir, p))
  throw std::runtime_error("ERROR:test_binpath: exe_dir and parent(exe_path) should be equivalent: " + bindir + " != " + p);

std::cout << "OK: exe_path: " << binpath << "\n";
std::cout << "OK: exe_dir: " << bindir << "\n";

}


void test_lib_path(char* argv[]){

  int shared = atoi(argv[1]);
  if(!shared){
    std::cerr << "SKIP: lib_path: feature not available\n";
    return;
  }

  std::string binpath = fs_lib_path();

  if(binpath.empty())
    throw std::runtime_error("ERROR:test_binpath: lib_path should be non-empty: " + binpath);

  if(binpath.find(argv[3]) == std::string::npos)
    throw std::runtime_error("ERROR:test_binpath: lib_path not found correctly: " + binpath + " does not contain " + argv[3]);

  std::cout << "OK: lib_path: " << binpath << "\n";

  std::string bindir = fs_lib_dir();

  std::string p;
#ifdef __CYGWIN__
  p = fs_parent(fs_as_cygpath(binpath));
#else
  p = fs_parent(binpath);
#endif
  std::cout << "parent(lib_path): " << p << "\n";

  if(bindir.empty())
    throw std::runtime_error("ERROR:test_binpath: lib_dir should be non-empty: " + bindir);

  if(!fs_equivalent(bindir, p))
    throw std::runtime_error("ERROR:test_binpath_c: lib_dir and parent(lib_path) should be equivalent: " + bindir + " != " + p);

  std::cout << "OK: lib_dir: " << bindir << "\n";
}

int main(int argc, char* argv[])
{
#ifdef _MSC_VER
  _CrtSetReportMode(_CRT_ASSERT, _CRTDBG_MODE_FILE);
  _CrtSetReportFile(_CRT_ASSERT, _CRTDBG_FILE_STDERR);
  _CrtSetReportMode(_CRT_WARN, _CRTDBG_MODE_FILE);
  _CrtSetReportFile(_CRT_WARN, _CRTDBG_FILE_STDERR);
  _CrtSetReportMode(_CRT_ERROR, _CRTDBG_MODE_FILE);
  _CrtSetReportFile(_CRT_ERROR, _CRTDBG_FILE_STDERR);
#endif

  if (argc < 4) {
    std::cerr << "ERROR: test_binpath_c: not enough arguments\n";
    return 1;
  }

  test_exe_path(argv);

  test_lib_path(argv);

  return EXIT_SUCCESS;
}
