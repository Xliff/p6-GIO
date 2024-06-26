use v6.c;

use NativeCall;

use GIO::Raw::Types;

unit package GIO::Raw::ListModel;

### /usr/src/glib/gio/glistmodel.h

sub g_list_model_get_item (GListModel $list, guint $position)
  returns Pointer
  is native(gio)
  is export
{ * }

sub g_list_model_get_item_type (GListModel $list)
  returns GType
  is native(gio)
  is export
{ * }

sub g_list_model_get_n_items (GListModel $list)
  returns guint
  is native(gio)
  is export
{ * }

sub g_list_model_get_object (GListModel $list, guint $position)
  returns GObject
  is native(gio)
  is export
{ * }

sub g_list_model_items_changed (
  GListModel $list,
  guint      $position,
  guint      $removed,
  guint      $added
)
  is native(gio)
  is export
{ * }

sub g_list_model_get_type
  returns GType
  is native(gio)
  is export
{ * }
