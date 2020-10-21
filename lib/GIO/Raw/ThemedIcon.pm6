use v6.c;

use NativeCall;

use GLib::Raw::Definitions;
use GLib::Raw::Enums;
use GLib::Raw::Object;
use GLib::Raw::Structs;
use GIO::Raw::Definitions;
use GIO::Raw::Enums;
use GIO::Raw::Structs;

unit package GIO::Raw::ThemedIcon;

sub g_themed_icon_append_name (GThemedIcon $icon, Str $iconname)
  is native(gio)
  is export
{ * }

sub g_themed_icon_get_type ()
  returns GType
  is native(gio)
  is export
{ * }

sub g_themed_icon_new (Str $iconname)
  returns GThemedIcon
  is native(gio)
  is export
{ * }

sub g_themed_icon_new_from_names (CArray[Str] $iconnames, gint $len)
  returns GThemedIcon
  is native(gio)
  is export
{ * }

sub g_themed_icon_new_with_default_fallbacks (Str $iconname)
  returns GThemedIcon
  is native(gio)
  is export
{ * }

sub g_themed_icon_prepend_name (GThemedIcon $icon, Str $iconname)
  is native(gio)
  is export
{ * }

sub g_themed_icon_get_names (GThemedIcon $icon)
  returns CArray[Str]
  is native(gio)
  is export
{ * }
