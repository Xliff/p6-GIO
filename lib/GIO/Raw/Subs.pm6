use v6.c;

use NativeCall;

use GLib::Raw::Types;
use GIO::Raw::Definitions;

unit package GIO::Raw::Subs;

sub g_io_error_quark ()
  returns GQuark
  is export
  is native(gio)
{ * }
