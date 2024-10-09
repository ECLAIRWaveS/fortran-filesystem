#include <cstdint>
#include <string>

#include "ffilesystem.h"

bool fs_is_exe(const char* path){ return Ffs::is_exe(path); }

bool fs_is_readable(const char* path){ return Ffs::is_readable(path); }

bool fs_is_writable(const char* path){ return Ffs::is_writable(path); }

std::string::size_type fs_canonical(const char* path, const bool strict, const bool expand_tilde,
                          char* result, const std::string::size_type buffer_size){
  return fs_str2char(Ffs::canonical(path, strict, expand_tilde).value_or(""), result, buffer_size);
}


bool fs_equivalent(const char* path1, const char* path2){
  return Ffs::equivalent(path1, path2);
}


std::string::size_type fs_get_cwd(char* path, const std::string::size_type buffer_size){
  return fs_str2char(Ffs::get_cwd().value_or(""), path, buffer_size);
}


std::string::size_type fs_file_name(const char* path,
                         char* result, const std::string::size_type buffer_size){
  return fs_str2char(Ffs::file_name(path), result, buffer_size);
}

std::string::size_type fs_join(const char* path, const char* other,
                         char* result, const std::string::size_type buffer_size){
  return fs_str2char(Ffs::join(path, other), result, buffer_size);
}

std::string::size_type fs_absolute(const char* path, const char* base, const bool expand_tilde,
                          char* out, const std::string::size_type buffer_size){
  return fs_str2char(Ffs::absolute(path, base, expand_tilde), out, buffer_size);
}

std::string::size_type fs_normal(const char* path,
                         char* result, const std::string::size_type buffer_size){
  return fs_str2char(Ffs::normal(path), result, buffer_size);
}

std::string::size_type fs_parent(const char* path,
                         char* result, const std::string::size_type buffer_size){
  return fs_str2char(Ffs::parent(path), result, buffer_size);
}

std::string::size_type fs_proximate_to(const char* base, const char* other,
                         char* result, const std::string::size_type buffer_size){
  return fs_str2char(Ffs::proximate_to(base, other), result, buffer_size);
}

std::string::size_type fs_relative_to(const char* base, const char* other,
                         char* result, const std::string::size_type buffer_size){
  return fs_str2char(Ffs::relative_to(base, other), result, buffer_size);
}

std::string::size_type fs_resolve(const char* path, const bool strict, const bool expand_tilde,
                         char* result, const std::string::size_type buffer_size){
  return fs_str2char(Ffs::resolve(path, strict, expand_tilde).value_or(""), result, buffer_size);
}

std::string::size_type fs_stem(const char* path,
                         char* result, const std::string::size_type buffer_size){
  return fs_str2char(Ffs::stem(path), result, buffer_size);
}

std::string::size_type fs_suffix(const char* path,
                         char* result, const std::string::size_type buffer_size){
  return fs_str2char(Ffs::suffix(path), result, buffer_size);
}

std::string::size_type fs_with_suffix(const char* path, const char* new_suffix,
                         char* result, const std::string::size_type buffer_size){
  return fs_str2char(Ffs::with_suffix(path, new_suffix), result, buffer_size);
}

bool fs_set_cwd(const char *path){ return Ffs::chdir(path); }

std::string::size_type fs_get_tempdir(char* path, const std::string::size_type buffer_size){
  return fs_str2char(Ffs::get_tempdir().value_or(""), path, buffer_size);
}


bool fs_copy_file(const char* source, const char* dest, bool overwrite){
  return Ffs::copy_file(source, dest, overwrite);
}

bool fs_mkdir(const char* path){ return Ffs::mkdir(path); }

bool fs_set_modtime(const char* path){ return Ffs::set_modtime(path); }

#ifdef HAVE_MERSENNE_TWISTER
std::string::size_type fs_mkdtemp(char* result, const std::string::size_type buffer_size){
  return fs_str2char(Ffs::mkdtemp("tmp."), result, buffer_size);
}
#endif
