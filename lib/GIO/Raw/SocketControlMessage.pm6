use v6.c;

use NativeCall;

use GLib::Raw::Definitions;
use GLib::Raw::Enums;
use GLib::Raw::Object;
use GLib::Raw::Structs;
use GIO::Raw::Definitions;
use GIO::Raw::Enums;
use GIO::Raw::Structs;

unit package GIO::Raw::SocketControlMessage;

### /usr/src/glib/gio/gsocketcontrolmessage.h

sub g_socket_control_message_deserialize (
  gint     $level,
  gint     $type,
  gsize    $size,
  gpointer $data
)
  returns GSocketControlMessage
  is native(gio)
  is export
{ * }

sub g_socket_control_message_get_level (GSocketControlMessage $message)
  returns gint
  is native(gio)
  is export
{ * }

sub g_socket_control_message_get_msg_type (GSocketControlMessage $message)
  returns gint
  is native(gio)
  is export
{ * }

sub g_socket_control_message_get_size (GSocketControlMessage $message)
  returns gsize
  is native(gio)
  is export
{ * }

sub g_socket_control_message_get_type ()
  returns GType
  is native(gio)
  is export
{ * }

sub g_socket_control_message_serialize (
  GSocketControlMessage $message,
  gpointer              $data
)
  is native(gio)
  is export
{ * }
