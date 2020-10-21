use v6.c;

use Method::Also;
use NativeCall;

use GIO::Raw::Types;
use GIO::Raw::FileIOStream;

use GIO::FileInfo;
use GIO::Stream;

use GIO::Roles::Seekable;

our subset GFileIOStreamAncestry is export of Mu
  where GFileIOStream | GSeekable | GIOStream;

class GIO::FileIOStream is GIO::Stream {
  also does GIO::Roles::Seekable;

  has GFileIOStream $!fios is implementor;

  submethod BUILD (:$fileio-stream) {
    self.setGFileIOStream($fileio-stream) if $fileio-stream;
  }

  method setGFileIOStream (GFileIOStreamAncestry $_) is also<setFileIOStream> {
    my $to-parent;

    $!fios = do {
      when GFileIOStream {
        $to-parent = cast(GIOStream, $_);
        $_
      }

      when GSeekable     {
        $to-parent = cast(GIOStream, $_);
        $!s = $_;
        cast(GFileIOStream, $_);
      }

      default {
        $to-parent = $_;
        cast(GFileIOStream, $_);
      }
    }
    self.setGIOStream($to-parent);
    self.roleInit-Seekable;
  }

  method GIO::Raw::Definitions::GFileIOStream
    is also<GFileIOStream>
  { $!fios }

  method new (GFileIOStreamAncestry $fileio-stream, :$ref = True) {
    return Nil unless $fileio-stream;

    my $o = self.bless( :$fileio-stream );
    $o.ref if $ref;
    $o;
  }

  method get_etag is also<get-etag> {
    g_file_io_stream_get_etag($!fios);
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_file_io_stream_get_type, $n, $t );
  }

  method query_info (
    Str()                   $attributes,
    GCancellable()          $cancellable = GCancellable,
    CArray[Pointer[GError]] $error       = gerror,
    :$raw = False
  )
    is also<query-info>
  {
    clear_error;
    my $fi = g_file_io_stream_query_info(
      $!fios,
      $attributes,
      $cancellable,
      $error
    );
    set_error($error);

    $fi ??
      ( $raw ?? $fi !! GIO::FileInfo.new($fi, :!ref) )
      !!
      Nil;
  }

  proto method query_info_async (|)
      is also<query-info-async>
  { * }

  multi method query_info_async (
    Str()    $attributes,
    Int()    $io_priority,
             &callback,
    gpointer $user_data = gpointer
  ) {
    samewith($attributes, $io_priority, GCancellable, &callback, $user_data);
  }
  multi method query_info_async (
    Str()          $attributes,
    Int()          $io_priority,
    GCancellable() $cancellable,
                   &callback,
    gpointer       $user_data    = gpointer
  ) {
    my gint $i = $io_priority;

    g_file_io_stream_query_info_async(
      $!fios,
      $attributes,
      $i,
      $cancellable,
      &callback,
      $user_data
    );
  }

  method query_info_finish (
    GAsyncResult()          $result,
    CArray[Pointer[GError]] $error   = gerror,
    :$raw = False;
  )
    is also<query-info-finish>
  {
    clear_error;
    my $fi = g_file_io_stream_query_info_finish($!fios, $result, $error);
    set_error($error);

    $fi ??
      ( $raw ?? $fi !! GIO::FileInfo.new($fi, :!ref) )
      !!
      Nil;
  }

}
