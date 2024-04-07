#ifdef _MSC_VER
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif
#ifndef _CRT_NONSTDC_NO_WARNINGS
#define _CRT_NONSTDC_NO_WARNINGS
#endif
#endif

#include "ffilesystem.h"

#include <stdbool.h>
#include <string.h>
#include <ctype.h> // toupper

#ifdef _WIN32
#define WIN32_LEAN_AND_MEAN
#include <io.h> // _access_s
#include <Windows.h> // GetDiskFreeSpaceEx
#else
#include <unistd.h>
#include <sys/statvfs.h>
#endif

// preferred import order for stat()
#include <sys/types.h>
#include <sys/stat.h>

#include <stdio.h>
#include <errno.h>


bool fs_exists(const char* path)
{
  /* fs_exists() is true even if path is non-readable
   this is like Python pathlib.Path.exists()
   but unlike kwSys:SystemTools:FileExists which uses R_OK instead of F_OK like this project.
  */

#ifdef _MSC_VER
  /* kwSys:SystemTools:FileExists is much more elaborate with Reparse point checks etc.
  * For this project, Windows non-C++ is not officially supported so we do it simply.
  * This way seems to work fine on Windows anyway.
  */
   // io.h
  return !_access_s(path, 0);
#else
  // unistd.h
  return !access(path, F_OK);
#endif
}


bool fs_is_char_device(const char* path)
{
// special character device like /dev/null
// Windows: https://learn.microsoft.com/en-us/cpp/c-runtime-library/reference/fstat-fstat32-fstat64-fstati64-fstat32i64-fstat64i32
  struct stat s;
  return !stat(path, &s) && (s.st_mode & S_IFCHR);
  // S_ISCHR not available with MSVC
}


bool fs_is_dir(const char* path)
{
// NOTE: root() e.g. "C:" needs a trailing slash
  struct stat s;
  return !stat(path, &s) && (s.st_mode & S_IFDIR);
  // S_ISDIR not available with MSVC
}


bool fs_is_exe(const char* path)
{
  return (fs_is_file(path) &&
#ifdef _WIN32
  // https://learn.microsoft.com/en-us/cpp/c-runtime-library/reference/access-s-waccess-s
  // in Windows, all readable files are executable. Do not use _S_IEXEC, it is not reliable.
  fs_is_readable(path)
#else
  !access(path, X_OK)
#endif
  );
}


bool fs_is_readable(const char* path)
{
/* directory or file readable */

#ifdef _WIN32
  // https://learn.microsoft.com/en-us/cpp/c-runtime-library/reference/access-s-waccess-s
  return !_access_s(path, 4);
#else
  return !access(path, R_OK);
#endif
}


bool fs_is_writable(const char* path)
{
/* directory or file writable */

#ifdef _WIN32
  // https://learn.microsoft.com/en-us/cpp/c-runtime-library/reference/access-s-waccess-s
  return !_access_s(path, 2);
#else
  return !access(path, W_OK);
#endif
}


bool fs_is_file(const char* path)
{
  struct stat s;

  return !stat(path, &s) && (s.st_mode & S_IFREG);
  // S_ISREG not available with MSVC
}


bool fs_is_reserved(const char* path)
{
  if(!fs_is_windows())
    return false;

  char* s = (char*) malloc(fs_get_max_path());
  if(!s) return false;

  if(!fs_stem(path, s, fs_get_max_path())){
    free(s);
    return false;
  }

  // convert to upper case
  for (char* p = s; *p; ++p)
    *p = (char) toupper(*p);

  // check if the stem is a reserved device name
  bool r = !strcmp(s, "CON") || !strcmp(s, "PRN") || !strcmp(s, "AUX") || !strcmp(s, "NUL") ||
           !strcmp(s, "COM1") || !strcmp(s, "COM2") || !strcmp(s, "COM3") || !strcmp(s, "COM4") ||
           !strcmp(s, "COM5") || !strcmp(s, "COM6") || !strcmp(s, "COM7") || !strcmp(s, "COM8") ||
           !strcmp(s, "COM9") || !strcmp(s, "LPT1") || !strcmp(s, "LPT2") || !strcmp(s, "LPT3") ||
           !strcmp(s, "LPT4") || !strcmp(s, "LPT5") || !strcmp(s, "LPT6") || !strcmp(s, "LPT7") ||
           !strcmp(s, "LPT8") || !strcmp(s, "LPT9");

  free(s);

  return r;
}


time_t fs_get_modtime(const char* path)
{
  struct stat s;
  return stat(path, &s) ? 0 : s.st_mtime;
}


uintmax_t fs_file_size(const char* path)
{
  struct stat s;
  return (fs_is_file(path) && !stat(path, &s)) ? s.st_size : 0;
}


uintmax_t fs_space_available(const char* path)
{

  if(!fs_exists(path))
    return 0;

  const size_t m = fs_get_max_path();

  char* r = (char*) malloc(m);
  if(!r) return 0;

  // for robustness and clarity, use root of path
  if (!fs_root(path, r, m)){
    fprintf(stderr, "ERROR:ffilesystem:space_available: %s => could not get root\n", path);
    free(r);
    return 0;
  }

#ifdef _WIN32

  ULARGE_INTEGER bytes_available;
  bool ok = GetDiskFreeSpaceExA(r, &bytes_available, NULL, NULL);
  free(r);

  if(ok)
    return bytes_available.QuadPart;

  fprintf(stderr, "ERROR:ffilesystem:space_available: %s => %s\n", path, strerror(errno));
  return 0;

#else

  struct statvfs stat;

  if (statvfs(r, &stat)) {
    fprintf(stderr, "ERROR:ffilesystem:space_available: %s => %s\n", r, strerror(errno));
    free(r);
    return 0;
  }
  free(r);

  return stat.f_bsize * stat.f_bavail;

#endif
}


size_t fs_get_permissions(const char* path, char* result, size_t buffer_size)
{
  if (buffer_size < 10) {
    fprintf(stderr, "ERROR:ffilesystem:fs_get_permissions: buffer_size must be at least 10\n");
    return 0;
  }

  struct stat s;

  result[9] = '\0';

  if (stat(path, &s) != 0){
    fprintf(stderr, "ERROR:ffilesystem:fs_get_permissions: %s => %s\n", path, strerror(errno));
    return 0;
  }

#ifdef _MSC_VER
  const int m = s.st_mode;
  result[0] = (m & _S_IREAD) ? 'r' : '-';
  result[1] = (m & _S_IWRITE) ? 'w' : '-';
  result[2] = (m & _S_IEXEC) ? 'x' : '-';
  result[3] = (m & _S_IREAD) ? 'r' : '-';
  result[4] = (m & _S_IWRITE) ? 'w' : '-';
  result[5] = (m & _S_IEXEC) ? 'x' : '-';
  result[6] = (m & _S_IREAD) ? 'r' : '-';
  result[7] = (m & _S_IWRITE) ? 'w' : '-';
  result[8] = (m & _S_IEXEC) ? 'x' : '-';
#else
  const mode_t m = s.st_mode;
  result[0] = (m & S_IRUSR) ? 'r' : '-';
  result[1] = (m & S_IWUSR) ? 'w' : '-';
  result[2] = (m & S_IXUSR) ? 'x' : '-';
  result[3] = (m & S_IRGRP) ? 'r' : '-';
  result[4] = (m & S_IWGRP) ? 'w' : '-';
  result[5] = (m & S_IXGRP) ? 'x' : '-';
  result[6] = (m & S_IROTH) ? 'r' : '-';
  result[7] = (m & S_IWOTH) ? 'w' : '-';
  result[8] = (m & S_IXOTH) ? 'x' : '-';
#endif
  return 9;
}
