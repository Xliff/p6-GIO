use v6.c;

use NativeCall;

use GLib::Raw::Definitions;
use GLib::Raw::Enums;
use GLib::Raw::Structs;
use GIO::Raw::Definitions;
use GIO::Raw::Enums;
use GIO::Raw::Structs;

unit package GIO::Raw::DataOutputStream;

### /usr/src/glib/gio/gdataoutputstream.h

sub g_data_output_stream_get_type ()
  returns GType
  is native(gio)
  is export
{ * }

sub g_data_output_stream_new (GOutputStream $base_stream)
  returns GDataOutputStream
  is native(gio)
  is export
{ * }

sub g_data_output_stream_put_byte (
  GDataOutputStream       $stream,
  guint8                  $data,
  GCancellable            $cancellable,
  CArray[Pointer[GError]] $error
)
  returns uint32
  is native(gio)
  is export
{ * }

sub g_data_output_stream_put_int16 (
  GDataOutputStream       $stream,
  gint16                  $data,
  GCancellable            $cancellable,
  CArray[Pointer[GError]] $error
)
  returns uint32
  is native(gio)
  is export
{ * }

sub g_data_output_stream_put_int32 (
  GDataOutputStream       $stream,
  gint32                  $data,
  GCancellable            $cancellable,
  CArray[Pointer[GError]] $error
)
  returns uint32
  is native(gio)
  is export
{ * }

sub g_data_output_stream_put_int64 (
  GDataOutputStream       $stream,
  gint64                  $data,
  GCancellable            $cancellable,
  CArray[Pointer[GError]] $error
)
  returns uint32
  is native(gio)
  is export
{ * }

sub g_data_output_stream_put_string (
  GDataOutputStream       $stream,
  Str                     $str,
  GCancellable            $cancellable,
  CArray[Pointer[GError]] $error
)
  returns uint32
  is native(gio)
  is export
{ * }

sub g_data_output_stream_put_uint16 (
  GDataOutputStream       $stream,
  guint16                 $data,
  GCancellable            $cancellable,
  CArray[Pointer[GError]] $error
)
  returns uint32
  is native(gio)
  is export
{ * }

sub g_data_output_stream_put_uint32 (
  GDataOutputStream       $stream,
  guint32                 $data,
  GCancellable            $cancellable,
  CArray[Pointer[GError]] $error
)
  returns uint32
  is native(gio)
  is export
{ * }

sub g_data_output_stream_put_uint64 (
  GDataOutputStream       $stream,
  guint64                 $data,
  GCancellable            $cancellable,
  CArray[Pointer[GError]] $error
)
  returns uint32
  is native(gio)
  is export
{ * }

sub g_data_output_stream_get_byte_order (GDataOutputStream $stream)
  returns GDataStreamByteOrder
  is native(gio)
  is export
{ * }

sub g_data_output_stream_set_byte_order (
  GDataOutputStream $stream,
  GDataStreamByteOrder $order
)
  is native(gio)
  is export
{ * }
