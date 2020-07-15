use v6.c;

use Method::Also;
use NativeCall;

use GIO::Raw::Types;
use GIO::Raw::Action;

use GLib::Variant;

use GLib::Roles::Properties;

role GIO::Roles::Action {
  also does GLib::Roles::Properties;

  has GAction $!a;

  submethod BUILD (:$action) {
    $!a = $action;

    self!roleInit-Object;
  }

  method !roleInit-Action {
    my \i = findProperImplementor(self.^attributes);

    $!a = cast( GAction, i.get_value(self) );
  }

  method GIO::Raw::Definitions::GAction
    is also<
      GAction
      Action
    >
  { $!a }

  method new-action-object (GAction $action) {
    $action ?? self.bless( :$action ) !! Nil;
  }

  method activate (GVariant() $parameter) {
    g_action_activate($!a, $parameter);
  }

  method change_state (GVariant() $value) is also<change-state> {
    g_action_change_state($!a, $value);
  }

  method get_enabled
    is also<
      get-enabled
      enabled
    >
  {
    so g_action_get_enabled($!a);
  }

  method get_name
    is also<
      get-name
      name
    >
  {
    g_action_get_name($!a);
  }

  method get_parameter_type (:$raw = False)
    is also<
      get-parameter-type
      parameter_type
      parameter-type
    >
  {
    my $v = g_action_get_parameter_type($!a);

    $v ??
      ( $raw ?? $v !! GLib::Variant.new($v) )
      !!
      Nil;
  }

  method get_state (:$raw = False)
    is also<
      get-state
      state
    >
  {
    my $v = g_action_get_state($!a);

    $v ??
      ( $raw ?? $v !! GLib::Variant.new($v) )
      !!
      Nil;
  }

  method get_state_hint (:$raw = False)
    is also<
      get-state-hint
      state_hint
      state-hint
    >
  {
    my $v = g_action_get_state_hint($!a);

    $v ??
      ( $raw ?? $v !! GLib::Variant.new($v) )
      !!
      Nil;
  }

  method get_state_type (:$raw = False)
    is also<
      get-state-type
      state_type
      state-type
    >
  {
    my $v = g_action_get_state_type($!a);

    $v ??
      ( $raw ?? $v !! GLib::Variant.new($v) )
      !!
      Nil;
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_action_get_type, $n, $t );
  }

  method name_is_valid(Str() $action_name) is also<name-is-valid> {
    so g_action_name_is_valid($action_name);
  }

  proto method parse_detailed_name (|)
    is also<parse-detailed-name>
  { * }

  multi method parse_detailed_name (
    Str() $detailed_name,
    Str() $action_name,
    GVariant() $target_value,
    CArray[Pointer[GError]] $error = gerror
  ) {
    clear_error;
    my $rc = so g_action_parse_detailed_name(
      $detailed_name,
      $action_name,
      $target_value,
      $error
    );
    set_error($error);
    $rc;
  }
  multi method print_detailed_name (
    Str() $action_name,
    GVariant() $target_value
  ) {
    g_action_print_detailed_name($action_name, $target_value);
  }

}
