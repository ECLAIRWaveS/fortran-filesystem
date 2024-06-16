#include <stdbool.h>
#include <stdio.h>
#include <errno.h>
#include <stdlib.h> // putenv, setenv, malloc, free
#include <string.h>

#include "ffilesystem.h"


size_t fs_getenv(const char* name, char* path, const size_t buffer_size)
{
  const char* buf = getenv(name);
  if(!buf) // not error because sometimes we just check if envvar is defined
    return 0;
  // need strncpy otherwise garbage output and/or segfault
  return fs_strncpy(buf, path, buffer_size);
}


bool fs_setenv(const char* name, const char* value)
{

#ifdef _WIN32
  // SetEnvironmentVariable returned OK but set blank values
  // https://learn.microsoft.com/en-us/cpp/c-runtime-library/reference/putenv-wputenv
  const size_t L = strlen(name) + strlen(value) + 2;
  char* buf = (char*) malloc(L);
  if(!buf) return false;

  snprintf(buf, L, "%s=%s", name, value);
  if(putenv(buf) == 0){
    free(buf);
    return true;
  }
  free(buf);
#else
  // https://www.man7.org/linux/man-pages/man3/setenv.3.html
  if(setenv(name, value, 1) == 0)
    return true;
#endif

  fprintf(stderr, "ERROR:ffilesystem:fs_setenv: %s => %s\n", name, strerror(errno));
  return false;
}
