env = environment()
env.unset('USERPROFILE')
env.unset('HOME')
env.unset('TMPDIR')
env.unset('TEMP')


if fortran

fortran_core = ['is_absolute', 'absolute',
'canonical', 'realpath',
'equivalent',
'expanduser',
'filesize', 'space',
'filename', 'is_dir',
'is_subdir', 'join', 'normal', 'parent', 'root', 'separator', 'stem',
'permissions', 'reserved',
'safe',
'setenv',
'set_cwd',
'suffix', 'with_suffix',
'resolve',
'path_t'
]

if backend_filesystem
  fortran_core += ['relative', 'proximate']
endif

foreach t : fortran_core

tec = executable(t + '_fortran', 'test_' + t + '.f90', link_with: filesystem, include_directories: inc)

test(t + '_fortran', tec, suite: 'fortran', workdir: meson.current_build_dir())

endforeach

tenv = executable('env_fortran', 'test_env.f90', link_with: filesystem, include_directories: inc)

test('Env_fortran', tenv, suite: 'fortran')
test('NoEnv_fortran', tenv, suite: 'fortran', env: env)

endif


cpp_core = [
'absolute',
'canonical',
'copyfile',
'env',
'equivalent',
'expanduser',
'filename',
'filesize',
'hard_link',
'is_absolute',
'is_char',
'is_dir',
'is_empty',
'is_fifo',
'is_file',
'is_prefix',
'is_subdir',
'join',
'mkdir',
'owner',
'normal',
'parent',
'permissions',
'realpath',
'rename',
'reserved',
'root',
'safe',
'separator',
'set_cwd',
'space',
'stem',
'suffix',
'system',
'touch',
'with_suffix'
]

if is_windows
  cpp_core += ['is_appexec_alias', 'windows']
endif

if backend_filesystem
  cpp_core += ['relative', 'proximate']
endif

foreach t : cpp_core

    t_cpp = executable(t + '_cpp', 'test_' + t + '.cpp', link_with: filesystem,
      include_directories: [inc, '..'])

    test(t + '_cpp', t_cpp, suite: 'cpp', workdir: meson.current_build_dir())

endforeach

tenv = executable('noenv_cpp', 'test_env.cpp', link_with: filesystem, include_directories: [inc, '..'])

test('NoEnv_cpp', tenv, suite: 'cpp', env: env)
