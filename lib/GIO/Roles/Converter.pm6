use v6.c;

use Method::Also;
use NativeCall;

use GIO::Raw::Types;

use GLib::Roles::Object;

role GIO::Roles::Converter does GLib::Roles::Object {
  has GConverter $!c;

  method roleInit-Converter is also<roleInit_Converter> {
    return if $!c;

    my \i = findProperImplementor(self.^attributes);
    $!c = cast( GConverter, i.get_value(self) );
  }

  multi method convert (
    Pointer                 $inbuf,
    Int()                   $inbuf_size,
    Pointer                 $outbuf,
    Int()                   $outbuf_size,
    Int()                   $flags,
    CArray[Pointer[GError]] $error       = gerror,
  ) {
    return-with-all(
      samewith(
        $inbuf,
        $inbuf_size,
        $outbuf,
        $outbuf_size,
        $flags,
        $,
        $,
        $error,
        :all
      )
    );
  }
  multi method convert (
    Pointer                 $inbuf,
    Int()                   $inbuf_size,
    Pointer                 $outbuf,
    Int()                   $outbuf_size,
    Int()                   $flags,
                            $bytes_read    is rw,
                            $bytes_written is rw,
    CArray[Pointer[GError]] $error         = gerror,
                            :$all          = False
  ) {
    my gsize ($is, $os, $br, $bw) = ($inbuf_size, $outbuf_size, 0, 0);
    my GConverterFlags $f = $flags;

    clear_error;
    my $rv = GConverterResultEnum(
      g_converter_convert($!c, $inbuf, $is, $outbuf, $os, $f, $br, $bw, $error)
    );
    set_error($error);
    ($bytes_read, $bytes_written) = ($br, $bw);

    $all.not ?? $rv !! ($rv, $bytes_read, $bytes_written)
  }

  method converter_get_type is also<converter-get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_converter_get_type, $n, $t );
  }

  method reset {
    g_converter_reset($!c);
  }

}

our subset GConverterAncestry is export of Mu
  where GConverter | GObject;

class GIO::Converter does GIO::Roles::Converter {

  submethod BUILD (:$conv) {
    self.setGConverter($conv) if $conv;
  }

  method setGConverter (GConverterAncestry $_) {
    my $to-parent;

    $!c = do {
      when GConverter {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GConverter, $_);
      }
    }
    self!setObject($to-parent);
  }

  method new (GConverterAncestry $conv, :$ref = True) {
    return Nil unless $conv;

    my $o = self.bless( :$conv );
    $o.ref if $ref;
    $o;
  }

}

sub g_converter_convert (
  GConverter              $converter,
  Pointer                 $inbuf,
  gsize                   $inbuf_size,
  Pointer                 $outbuf,
  gsize                   $outbuf_size,
  GConverterFlags         $flags,
  gsize                   $bytes_read    is rw,
  gsize                   $bytes_written is rw,
  CArray[Pointer[GError]] $error
)
  returns GConverterResult
  is native(gio)
  is export
{ * }

sub g_converter_get_type ()
  returns GType
  is native(gio)
  is export
{ * }

sub g_converter_reset (GConverter $converter)
  is native(gio)
  is export
{ * }

# our %GIO::Roles::Converter::RAW-DEFS;
# for MY::.pairs {
#   %GIO::Roles::Converter::RAW-DEFS{.key} := .value
#     if .key.starts-with('&g_converter_');
# }
