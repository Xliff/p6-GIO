use v6.c;

use Method::Also;
use NativeCall;

use GIO::Raw::Types;
use GIO::Raw::Application;

use GLib::Roles::Object;

use GIO::DBus::Connection;

use GIO::Roles::Signals::Application;

class GIO::Application {
  also does GLib::Roles::Object;
  also does GIO::Roles::Signals::Application;

  has GApplication $!a is implementor;

  submethod BUILD (:$application) {
    given $application {
      when GApplication { $!a = $application }
      default           { $!a = cast(GApplication, $application) }
    }

    self.roleInit-Object;
  }

  method GIO::Raw::Definitions::GApplication
    is also<GApplication>
  { $!a }

  multi method new (GApplication $application, :$ref = True) {
    return Nil unless $application;

    my $a = self.bless(:$application);
    $a.ref if $ref;
    $a;
  }
  multi method new (Str() $app_id, Int() $flags) {
    my GApplicationFlags $f = $flags;
    my $application = g_application_new($app_id, $f);

    $application ?? self.bless(:$application) !! Nil;
  }

  method get_default (GIO::Application:U: :$raw = False) is also<get-default> {
    my $a = g_application_get_default();

    $a ??
      ( $raw ?? $a !! GIO::Appliction.new($a) )
      !!
      Nil;
  }

  # Is originally:
  # GApplication, gpointer --> void
  method activate {
    self.connect($!a, 'activate');
  }

  # Is originally:
  # GApplication, GApplicationCommandLine, gpointer --> gint
  method command-line is also<command_line> {
    self.connect-command-line($!a);
  }

  # Is originally:
  # GApplication, GVariantDict, gpointer --> gint
  method handle-local-options is also<handle_local_options> {
    self.connect-handle-local-options($!a);
  }

  # Is originally:
  # GApplication, gpointer --> gboolean
  method name-lost is also<name_lost> {
    self.connect-rbool($!a, 'name-lost');
  }

  # Is originally:
  # GApplication, gpointer, gint, gchar, gpointer --> void
  # Made multi so as to not conflict with below methods.
  multi method open {
    self.connect-open($!a);
  }

  # Is originally:
  # GApplication, gpointer --> void
  method shutdown {
    self.connect($!a, 'shutdown');
  }

  # Is originally:
  # GApplication, gpointer --> void
  method startup {
    self.connect($!a, 'startup');
  }

  method emit_activate is also<emit-activate> {
    g_application_activate($!a);
  }

  method add_main_option (
    Str() $long_name,
    Str() $short_name,
    Int() $flags,
    GOptionArg $arg,
    Str() $description,
    Str() $arg_description
  )
    is also<add-main-option>
  {
    my GOptionFlags $f = $flags;

    g_application_add_main_option(
      $!a,
      $long_name,
      $short_name,
      $flags,
      $arg,
      $description,
      $arg_description
    );
  }

  proto method add_main_option_entries (|)
      is also<add-main-option-entries>
  { * }

  multi method add_main_option_entries (@entries) {
    # cw: XXX - Must be zero terminated! Do we account for that in TypedfBuffer?
    samewith( GLib::Roles::TypedBuffer.new(@entries).p );
  }
  multi method add_main_option_entries (Pointer $entries) {
    g_application_add_main_option_entries($!a, $entries);
  }

  method add_option_group (GOptionGroup() $group) is also<add-option-group> {
    g_application_add_option_group($!a, $group);
  }

  method bind_busy_property (GObject() $object, Str() $property)
    is also<bind-busy-property>
  {
    g_application_bind_busy_property($!a, $object, $property);
  }

  method get_application_id is also<get-application-id> {
    g_application_get_application_id($!a);
  }

  method get_dbus_connection (:$raw = False) is also<get-dbus-connection> {
    my $c = g_application_get_dbus_connection($!a);

    $c ??
      ( $raw ?? $c !! GIO::DBus::Connection.new($c) )
      !!
      Nil;
  }

  method get_dbus_object_path is also<get-dbus-object-path> {
    g_application_get_dbus_object_path($!a);
  }

  method get_flags is also<get-flags> {
    g_application_get_flags($!a);
  }

  method get_inactivity_timeout is also<get-inactivity-timeout> {
    g_application_get_inactivity_timeout($!a);
  }

  method get_is_busy is also<get-is-busy> {
    so g_application_get_is_busy($!a);
  }

  method get_is_registered is also<get-is-registered> {
    so g_application_get_is_registered($!a);
  }

  method get_is_remote is also<get-is-remote> {
    so g_application_get_is_remote($!a);
  }

  method get_resource_base_path is also<get-resource-base-path> {
    so g_application_get_resource_base_path($!a);
  }

  method hold {
    g_application_hold($!a);
  }

  method id_is_valid (GIO::Application:U: Str() $app-id)
    is also<id-is-valid>
  {
    so g_application_id_is_valid($app-id);
  }

  method mark_busy is also<mark-busy> {
    g_application_mark_busy($!a);
  }

  multi method open (@files, Str() $hint) {
    samewith( GLib::Roles::TypedBuffer.new(@files), @files.elems, $hint );
  }
  multi method open (Pointer $files, Int() $n_files, Str() $hint) {
    my gint $n = $n_files;

    g_application_open($!a, $files, $n_files, $hint);
  }

  method quit {
    g_application_quit($!a);
  }

  method register (
    GCancellable() $cancellable = GCancellable,
    CArray[Pointer[GError]] $error = gerror
  ) {
    clear_error;
    my $rv = so g_application_register($!a, $cancellable, $error);
    set_error($error);
    $rv;
  }

  method release {
    g_application_release($!a);
  }

  multi method run (@args) {
    samewith( @args.elems, ArrayToCArray(Str, @args) );
  }
  multi method run (Int() $argc, CArray[Str] $argv) {
    my gint $a = $argc;

    g_application_run($!a, $a, $argv);
  }

  method send_notification (Str() $id, GNotification() $notification)
    is also<send-notification>
  {
    g_application_send_notification($!a, $id, $notification);
  }

  method set_action_group (GActionGroup() $action_group)
    is also<set-action-group>
  {
    g_application_set_action_group($!a, $action_group);
  }

  method set_application_id (Str() $application_id)
    is also<set-application-id>
  {
    g_application_set_application_id($!a, $application_id);
  }

  method set_default is also<set-default> {
    g_application_set_default($!a);
  }

  method set_flags (GApplicationFlags $flags) is also<set-flags> {
    g_application_set_flags($!a, $flags);
  }

  method set_inactivity_timeout (Int() $inactivity_timeout)
    is also<set-inactivity-timeout>
  {
    my guint $i = $inactivity_timeout;

    g_application_set_inactivity_timeout($!a, $i);
  }

  method set_option_context_description (Str() $description)
    is also<set-option-context-description>
  {
    g_application_set_option_context_description($!a, $description);
  }

  method set_option_context_parameter_string (Str() $parameter_string)
    is also<set-option-context-parameter-string>
  {
    g_application_set_option_context_parameter_string($!a, $parameter_string);
  }

  method set_option_context_summary (Str() $summary)
    is also<set-option-context-summary>
  {
    g_application_set_option_context_summary($!a, $summary);
  }

  method set_resource_base_path (Str() $resource_path)
    is also<set-resource-base-path>
  {
    g_application_set_resource_base_path($!a, $resource_path);
  }

  method unbind_busy_property (GObject() $object, Str() $property)
    is also<unbind-busy-property>
  {
    g_application_unbind_busy_property($!a, $object, $property);
  }

  method unmark_busy is also<unmark-busy> {
    g_application_unmark_busy($!a);
  }

  method withdraw_notification (Str() $id) is also<withdraw-notification> {
    g_application_withdraw_notification($!a, $id);
  }

}