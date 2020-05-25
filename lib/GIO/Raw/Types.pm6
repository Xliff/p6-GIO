use v6;

use CompUnit::Util :re-export;

use GLib::Raw::Exports;
use GIO::Raw::Exports;

constant forced = 4;

unit package GIO::Raw::Types;

need GLib::Raw::Definitions;
need GLib::Raw::Enums;
need GLib::Raw::Structs;
need GLib::Raw::Struct_Subs;
need GLib::Raw::Subs;
need GLib::Raw::Exports;
need GIO::Raw::Definitions;
need GIO::Raw::Enums;
need GIO::Raw::Structs;
need GIO::Raw::Subs;
need GIO::Raw::Exports;
need GIO::DBus::Raw::Types;

BEGIN {
  re-export($_) for |@glib-exports, |@gio-exports;
}