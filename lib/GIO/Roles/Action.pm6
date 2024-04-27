use v6.c;

use Method::Also;
use NativeCall;

use GIO::Raw::Types;
use GIO::Raw::Action;

use GLib::Variant;

use GLib::Roles::Object;

role GIO::Roles::Action {
  has GAction $!a;

  method !roleInit-Action {
    return if $!a;

    my \i = findProperImplementor(self.^attributes);
    $!a = cast( GAction, i.get_value(self) );
  }
  method roleInit-GAction {
    self!roleInit-Action;
  }

  method GIO::Raw::Definitions::GAction
    is also<
      GAction
      Action
    >
  { $!a }

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
      ( $raw ?? $v !! GLib::Variant.new($v, :!ref) )
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
      ( $raw ?? $v !! GLib::Variant.new($v, :!ref) )
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
      ( $raw ?? $v !! GLib::Variant.new($v, :!ref) )
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
      ( $raw ?? $v !! GLib::Variant.new($v, :!ref) )
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


  proto method parse_detailed_name (
    Str()                   $detailed_name,
    Str()                   $action_name,
    CArray[Pointer[GError]] $error         = gerror
  ) {
    my $rv = samewith($detailed_name, $action_name, $, $error, :all);

    $rv[0] ?? $rv[1] !! Nil;
  }
  multi method parse_detailed_name (
    Str()                   $detailed_name,
    Str()                   $action_name,
                            $target_value is rw,
    CArray[Pointer[GError]] $error        = gerror,
                            :$all         = False,
                            :$raw         = False
  ) {
    my $tv = CArray[GVariant].new;
    $tv[0] = GVariant;

    clear_error;
    my $rv = so g_action_parse_detailed_name(
      $detailed_name,
      $action_name,
      $tv,
      $error
    );
    set_error($error);

    $tv = ppr($tv);
    $tv = GLib::Variant.new($tv) unless $tv.not || $raw;
    $target_value = $tv;

    $all.not ?? $rv !! ($rv, $target_value);
  }

  method print_detailed_name (
    Str() $action_name,
    GVariant() $target_value
  ) {
    g_action_print_detailed_name($action_name, $target_value);
  }

}

our subset GActionAncestry is export of Mu
  where GAction | GObject;

class GIO::Action does GLib::Roles::Object does GIO::Roles::Action {

  submethod BUILD (:$action) {
    self.setGAction($action) if $action;
  }

  method setGAction (GActionAncestry $_) {
    my $to-parent;

    $!a = do {
      when GAction {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GAction, $_);
      }
    }
    self!setObject($to-parent);
  }

  method new (GActionAncestry $action, :$ref = True) {
    return Nil unless $action;

    my $o = self.bless( :$action );
    $o.ref if $ref;
    $o;
  }

}
