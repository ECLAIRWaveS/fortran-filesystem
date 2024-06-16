#if defined(__linux__)
#include <sys/vfs.h>
#include <linux/magic.h>
// https://github.com/torvalds/linux/blob/master/include/uapi/linux/magic.h
#elif defined(__APPLE__) || defined(BSD)
#include <sys/param.h>
#include <sys/mount.h>
#elif defined(_WIN32) || defined(__CYGWIN__)
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#endif

#include <stdlib.h>  // malloc, free
#include <string.h>
#include <stdio.h>
#include <errno.h>
#include <ctype.h> // isalpha, toupper

#include "ffilesystem.h"


bool fs_is_reserved(const char* path)
{
  if(!fs_is_windows())
    return false;

  char* s = (char*) malloc(fs_get_max_path());
  if(!s) return false;

  const size_t L = fs_stem(path, s, fs_get_max_path());
  if(L == 0 || L < 3 || L > 4) {
    free(s);
    return false;
  }

  // convert to upper case
  for (char* p = s; *p; ++p)
    *p = (char) toupper(*p);

  // check if the stem is a reserved device name
  const bool r =
    !strcmp(s, "CON") || !strcmp(s, "PRN") || !strcmp(s, "AUX") || !strcmp(s, "NUL") ||
    !strcmp(s, "COM1") || !strcmp(s, "COM2") || !strcmp(s, "COM3") || !strcmp(s, "COM4") ||
    !strcmp(s, "COM5") || !strcmp(s, "COM6") || !strcmp(s, "COM7") || !strcmp(s, "COM8") ||
    !strcmp(s, "COM9") || !strcmp(s, "LPT1") || !strcmp(s, "LPT2") || !strcmp(s, "LPT3") ||
    !strcmp(s, "LPT4") || !strcmp(s, "LPT5") || !strcmp(s, "LPT6") || !strcmp(s, "LPT7") ||
    !strcmp(s, "LPT8") || !strcmp(s, "LPT9");

  free(s);

  return r;
}


bool fs_is_safe_name(const char* filename)
{
// check that only shell-safe characters are in filename using std::isalnum and a c++ set
// hasn't been fully tested yet across operating systems and file systems--let us know if character(s) should be unsafe
// does NOT check for reserved or device names
// => filenames only, not paths
// https://learn.microsoft.com/en-us/windows/win32/fileio/naming-a-file
// we do not consider whitespaces, quotes, or ticks safe, as they can be confusing in shell scripts and command line usage

const size_t L = strlen(filename);

if(L == 0)
  return false;

if(fs_is_windows() && filename[L-1] == '.')
  return false;

for (size_t i = 0; i < L; i++) {
  if(isalnum(filename[i]))
    continue;

  switch (filename[i]) {
    case '_': case '-': case '.': case '~': case '@': case '#': case '$':
    case '%': case '^': case '&': case '(': case ')': case '[': case ']':
    case '{': case '}': case '+': case '=': case ',': case '!':
      continue;
    default:
      return false;
  }
}

return true;
}


#ifdef __linux__
static inline const char* fs_type_linux(const char* path)
{
  struct statfs s;

  if(statfs(path, &s)) {
    fprintf(stderr, "ERROR:fs_get_type: statfs(%s) %s\n", path, strerror(errno));
    return "";
  }

  switch (s.f_type) {
    case BTRFS_SUPER_MAGIC: return "btrfs";
    case EXT4_SUPER_MAGIC: return "ext4";
#ifdef EXFAT_SUPER_MAGIC
    case EXFAT_SUPER_MAGIC: return "exfat";
#endif
#ifdef F2FS_SUPER_MAGIC
    case F2FS_SUPER_MAGIC: return "f2fs";
#endif
#ifdef FUSE_SUPER_MAGIC
    case FUSE_SUPER_MAGIC: return "fuse";
#endif
    case NFS_SUPER_MAGIC: return "nfs";
    case SQUASHFS_MAGIC: return "squashfs";
    case TMPFS_MAGIC: return "tmpfs";
#ifdef TRACEFS_MAGIC
    case TRACEFS_MAGIC: return "tracefs";
#endif
#ifdef UDF_SUPER_MAGIC
    case UDF_SUPER_MAGIC: return "udf";
#endif
    case V9FS_MAGIC: return "v9fs";
    // used for WSL
    // https://devblogs.microsoft.com/commandline/whats-new-for-wsl-in-windows-10-version-1903/
#ifdef XFS_SUPER_MAGIC
    case XFS_SUPER_MAGIC: return "xfs";
#endif
    default:
      fprintf(stderr, "ERROR:fs_get_type(%s) type ID: %ld\n", path, s.f_type);
      return "";
  }
}
#endif


size_t fs_filesystem_type(const char* path, char* name, const size_t buffer_size)
{
  // return name of filesystem type if known

#if defined(_WIN32) || defined(__CYGWIN__)
  const size_t MP = fs_get_max_path();

  char r[4];
  if(fs_is_cygwin()){
    // assume user input Windows path root directly.
    fs_strncpy(path, r, 4);
  } else {
    char* buf = (char*) malloc(MP);
    if(!buf) return 0;

    if (!fs_canonical(path, true, buf, MP) || !fs_root(buf, r, 4)) {
      free(buf);
      return 0;
    }
    free(buf);
  }

  // GetVolumeInformationA requires a trailing backslash
  if(isalpha(r[0]) && r[1] == ':') {
    if (r[2] == '\0')
      strcat(r, "\\");
    else if (r[2] == '/')
      r[2] = '\\';
  }

  if(FS_TRACE) printf("TRACE:get_type(%s) root: %s\n", path, r);

  size_t L;
  if(GetVolumeInformationA(r, NULL, 0, NULL, NULL, NULL, name, MAX_PATH+1)){
    L = strlen(name);
    if(L > 0 && L < buffer_size)
      return L;
  }

  fs_win32_print_error(path, "filesystem_type");
  return 0;
#elif defined(__linux__)
  return fs_strncpy(fs_type_linux(path), name, buffer_size);
#elif defined(__APPLE__) || defined(BSD)
  struct statfs s;
  if(!statfs(path, &s))
    return fs_strncpy(s.f_fstypename, name, buffer_size);
#endif
  fprintf(stderr, "ERROR:fs_get_type: Unknown operating system\n");
  return 0;
}
