#include <string>
#include <string_view>

#include <locale>

#include "ffilesystem.h"

#if defined(_WIN32)

#define WIN32_LEAN_AND_MEAN
#include <windows.h>

#elif defined(ffilesystem_locale)

#if __has_include(<codecvt>)
#define ffilesystem_HAVE_CODECVT
#include <codecvt>
#endif

#endif


std::string fs_get_locale_name() {
// https://en.cppreference.com/w/cpp/locale/locale/name
    return std::locale("").name();
}


std::string fs_to_narrow(std::wstring_view w)
{
  if(w.empty())
    return {};

  // https://learn.microsoft.com/en-us/windows/win32/api/stringapiset/nf-stringapiset-widechartomultibyte
#if defined(_WIN32)
  int L = WideCharToMultiByte(CP_UTF8, 0, w.data(), -1, nullptr, 0, nullptr, nullptr);
  if (L > 0) {
    std::string buf(L, '\0');
    L = WideCharToMultiByte(CP_UTF8, 0, w.data(), -1, buf.data(), L, nullptr, nullptr);

    if(L > 0){
      buf.resize(L-1);
      return buf;
    }
  }
#elif defined(ffilesystem_HAVE_CODECVT)

  // deprecated in C++17, but no STL replacement
  std::wstring_convert<std::codecvt_utf8<wchar_t>> converter;
  return converter.to_bytes(w.data());

#endif

  fs_print_error("", "fs_to_narrow: not enabled");
  return {};
}

std::wstring fs_to_wide(std::string_view n)
{
  if(n.empty())
    return {};

#if defined(_WIN32)
// https://docs.microsoft.com/en-us/windows/win32/api/stringapiset/nf-stringapiset-multibytetowidechar
  int L = MultiByteToWideChar(CP_UTF8, 0, n.data(), -1, nullptr, 0);
  if (L > 0) {
    std::wstring buf(L, L'\0');
    L = MultiByteToWideChar(CP_UTF8, 0, n.data(), -1, buf.data(), L);

    if(L > 0){
      buf.resize(L-1);
      return buf;
    }
  }

#elif defined(ffilesystem_HAVE_CODECVT)

  // deprecated in C++17, but no STL replacement
  std::wstring_convert<std::codecvt_utf8<wchar_t>> converter;
  return converter.from_bytes(n.data());

#endif

    fs_print_error("", "fs_to_wide: not enabled");
    return {};
  }