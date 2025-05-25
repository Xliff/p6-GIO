use v6.c;

use Method::Also;
use NativeCall;

use GIO::Raw::Types;
use GIO::Raw::Settings;

use GLib::Value;
use GIO::Settings::Schema;

use GLib::Roles::Object;
use GIO::Roles::Signals::Settings;

our subset GSettingsAncestry is export of Mu
  where GSettings | GObject;

class X::GIO::Settings::NoSchemaId is Exception {
  method message {
    'A GIO::Settings object cannot be created without a schema-id!'
  }
}

class GIO::Settings {
  also does GLib::Roles::Object;
  also does GIO::Roles::Signals::Settings;
  also does Associative;

  has GSettings $!s is implementor;

  submethod BUILD (:$settings) {
    self.setGSettings($settings) if $settings;
  }

  method setGSettings (GSettingsAncestry $_) {
    my $to-parent;

    $!s = do {
      when GSettings {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GSettings, $_);
      }
    }
    self!setObject($to-parent);
  }

  method GIO::Raw::Definitions::GSettings
    is also<GSettings>
  { $!s }

  multi method new (GSettings $settings, :$ref = True) {
    return Nil unless $settings;

    my $o = self.bless( :$settings );
    $o.upref if $ref;
    $o;
  }
  multi method new (*%a) {
    my $schema-id   = %a<schema-id>:delete;
    $schema-id    //= %a<schema_id>:delete;

    %a{$_}:delete for <schema-id schema_id>;

    X::GIO::Settings::NoSchemaId.new.throw unless $schema-id;
    my $o = samewith($schema-id);
    $o.setAttributes( |%a ) if $o && +%a;
    $o;
  }
  multi method new (Str() $schema_id) {
    my $s = g_settings_new($schema_id);

    $s ?? self.bless( settings => $s ) !! Nil;
  }

  multi method new (
    Str()              $schema_id,
    GSettingsBackend() $backend,
    Str()              $path,
                       :$full      is required
  ) {
    self.new_full($schema_id, $backend, $path);
  }
  method new_full (
    Str()              $schema_id,
    GSettingsBackend() $backend,
    Str()              $path
  )
    is also<new-full>
  {
    my $s = g_settings_new_full($schema_id, $backend, $path);

    $s ?? self.bless( settings => $s ) !! Nil;
  }

  multi method new (
    Str()              $schema_id,
    GSettingsBackend() $settings_backend,
                       :$backend          is required
  ) {
    self.new_with_backend($schema_id, $settings_backend);
  }
  method new_with_backend (Str() $schema_id, GSettingsBackend() $backend)
    is also<new-with-backend>
  {
    my $s = g_settings_new_with_backend($schema_id, $backend);

    $s ?? self.bless( settings => $s ) !! Nil;
  }

  multi method new (
    Str()              $schema_id,
    GSettingsBackend() $backend,
    Str()              $path,
                       :backend_path( :$backend-path )
  ) {
    self.new_with_backend_and_path($schema_id, $backend, $path);
  }
  method new_with_backend_and_path (
    Str()              $schema_id,
    GSettingsBackend() $backend,
    Str()              $path
  )
    is also<new-with-backend-and-path>
  {
    my $s = g_settings_new_with_backend_and_path(
      $schema_id,
      $backend,
      $path
    );

    $s ?? self.bless( settings => $s ) !! Nil;
  }

  method new_with_path (Str() $schema_id, Str() $path) is also<new-with-path> {
    my $s = g_settings_new_with_path($schema_id, $path);

    $s ?? self.bless( settings => $s ) !! Nil;
  }

  # Type: GSettingsBackend
  method backend (:$raw = False) is rw  {
    my GLib::Value $gv .= new( G_TYPE_OBJECT );
    Proxy.new(
      FETCH => -> $ {
        $gv = GLib::Value.new(
          self.prop_get('backend', $gv)
        );

        propReturnObject(
          $gv.object,
          $raw,
          |GIO::Settings::Backend.getTypePair
        );
      },
      STORE => -> $,  $val is copy {
        warn "{ &?ROUTINE.name } can not be modified after creation!"
          if $DEBUG;
      }
    );
  }

  # Type: gboolean
  method delay-apply is rw  is also<delay_apply> {
    my GLib::Value $gv .= new( G_TYPE_BOOLEAN );
    Proxy.new(
      FETCH => -> $ {
        $gv = GLib::Value.new(
          self.prop_get('delay-apply', $gv)
        );
        $gv.boolean;
      },
      STORE => -> $, Int() $val is copy {
        warn 'delay-apply does not allow writing' if $DEBUG;
      }
    );
  }

  # Type: gboolean
  method has-unapplied is rw  is also<has_unapplied> {
    my GLib::Value $gv .= new( G_TYPE_BOOLEAN );
    Proxy.new(
      FETCH => -> $ {
        $gv = GLib::Value.new(
          self.prop_get('has-unapplied', $gv)
        );
        $gv.boolean;
      },
      STORE => -> $, Int() $val is copy {
        warn 'has-unapplied does not allow writing' if $DEBUG;
      }
    );
  }

  # Type: Str
  method path is rw  {
    my GLib::Value $gv .= new( G_TYPE_STRING );
    Proxy.new(
      FETCH => -> $ {
        $gv = GLib::Value.new(
          self.prop_get('path', $gv)
        );
        $gv.string;
      },
      STORE => -> $, Str() $val is copy {
        warn "{ &?ROUTINE.name } can not be modified after creation!"
          if $DEBUG;
      }
    );
  }

  # Type: Str
  method schema-id is rw  is also<schema_id> {
    my GLib::Value $gv .= new( G_TYPE_STRING );
    Proxy.new(
      FETCH => -> $ {
        $gv = GLib::Value.new(
          self.prop_get('schema-id', $gv)
        );
        $gv.string;
      },
      STORE => -> $, Str() $val is copy {
        warn "{ &?ROUTINE.name } can not be modified after creation!"
          if $DEBUG;
      }
    );
  }

  # Type: GSettingsSchema
  method settings-schema (:$raw = False) is rw  is also<settings_schema> {
    my GLib::Value $gv .= new( G_TYPE_POINTER );
    Proxy.new(
      FETCH => -> $ {
        $gv = GLib::Value.new(
          self.prop_get('settings-schema', $gv)
        );

        propReturnObject(
          $gv.boxed,
          $raw,
          |GIO::Settings::Schema.getTypePair
        );
      },
      STORE => -> $, GSettingsSchema() $val is copy {
        warn "{ &?ROUTINE.name } can not be modified after creation!"
          if $DEBUG;
      }
    );
  }

  # Is originally:
  # GSettings, gpointer, gint, gpointer --> gboolean
  method change-event is also<change_event> {
    self.connect-change-event($!s, 'change-event');
  }

  # Is originally:
  # GSettings, Str, gpointer --> void
  method changed ($d?) {
    my $signame = $d;
    $signame = "{ $signame }::$d" if $d;

    self.connect-string($!s, $signame);
  }

  # Is originally:
  # GSettings, guint, gpointer --> gboolean
  method writable-change-event is also<writable_change_event> {
    self.connect-int($!s, 'writeable-change-event');
  }

  # Is originally:
  # GSettings, Str, gpointer --> void
  method writable-changed is also<writable_changed> {
    self.connect-string($!s, 'writable-changed');
  }


  method apply {
    g_settings_apply($!s);
  }

  method processBindFlags (
     $get,
     $set,
     $sensitivity,
     $no_sensitivity,
     $no_changes,
     $invert_boolean,
    :$flags           = 0;
    :$pass            = False
  ) {
    return $flags if $pass;

    my $f = $flags;
    # cw: Should also handle unset if $flags
    if $f {
      $f +&= +^G_SETTINGS_BIND_GET            unless $get;
      $f +&= +^G_SETTINGS_BIND_SET            unless $set;
      $f +&= +^G_SETTINGS_BIND_NO_SENSITIVITY unless $no_sensitivity;
      $f +&= +^G_SETTINGS_BIND_GET_NO_CHANGES unless $no_changes;
      $f +&= +^G_SETTINGS_BIND_INVERT_BOOLEAN unless $invert_boolean;
    }
    $f +&= G_SETTINGS_BIND_GET             if $get;
    $f +&= G_SETTINGS_BIND_SET             if $set;
    $f +&= G_SETTINGS_BIND_NO_SENSITIVITY  if $no_sensitivity;
    $f +&= G_SETTINGS_BIND_GET_NO_CHANGES  if $no_changes;
    $f +&= G_SETTINGS_BIND_INVERT_BOOLEAN  if $invert_boolean;
    $f;
  }

  proto method bind_setting (|)
    is also<bind-setting>
  { * }

  multi method bind_setting (
    Str()  $key,
    Str()  $property,
          :$get                                      = False,
          :$set                                      = False,
          :$sensitivity                              = True,
          :no-sensitivity(:$no_sensitivity)          = $sensitivity.not,
          :$changes                                  = True,
          :no-changes(:$no_changes)                  = $changes.not,
          :invert(:invert-boolean(:$invert_boolean)) = False,
    Int() :$flags                                    = 0,
          :$pass                                     = False
  ) {
    samewith(
      $key,
      self,
      $property,
      flags => self.processBindFlags(
         $get,
         $set,
         $no_sensitivity,
         $no_changes,
         $invert_boolean,
        :$flags,
        :$pass
      )
    )
  }
  multi method bind_setting (
    Str()      $key,
    GObject()  $object,
    Str()      $property,
              :$get                                      = False,
              :$set                                      = False,
              :$sensitivity                              = True,
              :no-sensitivity(:$no_sensitivity)          = $sensitivity.not,
              :$changes                                  = True,
              :no-changes(:$no_changes)                  = $changes.not,
              :invert(:invert-boolean(:$invert_boolean)) = False,
    Int()     :$flags                                    = 0,
              :$pass                                     = False
  ) {
    self.bind(
      $key,
      $object,
      $property,
      flags => self.processBindFlags(
         $get,
         $set,
         $no_sensitivity,
         $no_changes,
         $invert_boolean,
        :$flags,
        :$pass
      );
      :setting);
  }

  multi method bind (
    Str()      $key,
    GObject()  $object,
    Str()      $property,
              :$get                                      = False,
              :$set                                      = False,
              :$sensitivity                              = True,
              :no-sensitivity(:$no_sensitivity)          = $sensitivity.not,
              :$changes                                  = True,
              :no-changes(:$no_changes)                  = $changes.not,
              :invert(:invert-boolean(:$invert_boolean)) = False,
    Int()     :$flags                                    = 0,
              :$pass                                     = False,
              :$settings is required
  ) {
    my GSettingsBindFlags $f = self.processBindFlags(
       $get,
       $set,
       $no_sensitivity,
       $no_changes,
       $invert_boolean,
      :$flags,
      :$pass
    );

    g_settings_bind($!s, $key, $object, $property, $f);
  }

  method bind_with_mapping (
    Str()          $key,
    GObject()      $object,
    Str()          $property,
    Int()          $flags,
                   &get_mapping,
                   &set_mapping,
    gpointer       $user_data    = gpointer,
                   &destroy      = Callable
  )
    is also<bind-with-mapping>
  {
    my GSettingsBindFlags $f = $flags;

    g_settings_bind_with_mapping(
      $!s,
      $key,
      $object,
      $property,
      $flags,
      &get_mapping,
      &set_mapping,
      $user_data,
      &destroy
    );
  }

  method bind_writable (
    Str       $key,
    GObject() $object,
    Str()     $property,
    Int()     $inverted
  )
    is also<bind-writable>
  {
    my gboolean $i = $inverted.so.Int;

    g_settings_bind_writable($!s, $key, $object, $property, $inverted);
  }

  method create_action (Str() $key) is also<create-action> {
    g_settings_create_action($!s, $key);
  }

  method delay {
    g_settings_delay($!s);
  }

  method get_boolean (Str() $key) is also<get-boolean> {
    so g_settings_get_boolean($!s, $key);
  }

  method get_child (Str() $name, :$raw = False) is also<get-child> {
    my $s = g_settings_get_child($!s, $name);

    $s ??
      ( $raw ?? $s !! GIO::Settings.new($s, :!ref) )
      !!
      Nil;
  }

  method get_default_value (Str() $key) is also<get-default-value> {
    g_settings_get_default_value($!s, $key);
  }

  method get_double (Str() $key) is also<get-double> {
    g_settings_get_double($!s, $key);
  }

  method get_enum (Str() $key) is also<get-enum> {
    g_settings_get_enum($!s, $key);
  }

  method get_flags (Str() $key) is also<get-flags> {
    g_settings_get_flags($!s, $key);
  }

  method get_has_unapplied is also<get-has-unapplied> {
    so g_settings_get_has_unapplied($!s);
  }

  method get_int (Str() $key) is also<get-int> {
    g_settings_get_int($!s, $key);
  }

  method get_int64 (Str() $key) is also<get-int64> {
    g_settings_get_int64($!s, $key);
  }

  method get_mapped (
    Str()    $key,
             &mapping,
    gpointer $user_data = gpointer
  )
    is also<get-mapped>
  {
    g_settings_get_mapped($!s, $key, &mapping, $user_data);
  }

  method get_string (Str() $key) is also<get-string> {
    g_settings_get_string($!s, $key);
  }

  method get_strv (Str() $key) is also<get-strv> {
    CStringArrayToArray( g_settings_get_strv($!s, $key) );
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_settings_get_type, $n, $t );
  }

  method get_uint (Str() $key) is also<get-uint> {
    g_settings_get_uint($!s, $key);
  }

  method get_uint64 (Str() $key) is also<get-uint64> {
    g_settings_get_uint64($!s, $key);
  }

  method get_user_value (Str() $key) is also<get-user-value> {
    g_settings_get_user_value($!s, $key);
  }

  method get_value (Str() $key, :$raw = False) is also<get-value> {
    my $v = g_settings_get_value($!s, $key);

    $v ??
      ( $raw ?? $v !! GLib::Variant.new($v, :!ref) )
      !!
      Nil;
  }

  method is_writable (Str() $name) is also<is-writable> {
    so g_settings_is_writable($!s, $name);
  }

  method list_children is also<list-children> {
    CStringArrayToArray( g_settings_list_children($!s) );
  }

  method reset (Str() $key) {
    g_settings_reset($!s, $key);
  }

  method revert {
    g_settings_revert($!s);
  }

  method set_boolean (Str() $key, Int() $value) is also<set-boolean> {
    my gboolean $v = $value;

    so g_settings_set_boolean($!s, $key, $v);
  }

  method set_double (Str() $key, Num() $value) is also<set-double> {
    my gdouble $v = $value;

    so g_settings_set_double($!s, $key, $v);
  }

  method set_enum (Str() $key, Int() $value) is also<set-enum> {
    my gint $v = $value;

    so g_settings_set_enum($!s, $key, $v);
  }

  method set_flags (Str() $key, Int() $value) is also<set-flags> {
    my gint $v = $value;

    so g_settings_set_flags($!s, $key, $v);
  }

  proto method set_strv (|)
      is also<set-strv>
  { * }

  multi method set_strv(
    Str() $key,
          @value
  ) {
    samewith( $key, ArrayToCArray(@value, :null) );
  }
  multi method set_strv (
    Str()       $key,
    CArray[Str] $value
  ) {
    so g_settings_set_strv($!s, $key, resolve-gstrv($value) )
  }

  method set_int (Str() $key, $value is copy) is also<set-int> {
    if $value !~~ (Int, Num).any {
      $*ERR.say: "Warning! Coering «{ $value }» to Int when {
                  '' }setting '{ $key }'";
      $value .= Int;
    }
    my gint $v = $value;

    so g_settings_set_int($!s, $key, $v);
  }

  method set_int64 (Str() $key, $value is copy) is also<set-int64> {
    if $value !~~ (Int, Num).any {
      $*ERR.say: "Warning! Coering «{ $value }» to Int when {
                  '' }setting '{ $key }'";
      $value .= Int;
    }
    my gint64 $v = $value;

    so g_settings_set_int64($!s, $key, $v);
  }

  method set_string (Str() $key, $value is copy) is also<set-string> {
    if $value !~~ Str {
      $*ERR.say: "Warning! Coering «{ $value }» to Str when {
                  '' }setting '{ $key }'";
      $value .= Str;
    }

    so g_settings_set_string($!s, $key, $value);
  }

  method set_uint (Str() $key, $value is copy) is also<set-uint> {
    if $value !~~ (Int, Num).any {
      $*ERR.say: "Warning! Coering «{ $value }» to Int when {
                  '' }setting '{ $key }'";
      $value .= Int;
    }
    my guint $v = $value;

    so g_settings_set_uint($!s, $key, $v);
  }

  method set_uint64 (Str() $key, $value is copy) is also<set-uint64> {
    if $value !~~ (Int, Num).any {
      $*ERR.say: "Warning! Coering «{ $value }» to Int when {
                  '' }setting '{ $key }'";
      $value .= Int;
    }
    my guint64 $v = $value;

    so g_settings_set_uint64($!s, $key, $v);
  }

  method set_value (Str() $key, GVariant() $value) is also<set-value> {
    so g_settings_set_value($!s, $key, $value);
  }

  method sync {
    g_settings_sync();
  }

  method unbind (
    GIO::Settings:U:
    GObject()        $object,
    Str()            $property
  ) {
    g_settings_unbind($object, $property);
  }

  # Associative methods

  method keys {
    state $keys = self.settings-schema.list-keys;
    $keys;
  }

  method AT-KEY (Str() $k) is rw {
    return Nil without self.keys.first($k);

    my $t = self.settings-schema.get-key($k).value-type;

    sub getKeyValue ($_) {
      when 'b'               { self.get_boolean($k) }
      when 'y' | 'q' | 'i' |
           'h'               { self.get_uint($k)    }
      when 'd'               { self.get_double($k)  }
      when 's' | 'g'         { self.get_string($k)  }

      default {
        X::GLib::Error.new(
          message => "Do not know how to handle single value variant type {
                      ''} '{ $_ }'"
        ).throw
      }
    }

    sub setKeyValue ($_, \v) {
      when 'b'               { self.set_boolean($k, v) }
      when 'y' | 'q' | 'i' |
           'h'               { self.set_uint($k, v)    }
      when 'd'               { self.set_double($k, v)  }
      when 's' | 'g'         { self.set_string($k, v)  }

      default {
        X::GLib::Error.new(
          message => "Do not know how to handle single value variant type {
                      ''} '{ $_ }'"
        ).throw
      }
    }

    Proxy.new:
      FETCH => -> $     { getKeyValue($t)    },
      STORE => -> $, \v { setKeyValue($t, v) }
  }

  method EXISTS-KEY (\k) {
    self.AT-KEY(k).defined;
  }

}
