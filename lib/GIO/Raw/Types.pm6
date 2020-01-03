use v6;

use CompUnit::Util :re-export;

unit package GIO::Raw::Types;

need GLib::Raw::Definitions;
need GLib::Raw::Enums;
need GLib::Raw::Structs;
need GLib::Raw::Subs;
need GIO::DBus::Raw::Types;
need GIO::Raw::Definitions;
need GIO::Raw::Enums;
need GIO::Raw::Structs;
need GIO::Raw::Subs;

our @gio-exports is export;

BEGIN {
  @glib-exports = <
    GIO::Raw::Definitions
    GIO::Raw::Enums
    GIO::Raw::Structs
    GIO::Raw::Subs
    GIO::DBus::Raw::Types
  >;
  re-export($_) for |@glib-exports, |@gio-exports;
}
