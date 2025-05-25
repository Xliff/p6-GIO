use v6.c;

use NativeCall;

use GLib::Raw::Definitions;
use GLib::Raw::Enums;
use GLib::Raw::Object;
use GLib::Raw::Structs;
use GIO::Raw::Definitions;
use GIO::Raw::Enums;
use GIO::Raw::Structs;

unit package GIO::Raw::VFS;

### /usr/src/glib/gio/gvfs.h

sub g_vfs_get_default ()
  returns GVfs
  is native(gio)
  is export
{ * }

sub g_vfs_get_file_for_path (GVfs $vfs, Str $path)
  returns GFile
  is native(gio)
  is export
{ * }

sub g_vfs_get_file_for_uri (GVfs $vfs, Str $uri)
  returns GFile
  is native(gio)
  is export
{ * }

sub g_vfs_get_local ()
  returns GVfs
  is native(gio)
  is export
{ * }

sub g_vfs_get_type ()
  returns GType
  is native(gio)
  is export
{ * }

sub g_vfs_is_active (GVfs $vfs)
  returns uint32
  is native(gio)
  is export
{ * }

sub g_vfs_parse_name (GVfs $vfs, Str $parse_name)
  returns GFile
  is native(gio)
  is export
{ * }

sub g_vfs_register_uri_scheme (
  GVfs               $vfs,
  Str                $scheme,
                     &uri_func (GVfs, Str, gpointer --> GFile),
  gpointer           $uri_data,
  GDestroyNotify     $uri_destroy,
                     &parse_name_func (GVfs, Str, gpointer --> GFile),
  gpointer           $parse_name_data,
                     &parse_name_destroy (gpointer)
)
  returns uint32
  is native(gio)
  is export
{ * }

sub g_vfs_unregister_uri_scheme (GVfs $vfs, Str $scheme)
  returns uint32
  is native(gio)
  is export
{ * }

sub g_vfs_get_supported_uri_schemes (GVfs $vfs)
  returns CArray[Str]
  is native(gio)
  is export
{ * }
