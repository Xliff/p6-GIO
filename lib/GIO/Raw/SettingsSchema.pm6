use v6.c;

use NativeCall;

use GLib::Raw::Definitions;
use GLib::Raw::Enums;
use GLib::Raw::Object;
use GLib::Raw::Structs;
use GIO::Raw::Definitions;
use GIO::Raw::Enums;
use GIO::Raw::Structs;

unit package GIO::Raw::SettingsSchema;

### /usr/src/glib/gio/gsettingsschema.h

sub g_settings_schema_get_id (GSettingsSchema $schema)
  returns Str
  is      native(gio)
  is      export
{ * }

sub g_settings_schema_get_key (GSettingsSchema $schema, Str $name)
  returns GSettingsSchemaKey
  is      native(gio)
  is      export
{ * }

sub g_settings_schema_get_path (GSettingsSchema $schema)
  returns Str
  is      native(gio)
  is      export
{ * }

sub g_settings_schema_get_type ()
  returns GType
  is      native(gio)
  is      export
{ * }

sub g_settings_schema_has_key (GSettingsSchema $schema, Str $name)
  returns uint32
  is      native(gio)
  is      export
{ * }

sub g_settings_schema_key_get_default_value (GSettingsSchemaKey $key)
  returns GVariant
  is      native(gio)
  is      export
{ * }

sub g_settings_schema_key_get_description (GSettingsSchemaKey $key)
  returns Str
  is      native(gio)
  is      export
{ * }

sub g_settings_schema_key_get_name (GSettingsSchemaKey $key)
  returns Str
  is      native(gio)
  is      export
{ * }

sub g_settings_schema_key_get_range (GSettingsSchemaKey $key)
  returns GVariant
  is      native(gio)
  is      export
{ * }

sub g_settings_schema_key_get_summary (GSettingsSchemaKey $key)
  returns Str
  is      native(gio)
  is      export
{ * }

sub g_settings_schema_key_get_type ()
  returns GType
  is      native(gio)
  is      export
{ * }

sub g_settings_schema_key_get_value_type (GSettingsSchemaKey $key)
  returns Str
  is      native(gio)
  is      export
{ * }

sub g_settings_schema_key_range_check (
  GSettingsSchemaKey $key,
  GVariant           $value
)
  returns uint32
  is      native(gio)
  is      export
{ * }

sub g_settings_schema_key_ref (GSettingsSchemaKey $key)
  returns GSettingsSchemaKey
  is      native(gio)
  is      export
{ * }

sub g_settings_schema_key_unref (GSettingsSchemaKey $key)
  is native(gio)
  is export
{ * }

sub g_settings_schema_list_children (GSettingsSchema $schema)
  returns CArray[Str]
  is      native(gio)
  is      export
{ * }

sub g_settings_schema_list_keys (GSettingsSchema $schema)
  returns CArray[Str]
  is      native(gio)
  is      export
{ * }

sub g_settings_schema_ref (GSettingsSchema $schema)
  returns GSettingsSchema
  is      native(gio)
  is      export
{ * }

sub g_settings_schema_source_get_default ()
  returns GSettingsSchemaSource
  is      native(gio)
  is      export
{ * }

sub g_settings_schema_source_get_type ()
  returns GType
  is      native(gio)
  is      export
{ * }

sub g_settings_schema_source_list_schemas (
  GSettingsSchemaSource $source,
  gboolean              $recursive,
  CArray[CArray[Str]]   $non_relocatable,
  CArray[CArray[Str]]   $relocatable
)
  is native(gio)
  is export
{ * }

sub g_settings_schema_source_lookup (
  GSettingsSchemaSource $source,
  Str                   $schema_id,
  gboolean              $recursive
)
  returns GSettingsSchema
  is      native(gio)
  is      export
{ * }

sub g_settings_schema_source_new_from_directory (
  Str                     $directory,
  GSettingsSchemaSource   $parent,
  gboolean                $trusted,
  CArray[Pointer[GError]] $error
)
  returns GSettingsSchemaSource
  is      native(gio)
  is      export
{ * }

sub g_settings_schema_source_ref (GSettingsSchemaSource $source)
  returns GSettingsSchemaSource
  is      native(gio)
  is      export
{ * }

sub g_settings_schema_source_unref (GSettingsSchemaSource $source)
  is native(gio)
  is export
{ * }

sub g_settings_schema_unref (GSettingsSchema $schema)
  is native(gio)
  is export
{ * }
