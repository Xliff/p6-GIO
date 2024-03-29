use v6.c;

use Method::Also;
use NativeCall;

use GIO::Raw::Types;
use GIO::Raw::MenuModel;

use GIO::MenuAttributeIter;
use GIO::MenuLinkIter;

use GLib::Roles::Object;
use GIO::Roles::Signals::MenuModel;

sub EXPORT {
  %(
    GIO::MenuAttributeIter::,
    GIO::MenuLinkIter::,
  );
}

our subset GMenuModelAncestry is export of Mu
  where GMenuModel | GObject;

class GIO::MenuModel {
  also does GLib::Roles::Object;
  also does GIO::Roles::Signals::MenuModel;

  has GMenuModel $!mm is implementor;

  submethod BUILD(:$model) {
    self.setMenuModel($model) if $model;
  }

  submethod DESTROY {
    self.disconnect-all(%_) for %!signals-mm;
  }

  method setMenuModel(GMenuModelAncestry $_) {
    my $to-parent;

    $!mm = do {
      when GMenuModel {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GMenuModel, $_);
      }
    }
    self!setObject($to-parent);
  }

  method new (GMenuModelAncestry $model, :$ref = True) {
    return Nil unless $model;

    my $o = self.bless( :$model );
    $o.ref if $ref;
    $o;
  }

  method GIO::Raw::Definitions::GMenuModel
    is also<GMenuModel>
  { $!mm }

  # ↓↓↓↓ SIGNALS ↓↓↓↓

  # Is originally:
  # GMenuModel, gint, gint, gint, gpointer
  method items-changed is also<items_changed> {
    self.connect-items-changed($!mm);
  }

  # ↑↑↑↑ SIGNALS ↑↑↑↑

  # ↓↓↓↓ ATTRIBUTES ↓↓↓↓
  # ↑↑↑↑ ATTRIBUTES ↑↑↑↑

  # ↓↓↓↓ METHODS ↓↓↓↓
  method get_item_attribute_value (
    Int()          $item_index,
    Str()          $attribute,
    GVariantType() $expected_type,
                   :$raw = False
  )
    is also<get-item-attribute-value>
  {
    my gint $ii = $item_index;
    my $v = g_menu_model_get_item_attribute_value(
      $!mm,
      $ii,
      $attribute,
      $expected_type
    );

    $v ??
      ( $raw ?? $v !! GLib::Variant.new($v, :!ref) )
      !!
      Nil;
  }

  method get_item_link (
    Int() $item_index,
    Str() $link,
          :$raw = False
  )
    is also<get-item-link>
  {
    my gint $ii = $item_index;
    my $ml = g_menu_model_get_item_link($!mm, $ii, $link);

    $ml ??
      ( $raw ?? $ml !! GIO::MenuModel.new($ml, :!ref) )
      !!
      Nil;
  }

  method get_n_items
    is also<
      get-n-items
      elems
    >
  {
    g_menu_model_get_n_items($!mm);
  }

  method get_type {
    state ($n, $t);

    unstable_get_type( self.^name, &g_menu_model_get_type, $n, $t);
  }

  method is_mutable is also<is-mutable> {
    so g_menu_model_is_mutable($!mm);
  }

  method emit_items_changed (
    Int() $position,
    Int() $removed,
    Int() $added
  )
    is also<emit-items-changed>
  {
    my gint ($p, $r, $a) = ($position, $removed, $added);

    g_menu_model_items_changed($!mm, $position, $removed, $added);
  }

  method iterate_item_attributes (Int() $item_index, :$raw = False)
    is also<iterate-item-attributes>
  {
    my gint $ii = $item_index;
    my $mai = g_menu_model_iterate_item_attributes($!mm, $ii);

    $mai ??
      ( $raw ?? $mai !! GIO::MenuAttributeIter.new($mai) )
      !!
      Nil;
  }

  method iterate_item_links (Int() $item_index, :$raw = False)
    is also<iterate-item-links>
  {
    my gint $ii = $item_index;
    my $mli = g_menu_model_iterate_item_links($!mm, $ii);

    $mli ??
      ( $raw ?? $mli !! GTK::Compat::MenuLinkIter.new($mli) )
      !!
      Nil;
  }
  # ↑↑↑↑ METHODS ↑↑↑↑

}
