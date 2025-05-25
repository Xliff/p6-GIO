use v6.c;

use NativeCall;

use GLib::Raw::Definitions;
use GLib::Raw::Enums;
use GLib::Raw::Object;
use GLib::Raw::Structs;
use GIO::Raw::Definitions;
use GIO::Raw::Enums;
use GIO::Raw::Structs;

unit package GIO::Raw::SrvTarget;

### /usr/src/glib/gio/gsrvtarget.h

sub g_srv_target_copy (GSrvTarget $target)
  returns GSrvTarget
  is native(gio)
  is export
{ * }

sub g_srv_target_free (GSrvTarget $target)
  is native(gio)
  is export
{ * }

sub g_srv_target_get_hostname (GSrvTarget $target)
  returns Str
  is native(gio)
  is export
{ * }

sub g_srv_target_get_port (GSrvTarget $target)
  returns guint16
  is native(gio)
  is export
{ * }

sub g_srv_target_get_priority (GSrvTarget $target)
  returns guint16
  is native(gio)
  is export
{ * }

sub g_srv_target_get_type ()
  returns GType
  is native(gio)
  is export
{ * }

sub g_srv_target_get_weight (GSrvTarget $target)
  returns guint16
  is native(gio)
  is export
{ * }

sub g_srv_target_list_sort (GList $targets)
  returns GList
  is native(gio)
  is export
{ * }

sub g_srv_target_new (
  Str     $hostname,
  guint16 $port,
  guint16 $priority,
  guint16 $weight
)
  returns GSrvTarget
  is native(gio)
  is export
{ * }
