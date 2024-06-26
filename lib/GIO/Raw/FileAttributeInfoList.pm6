use v6.c;

use NativeCall;

use GLib::Raw::Definitions;
use GLib::Raw::Enums;
use GLib::Raw::Structs;
use GIO::Raw::Definitions;
use GIO::Raw::Enums;
use GIO::Raw::Structs;

unit package GIO::Raw::FileAttributeInfoList;

### /usr/src/glib/gio/gfileattribute.h

sub g_file_attribute_info_list_add (
  GFileAttributeInfoList  $list,
  Str                     $name,
  GFileAttributeType      $type,
  GFileAttributeInfoFlags $flags
)
  is native(gio)
  is export
{ * }

sub g_file_attribute_info_list_dup (GFileAttributeInfoList $list)
  returns GFileAttributeInfoList
  is native(gio)
  is export
{ * }

sub g_file_attribute_info_list_get_type ()
  returns GType
  is native(gio)
  is export
{ * }

sub g_file_attribute_info_list_lookup (GFileAttributeInfoList $list, Str $name)
  returns GFileAttributeInfo
  is native(gio)
  is export
{ * }

sub g_file_attribute_info_list_new ()
  returns GFileAttributeInfoList
  is native(gio)
  is export
{ * }

sub g_file_attribute_info_list_ref (GFileAttributeInfoList $list)
  returns GFileAttributeInfoList
  is native(gio)
  is export
{ * }

sub g_file_attribute_info_list_unref (GFileAttributeInfoList $list)
  is native(gio)
  is export
{ * }
