use v6.c;

use Method::Also;

use NativeCall;

use GIO::Raw::Types;

use GLib::Bytes;

use GLib::Roles::Object;
use GIO::Roles::Icon;
use GIO::Roles::LoadableIcon;

our subset GBytesIconAncestry is export of Mu
  where GBytesIcon | GLoadableIcon | GIcon | GObject;

class GIO::BytesIcon {
  also does GLib::Roles::Object;
  also does GIO::Roles::Icon;
  also does GIO::Roles::LoadableIcon;

  has GBytesIcon $!bi is implementor;

  submethod BUILD (:$bytes-icon, :$icon) {
    self.setGBytesIcon($bytes-icon // $icon) if $bytes-icon || $icon;
  }

  method setGBytesIcon (GBytesIconAncestry $_) {
    my $to-parent;

    $!bi = do {
      when GBytesIcon {
        $to-parent = cast(GObject, $_);
        $_;
      }

      when GLoadableIcon {
        $to-parent = cast(GObject, $_);
        $!li = $_;
        cast(GBytesIcon, $_);
      }

      when GIcon {
        $to-parent = cast(GObject, $_);
        $!icon = $_;
        cast(GBytesIcon, $_);
      }

      default {
        $to-parent = $_;
        cast(GBytesIcon, $_);
      }
    }

    self.roleInit-Object;
    self.roleInit-Icon;
    self.roleInit-LoadableIcon;
  }

  method GIO::Raw::Definitions::GBytesIcon
    is also<GBytesIcon>
  { $!bi }

  multi method new (GBytesIconAncestry $bytes-icon, :$ref = True) {
    return Nil unless $bytes-icon;

    my $o = self.bless( :$bytes-icon );
    $o.ref if $ref;
    $o;
  }
  multi method new (GBytes() $bytes) {
    my $bytes-icon = g_bytes_icon_new($bytes);

    $bytes-icon ?? self.bless( :$bytes-icon ) !! Nil;
  }

  method get_bytes (:$raw = False)
    is also<
      get-bytes
      bytes
    >
  {
    my $b = g_bytes_icon_get_bytes($!bi);

    $b ??
      ( $raw ?? $b !! GLib::Bytes.new($b) )
      !!
      Nil;
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_bytes_icon_get_type, $n, $t );
  }

}

### /usr/src/glib/gio/gbytesicon.h

sub g_bytes_icon_get_bytes (GBytesIcon $icon)
  returns GBytes
  is native(gio)
  is export
{ * }

sub g_bytes_icon_get_type ()
  returns GType
  is native(gio)
  is export
{ * }

sub g_bytes_icon_new (GBytes $bytes)
  returns GBytesIcon
  is native(gio)
  is export
{ * }

# our %GIO::BytesIcon::RAW-DEFS;
# for MY::.pairs {
#   %GIO::BytesIcon::RAW-DEFS{.key} := .value if .key.starts-with('&g_bytes_');
# }
