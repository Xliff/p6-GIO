use v6.c;

use Method::Also;

use GIO::Raw::Types;
use GIO::Raw::ListModel;

use GLib::Roles::Object;
use GIO::Roles::Signals::ListModel;

role GIO::Roles::ListModel {
  also does GIO::Roles::Signals::ListModel;

  has GListModel $!lm;

  method roleInit-ListModel {
    return if $!lm;

    my \i = findProperImplementor(self.^attributes);
    $!lm = cast( GListModel, i.get_value(self) );
  }

  method GIO::Raw::Definitions::GListModel
    is also<GListModel>
  { $!lm }

  # Is originally:
  # GListModel, guint, guint, guint, gpointer --> void
  method items-changed {
    self.connect-items-changed($!lm);
  }

  method get_item (Int() $position) is also<get-item> {
    my guint $p = $position;

    g_list_model_get_item($!lm, $p);
  }

  method get_item_type is also<get-item-type> {
    GTypeEnum( g_list_model_get_item_type($!lm) );
  }

  method get_n_items
    is also<
      get-n-items
      elems
    >
  {
    g_list_model_get_n_items($!lm);
  }

  method get_object (
    Int() $position,
          :$raw                               = False,
          :object(
            :obj-type(
              :obj_type(:$type)
            )
          )                                   = GLib::Object
  ) is also<get-object> {
    my guint $p = $position;

    propReturnObject(
      g_list_model_get_object($!lm, $p),
      $raw,
      |$type.getTypePair
    )
  }

  method emit_items_changed (
    Int() $position,
    Int() $removed,
    Int() $added
  )
    is also<emit-items-changed>
  {
    my guint ($p, $r, $a) = ($position, $removed, $added);

    g_list_model_items_changed($!lm, $p, $r, $a);
  }

}

our subset GListModelAncestry is export of Mu
  where GListModel | GObject;

class GIO::ListModel does GLib::Roles::Object does GIO::Roles::ListModel {

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

}
