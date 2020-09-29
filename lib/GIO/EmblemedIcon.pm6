use v6.c;

use Method::Also;

use GIO::Raw::Types;
use GIO::Raw::EmblemedIcon;

use GLib::GList;
use GIO::Emblem;

use GLib::Roles::Object;
use GLib::Roles::ListData;
use GIO::Roles::Icon;

our subset GEmblemedIconAncestry is export of Mu
  where GEmblemedIcon | GIcon | GObject;

class GIO::EmblemedIcon {
  also does GLib::Roles::Object;
  also does GIO::Roles::Icon;

  has GEmblemedIcon $!ei is implementor;

  submethod BUILD (:$emblem) {
    self.setEmblemedIcon($emblem) if $emblem;
  }

  method setGEmblemedIcon (GEmblemedIconAncestry $_) {
    my $to-parent;

    $!ei = {
      when GEmblemedIcon {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GEmblemedIcon, $_);
      }
    }
    self!setObject($to-parent);
    self.roleInit-Icon;
  }

  method GIO::Raw::Definitions::GEmblemedIcon
    is also<GEmblemedIcon>
  { $!ei }

  multi method new (GEmblemedIconAncestry $emblem, :$ref = True) {
    return Nil unless $emblem;

    my $o = self.bless( :$emblem );
    $o.ref if $ref;
    $o;
  }
  multi method new (GIcon() $icon, GEmblem() $e) {
    my $emblem = g_emblemed_icon_new($icon, $e);

    $emblem ?? self.bless( :$emblem ) !! Nil;
  }

  method add_emblem (GEmblem() $emblem) is also<add-emblem> {
    g_emblemed_icon_add_emblem($!ei, $emblem);
  }

  method clear_emblems is also<clear-emblems> {
    g_emblemed_icon_clear_emblems($!ei);
  }

  method get_emblems (:$glist = False, :$raw = False)
    is also<
      get-emblems
      emblems
    >
  {
    my $el = g_emblemed_icon_get_emblems($!ei);
    return Nil unless $el;
    return $el if $glist && $raw;

    $el = GLib::GList.new($el)
      but GLib::Roles::ListData[GEmblem];
    return $el if $glist;

    $raw ?? $el.Array !! $el.Array.map({ GIO::Emblem.new($_) });
  }

  method get_icon (:$raw = False)
    is also<
      get-icon
      icon
      gicon
    >
  {
    my $i = g_emblemed_icon_get_icon($!ei);

    $i ??
      ( $raw ?? $i !! GIO::Roles::Icon.new-icon-obj($i, :!ref) )
      !!
      Nil;
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_emblemed_icon_get_type, $n, $t );
  }

}
