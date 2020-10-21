use v6.c;

use Method::Also;
use NativeCall;

use GIO::Raw::Types;

use GLib::Value;

use GLib::Roles::Object;
use GIO::Roles::Converter;

our subset GZlibCompressorAncestry is export of Mu
  where GZlibCompressor | GConverter | GObject;

class GIO::ZlibCompressor {
  also does GIO::Roles::Converter;

  has GZlibCompressor $!zc is implementor;

  submethod BUILD ( :$compressor ) {
    self.setGZlibCompressor($compressor) if $compressor;
  }

  method setGZlibCompressor (GZlibCompressorAncestry $_) {
    my $to-parent;

    $!zc = do {
      when GZlibCompressor {
        $to-parent = cast(GObject, $_);
        $_;
      }

      when GConverter {
        $to-parent = cast(GObject, $_);
        $!c = $_;
        cast(GZlibCompressor, $_);
      }

      default {
        $to-parent = $_;
        cast(GZlibCompressor, $_);
      }
    }
    self!setObject($to-parent);
    self.roleInit-Converter;
  }

  method GIO::Raw::Definitions::GZlibCompressor
    is also<GZlibCompressor>
  { $!zc }

  multi method new (GZlibCompressorAncestry $compressor, :$ref = True) {
    return Nil unless $compressor;

    my $o = self.bless( :$compressor );
    $o.ref if $ref;
    $o;
  }
  multi method new (Int() $level) {
    my gint $l          = $level;
    my      $compressor = g_zlib_compressor_new($!zc, $l);

    $compressor ?? self.bless( :$compressor ) !! Nil;
  }

  method file_info (:$raw = False) is rw is also<file-info> {
    Proxy.new(
      FETCH => sub ($) {
        my $fi = g_zlib_compressor_get_file_info($!zc);

        $fi ??
          ( $raw ?? $fi !! GLib::FileInfo.new($fi, :!ref) )
          !!
          Nil;
      },
      STORE => sub ($, GFileInfo() $file_info is copy) {
        g_zlib_compressor_set_file_info($!zc, $file_info);
      }
    );
  }

  # Type: GZlibCompressorFormat
  method format is rw  {
    my GLib::Value $gv .= new( G_TYPE_UINT );
    Proxy.new(
      FETCH => -> $ {
        $gv = GLib::Value.new(
          self.prop_get('format', $gv)
        );
        GZlibCompressorFormatEnum( $gv.uint )
      },
      STORE => -> $, Int() $val is copy {
        $gv.uint = $val;
        self.prop_set('format', $gv);
      }
    );
  }

  # Type: gint
  method level is rw  {
    my GLib::Value $gv .= new( G_TYPE_INT );
    Proxy.new(
      FETCH => -> $ {
        $gv = GLib::Value.new(
          self.prop_get('level', $gv)
        );
        $gv.int;
      },
      STORE => -> $, Int() $val is copy {
        $gv.int = $val;
        self.prop_set('level', $gv);
      }
    );
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_zlib_compressor_get_type, $n, $t );
  }

}

sub g_zlib_compressor_get_type ()
  returns GType
  is native(gio)
  is export
{ * }

sub g_zlib_compressor_new (GZlibCompressorFormat $format, gint $level)
  returns GZlibCompressor
  is native(gio)
  is export
{ * }

sub g_zlib_compressor_get_file_info (GZlibCompressor $compressor)
  returns GFileInfo
  is native(gio)
  is export
{ * }

sub g_zlib_compressor_set_file_info (
  GZlibCompressor $compressor,
  GFileInfo       $file_info
)
  is native(gio)
  is export
{ * }

# our %GIO::ZlibCompressor::RAW-DEFS;
# for MY::.pairs {
#   %GIO::ZlibCompressor::RAW-DEFS{.key} := .value
#     if .key.starts-with('&g_zlib_compressor_');
# }
