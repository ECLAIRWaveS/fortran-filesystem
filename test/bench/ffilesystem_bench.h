#include <chrono>
#include <string>

std::chrono::duration<double> bench_c(int, std::string_view, std::string_view, bool);

std::chrono::duration<double> bench_cpp(int, std::string_view, std::string_view, bool);

void print_c(std::chrono::duration<double>, int, std::string_view, std::string_view, std::string_view);
void print_cpp(std::chrono::duration<double>, int, std::string_view, std::string_view, std::string_view);
