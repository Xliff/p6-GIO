use v6.c;

use GLib::Raw::Debug;
use GLib::Raw::Distro;

unit package GIO::Raw::Distro;

INIT {
  add-distro-adjustments(
    %( gio => glib-adjustments )
  );
}
