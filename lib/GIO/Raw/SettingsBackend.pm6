use v6.c;

use NativeCall;

use GLib::Raw::Definitions;
use GLib::Raw::Enums;
use GLib::Raw::Object;
use GLib::Raw::Structs;
use GIO::Raw::Definitions;
use GIO::Raw::Enums;
use GIO::Raw::Structs;

unit package GIO::Raw::SettingsBackend;

### /usr/include/glib-2.0/gio/gsettingsbackend.h

sub g_settings_backend_changed (
  GSettingsBackend $backend,
  Str              $key,
  gpointer         $origin_tag
)
  is native(gio)
  is export
{ * }

sub g_settings_backend_changed_tree (
  GSettingsBackend $backend,
  GTree            $tree,
  gpointer         $origin_tag
)
  is native(gio)
  is export
{ * }

sub g_settings_backend_flatten_tree (
  GTree                    $tree,
  CArray[Str]              $path,
  CArray[CArray[Str]]      $keys,
  CArray[CArray[GVariant]] $values
)
  is native(gio)
  is export
{ * }

sub g_settings_backend_keyfile_new (
  Str $filename,
  Str $root_path,
  Str $root_group
)
  returns GSettingsBackend
  is symbol('g_keyfile_settings_backend_new')
  is native(gio)
  is export
{ * }

sub g_settings_backend_memory_new ()
  returns GSettingsBackend
  is symbol('g_memory_settings_backend_new')
  is native(gio)
  is export
{ * }

sub g_settings_backend_null_new ()
  returns GSettingsBackend
  is symbol('g_null_settings_backend_new')
  is native(gio)
  is export
{ * }

sub g_settings_backend_get_default ()
  returns GSettingsBackend
  is native(gio)
  is export
{ * }

sub g_settings_backend_get_type ()
  returns GType
  is native(gio)
  is export
{ * }

sub g_settings_backend_path_changed (
  GSettingsBackend $backend,
  Str              $path,
  gpointer         $origin_tag
)
  is native(gio)
  is export
{ * }

sub g_settings_backend_path_writable_changed (
  GSettingsBackend $backend,
  Str              $path
)
  is native(gio)
  is export
{ * }

sub g_settings_backend_writable_changed (GSettingsBackend $backend, Str $key)
  is native(gio)
  is export
{ * }

sub g_settings_backend_keys_changed (
  GSettingsBackend $backend,
  Str              $path,
  CArray[Str]      $items,
  gpointer         $origin_tag
)
  is native(gio)
  is export
{ * }
