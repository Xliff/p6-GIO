use v6.c;

use NativeCall;

use GIO::Raw::Types;

unit package GIO::Raw::Application;

### /usr/include/glib-2.0/gio/gapplication.h

sub g_application_activate (GApplication $application)
  is native(gio)
  is export
{ * }

sub g_application_add_main_option (
  GApplication $application,
  Str          $long_name,
  Str          $short_name,
  GOptionFlags $flags,
  GOptionArg   $arg,
  Str          $description,
  Str          $arg_description
)
  is native(gio)
  is export
{ * }

sub g_application_add_main_option_entries (
  GApplication $application,
  Pointer      $entries
)
  is native(gio)
  is export
{ * }

sub g_application_add_option_group (
  GApplication $application,
  GOptionGroup $group
)
  is native(gio)
  is export
{ * }

sub g_application_bind_busy_property (
  GApplication $application,
  GObject      $object,
  Str          $property
)
  is native(gio)
  is export
{ * }

sub g_application_get_application_id (GApplication $application)
  returns Str
  is native(gio)
  is export
{ * }

sub g_application_get_dbus_connection (GApplication $application)
  returns GDBusConnection
  is native(gio)
  is export
{ * }

sub g_application_get_dbus_object_path (GApplication $application)
  returns Str
  is native(gio)
  is export
{ * }

sub g_application_get_default ()
  returns GApplication
  is native(gio)
  is export
{ * }

sub g_application_get_flags (GApplication $application)
  returns GApplicationFlags
  is native(gio)
  is export
{ * }

sub g_application_get_inactivity_timeout (GApplication $application)
  returns guint
  is native(gio)
  is export
{ * }

sub g_application_get_is_busy (GApplication $application)
  returns uint32
  is native(gio)
  is export
{ * }

sub g_application_get_is_registered (GApplication $application)
  returns uint32
  is native(gio)
  is export
{ * }

sub g_application_get_is_remote (GApplication $application)
  returns uint32
  is native(gio)
  is export
{ * }

sub g_application_get_resource_base_path (GApplication $application)
  returns Str
  is native(gio)
  is export
{ * }

sub g_application_hold (GApplication $application)
  is native(gio)
  is export
{ * }

sub g_application_id_is_valid (Str $application_id)
  returns uint32
  is native(gio)
  is export
{ * }

sub g_application_mark_busy (GApplication $application)
  is native(gio)
  is export
{ * }

sub g_application_new (Str $application_id, GApplicationFlags $flags)
  returns GApplication
  is native(gio)
  is export
{ * }

sub g_application_open (
  GApplication $application,
  Pointer      $files,
  gint         $n_files,
  Str          $hint
)
  is native(gio)
  is export
{ * }

sub g_application_quit (GApplication $application)
  is native(gio)
  is export
{ * }

sub g_application_register (
  GApplication            $application,
  GCancellable            $cancellable,
  CArray[Pointer[GError]] $error
)
  returns uint32
  is native(gio)
  is export
{ * }

sub g_application_release (GApplication $application)
  is native(gio)
  is export
{ * }

sub g_application_run (
  GApplication $application,
  gint         $argc,
  CArray[Str]  $argv
)
  returns gint
  is native(gio)
  is export
{ * }

sub g_application_send_notification (
  GApplication  $application,
  Str           $id,
  GNotification $notification
)
  is native(gio)
  is export
{ * }

sub g_application_set_action_group (
  GApplication $application,
  GActionGroup $action_group
)
  is native(gio)
  is export
{ * }

sub g_application_set_application_id (
  GApplication $application,
  Str          $application_id
)
  is native(gio)
  is export
{ * }

sub g_application_set_default (GApplication $application)
  is native(gio)
  is export
{ * }

sub g_application_set_flags (
  GApplication      $application,
  GApplicationFlags $flags
)
  is native(gio)
  is export
{ * }

sub g_application_set_inactivity_timeout (
  GApplication $application,
  guint        $inactivity_timeout
)
  is native(gio)
  is export
{ * }

sub g_application_set_option_context_description (
  GApplication $application,
  Str          $description
)
  is native(gio)
  is export
{ * }

sub g_application_set_option_context_parameter_string (
  GApplication $application,
  Str          $parameter_string
)
  is native(gio)
  is export
{ * }

sub g_application_set_option_context_summary (
  GApplication $application,
  Str          $summary
)
  is native(gio)
  is export
{ * }

sub g_application_set_resource_base_path (
  GApplication $application,
  Str          $resource_path
)
  is native(gio)
  is export
{ * }

sub g_application_unbind_busy_property (
  GApplication $application,
  gpointer     $object,
  Str          $property
)
  is native(gio)
  is export
{ * }

sub g_application_unmark_busy (GApplication $application)
  is native(gio)
  is export
{ * }

sub g_application_withdraw_notification (GApplication $application, Str $id)
  is native(gio)
  is export
{ * }
