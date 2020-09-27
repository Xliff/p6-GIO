use v6.c;

use NativeCall;

use GIO::Raw::Types;

role GIO::Roles::Converter {
  has GConverter $!c;

  submethod BUILD (:$conv) {
    $!c = $conv;
  }

  method roleInit-Converter {
    return if $!c;

    my \i = findProperImplementor(self.^attributes);
    $!c = cast( GConverter, i.get_value(self) );
  }

  method new-converter-obj (GConverter $conv) {
    $conv ?? self.bless( :$conv ) !! Nil;
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

  method converter_get_type {
    state ($n, $t);

    unstable_get_type( self.^name, &g_converter_get_type, $n, $t );
  }

  method reset {
    g_converter_reset($!c);
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
