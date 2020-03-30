use v6.c;

unit package GIO::Raw::Exports;

our @gio-exports is export;

BEGIN {
  @gio-exports = <
    GIO::Raw::Definitions
    GIO::Raw::Enums
    GIO::Raw::Structs
    GIO::Raw::Subs
    GIO::DBus::Raw::Types
  >;
}
