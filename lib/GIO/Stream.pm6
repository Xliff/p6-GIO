use v6.c;

use Method::Also;
use NativeCall;

use GIO::Raw::Types;
use GIO::Raw::Stream;

use GIO::InputStream;
use GIO::OutputStream;

use GLib::Roles::Object;

our subset GIOStreamAncestry is export of Mu
  where GIOStream | GObject;

class GIO::Stream {
  also does GLib::Roles::Object;

  has GIOStream $!ios is implementor;

  submethod BUILD (:$stream) {
    self.setStream($stream) if $stream;
  }

  method setStream (GIOStreamAncestry $_) {
    my $to-parent;

    $!ios = do {
      when GIOStream {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GIOStream, $_);
      }
    }
    self!setObject($to-parent);
  }

  method new (GIOStreamAncestry $stream, :$ref = True) {
    return Nil unless $stream;

    my $o = self.bless( :$stream );
    $o.ref if $ref;
    $o;
  }

  method GIO::Raw::Definitions::GIOStream
    is also<GIOStream>
  { $!ios }

  method clear_pending is also<clear-pending> {
    g_io_stream_clear_pending($!ios);
  }

  method close (
    GCancellable()          $cancellable,
    CArray[Pointer[GError]] $error        = gerror
  ) {
    clear_error;
    my $rv = so g_io_stream_close($!ios, $cancellable, $error);
    set_error($error);
    $rv;
  }

  proto method close_async (|)
    is also<close-async>
  { * }

  multi method close_async (
    Int()          $io_priority,
                   &callback,
    gpointer       $user_data    = gpointer
  ) {
    samewith($io_priority, GCancellable, &callback, $user_data);
  }
  multi method close_async (
    Int()          $io_priority,
    GCancellable() $cancellable,
                   &callback,
    gpointer       $user_data    = gpointer
  ) {
    my gint $io = $io_priority;

    g_io_stream_close_async($!ios, $io, $cancellable, &callback, $user_data);
  }

  method close_finish (
    GAsyncResult()          $result,
    CArray[Pointer[GError]] $error   = gerror
  )
    is also<close-finish>
  {
    clear_error;
    my $rv = so g_io_stream_close_finish($!ios, $result, $error);
    set_error($error);
    $rv;
  }

  method get_input_stream (:$raw = False)
    is also<get-input-stream>
  {
    my $is = g_io_stream_get_input_stream($!ios);

    $is ??
      ( $raw ?? $is !! GIO::InputStream.new($is, :!ref) )
      !!
      Nil
  }

  method get_output_stream (:$raw = False)
    is also<get-output-stream>
  {
    my $os = g_io_stream_get_output_stream($!ios);

    $os ??
      ( $raw ?? $os !! GIO::OutputStream.new($os, :!ref) )
      !!
      Nil;
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_io_stream_get_type, $n, $t );
  }

  method has_pending is also<has-pending> {
    so g_io_stream_has_pending($!ios);
  }

  method is_closed is also<is-closed> {
    so g_io_stream_is_closed($!ios);
  }

  method set_pending (
    CArray[Pointer[GError]] $error = gerror
  )
    is also<set-pending>
  {
    g_io_stream_set_pending($!ios, $error);
  }

  proto method splice_async (|)
    is also<splice-async>
  { * }

  multi method splice_async (
    GIOStream()         $stream2,
    Int()               $flags,
    Int()               $io_priority,
                        &callback,
    gpointer            $user_data    = gpointer
  ) {
    samewith(
      $stream2,
      $flags,
      $io_priority,
      GCancellable,
      &callback,
      $user_data
    );
  }
  multi method splice_async (
    GIOStream()         $stream2,
    Int()               $flags,
    Int()               $io_priority,
    GCancellable()      $cancellable,
                        &callback,
    gpointer            $user_data    = gpointer
  ) {
    my gint                 $io = $io_priority;
    my GIOStreamSpliceFlags $f  = $flags;

    g_io_stream_splice_async(
      $!ios,
      $stream2,
      $f,
      $io,
      $cancellable,
      &callback,
      $user_data
    );
  }

  method splice_finish (
    GAsyncResult()          $result,
    CArray[Pointer[GError]] $error   = gerror
  )
    is also<splice-finish>
  {
    clear_error;
    my $rv = so g_io_stream_splice_finish($result, $error);
    set_error($error);
    $rv;
  }

}
