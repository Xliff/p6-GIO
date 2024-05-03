use v6.c;

use NativeCall;

use GLib::Raw::Definitions;
use GLib::Raw::Enums;
use GLib::Raw::Object;
use GLib::Raw::Structs;
use GIO::Raw::Definitions;
use GIO::Raw::Enums;
use GIO::Raw::Structs;

unit package GIO::Raw::SocketService;

### /usr/src/glib/gio/gsocketservice.h

sub g_socket_service_get_type ()
  returns GType
  is native(gio)
  is export
{ * }

sub g_socket_service_is_active (GSocketService $service)
  returns uint32
  is native(gio)
  is export
{ * }

sub g_socket_service_new ()
  returns GSocketService
  is native(gio)
  is export
{ * }

sub g_socket_service_start (GSocketService $service)
  is native(gio)
  is export
{ * }

sub g_socket_service_stop (GSocketService $service)
  is native(gio)
  is export
{ * }
