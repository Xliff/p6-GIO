use v6.c;

use Method::Also;

use NativeCall;

use GIO::Raw::Types;

use GIO::FilterInputStream;

use GIO::Roles::Converter;
use GIO::Roles::PollableInputStream;

our subset ConverterInputStreamAncestry is export of Mu
  where GConverterInputStream      | GPollableInputStream |
        GFilterInputStreamAncestry;

class GIO::ConverterInputStream is GIO::FilterInputStream {
  also does GIO::Roles::Converter;
  also does GIO::Roles::PollableInputStream;

  has GConverterInputStream $!cis is implementor;

  submethod BUILD (:$convert-stream) {
    self.setConverterInputStream($convert-stream) if $convert-stream;
  }

  method setConverterInputStream(ConverterInputStreamAncestry $_) {
    my $to-parent;

    $!cis = do {
      when GConverterInputStream {
        $to-parent = cast(GFilterInputStream, $_);
        $_
      }

      when GPollableInputStream {
        $to-parent = cast(GFilterInputStream, $_);
        $!pis = $_;
        cast(GConverterInputStream, $_);
      }

      default {
        $to-parent = $_;
        cast(GConverterInputStream, $_);
      }
    }
    self.setGFilterInputStream($to-parent);
    self.roleInit-PollableInputStream;
  }

  method GIO::Raw::Definitions::GConverterInputStream
    is also<GConverterInputStream>
  { $!cis }

  proto method new (|)
  { * }

  multi method new (
    ConverterInputStreamAncestry $convert-stream,
    :$ref = True
  ) {
    return Nil unless $convert-stream;

    my $o = self.bless( :$convert-stream );
    $o.ref if $ref;
    $o;
  }
  multi method new (GInputStream() $base, GConverter() $converter) {
    my $convert-stream = g_converter_input_stream_new($base, $converter);

    $convert-stream ?? self.bless( :$convert-stream ) !! Nil;
  }

  method get_converter (:$raw = False) is also<get-converter> {
    my $c = g_converter_input_stream_get_converter($!cis);

    $c ??
      ( $raw ?? $c !! GIO::Converter.new($c, :!ref) )
      !!
      Nil;
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type(
      self.^name,
      &g_converter_input_stream_get_type,
      $n,
      $t
    );
  }

}

### /usr/src/glib/gio/gconverterinputstream.h

sub g_converter_input_stream_get_converter (
  GConverterInputStream $converter_stream
)
  returns GConverter
  is native(gio)
  is export
{ * }

sub g_converter_input_stream_get_type ()
  returns GType
  is native(gio)
  is export
{ * }

sub g_converter_input_stream_new (
  GInputStream $base_stream,
  GConverter   $converter
)
  returns GConverterInputStream
  is native(gio)
  is export
{ * }

# our %GIO::ConverterInputStream::RAW-DEFS;
# for MY::.pairs {
#   %GIO::ConverterInputStream::RAW-DEFS{.key} := .value
#     if .key.starts-with('&g_converter_input_stream_');
# }
