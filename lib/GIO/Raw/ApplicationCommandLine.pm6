use v6.c;

use NativeCall;

use GIO::Raw::Types;

unit package GIO::Raw::ApplicationCommandLine;

### /usr/include/glib-2.0/gio/gapplicationcommandline.h

sub g_application_command_line_create_file_for_arg (
  GApplicationCommandLine $cmdline,
  Str $arg
)
  returns CArray[GFile]
  is native(gio)
  is export
{ * }

sub g_application_command_line_get_arguments (
  GApplicationCommandLine $cmdline,
  gint $argc is rw
)
  returns CArray[Str]
  is native(gio)
  is export
{ * }

sub g_application_command_line_get_cwd (GApplicationCommandLine $cmdline)
  returns Str
  is native(gio)
  is export
{ * }

sub g_application_command_line_get_environ (GApplicationCommandLine $cmdline)
  returns CArray[Str]
  is native(gio)
  is export
{ * }

sub g_application_command_line_get_exit_status (
  GApplicationCommandLine $cmdline
)
  returns gint
  is native(gio)
  is export
{ * }

sub g_application_command_line_get_is_remote (GApplicationCommandLine $cmdline)
  returns uint32
  is native(gio)
  is export
{ * }

sub g_application_command_line_get_options_dict (
  GApplicationCommandLine $cmdline
)
  returns CArray[GVariantDict]
  is native(gio)
  is export
{ * }

sub g_application_command_line_get_platform_data (
  GApplicationCommandLine $cmdline
)
  returns CArray[GVariant]
  is native(gio)
  is export
{ * }

sub g_application_command_line_get_stdin (GApplicationCommandLine $cmdline)
  returns CArray[GInputStream]
  is native(gio)
  is export
{ * }

sub g_application_command_line_getenv (
  GApplicationCommandLine $cmdline,
  Str $name
)
  returns Str
  is native(gio)
  is export
{ * }

# sub g_application_command_line_print (GApplicationCommandLine $cmdline, Str $format, ...)
#   is native(gio)
#   is export
# { * }
#
# sub g_application_command_line_printerr (GApplicationCommandLine $cmdline, Str $format, ...)
#   is native(gio)
#   is export
# { * }

sub g_application_command_line_set_exit_status (
  GApplicationCommandLine $cmdline,
  gint $exit_status
)
  is native(gio)
  is export
{ * }
