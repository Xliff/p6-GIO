use v6.c;

use NativeCall;

use GLib::Raw::Definitions;
use GLib::Raw::Enums;
use GLib::Raw::Object;
use GLib::Raw::Structs;
use GIO::Raw::Definitions;
use GIO::Raw::Enums;
use GIO::Raw::Structs;

unit package GIO::Raw::UnixSocketAddress;

### /usr/src/glib/gio/gunixsocketaddress.h

sub g_unix_socket_address_abstract_names_supported ()
  returns uint32
  is native(gio)
  is export
{ * }

sub g_unix_socket_address_get_address_type (GUnixSocketAddress $address)
  returns GUnixSocketAddressType
  is native(gio)
  is export
{ * }

sub g_unix_socket_address_get_is_abstract (GUnixSocketAddress $address)
  returns uint32
  is native(gio)
  is export
{ * }

sub g_unix_socket_address_get_path (GUnixSocketAddress $address)
  returns Str
  is native(gio)
  is export
{ * }

sub g_unix_socket_address_get_path_len (GUnixSocketAddress $address)
  returns gsize
  is native(gio)
  is export
{ * }

sub g_unix_socket_address_get_type ()
  returns GType
  is native(gio)
  is export
{ * }

sub g_unix_socket_address_new (Str $path)
  returns GUnixSocketAddress
  is native(gio)
  is export
{ * }

sub g_unix_socket_address_new_with_type (
  Str                    $path,
  gint                   $path_len,
  GUnixSocketAddressType $type
)
  returns GUnixSocketAddress
  is native(gio)
  is export
{ * }
