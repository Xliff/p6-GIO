use v6.c;

use NativeCall;

use GLib::Raw::Definitions;
use GLib::Raw::Structs;
use GIO::Raw::Definitions;
use GIO::Raw::Enums;

unit package GIO::Raw::FileMonitor::Local;

### /usr/src/glib/gio/glocalfilemonitor.h

sub g_file_monitor_source_handle_event (
  GFileMonitorSource $fms,
  GFileMonitorEvent  $event_type,
  Str                $child,
  Str                $rename_to,
  GFile              $other,
  gint64             $event_time
)
  returns uint32
  is      native(gio)
  is      export
{ * }

sub g_local_file_monitor_get_type
  returns GType
  is      native(gio)
  is      export
{ * }

sub g_local_file_monitor_new_for_path (
  Str                     $pathname,
  gboolean                $is_directory,
  GFileMonitorFlags       $flags,
  CArray[Pointer[GError]] $error
)
  returns GLocalFileMonitor
  is      native(gio)
  is      export
{ * }

sub g_local_file_monitor_new_in_worker (
  Str                     $pathname,
  gboolean                $is_directory,
  GFileMonitorFlags       $flags,
                          &callback (
                            GFileMonitor,
                            GFile,
                            GFile,
                            GFileMonitorEvent,
                            gpointer
                          ),
  gpointer                $user_data,
                          &destroy_user_data (gpointer),
  CArray[Pointer[GError]] $error
)
  returns GLocalFileMonitor
  is      native(gio)
  is      export
{ * }
