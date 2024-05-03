use v6.c;

use NativeCall;

use GIO::Raw::Types;

### /usr/src/glib/gio/gappinfo.h

unit package GIO::Raw::AppInfo;

sub g_app_info_add_supports_type (
  GAppInfo                $appinfo,
  Str                     $content_type,
  CArray[Pointer[GError]] $error
)
  returns uint32
  is native(gio)
  is export
{ * }

sub g_app_info_can_delete (GAppInfo $appinfo)
  returns uint32
  is native(gio)
  is export
{ * }

sub g_app_info_can_remove_supports_type (GAppInfo $appinfo)
  returns uint32
  is native(gio)
  is export
{ * }

sub g_app_info_create_from_commandline (
  Str                     $commandline,
  Str                     $application_name,
  uint32                  $flags,                 # GAppInfoCreateFlags $flags,
  CArray[Pointer[GError]] $error
)
  returns GAppInfo
  is native(gio)
  is export
{ * }

sub g_app_info_delete (GAppInfo $appinfo)
  returns uint32
  is native(gio)
  is export
{ * }

sub g_app_info_dup (GAppInfo $appinfo)
  returns GAppInfo
  is native(gio)
  is export
{ * }

sub g_app_info_equal (GAppInfo $appinfo1, GAppInfo $appinfo2)
  returns uint32
  is native(gio)
  is export
{ * }

sub g_app_launch_context_get_display (
  GAppLaunchContext $context,
  GAppInfo          $info,
  GList             $files
)
  returns Str
  is native(gio)
  is export
{ * }

sub g_app_launch_context_get_environment (GAppLaunchContext $context)
  returns CArray[Str]
  is native(gio)
  is export
{ * }

sub g_app_launch_context_get_startup_notify_id (
  GAppLaunchContext $context,
  GAppInfo          $info,
  GList             $files
)
  returns Str
  is native(gio)
  is export
{ * }

sub g_app_launch_context_launch_failed (
  GAppLaunchContext $context,
  Str               $startup_notify_id
)
  is native(gio)
  is export
{ * }

sub g_app_launch_context_new ()
  returns GAppLaunchContext
  is native(gio)
  is export
{ * }

sub g_app_launch_context_setenv (
  GAppLaunchContext $context,
  Str               $variable,
  Str               $value
)
  is native(gio)
  is export
{ * }

sub g_app_launch_context_unsetenv (
  GAppLaunchContext $context,
  Str               $variable
)
  is native(gio)
  is export
{ * }

sub g_app_info_get_all ()
  returns GList
  is native(gio)
  is export
{ * }

sub g_app_info_get_all_for_type (Str $content_type)
  returns GList
  is native(gio)
  is export
{ * }

sub g_app_info_get_commandline (GAppInfo $appinfo)
  returns Str
  is native(gio)
  is export
{ * }

sub g_app_info_get_default_for_type (
  Str      $content_type,
  gboolean $must_support_uris
)
  returns GAppInfo
  is native(gio)
  is export
{ * }

sub g_app_info_get_default_for_uri_scheme (Str $uri_scheme)
  returns GAppInfo
  is native(gio)
  is export
{ * }

sub g_app_info_get_description (GAppInfo $appinfo)
  returns Str
  is native(gio)
  is export
{ * }

sub g_app_info_get_display_name (GAppInfo $appinfo)
  returns Str
  is native(gio)
  is export
{ * }

sub g_app_info_get_executable (GAppInfo $appinfo)
  returns Str
  is native(gio)
  is export
{ * }

sub g_app_info_get_fallback_for_type (Str $content_type)
  returns GList
  is native(gio)
  is export
{ * }

sub g_app_info_get_icon (GAppInfo $appinfo)
  returns GIcon
  is native(gio)
  is export
{ * }

sub g_app_info_get_id (GAppInfo $appinfo)
  returns Str
  is native(gio)
  is export
{ * }

sub g_app_info_get_name (GAppInfo $appinfo)
  returns Str
  is native(gio)
  is export
{ * }

sub g_app_info_get_recommended_for_type (Str $content_type)
  returns GList
  is native(gio)
  is export
{ * }

sub g_app_info_get_supported_types (GAppInfo $appinfo)
  returns CArray[Str]
  is native(gio)
  is export
{ * }

sub g_app_info_launch (
  GAppInfo                $appinfo,
  GList                   $files,
  GAppLaunchContext       $context,
  CArray[Pointer[GError]] $error
)
  returns uint32
  is native(gio)
  is export
{ * }

sub g_app_info_launch_default_for_uri (
  Str                     $uri,
  GAppLaunchContext       $context,
  CArray[Pointer[GError]] $error
)
  returns uint32
  is native(gio)
  is export
{ * }

sub g_app_info_launch_default_for_uri_async (
  Str                 $uri,
  GAppLaunchContext   $context,
  GCancellable        $cancellable,
                      &callback (GAppInfo, GAsyncResult, gpointer),
  gpointer            $user_data
)
  is native(gio)
  is export
{ * }

sub g_app_info_launch_default_for_uri_finish (
  GAsyncResult            $result,
  CArray[Pointer[GError]] $error
)
  returns uint32
  is native(gio)
  is export
{ * }

sub g_app_info_launch_uris (
  GAppInfo                $appinfo,
  GList                   $uris,
  GAppLaunchContext       $context,
  CArray[Pointer[GError]] $error
)
  returns uint32
  is native(gio)
  is export
{ * }

sub g_app_info_monitor_get ()
  returns GAppInfoMonitor
  is native(gio)
  is export
{ * }

sub g_app_info_monitor_get_type ()
  returns GType
  is native(gio)
  is export
{ * }

sub g_app_info_remove_supports_type (
  GAppInfo                $appinfo,
  Str                     $content_type,
  CArray[Pointer[GError]] $error
)
  returns uint32
  is native(gio)
  is export
{ * }

sub g_app_info_reset_type_associations (Str $content_type)
  is native(gio)
  is export
{ * }

sub g_app_info_set_as_default_for_extension (
  GAppInfo                $appinfo,
  Str                     $extension,
  CArray[Pointer[GError]] $error
)
  returns uint32
  is native(gio)
  is export
{ * }

sub g_app_info_set_as_default_for_type (
  GAppInfo                $appinfo,
  Str                     $content_type,
  CArray[Pointer[GError]] $error
)
  returns uint32
  is native(gio)
  is export
{ * }

sub g_app_info_set_as_last_used_for_type (
  GAppInfo                $appinfo,
  Str                     $content_type,
  CArray[Pointer[GError]] $error
)
  returns uint32
  is native(gio)
  is export
{ * }

sub g_app_info_should_show (GAppInfo $appinfo)
  returns uint32
  is native(gio)
  is export
{ * }

sub g_app_info_supports_files (GAppInfo $appinfo)
  returns uint32
  is native(gio)
  is export
{ * }

sub g_app_info_supports_uris (GAppInfo $appinfo)
  returns uint32
  is native(gio)
  is export
{ * }
