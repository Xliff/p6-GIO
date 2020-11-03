use v6.c;

use Method::Also;

use GIO::Raw::Types;
use GIO::Raw::FilterOutputStream;

use GIO::OutputStream;

our subset GFilterOutputStreamAncestry is export of Mu
  where GFilterOutputStream | GOutputStream;

class GIO::FilterOutputStream is GIO::OutputStream {
  has GFilterOutputStream $!fis is implementor;

  submethod BUILD (:$filter-stream) {
    self.setFilterOutputStream($filter-stream) if $filter-stream;
  }

  method setGFilterOutputStream (GFilterOutputStreamAncestry $_) {
    my $to-parent;

    $!fis = do {
      when GFilterOutputStream {
        $to-parent = cast(GOutputStream, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GFilterOutputStream, $_);
      }
    };
    self.setGOutputStream($to-parent);
  }

  method GIO::Raw::Definitions::GFilterOutputStream
    is also<GFilterOutputStream>
  { $!fis }

  proto method new(|)
  { * }

  multi method new (GFilterOutputStreamAncestry $filter-stream, :$ref = True) {
    return Nil unless $filter-stream;

    my $o = self.bless( :$filter-stream );
    $o.ref if $ref;
    $o;
  }

  method close_base_stream is rw is also<close-base-stream> {
    Proxy.new(
      FETCH => sub ($) {
        so g_filter_output_stream_get_close_base_stream($!fis);
      },
      STORE => sub ($, Int() $close_base is copy) {
        my gboolean $c  = $close_base.so.Int;

        g_filter_output_stream_set_close_base_stream($!fis, $c);
      }
    );
  }

  method get_base_stream (:$raw = False)
    is also<
      get-base-stream
      base_stream
      base-stream
    >
  {
    my $bs = g_filter_output_stream_get_base_stream($!fis);

    $bs ??
      ( $raw ?? $bs !! GIO::OutputStream.new($bs, :!ref) )
      !!
      Nil;
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_filter_output_stream_get_type, $n, $t );
  }

}
