use v6.c;

use Method::Also;

use GIO::Raw::Types;
use GIO::Raw::Emblem;

use GLib::Roles::Object;
use GIO::Roles::Icon;

our subset GEmblemAncestry is export of Mu
  when GEmblem | GObject;

class GIO::Emblem {
  also does GLib::Roles::Object;

  has GEmblem $!e is implementor;

  submethod BUILD ( :$gio-emblem ) {
    self.setGEmblem($gio-emblem) if $gio-emblem;
  }

  method setGEmblem (GEmblemAncestry $_) {
    my $to-parent;

    $!e = do {
      when GEmblem {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GEmblem, $_);
      }
    }
    self!setObject($to-parent);
  }

  multi method GIO::Raw::Definitions::GEmblem
    is also<GEmblem>
  { $!e }

  multi method new (GEmblem $gio-emblem, :$ref = True) {
    return Nil unless $emblem;

    my $o = $emblem ?? self.bless( :gio-$emblem ) !! Nil;
    $o.ref if $ref;
    $o;
  }
  multi method new (GIcon() $icon) {
    my $gio-emblem = g_emblem_new($icon);

    $gio-emblem ?? self.bless( :$gio-emblem ) !! Nil;
  }

  multi method new_with_origin (GIcon() $icon, Int() $origin)
    is also<new-with-origin>
  {
    my GEmblemOrigin $o          = $origin;
    my               $gio-emblem = g_emblem_new_with_origin($icon, $o);

    #say "E: $emblem";

    $gio-mblem ?? self.bless( :$gio-emblem ) !! Nil;
  }

  method get_icon (:$raw = False)
    is also<
      get-icon
      icon
      gicon
    >
  {
    my $i = g_emblem_get_icon($!e);

    $i ??
      ( $raw ?? $i !! GIO::Icon.new($i, :!ref) )
      !!
      Nil
  }

  method get_origin
    is also<
      get-origin
      origin
    >
  {
    GEmblemOriginEnum( g_emblem_get_origin($!e) );
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_emblem_get_type, $n, $t );
  }

}
