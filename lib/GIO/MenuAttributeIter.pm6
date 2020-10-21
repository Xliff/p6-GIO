use v6.c;

use Method::Also;

use GIO::Raw::Types;
use GIO::Raw::MenuModel;

use GLib::Roles::Object;

our subset GMenuAttributeIterAncestry is export of Mu
  where GMenuAttributeIter | GObject;

class GIO::MenuAttributeIter {
  also does GLib::Roles::Object;

  has GMenuAttributeIter $!mai is implementor;

  submethod BUILD(:$iter) {
    self.setGMenuAttributeIter($iter) if $iter;
  }

  method setGMenuAttributeIter (GMenuAttributeIterAncestry $_) {
    my $to-parent;

    $!mai = do {
      when GMenuAttributeIter {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GMenuAttributeIter, $_);
      }
    }
    self!setObject($to-parent);
  }

  method GIO::Raw::Definitions::GMenuAttributeIter
    is also<GMenuAttributeIter>
  { $!mai }

  method new (GMenuAttributeIterAncestry $iter, :$ref = True) {
    return Nil unless $iter;

    my $o = self.bless( :$iter );
    $o.ref if $ref;
    $o;
  }

  method next {
    g_menu_attribute_iter_next($!mai);
  }

  method name {
    g_menu_attribute_iter_get_name($!mai);
  }

  method value {
    g_menu_attribute_iter_get_value($!mai);
  }

}
