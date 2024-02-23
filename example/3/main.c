// use ffilesystem library from C

#include <stdio.h>

#include "ffilesystem.h"

int main(void) {

  const size_t FS_MAX_PATH = fs_get_max_path();

  char* d = (char*) malloc(FS_MAX_PATH);

  fs_get_cwd(d, FS_MAX_PATH);
  printf("current working dir %s\n", d);

  fs_get_homedir(d, FS_MAX_PATH);
  printf("home dir %s\n", d);

  fs_expanduser("~", d, FS_MAX_PATH);
  printf("expanduser('~') %s\n", d);

  free(d);

  return 0;

}
