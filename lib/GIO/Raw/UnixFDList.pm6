use v6.c;

use NativeCall;

use GLib::Raw::Definitions;
use GLib::Raw::Enums;
use GLib::Raw::Object;
use GLib::Raw::Structs;
use GIO::Raw::Definitions;
use GIO::Raw::Enums;
use GIO::Raw::Structs;

unit package GIO::Raw::UnixFDList;

### /usr/src/glib/gio/gunixfdlist.h

sub g_unix_fd_list_append (
  GUnixFDList             $list,
  gint                    $fd,
  CArray[Pointer[GError]] $error
)
  returns gint
  is native(gio)
  is export
{ * }

sub g_unix_fd_list_get (
  GUnixFDList             $list,
  gint                    $index,
  CArray[Pointer[GError]] $error
)
  returns gint
  is native(gio)
  is export
{ * }

sub g_unix_fd_list_get_length (GUnixFDList $list)
  returns gint
  is native(gio)
  is export
{ * }

sub g_unix_fd_list_get_type ()
  returns GType
  is native(gio)
  is export
{ * }

sub g_unix_fd_list_new ()
  returns GUnixFDList
  is native(gio)
  is export
{ * }

sub g_unix_fd_list_new_from_array (CArray[gint] $fds, gint $n_fds)
  returns GUnixFDList
  is native(gio)
  is export
{ * }

sub g_unix_fd_list_peek_fds (GUnixFDList $list, gint $length is rw)
  returns CArray[gint]
  is native(gio)
  is export
{ * }

sub g_unix_fd_list_steal_fds (GUnixFDList $list, gint $length is rw)
  returns CArray[gint]
  is native(gio)
  is export
{ * }
