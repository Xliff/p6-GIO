use v6.c;

use NativeCall;

use GIO::Raw::Definitions;

unit package GIO::Raw::Subs;

#
# APPLICATION
#
sub g_application_run(Pointer, int32, CArray[Str])
  is native(gio)
  is export
  { * }

sub g_application_quit(Pointer)
  is native(gio)
  is export
{ * }
