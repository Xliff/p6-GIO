use v6.c;

use Method::Also;

use GIO::Raw::Types;
use GIO::Raw::MenuModel;

use GLib::Roles::Object;

our subset GMenuLinkIterAncestry is export of Mu
  where GMenuLinkIter | GObject;

class GIO::MenuLinkIter {
  also does GLib::Roles::Object;

  has GMenuLinkIter $!mli is implementor;

  submethod BUILD (:$iter) {
    self.setGMenuLinkIter($iter) if $iter;
  }

  method setGMenuLinkIter (GMenuLinkIterAncestry $_) {
    my $to-parent;

    $!mli = do {
      when GMenuLinkIter {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GMenuLinkIter, $_);
      }
    }
    self!setObject($to-parent);
  }

  method new (GMenuLinkIter $iter, :$ref = True) {
    return Nil unless $iter;

    my $o = self.bless(:$iter);
    $o.ref if $ref;
    $o;
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_menu_link_iter_get_type, $n, $t );
  }

  method next {
    g_menu_link_iter_next($!mli);
  }

  method name {
    g_menu_link_iter_get_name($!mli);
  }

  method value (:$raw = False) {
    my $mm = g_menu_link_iter_get_value($!mli);

    $mm ??
      ( $raw ?? $mm !! ::('GIO::MenuModel').new($mm, :!ref) )
      !!
      Nil;
  }
}
