use v6.c;

use Method::Also;
use NativeCall;

use GIO::Raw::Types;
use GIO::Raw::SettingsSchema;

use GLib::Roles::Implementor;

class GIO::Settings::Schema::Key { ... }

# BOXED
class GIO::Settings::Schema {
  also does GLib::Roles::Implementor;

  has GSettingsSchema $!ss is implementor;

  submethod BUILD (:$schema) {
    $!ss = $schema;
  }

  method new (GSettingsSchema $schema, :$ref = True) {
    return Nil unless $schema;

    my $o = self.bless( :$schema );
    $o.upref if $ref;
    $o;
  }

  method get_id
    is also<
      get-id
      id
    >
  {
    g_settings_schema_get_id($!ss);
  }

  method get_key (Str() $name, :$raw = False) is also<get-key> {
    my $sk = g_settings_schema_get_key($!ss, $name);

    $sk ??
      ( $raw ?? $sk !! GIO::Settings::Schema::Key.new($sk, :!ref) )
      !!
      Nil;
  }

  method get_path
    is also<
      get-path
      path
    >
  {
    g_settings_schema_get_path($!ss);
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_settings_schema_get_type, $n, $t );
  }

  method has_key (Str() $name) is also<has-key> {
    so g_settings_schema_has_key($!ss, $name);
  }

  method list_children is also<list-children> {
    CStringArrayToArray( g_settings_schema_list_children($!ss) );
  }

  method list_keys is also<list-keys> {
    CStringArrayToArray( g_settings_schema_list_keys($!ss) );
  }

  method ref is also<upref> {
    g_settings_schema_ref($!ss);
  }

  method unref is also<downref> {
    g_settings_schema_unref($!ss);
  }

}

class GIO::Settings::Schema::Key {
  has GSettingsSchemaKey $!ssk;

  submethod BUILD (:$key) {
    $!ssk = $key;
  }

  method new (GSettingsSchemaKey $key, :$ref = True) {
    return Nil unless $key;

    my $o = self.bless(:$key);
    $o.upref if $ref;
    $o;
  }

  method get_default_value
    is also<
      get-default-value
      default_value
      default-value
    >
  {
    g_settings_schema_key_get_default_value($!ssk);
  }

  method get_description
    is also<
      get-description
      description
    >
  {
    g_settings_schema_key_get_description($!ssk);
  }

  method get_name
    is also<
      get-name
      name
    >
  {
    g_settings_schema_key_get_name($!ssk);
  }

  method get_range (:$raw = False)
    is also<
      get-range
      range
    >
  {
    my $v = g_settings_schema_key_get_range($!ssk);

    $raw ?? $v !! GLib::Variant.new($v, :!ref);
  }

  method get_summary
    is also<
      get-summary
      summary
    >
  {
    g_settings_schema_key_get_summary($!ssk);
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_settings_schema_key_get_type, $n, $t );
  }

  method get_value_type
    is also<
      get-value-type
      value_type
      value-type
    >
  {
    g_settings_schema_key_get_value_type($!ssk);
  }

  method range_check (GVariant() $value) is also<range-check> {
    so g_settings_schema_key_range_check($!ssk, $value);
  }

  method ref is also<upref> {
    g_settings_schema_key_ref($!ssk);
    self;
  }

  method unref is also<downref> {
    g_settings_schema_key_unref($!ssk);
  }

}

# BOXED
class GIO::Settings::Schema::Source {
  has GSettingsSchemaSource $!sss;

  submethod BUILD (:$source) {
    $!sss = $source;
  }

  method GTK::Compat::TYpes::GSettingsSchemaSource
    is also<GSettingsSchemaSource>
  { $!sss }

  method new (GSettingsSchemaSource $source, :$ref = True) {
    return Nil unless $source;

    my $o = self.bless( :$source );
    $o.upref if $ref;
    $o;
  }

  method new_from_directory (
    Str()                   $directory,
    GSettingsSchemaSource   $parent,
    Int()                   $trusted,
    CArray[Pointer[GError]] $error     = gerror
  )
    is also<new-from-directory>
  {
    my gboolean $t = $trusted.so.Int;

    clear_error;
    my $source = g_settings_schema_source_new_from_directory(
      $directory,
      $parent,
      $t,
      $error
    );
    set_error($error);

    $source ?? self.bless( :$source ) !! Nil
  }

  method get_default (:$raw = False)
    is also<
      get-default
      default
    >
  {
    my $source = g_settings_schema_source_get_default();

    $source ??
      ( $raw ?? $source !! GIO::SettingsSchema::Source.new($source, :!ref) )
      !!
      Nil;
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type(
      self.^name,
      &g_settings_schema_source_get_type,
      $n,
      $t
    );
  }

  proto method list_schemas (|)
    is also<list-schemas>
  { * }

  multi method list_schemas (Int() $recursive = False) {
    samewith($recursive, $, $)
  }
  multi method list_schemas (
    Int() $recursive,
          $non_relocatable  is rw,
          $relocatable      is rw
  ) {
    my gboolean  $r        = $recursive.so.Int;
    my          ($na, $ra) = newCArray(CArray[Str]) xx 2;

    g_settings_schema_source_list_schemas(
      $!sss,
      $r,
      $na,
      $ra
    );

    ($non_relocatable, $relocatable) = (
      $na[0] ?? CStringArrayToArray( $na[0] ) !! Nil,
      $ra[0] ?? CStringArrayToArray( $ra[0] ) !! Nil
    )
  }

  method lookup (
    Str()  $schema_id,
    Int()  $recursive  = False,
          :$raw        = False
  ) {
    my gboolean $r = $recursive;
    my $ss = g_settings_schema_source_lookup($!sss, $schema_id, $r);

    $ss ??
      ( $raw ?? $ss !! GIO::SettingsSchema.new($ss, :!ref) )
      !!
      Nil;
  }

  method ref is also<upref> {
    g_settings_schema_source_ref($!sss);
    self;
  }

  method unref is also<downref> {
    g_settings_schema_source_unref($!sss);
  }

}
