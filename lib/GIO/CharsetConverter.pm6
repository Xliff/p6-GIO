use v6.c;

use Method::Also;

use NativeCall;

use GIO::Raw::Types;
use GIO::Raw::CharsetConverter;

use GLib::Value;

use GLib::Roles::Properties;
use GLib::Roles::Object;
use GIO::Roles::Converter;
use GIO::Roles::Initable;

our subset GCharsetConverterAncestry is export of Mu
  where GCharsetConverter | GConverter | GInitable | GObject;

class GIO::CharsetConverter {
  also does GLib::Roles::Object;
  also does GIO::Roles::Converter;
  also does GIO::Roles::Initable;

  has GCharsetConverter $!cc is implementor;

  submethod BUILD (:$char-converter) {
    self.setGCharsetConverter($char-converter) if $char-converter;
  }

  method setGCharsetConverter (GCharsetConverterAncestry $_) {
    my $to-parent;

    $!cc = do {
      when GCharsetConverter {
        $to-parent = cast(GObject, $_);
        $_;
      }

      when GConverter {
        $to-parent = cast(GObject, $_);
        $!c = $_;
        cast(GCharsetConverter, $_);
      }

      when GInitable {
        $to-parent = cast(GObject, $_);
        $!i = $_;
        cast(GCharsetConverter, $_);
      }

      default {
        $to-parent = cast(GObject, $_);
        cast(GCharsetConverter, $_);
      }
    }

    self.roleInit-Object;
    self.roleInit-Converter unless $!c;
    self.roleInit-Initable  unless $!i;
  }

  method GTK::Compat::Raw::GCharsetConverter
    is also<GCharsetConverter>
  { $!cc }

  multi method new (GCharsetConverterAncestry $char-converter, :$ref = True) {
    return Nil unless $char-converter;

    my $o = self.bless( :$char-converter );
    $o.ref if $ref;
    $o;
  }
  multi method new (
    Str()                   $to_charset,
    Str()                   $from_charset,
    CArray[Pointer[GError]] $error        = gerror
  ) {
    clear_error;
    my $char-converter = g_charset_converter_new(
      $to_charset,
      $from_charset,
      $error
    );
    set_error($error);

    $char-converter ?? self.bless( :$char-converter ) !! Nil;
  }

  my %attributes = (
    from-charset => G_TYPE_STRING,
    to-charset   => G_TYPE_STRING,
    use-fallback => G_TYPE_BOOLEAN
  );

  method attributes ($key) {
    %attributes{$key}:exists ?? %attributes{$key}
                             !! die "Attribute '{ $key }' does not exist"
  }

  method new_initable (:$init = True, :$cancellable = Callable, *%options)
    is also<new-initable>
  {
    my $char-converter = self.new_object_with_properties(:raw, |%options);

    $char-converter ?? self.bless(
                        :$char-converter,
                        :$init,
                        :$cancellable
                       )
                    !! Nil
  }

  # Type: Str
  method from-charset is rw  is also<from_charset> {
    my GLib::Value $gv .= new( G_TYPE_STRING );
    Proxy.new(
      FETCH => -> $ {
        $gv = GLib::Value.new(
          self.prop_get('from-charset', $gv)
        );
        $gv.string;
      },
      STORE => -> $, Str() $val is copy {
        $gv.string = $val;
        self.prop_set('from-charset', $gv);
      }
    );
  }

  # Type: Str
  method to-charset is rw  is also<to_charset> {
    my GLib::Value $gv .= new( G_TYPE_STRING );
    Proxy.new(
      FETCH => -> $ {
        $gv = GLib::Value.new(
          self.prop_get('to-charset', $gv)
        );
        $gv.string;
      },
      STORE => -> $, Str() $val is copy {
        $gv.string = $val;
        self.prop_set('to-charset', $gv);
      }
    );
  }

  # Type: gboolean
  method use_fallback is rw is also<use-fallback> {
    Proxy.new(
      FETCH => sub ($) {
        so g_charset_converter_get_use_fallback($!cc);
      },
      STORE => sub ($, Int() $use_fallback is copy) {
        my gboolean $u = $use_fallback.so.Int;

        g_charset_converter_set_use_fallback($!cc, $u);
      }
    );
  }

  method get_num_fallbacks
    is also<
      get-num-fallbacks
      num_fallbacks
      num-fallbacks
    >
  {
    g_charset_converter_get_num_fallbacks($!cc);
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_charset_converter_get_type, $n, $t );
  }

}
