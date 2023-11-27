use v6.c;

use Method::Also;

use GIO::Raw::Types;
use GIO::Raw::ListModel;

use GLib::Roles::Object;
use GIO::Roles::Signals::ListModel;

role GIO::Roles::ListModel {
  also does GIO::Roles::Signals::ListModel;
  also does Positional;

  has GListModel $!lm;

  has $!items-are-objects;

  method roleInit-GListModel {
    return if $!lm;

    my \i = findProperImplementor(self.^attributes);
    $!lm = cast( GListModel, i.get_value(self) );

    $!items-are-objects =
      GLib::Object::Type.new( self.get_item_type ).fundamental( :raw )
      ==
      G_TYPE_OBJECT.Int;
  }

  method GIO::Raw::Definitions::GListModel
    is also<GListModel>
  { $!lm }

  # Is originally:
  # GListModel, guint, guint, guint, gpointer --> void
  method Items-Changed {
    self.connect-items-changed($!lm);
  }

  method itemObjects (Bool() $o) {
    $!items-are-objects = $o.so;
  }

  method get_item (Int() $position) is also<get-item> {
    my guint $p = $position;

    g_list_model_get_item($!lm, $p);
  }

  method get_item_type is also<get-item-type> {
    g_list_model_get_item_type($!lm);
  }

  method get_n_items is also<get-n-items> {
    g_list_model_get_n_items($!lm);
  }

  method elems {
    self.get_n_items;
  }

  method get_object (
    Int() $position,
          :$raw                   = False,
          :type-pair(:$type_pair) = GLib::Object.getTypePair
  )
    is also<get-object>
  {
    my guint $p = $position;

    propReturnObject(
      g_list_model_get_object($!lm, $p),
      $raw,
      |$type_pair
    )
  }

  # cw: Really now handled by GLib::Roles::TypedArray!
  method to_array (\P, $O?) is also<to-array> {
    my $raw = $O =:= (Nil, Mu).any;

    my @a;
    for ^self.elems {
      my $e = $!items-are-objects ?? self.get_object($_, :$raw)
                                  !! self.get_item($_);
      $e = cast(P, $e);
      @a.push: $raw ?? $e !! $O.new($e);
    }
    @a;
  }

  method AT-POS (\k) {
    $!items-are-objects ?? self.get_object(k) !! self.get_item(k);
  }

  method items_changed (
    Int() $position,
    Int() $removed,
    Int() $added
  )
    is also<items-changed>
  {
    my guint ($p, $r, $a) = ($position, $removed, $added);

    g_list_model_items_changed($!lm, $p, $r, $a);
  }

  method glistmodel_get_type {
    state ($n, $t);

    unstable_get_type( ::?CLASS.^name, &g_list_model_get_type, $n, $t );
  }

}

our subset GListModelAncestry is export of Mu
  where GListModel | GObject;

class GIO::ListModel {
  also does GLib::Roles::Object;
  also does GIO::Roles::ListModel;

  submethod BUILD (:$model) {
    self.setGListModel($model) if $model;
  }

  method setGListModel (GListModelAncestry $_) {
    my $to-parent;

    $!lm = do {
      when GListModel {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GListModel, $_);
      }
    }
    self!setObject($to-parent);
  }

  method new (GListModelAncestry $model, :$ref = True)
    is also<new_listmodel_obj>
  {
    return Nil unless $model;

    my $o = self.bless( :$model );
    $o.ref if $ref;
    $o;
  }

  method get_type {
    self.glistmodel_get_type
  }

}
