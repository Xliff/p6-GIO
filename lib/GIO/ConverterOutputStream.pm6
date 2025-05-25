use v6.c;

use Method::Also;

use NativeCall;

use GIO::Raw::Types;

use GIO::FilterOutputStream;

use GIO::Roles::Converter;
use GIO::Roles::PollableOutputStream;

our subset ConverterOutputStreamAncestry is export of Mu
  where GConverterOutputStream       | GPollableOutputStream |
        GFilterOutputStreamAncestry;

class GIO::ConverterOutputStream is GIO::FilterOutputStream {
  also does GIO::Roles::Converter;
  also does GIO::Roles::PollableOutputStream;

  has GConverterOutputStream $!cos is implementor;

  submethod BUILD (:$convert-stream) {
    self.setConverterOutputStream($convert-stream) if $convert-stream;
  }

  method setConverterOutputStream(ConverterOutputStreamAncestry $_) {
    my $to-parent;

    $!cos = do {
      when GConverterOutputStream {
        $to-parent = cast(GFilterOutputStream, $_);
        $_;
      }

      when GPollableOutputStream {
        $to-parent = cast(GFilterOutputStream, $_);
        $!pos = $_;
        cast(GConverterOutputStream, $_);
      }

      default {
        $to-parent = $_;
        cast(GConverterOutputStream, $_);
      }
    }
    self.roleInit-PollableOutputStream;
    self.setGFilterOutputStream($to-parent);
  }

  method GIO::Raw::Definitions::GConverterOutputStream
    is also<GConverterOutputStream>
  { $!cos }

  proto method new (|)
  { * }

  multi method new (
    ConverterOutputStreamAncestry $convert-stream,
    :$ref = True
  ) {
    return Nil unless $convert-stream;

    my $o = self.bless( :$convert-stream );
    $o.ref if $ref;
    $o;
  }
  multi method new (GOutputStream() $base, GConverter() $converter) {
    my $convert-stream = g_converter_output_stream_new($base, $converter);

    $convert-stream ?? self.bless( :$convert-stream ) !! Nil;
  }

  method get_converter (:$raw = False) is also<get-converter> {
    my $c = g_converter_output_stream_get_converter($!cos);

    $c ??
      ( $raw ?? $c !! GIO::Converter.new($c, :!ref) )
      !!
      Nil;
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type(
      self.^name,
      &g_converter_output_stream_get_type,
      $n,
      $t
    );
  }

}


### gio/gconverteroutputstream.h

sub g_converter_output_stream_get_converter (
  GConverterOutputStream $converter_stream
)
  returns GConverter
  is native(gio)
  is export
{ * }

sub g_converter_output_stream_get_type ()
  returns GType
  is native(gio)
  is export
{ * }

sub g_converter_output_stream_new (
  GOutputStream $base_stream,
  GConverter    $converter
)
  returns GConverterOutputStream
  is native(gio)
  is export
{ * }

# our %GIO::ConverterOutputStream::RAW-DEFS;
# for MY::.pairs {
#   %GIO::ConverterOutputStream::RAW-DEFS{.key} := .value
#     if .key.starts-with('&g_converter_output_stream_');
# }
