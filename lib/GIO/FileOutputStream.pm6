use v6.c;

use NativeCall;
use Method::Also;

use GIO::Raw::Types;

use GIO::OutputStream;

our subset GFileOutputStreamAncestry is export of Mu
  where GFileOutputStream | GOutputStreamAncestry;

class GIO::FileOutputStream is GIO::OutputStream {
  has GFileOutputStream $!fos;

  submethod BUILD (:$file-output) {
    self.setGFileOutputStream($file-output) if $file-output;
  }

  method setGFileOutputStream (GFileOutputStreamAncestry $_) {
    my $to-parent;

    $!fos = do {
      when GFileOutputStream {
        $to-parent = cast(GOutputStream, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GFileOutputStream, $_);
      }
    }
    self.setGOutputStream($to-parent);
  }

  method GIO::Raw::Definitions::GFileOutputStream
    is also<GFileOutputStream>
  { $!fos }

  method new (GFileOutputStreamAncestry $file-output, :$ref = True) {
    return Nil unless $file-output;

    my $o = self.bless( :$file-output );
    $o.ref if $ref;
    $o
  }

  method get_etag is also<get-etag> {
    g_file_output_stream_get_etag($!fos);
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_file_output_stream_get_type, $n, $t );
  }

  method query_info (
    Str() $attributes,
    GCancellable() $cancellable    = GCancellable,
    CArray[Pointer[GError]] $error = gerror,
    :$raw = False
  )
    is also<query-info>
  {
    clear_error;
    my $fi = g_file_output_stream_query_info(
      $!fos,
      $attributes,
      $cancellable,
      $error
    );
    set_error($error);

    $fi ??
      ( $raw ?? $fi !! GIO::FileInfo.new($fi) )
      !!
      Nil;
  }

  proto method query_info_async (|)
    is also<query-info-async>
  { * }

  multi method query_info_async (
    Str() $attributes,
    Int() $io_priority,
    &callback,
    gpointer $user_data         = gpointer,
    GCancellable() $cancellable = GCancellable
  ) {
    samewith($attributes, $io_priority, $cancellable, &callback, $user_data);
  }
  multi method query_info_async (
    Str() $attributes,
    Int() $io_priority,
    GCancellable() $cancellable,
    &callback,
    gpointer $user_data
  ) {
    my gint $i = $io_priority;

    g_file_output_stream_query_info_async(
      $!fos,
      $attributes,
      $io_priority,
      $cancellable,
      &callback,
      $user_data
    );
  }

  method query_info_finish (
    GAsyncResult() $result,
    CArray[Pointer[GError]] $error = gerror,
    :$raw = False
  )
    is also<query-info-finish>
  {
    clear_error;
    my $fi = g_file_output_stream_query_info_finish($!fos, $result, $error);
    set_error($error);

    $fi ??
      ( $raw ?? $fi !! GIO::FileInfo.new($fi) )
      !!
      Nil;
  }
}


### /usr/include/glib-2.0/gio/gfileoutputstream.h

sub g_file_output_stream_get_etag (GFileOutputStream $stream)
  returns Str
  is native(glib)
  is export
{ * }

sub g_file_output_stream_get_type ()
  returns GType
  is native(glib)
  is export
{ * }

sub g_file_output_stream_query_info (
  GFileOutputStream $stream,
  Str $attributes,
  GCancellable $cancellable,
  CArray[Pointer[GError]] $error
)
  returns GFileInfo
  is native(glib)
  is export
{ * }

sub g_file_output_stream_query_info_async (
  GFileOutputStream $stream,
  Str $attributes,
  gint $io_priority,
  GCancellable $cancellable,
  &callback (GObject, GAsyncResult, gpointer),
  gpointer $user_data
)
  is native(glib)
  is export
{ * }

sub g_file_output_stream_query_info_finish (
  GFileOutputStream $stream,
  GAsyncResult $result,
  CArray[Pointer[GError]] $error
)
  returns GFileInfo
  is native(glib)
  is export
{ * }
