use v6.c;

use NativeCall;

use GIO::Raw::Types;

unit package GIO::Raw::MemoryOutputStream;

### /usr/src/glib/gio/gmemoryoutputstream.h

sub g_memory_output_stream_get_data (GMemoryOutputStream $ostream)
  returns CArray[uint8]
  is      native(gio)
  is      export
{ * }

sub g_memory_output_stream_get_data_size (GMemoryOutputStream $ostream)
  returns gsize
  is      native(gio)
  is      export
{ * }

sub g_memory_output_stream_get_size (GMemoryOutputStream $ostream)
  returns gsize
  is      native(gio)
  is      export
{ * }

sub g_memory_output_stream_get_type ()
  returns GType
  is      native(gio)
  is      export
{ * }

sub g_memory_output_stream_new (
  gpointer     $data,
  gsize        $size,
               &realloc_function (Pointer, gsize --> Pointer),
               &destroy_function (Pointer)
)
  returns GMemoryOutputStream
  is      native(gio)
  is      export
{ * }

sub g_memory_output_stream_new_resizable ()
  returns GMemoryOutputStream
  is      native(gio)
  is      export
{ * }

sub g_memory_output_stream_steal_as_bytes (GMemoryOutputStream $ostream)
  returns GBytes
  is      native(gio)
  is      export
{ * }

sub g_memory_output_stream_steal_data (GMemoryOutputStream $ostream)
  returns Pointer
  is      native(gio)
  is      export
{ * }
