use v6.c;

use NativeCall;
use Method::Also;

use GIO::Raw::Types;

use GIO::InputStream;

our subset GFileInputStreamAncestry is export of Mu
  where GFileInputStream | GInputStreamAncestry;

class GIO::FileInputStream is GIO::InputStream {
  has GFileInputStream $!fis;

  submethod BUILD (:$file-input) {
    self.setGFileInputStream($file-input) if $file-input;
  }

  method setGFileInputStream (GFileInputStreamAncestry $_) {
    my $to-parent;

    $!fis = do {
      when GFileInputStream {
        $to-parent = cast(GInputStream, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GFileInputStream, $_);
      }
    }
    self.setInputStream($to-parent);
  }

  method GIO::Raw::Definitions::GFileInputStream
    is also<GFileInputStream>
  { $!fis }

  method new (GFileInputStreamAncestry $file-input, :$ref = True) {
    return Nil unless $file-input;

    my $o = self.bless( :$file-input );
    $o.ref if $ref;
    $o
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_file_input_stream_get_type, $n, $t );
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
    my $fi = g_file_input_stream_query_info(
      $!fis,
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
    samewith(
      $attributes,
      $io_priority,
      $cancellable,
      &callback,
      $user_data
    );
  }
  multi method query_info_async (
    Str() $attributes,
    Int() $io_priority,
    GCancellable() $cancellable,
    &callback,
    gpointer $user_data = gpointer
  ) {
    my gint $i = $io_priority;

    g_file_input_stream_query_info_async(
      $!fis,
      $attributes,
      $i,
      $cancellable,
      &callback,
      $user_data
    );
  }

  method query_info_finish (
    GAsyncResult() $result,
    CArray[Pointer[GError]] $error,
    :$raw = False;
  )
    is also<query-info-finish>
  {
    my $fi = g_file_input_stream_query_info_finish($!fis, $result, $error);

    $fi ??
      ( $raw ?? $fi !! GIO::FileInfo.new($fi) )
      !!
      Nil;
  }
}


### /usr/include/glib-2.0/gio/gfileinputstream.h

sub g_file_input_stream_get_type ()
  returns GType
  is native(glib)
  is export
{ * }

sub g_file_input_stream_query_info (
  GFileInputStream $stream,
  Str $attributes,
  GCancellable $cancellable,
  CArray[Pointer[GError]] $error
)
  returns GFileInfo
  is native(glib)
  is export
{ * }

sub g_file_input_stream_query_info_async (
  GFileInputStream $stream,
  Str $attributes,
  gint $io_priority,
  GCancellable $cancellable,
  &callback (GObject, GAsyncResult, gpointer),
  gpointer $user_data
)
  is native(glib)
  is export
{ * }

sub g_file_input_stream_query_info_finish (
  GFileInputStream $stream,
  GAsyncResult $result,
  CArray[Pointer[GError]] $error
)
  returns GFileInfo
  is native(glib)
  is export
{ * }
