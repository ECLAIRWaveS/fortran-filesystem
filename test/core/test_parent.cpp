#include <iostream>
#include <string>
#include <vector>
#include <tuple>
#include <cstdlib>

#include "ffilesystem.h"

int check(std::string_view in, std::string_view ref){
  std::string r = fs_parent(in);
  if (r != ref) {
    std::cerr << "FAIL: parent(" << in << ") " << r << std::endl;
    return 1;
  }
  return 0;
}

int main() {

  std::vector<std::tuple<std::string_view, std::string_view>> test_cases;

test_cases = {
    {"", "."}, {"/", "/"}, {".", "."}, {"./", "."}, {"..", "."}, {"../", "."},
    {"a", "."}, {"a/", "."}, {"a/.", "a"}, {"a/..", "a"}, {"a/b", "a"}, {"a/b/", "a"}, {"a/b/c", "a/b"},
    {"ab/.parent", "ab"}, {"ab/.parent.txt", "ab"}, {"a/b/../.parent.txt", "a/b/.."}, {"a////////b/////c", "a/b"}
};

  if(fs_is_windows()){
    test_cases.emplace_back("c:\\a\\b/../.parent.txt", "c:/a/b/..");
    test_cases.emplace_back("x:/", "x:/");
  }

  int i = 0;

  for (const auto& [input, expected] : test_cases) {
    i += check(input, expected);
  }

  if (i != 0) {
    std::cerr << "FAIL: parent()" << std::endl;
    return EXIT_FAILURE;
  }

  std::cout << "PASS: parent()" << std::endl;
  return EXIT_SUCCESS;
}