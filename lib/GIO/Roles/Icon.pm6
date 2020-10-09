use v6.c;

use Method::Also;
use NativeCall;

use GLib::Variant;

use GIO::Raw::Types;
use GIO::Raw::Icon;

use GLib::Roles::Object;

our subset GIconAncestry is export of Mu
  where GIcon | GObject;

role GIO::Roles::Icon does GLib::Roles::Object {
  has GIcon $!icon;

  method ROLEBUILD (:$icon) {
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

  method new-icon-obj (GIconAncestry $icon, :$ref = True) {
    return Nil unless $icon;

    my $o = self.bless( :$icon );
    $o.ROLEBUILD( :$icon );
    $o.ref if $ref;
    $o;
  }

  method new_for_string (
    Str() $name,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<new-for-string>
  {
    clear_error;
    my $icon = g_icon_new_for_string($name, $error);
    set_error($error);

    $icon ?? self.bless( :$icon ) !! Nil;
  }


  # ↓↓↓↓ SIGNALS ↓↓↓↓
  # ↑↑↑↑ SIGNALS ↑↑↑↑

  # ↓↓↓↓ ATTRIBUTES ↓↓↓↓
  # ↑↑↑↑ ATTRIBUTES ↑↑↑↑

  # ↓↓↓↓ METHODS ↓↓↓↓
  method deserialize(
    GIO::Roles::Icon:U:
    GVariant() $v,
    :$raw = False
  ) {
    my $i = g_icon_deserialize($v);

    $i ??
      ( $raw ?? $i !! self.bless( icon => $i ) )
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

  multi method hash(GIO::Roles::Icon:D:) {
    GIO::Roles::Icon.hash($!icon);
  }
  multi method hash (GIO::Roles::Icon:U: GIcon() $i) {
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
