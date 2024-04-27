use v6.c;

use NativeCall;

use GLib::Raw::Definitions;
use GIO::Raw::Definitions;

unit package GIO::Raw::SimpleActionGroup;

### /usr/src/glib/gio/gsimpleactiongroup.h

sub g_simple_action_group_add_entries (
  GSimpleActionGroup $simple,
  gpointer           $entries,
  gint               $n_entries,
  gpointer           $user_data
)
  is      native(gio)
  is      export
{ * }

sub g_simple_action_group_get_type
  returns GType
  is      native(gio)
  is      export
{ * }

sub g_simple_action_group_insert (
  GSimpleActionGroup $simple,
  GAction            $action
)
  is      native(gio)
  is      export
{ * }

sub g_simple_action_group_lookup (
  GSimpleActionGroup $simple,
  Str                $action_name
)
  returns GAction
  is      native(gio)
  is      export
{ * }

sub g_simple_action_group_new
  returns GSimpleActionGroup
  is      native(gio)
  is      export
{ * }

sub g_simple_action_group_remove (
  GSimpleActionGroup $simple,
  Str                $action_name
)
  is      native(gio)
  is      export
{ * }
