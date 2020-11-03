use v6.c;

use Method::Also;

use GIO::Raw::Types;
use GIO::Raw::BufferedOutputStream;

use GIO::FilterOutputStream;

use GLib::Roles::Object;
use GIO::Roles::Seekable;

our subset BufferedOutputStreamAncestry is export of Mu
  where GBufferedOutputStream | GSeekable | GFilterOutputStreamAncestry;

class GIO::BufferedOutputStream is GIO::FilterOutputStream {
  also does GIO::Roles::Seekable;

  has GBufferedOutputStream $!bos is implementor;

  submethod BUILD (:$buffered-stream) {
    self.setGBufferedOutputStream($buffered-stream) if $buffered-stream;
  }

  method setGBufferedOutputStream (BufferedOutputStreamAncestry $_) {
    my $to-parent;

    say "BOS: $_" if $DEBUG;

    $!bos = do {
      when GBufferedOutputStream {
        $to-parent = cast(GFilterOutputStream, $_);
        $_;
      }

      when GSeekable {
        $to-parent = cast(GFilterOutputStream, $_);
        $!s = $_;
        cast(GBufferedOutputStream, $_);
      }

      default {
        $to-parent = $_;
        cast(GBufferedOutputStream, $_);
      }
    }
    self.setFilterOutputStream($to-parent);
    self.roleInit-Seekable;
  }

  method GIO::Raw::Definitions::GBufferedOutputStream
    is also<GBufferedOutputStream>
  { $!bos }

  proto method new (|)
  { * }

  multi method new (
    BufferedOutputStreamAncestry $buffered-stream,
                                 :$ref             = True
  ) {
    return Nil unless $buffered-stream;

    my $o = self.bless( :$buffered-stream );
    $o.ref if $ref;
    $o;
  }
  multi method new (GIO::OutputStream $base) {
    my $buffered-stream = g_buffered_output_stream_new($base.GOutputStream);

    $buffered-stream ?? self.bless( :$buffered-stream ) !! Nil;
  }

  multi method new (GOutputStream() $base, Int() $size, :$sized is required) {
    self.new_sized($base, $size);
  }
  method new_sized (GOutputStream() $base, Int() $size) is also<new-sized> {
    my gsize $s               = $size;
    my       $buffered-stream = g_buffered_output_stream_new_sized($base, $s);

    $buffered-stream ?? self.bless( :$buffered-stream ) !! Nil;
  }

  method auto_grow is rw is also<auto-grow> {
    Proxy.new(
      FETCH => sub ($) {
        so g_buffered_output_stream_get_auto_grow($!bos);
      },
      STORE => sub ($, Int() $auto_grow is copy) {
        my gboolean $a = $auto_grow.so.Int;

        g_buffered_output_stream_set_auto_grow($!bos, $a);
      }
    );
  }

  method buffer_size is rw is also<buffer-size> {
    Proxy.new(
      FETCH => sub ($) {
        g_buffered_output_stream_get_buffer_size($!bos);
      },
      STORE => sub ($, Int() $size is copy) {
        my gsize $s = $size;

        g_buffered_output_stream_set_buffer_size($!bos, $s);
      }
    );
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_buffered_output_stream_get_type, $n, $t );
  }

}
