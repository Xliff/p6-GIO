use v6.c;

use Method::Also;
use NativeCall;

use GIO::Raw::Types;
use GIO::Raw::Application;

use GLib::Roles::Object;

use GIO::Enums;
use GIO::DBus::Connection;
use GIO::Resource;

use GIO::Roles::ActionMap;
use GIO::Roles::ActionGroup;
use GIO::Roles::Signals::Application;

our subset GApplicationAncestry is export of Mu
  where GApplication | GActionGroup | GActionMap | GObject;

constant ApplicationAncestry is export = GApplicationAncestry;

class GIO::Application {
  also does GLib::Roles::Object;
  also does GIO::Roles::ActionMap;
  also does GIO::Roles::ActionGroup;
  also does GIO::Roles::Signals::Application;

  has GApplication $!a is implementor;

  submethod BUILD ( :$gio-application ) {
    self.setGApplication($gio-application) if $gio-application;
  }

  method setGApplication (GApplicationAncestry $_) {
    my $to-parent;

    say "set-GApp: { $_ }";

    $!a = do {
      when GApplication {
        $to-parent = cast(GObject, $_);
        $_
      }

      when GActionGroup {
        $to-parent = cast(GObject, $_);
        $!ag       = $_;
        cast(GApplication, $_)
      }

      when GActionMap {
        $to-parent = cast(GObject, $_);
        $!actmap   = $_;
        cast(GApplication, $_)
      }

      default {
        $to-parent = $_;
        cast(GApplication, $_)
      }
    }
    say "GObject: { $to-parent }" if $DEBUG // 0 > 2;
    say "Implementor: { $!a }"    if $DEBUG // 0 > 2;
    self!setObject($to-parent);
    self.roleInit-ActionMap;
    self.roleInit-GActionGroup;
  }

  method GIO::Raw::Definitions::GApplication
    is also<GApplication>
  { $!a }

  multi method new (GApplicationAncestry $gio-application, :$ref = True) {
    return Nil unless $gio-application;

    my $a = self.bless( :$gio-application );
    $a.ref if $ref;
    $a;
  }
  multi method new (Str() $app_id, Int() $flags = 0) {
    say 'using GIO::Application.new...';

    my GApplicationFlags $f = $flags;

    my $gio-application = g_application_new($app_id, $f);

    say "G-App: { $gio-application // '»UNDEF«' }";

    $gio-application ?? self.bless( :$gio-application ) !! Nil;
  }
  multi method new ( *%a ) {
    my ($app-id, $flags) = %a<application-id flags>:delete;

    die 'Cannot initialize application without an <application-id>'
      unless $app-id;

    %a<resource-base-path> //= '.';

    my $o = samewith($app-id, $flags // 0);
    $o.setAttributes(%a);
  }

  method get_default (GIO::Application:U: :$raw = False) is also<get-default> {
    my $a = g_application_get_default();

    $a ??
      ( $raw ?? $a !! GIO::Appliction.new($a) )
      !!
      Nil;
  }

  # Type: GActionGroup
  method action-group is rw  is g-property {
    my $gv = GLib::Value.new( GIO::ActionGroup.get_type );
    Proxy.new(
      FETCH => sub ($) {
        warn 'action-group does not allow reading' if $DEBUG;
        0;
      },
      STORE => -> $, GActionGroup() $val is copy {
        $gv.pointer = $val;
        self.prop_set('action-group', $gv);
      }
    );
  }

  # Type: string
  method application-id is rw  is g-property {
    my $gv = GLib::Value.new( G_TYPE_STRING );
    Proxy.new(
      FETCH => sub ($) {
        self.prop_get('application-id', $gv);
        $gv.string;
      },
      STORE => -> $, Str() $val is copy {
        $gv.string = $val;
        self.prop_set('application-id', $gv);
      }
    );
  }

  # Type: GApplicationFlags
  method flags ( :set(:$flags) = True ) is rw  is g-property {
    my $gv = GLib::Value.new( GIO::Enums::ActionFlags.get_type );
    Proxy.new(
      FETCH => sub ($) {
        self.prop_get('flags', $gv);
        my $f = $gv.flags;
        return $f unless $flags;
        getFlags(GApplicationFlags, $f);
      },
      STORE => -> $, Int() $val is copy {
        $gv.valueFromEnum(GApplicationFlags) = $val;
        self.prop_set('flags', $gv);
      }
    );
  }

  # Type: uint
  method inactivity-timeout is rw  is g-property {
    my $gv = GLib::Value.new( G_TYPE_UINT );
    Proxy.new(
      FETCH => sub ($) {
        self.prop_get('inactivity-timeout', $gv);
        $gv.uint;
      },
      STORE => -> $, Int() $val is copy {
        $gv.uint = $val;
        self.prop_set('inactivity-timeout', $gv);
      }
    );
  }

  # Type: boolean
  method is-busy is rw  is g-property {
    my $gv = GLib::Value.new( G_TYPE_BOOLEAN );
    Proxy.new(
      FETCH => sub ($) {
        self.prop_get('is-busy', $gv);
        $gv.boolean;
      },
      STORE => -> $, Int() $val is copy {
        warn 'is-busy does not allow writing'
      }
    );
  }

  # Type: boolean
  method is-registered is rw  is g-property {
    my $gv = GLib::Value.new( G_TYPE_BOOLEAN );
    Proxy.new(
      FETCH => sub ($) {
        self.prop_get('is-registered', $gv);
        $gv.boolean;
      },
      STORE => -> $, Int() $val is copy {
        warn 'is-registered does not allow writing'
      }
    );
  }

  # Type: boolean
  method is-remote is rw  is g-property {
    my $gv = GLib::Value.new( G_TYPE_BOOLEAN );
    Proxy.new(
      FETCH => sub ($) {
        self.prop_get('is-remote', $gv);
        $gv.boolean;
      },
      STORE => -> $, Int() $val is copy {
        warn 'is-remote does not allow writing'
      }
    );
  }

  # Type: string
  method resource-base-path is rw  is g-property {
    my $gv = GLib::Value.new( G_TYPE_STRING );
    Proxy.new(
      FETCH => sub ($) {
        self.prop_get('resource-base-path', $gv);
        $gv.string;
      },
      STORE => -> $, Str() $val is copy {
        $gv.string = $val;
        self.prop_set('resource-base-path', $gv);
      }
    );
  }


  # Is originally:
  # GApplication, gpointer --> void
  method activate is also<Activate> {
    say "activate: { $!a // '»NIL«' }" if $DEBUG // 0 > 2;

    self.connect($!a, 'activate');
  }

  # Is originally:
  # GApplication, GApplicationCommandLine, gpointer --> gint
  method command-line
    is also<
      command_line
      Command-Line
      Command_Line
    >
  {
    self.connect-command-line($!a);
  }

  # Is originally:
  # GApplication, GVariantDict, gpointer --> gint
  method handle-local-options
    is also<
      handle_local_options
      Handle-Local-Options
      Handle_Local_Options
    >
  {
    self.connect-handle-local-options($!a);
  }

  # Is originally:
  # GApplication, gpointer --> gboolean
  method name-lost
    is also<
      name_lost
      Name-Lost
      Name_Lost
    >
  {
    self.connect-rbool($!a, 'name-lost');
  }

  # Is originally:
  # GApplication, gpointer, gint, Str, gpointer --> void
  # Made multi so as to not conflict with below methods.
  multi method open is also<Open> {
    self.connect-open($!a);
  }

  # Is originally:
  # GApplication, gpointer --> void
  method shutdown is also<Shutdown> {
    self.connect($!a, 'shutdown');
  }

  # Is originally:
  # GApplication, gpointer --> void
  method startup is also<Startup> {
    self.connect($!a, 'startup');
  }

  method emit_activate is also<emit-activate> {
    g_application_activate($!a);
  }

  method add_main_option (
    Str()      $long_name,
    Str()      $short_name,
    Int()      $flags,
    GOptionArg $arg,
    Str()      $description,
    Str()      $arg_description
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
    samewith(
      GLib::Roles::TypedBuffer.new-typedbuffer-obj(@entries, :zero).p
    );
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
    samewith(
      GLib::Roles::TypedBuffer.new(@files).p,
      @files.elems,
      $hint
    );
  }
  multi method open (Pointer $files, Int() $n_files, Str() $hint) {
    my gint $n = $n_files;

    g_application_open($!a, $files, $n_files, $hint);
  }

  method postInit {
    for $*PROGRAM.dirname.IO.dir.grep( *.extension eq 'gresource' ) {
      print "Loading resources from { .absolute }...";
      GIO::Resources.register(
        GIO::Resource.load( .absolute )
      );
      say "done!";
    }
  }

  proto method quit (|)
    is also<exit>
  { * }

  multi method quit (GIO::Application:D: ) {
    self.quit( :gio );
  }
  multi method quit (GIO::Application:D: :$gio is required) {
    g_application_quit( $!a );
  }

  method register (
    GCancellable()          $cancellable = GCancellable,
    CArray[Pointer[GError]] $error       = gerror
  ) {
    clear_error;
    my $rv = so g_application_register($!a, $cancellable, $error);
    set_error($error);
    $rv;
  }

  method release {
    g_application_release($!a);
  }

  multi method run {
    samewith( ().Array );
  }
  multi method run (@args) {
    samewith( @args.elems, ArrayToCArray(Str, @args) );
  }
  multi method run (Int() $argc = 0, CArray[Str] $argv = CArray[Str]) {
    my gint $ac = $argc;

    if $argc {
      die "Count given with no defined list of arguments!"
        if !$argv || $argv.elems == 0;
    }

    say "Run -- \$!a: {$!a.&p} / a: { $ac } / \$argv: { $argv ?? $argv.&p !! '»UNDEF«' }";

    g_application_run($!a, $ac, $argv);
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

  method set_application_id (Str() $gio-application_id)
    is also<set-application-id>
  {
    g_application_set_application_id($!a, $gio-application_id);
  }

  method set_default is also<set-default> {
    g_application_set_default($!a);
  }

  method set_flags (Int() $flags) is also<set-flags> {
    my GApplicationFlags $f = $flags;

    g_application_set_flags($!a, $f);
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
