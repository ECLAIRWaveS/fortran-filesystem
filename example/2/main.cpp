// use ffilesystem library from C++

#include <iostream>
#include <string>
#include <cstdlib>

#include "ffilesystem.h"

[[noreturn]] void err(std::string_view m){
    std::cerr << "ERROR: " << m << "\n";
    std::exit(EXIT_FAILURE);
}


int main() {

  auto cwd = Ffs::get_cwd();
  if (!cwd)
    err("current working dir not found");

  std::cout << "current working dir " << cwd.value() << "\n";

  std::string h;
  h = Ffs::get_homedir();
  if (h.empty())
    err("home dir not found");

  std::cout << "home dir " << h << "\n";

  h = Ffs::expanduser("~");
  if (h.empty())
    err("home dir not found");

  std::cout << "expanduser('~') " << h << "\n";

  return EXIT_SUCCESS;
}
