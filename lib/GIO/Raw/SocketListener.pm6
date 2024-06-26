use v6.c;

use NativeCall;

use GLib::Raw::Definitions;
use GLib::Raw::Enums;
use GLib::Raw::Object;
use GLib::Raw::Structs;
use GIO::Raw::Definitions;
use GIO::Raw::Enums;
use GIO::Raw::Structs;

unit package GIO::Raw::SocketListener;

### /usr/src/glib/gio/gsocketlistener.h

sub g_socket_listener_accept (
  GSocketListener         $listener,
  GObject                 $source_object,
  GCancellable            $cancellable,
  CArray[Pointer[GError]] $error
)
  returns GSocketConnection
  is native(gio)
  is export
{ * }

sub g_socket_listener_accept_async (
  GSocketListener $listener,
  GCancellable    $cancellable,
                  &callback (GSocketListener, GAsyncResult, gpointer),
  gpointer        $user_data
)
  is native(gio)
  is export
{ * }

sub g_socket_listener_accept_finish (
  GSocketListener         $listener,
  GAsyncResult            $result,
  GObject                 $source_object,
  CArray[Pointer[GError]] $error
)
  returns GSocketConnection
  is native(gio)
  is export
{ * }

sub g_socket_listener_accept_socket (
  GSocketListener         $listener,
  GObject                 $source_object,
  GCancellable            $cancellable,
  CArray[Pointer[GError]] $error
)
  returns GSocket
  is native(gio)
  is export
{ * }

sub g_socket_listener_accept_socket_async (
  GSocketListener $listener,
  GCancellable    $cancellable,
                  &callback (GSocketListener, GAsyncResult, gpointer),
  gpointer        $user_data
)
  is native(gio)
  is export
{ * }

sub g_socket_listener_accept_socket_finish (
  GSocketListener         $listener,
  GAsyncResult            $result,
  GObject                 $source_object,
  CArray[Pointer[GError]] $error
)
  returns GSocket
  is native(gio)
  is export
{ * }

sub g_socket_listener_add_address (
  GSocketListener         $listener,
  GSocketAddress          $address,
  GSocketType             $type,
  GSocketProtocol         $protocol,
  GObject                 $source_object,
  GSocketAddress          $effective_address,
  CArray[Pointer[GError]] $error
)
  returns uint32
  is native(gio)
  is export
{ * }

sub g_socket_listener_add_any_inet_port (
  GSocketListener         $listener,
  GObject                 $source_object,
  CArray[Pointer[GError]] $error
)
  returns guint16
  is native(gio)
  is export
{ * }

sub g_socket_listener_add_inet_port (
  GSocketListener         $listener,
  guint16                 $port,
  GObject                 $source_object,
  CArray[Pointer[GError]] $error
)
  returns uint32
  is native(gio)
  is export
{ * }

sub g_socket_listener_add_socket (
  GSocketListener         $listener,
  GSocket                 $socket,
  GObject                 $source_object,
  CArray[Pointer[GError]] $error
)
  returns uint32
  is native(gio)
  is export
{ * }

sub g_socket_listener_close (GSocketListener $listener)
  is native(gio)
  is export
{ * }

sub g_socket_listener_get_type ()
  returns GType
  is native(gio)
  is export
{ * }

sub g_socket_listener_new ()
  returns GSocketListener
  is native(gio)
  is export
{ * }

sub g_socket_listener_set_backlog (
  GSocketListener $listener,
  gint            $listen_backlog
)
  is native(gio)
  is export
{ * }
