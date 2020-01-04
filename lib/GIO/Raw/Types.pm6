use v6;

use CompUnit::Util :re-export;

unit package GIO::Raw::Types;

need GLib::Raw::Definitions;
need GLib::Raw::Enums;
need GLib::Raw::Structs;
need GLib::Raw::Subs;
need GLib::Raw::Exports;
need GIO::DBus::Raw::Types;
need GIO::Raw::Definitions;
need GIO::Raw::Enums;
need GIO::Raw::Structs;
need GIO::Raw::Subs;
need GIO::Raw::Exports;

BEGIN {
  re-export($_) for
    |@GLib::Raw::Exports::glib-exports,
    |@GIO::Raw::Exports::gio-exports;
}
