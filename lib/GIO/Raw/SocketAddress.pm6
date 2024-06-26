use v6.c;

use NativeCall;

use GLib::Raw::Definitions;
use GLib::Raw::Enums;
use GLib::Raw::Object;
use GLib::Raw::Structs;
use GIO::Raw::Definitions;
use GIO::Raw::Enums;
use GIO::Raw::Structs;

### /usr/src/glib/gio/gsocketaddress.h

unit package GIO::Raw::SocketAddress;

sub g_socket_address_get_family (GSocketAddress $address)
  returns GSocketFamily
  is native(gio)
  is export
{ * }

sub g_socket_address_get_native_size (GSocketAddress $address)
  returns gssize
  is native(gio)
  is export
{ * }

sub g_socket_address_get_type ()
  returns GType
  is native(gio)
  is export
{ * }

sub g_socket_address_new_from_native (gpointer $native, gsize $len)
  returns GSocketAddress
  is native(gio)
  is export
{ * }

sub g_socket_address_to_native (
  GSocketAddress          $address, 
  gpointer                $dest, 
  gsize                   $destlen, 
  CArray[Pointer[GError]] $error
)
  returns uint32
  is native(gio)
  is export
{ * }
