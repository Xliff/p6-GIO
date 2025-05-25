use v6.c;

use Method::Also;
use NativeCall;

use NativeHelpers::Blob;

use GIO::Raw::Types;
use GIO::Raw::BufferedInputStream;

use GIO::FilterInputStream;

use GIO::Roles::Seekable;

our subset GBufferedInputStreamAncestry is export of Mu
  where GBufferedInputStream | GSeekable | GFilterInputStreamAncestry;

class GIO::BufferedInputStream is GIO::FilterInputStream {
  also does GIO::Roles::Seekable;

  has GBufferedInputStream $!bis is implementor;

  submethod BUILD (:$buffered-stream) {
    self.setGBufferedInputStream($buffered-stream) if $buffered-stream;
  }

  method setGBufferedInputStream (GBufferedInputStreamAncestry $_) {
    my $to-parent;

    $!bis = do {
      when GBufferedInputStream {
        $to-parent = cast(GFilterInputStream, $_);
        $_;
      }

      when GSeekable {
        $to-parent = cast(GFilterInputStream, $_);
        $!s = $_;
        cast(GBufferedInputStream, $_);
      }

      default {
        $to-parent = $_;
        cast(GBufferedInputStream, $_);
      }
    }
    self.setGFilterInputStream($to-parent);
    self.roleInit-Seekable;
  }

  method GIO::Raw::Definitions::GBufferedInputStream
    is also<GBufferedInputStream>
  { $!bis }

  proto method new (|)
  { * }

  multi method new (
    GBufferedInputStreamAncestry $buffered-stream,
                                 :$ref             = True)
  {
    return Nil unless $buffered-stream;

    my $o = self.bless( :$buffered-stream );
    $o.ref if $ref;
    $o;
  }
  multi method new (GIO::InputStream $base) {
    my $buffered-stream = g_buffered_input_stream_new($base.GInputStream);

    $buffered-stream ?? self.bless( :$buffered-stream ) !! Nil;
  }
  multi method new (GInputStream() $base, Int() $size, :$sized is required) {
    self.new_sized($base, $size);
  }

  method new_sized (GInputStream() $base, Int() $size) is also<new-sized> {
    my gsize $s               = $size;
    my       $buffered-stream = g_buffered_input_stream_new_sized($base, $s);

    $buffered-stream ?? self.bless( :$buffered-stream ) !! Nil;
  }

  method buffer_size is rw is also<buffer-size> {
    Proxy.new(
      FETCH => sub ($) {
        g_buffered_input_stream_get_buffer_size($!bis);
      },
      STORE => sub ($, Int() $size is copy) {
        my gsize $s = $size;

        g_buffered_input_stream_set_buffer_size($!bis, $s);
      }
    );
  }

  method fill (
    Int()                   $count,
    GCancellable()          $cancellable = GCancellable,
    CArray[Pointer[GError]] $error       = gerror
  ) {
    my gssize $c = $count;

    clear_error;
    my $rv = g_buffered_input_stream_fill($!bis, $c, $cancellable, $error);
    set_error($error);
    $rv;
  }

  proto method fill_async (|)
    is also<fill-async>
  { * }

  multi method fill_async (
    Int()    $count,
    Int()    $io_priority,
             &callback,
    gpointer $user_data    = gpointer
  ) {
    samewith($count, $io_priority, GCancellable, &callback, $user_data);
  }
  multi method fill_async (
    Int()          $count,
    Int()          $io_priority,
    GCancellable() $cancellable,
                   &callback,
    gpointer       $user_data    = gpointer
  ) {
    my gsize $c = $count;
    my gint $i = $io_priority;

    g_buffered_input_stream_fill_async(
      $!bis,
      $c,
      $i,
      $cancellable,
      &callback,
      $user_data
    );
  }

  method fill_finish (
    GAsyncResult()          $result,
    CArray[Pointer[GError]] $error   = gerror
  )
    is also<fill-finish>
  {
    clear_error;
    my $rv = g_buffered_input_stream_fill_finish($!bis, $result, $error);
    set_error($error);
    $rv;
  }

  method get_available
    is also<
      get-available
      available
    >
  {
    g_buffered_input_stream_get_available($!bis);
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_buffered_input_stream_get_type, $n, $t );
  }

  multi method peek (Int() $offset, Int() $count, :$raw = False) {
    my $a = CArray[uint8].allocate($offset + $count);
    samewith($a, $offset, $count);

    $raw ?? $a !! Blob.new($a);
  }
  multi method peek (Buf $buffer, Int() $offset, Int() $count) {
    samewith(
      pointer-to($buffer, typed => uint8),
      $offset,
      $count
    );
  }
  multi method peek (CArray[uint8] $buffer, Int() $offset, Int() $count) {
    samewith(
      cast(Pointer, $buffer),
      $offset,
      $count
    );
  }
  multi method peek (
    Pointer $buffer,
    Int()   $offset,
    Int()   $count,
  ) {
    my gsize ($o, $c) = ($offset, $count);

    my $b = g_buffered_input_stream_peek($!bis, $buffer, $o, $c);
  }

  proto method peek_buffer (|)
    is also<peek-buffer>
  { * }

  multi method peek_buffer (:$all = False) {
    samewith($, :$all);
  }
  multi method peek_buffer ($count is rw, :$raw = False, :$all = False) {
    my gsize $c = 0;

    # Minimize possibility of corruption by prepping buf in
    # stages
    my $b = g_buffered_input_stream_peek_buffer($!bis, $c);
    $count = $c;

    my $buf = $raw ?? $b !! Buf.new( $b[^$count] );

    $all.not ?? $buf !! ($buf, $count);
  }

  method read_byte (
    GCancellable()          $cancellable = GCancellable,
    CArray[Pointer[GError]] $error       = gerror
  )
    is also<read-byte>
  {
    clear_error;
    my $br = g_buffered_input_stream_read_byte($!bis, $cancellable, $error);
    set_error($error);
    $br;
  }

}
