use v6.c;

use Method::Also;
use NativeCall;

use GLib::Variant;

use GIO::Raw::Types;
use GIO::Raw::Icon;

use GLib::Roles::Object;

role  GIO::Roles::Icon { ... }
class GIO::Icon        { ... }

role GIO::Roles::Icon does GLib::Roles::Object {
  has GIcon $!icon;

  method new_for_string (
    Str()                   $name,
    CArray[Pointer[GError]] $error = gerror,
                            :$raw  = False
  )
    is also<new-for-string>
  {
    clear_error;
    my $icon = g_icon_new_for_string($name, $error);
    set_error($error);
    return $icon if $raw;

    $icon ?? self.bless( :$icon ) !! Nil;
  }

  method roleInit-Icon {
    return if $!icon;

    my \i = findProperImplementor(self.^attributes);
    $!icon = cast( GIcon, i.get_value(self) );
  }

  method GIcon { $!icon }
  method GIO::Raw::Definitions::GIcon
    is also<
      GIcon
      Icon
    >
  { $!icon }


  # ↓↓↓↓ SIGNALS ↓↓↓↓
  # ↑↑↑↑ SIGNALS ↑↑↑↑

  # ↓↓↓↓ ATTRIBUTES ↓↓↓↓
  # ↑↑↑↑ ATTRIBUTES ↑↑↑↑

  # ↓↓↓↓ METHODS ↓↓↓↓
  method deserialize(
    ::?CLASS:U:
    GVariant() $v,
    :$raw = False
  ) {
    my $i = g_icon_deserialize($v);

    $i ??
      ( $raw ?? $i !! GIO::Icon.new($i, :!ref) )
      !!
      Nil;
  }

  method equal (GIcon() $icon2) {
    so g_icon_equal($!icon, $icon2);
  }

  method icon_get_type is also<icon-get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_icon_get_type, $n, $t );
  }

  multi method hash(::?CLASS:D:) {
    GIO::Roles::Icon.hash($!icon);
  }
  multi method hash (::?CLASS:U: GIcon() $i) {
    g_icon_hash($i);
  }

  method serialize (:$raw = False) {
    my $si = g_icon_serialize($!icon);

    $si ??
      ( $raw ?? $si !! GLib::Variant.new($si, :!ref) )
      !!
      Nil
  }

  method to_string
    is also<
      to-string
      Str
    >
  {
    g_icon_to_string($!icon);
  }
  # ↑↑↑↑ METHODS ↑↑↑↑

}

our subset GIconAncestry is export of Mu
  where GIcon | GObject;

class GIO::Icon does GIO::Roles::Icon {

  method BUILD (:$icon) {
    self.setGIcon($icon) if $icon;
  }

  method setGIcon (GIconAncestry $_) {
    my $to-parent;

    $!icon = do {
      when GIcon {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GIcon, $_);
      }
    }
    self!setObject($to-parent);
    self.roleInit-Icon;
  }

  method new (GIconAncestry $icon, :$ref = True) {
    return Nil unless $icon;

    my $o = self.bless( :$icon );
    $o.ref if $ref;
    $o;
  }

}
