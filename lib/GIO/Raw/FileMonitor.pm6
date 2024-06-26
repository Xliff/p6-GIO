use v6.c;

use NativeCall;

use GIO::Raw::Types;

unit package GIO::Raw::FileMonitor;

### /usr/src/glib/gio/gfilemonitor.h

sub g_file_monitor_cancel (GFileMonitor $monitor)
  returns uint32
  is native(gio)
  is export
{ * }

sub g_file_monitor_emit_event (
  GFileMonitor      $monitor,
  GFile             $child,
  GFile             $other_file,
  GFileMonitorEvent $event_type
)
  is native(gio)
  is export
{ * }

sub g_file_monitor_get_type ()
  returns GType
  is native(gio)
  is export
{ * }

sub g_file_monitor_is_cancelled (GFileMonitor $monitor)
  returns uint32
  is native(gio)
  is export
{ * }

sub g_file_monitor_set_rate_limit (GFileMonitor $monitor, gint $limit_msecs)
  is native(gio)
  is export
{ * }
