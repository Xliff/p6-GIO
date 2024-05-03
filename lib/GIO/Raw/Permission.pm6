use v6.c;

use NativeCall;

use GLib::Raw::Definitions;
use GLib::Raw::Enums;
use GLib::Raw::Object;
use GLib::Raw::Structs;
use GIO::Raw::Definitions;
use GIO::Raw::Enums;
use GIO::Raw::Structs;

unit package GIO::Raw::Permission;

### /usr/src/glib/gio/gpermission.h

sub g_permission_acquire (
  GPermission             $permission,
  GCancellable            $cancellable,
  CArray[Pointer[GError]] $error
)
  returns uint32
  is native(gio)
  is export
  { * }

sub g_permission_acquire_async (
  GPermission  $permission,
  GCancellable $cancellable,
               &callback (GObject, GAsyncResult, Pointer),
  gpointer     $user_data
)
  is native(gio)
  is export
  { * }

sub g_permission_acquire_finish (
  GPermission             $permission,
  GAsyncResult            $result,
  CArray[Pointer[GError]] $error
)
  returns uint32
  is native(gio)
  is export
  { * }

sub g_permission_get_allowed (GPermission $permission)
  returns uint32
  is native(gio)
  is export
  { * }

sub g_permission_get_can_acquire (GPermission $permission)
  returns uint32
  is native(gio)
  is export
  { * }

sub g_permission_get_can_release (GPermission $permission)
  returns uint32
  is native(gio)
  is export
  { * }

sub g_permission_get_type ()
  returns GType
  is native(gio)
  is export
  { * }

sub g_permission_impl_update (
  GPermission $permission,
  gboolean    $allowed,
  gboolean    $can_acquire,
  gboolean    $can_release
)
  is native(gio)
  is export
  { * }

sub g_permission_release (
  GPermission             $permission,
  GCancellable            $cancellable,
  CArray[Pointer[GError]] $error
)
  returns uint32
  is native(gio)
  is export
  { * }

sub g_permission_release_async (
  GPermission  $permission,
  GCancellable $cancellable,
               &callback (GObject, GAsyncResult, Pointer),
  gpointer     $user_data
)
  is native(gio)
  is export
  { * }

sub g_permission_release_finish (
  GPermission             $permission,
  GAsyncResult            $result,
  CArray[Pointer[GError]] $error
)
  returns uint32
  is native(gio)
  is export
  { * }
