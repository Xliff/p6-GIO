use v6.c;

use NativeCall;

use GLib::Raw::Definitions;
use GLib::Raw::Enums;
use GLib::Raw::Object;
use GLib::Raw::Structs;
use GIO::Raw::Definitions;
use GIO::Raw::Enums;
use GIO::Raw::Structs;

unit package GIO::Raw::PollableInputStream;

sub g_pollable_input_stream_can_poll (GPollableInputStream $stream)
  returns uint32
  is native(gio)
  is export
{ * }

sub g_pollable_input_stream_create_source (
  GPollableInputStream $stream,
  GCancellable         $cancellable
)
  returns GSource
  is native(gio)
  is export
{ * }

sub g_pollable_input_stream_get_type ()
  returns GType
  is native(gio)
  is export
{ * }

sub g_pollable_input_stream_is_readable (GPollableInputStream $stream)
  returns uint32
  is native(gio)
  is export
{ * }

sub g_pollable_input_stream_read_nonblocking (
  GPollableInputStream    $stream,
  Pointer                 $buffer,
  gsize                   $count,
  GCancellable            $cancellable,
  CArray[Pointer[GError]] $error
)
  returns gssize
  is native(gio)
  is export
{ * }
