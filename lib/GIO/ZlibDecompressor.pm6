use v6.c;

use Method::Also;

use NativeCall;

use GIO::Raw::Types;

use GLib::Value;
use GIO::FileInfo;

use GLib::Roles::Properties;
use GIO::Roles::Converter;

class GIO::ZlibDecompressor {
  also does GLib::Roles::Properties;
  also does GIO::Roles::Converter;

  has GZlibDecompressor $!zd is implementor;

  submethod BUILD (:$decompressor) {
    $!zd = $decompressor;

    self.roleInit-Object;
    self.roleInit-Converter;
  }

  method GIO::Raw::Definitions::GZlibDecompressor
    is also<GZlibDecompressor>
  { $!zd }

  method new (Int() $format) {
    my GZlibCompressorFormat $f = $format;

    self.bless( decompressor => g_zlib_decompressor_new($f) );
  }

  # Type: GZlibCompressorFormat
  method format is rw  {
    my GLib::Value $gv .= new( typeToGType(GZlibCompressorFormat) );
    Proxy.new(
      FETCH => sub ($) {
        $gv = GLib::Value.new(
          self.prop_get('format', $gv)
        );
        GZlibCompressorFormatEnum( $gv.value );
      },
      STORE => -> $, Int() $val is copy {
        $gv.value = $val;
        self.prop_set('format', $gv);
      }
    );
  }


  method get_file_info (:$raw = False) is also<get-file-info> {
    my $fi = g_zlib_decompressor_get_file_info($!zd);

    $fi ??
      ( $raw ?? $fi !! GIO::FileInfo.new($fi) )
      !!
      Nil;
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_zlib_decompressor_get_type, $n, $t );
  }

}

sub g_zlib_decompressor_get_file_info (GZlibDecompressor $decompressor)
  returns GFileInfo
  is native(gio)
  is export
{ * }

sub g_zlib_decompressor_get_type ()
  returns GType
  is native(gio)
  is export
{ * }

sub g_zlib_decompressor_new (GZlibCompressorFormat $format)
  returns GZlibDecompressor
  is native(gio)
  is export
{ * }
