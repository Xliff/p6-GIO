use v6.c;

use Method::Also;

use GIO::Raw::Types;
use GIO::DBus::Raw::Utils;

use GLib::Roles::StaticClass;

class GIO::DBus::Utils {
  also does GLib::Roles::StaticClass;

  method generate_guid is also<generate-guid> {
    g_dbus_generate_guid();
  }

  method gvalue_to_gvariant (GValue() $gvalue, Int() $type)
    is also<gvalue-to-gvariant>
  {
    my GVariantType $t = $type;

    g_dbus_gvalue_to_gvariant($gvalue, $t);
  }

  proto method gvariant_to_gvalue (|)
      is also<gvariant-to-gvalue>
  { * }

  multi method gvariant_to_gvalue (GVariant() $value) {
    my $gv = GValue.new;
    samewith($value, $gv);
  }
  multi method gvariant_to_gvalue (GVariant() $value, GValue() $out_gvalue) {
    g_dbus_gvariant_to_gvalue($value, $out_gvalue);
    $out_gvalue;
  }

  method is_guid (Str() $string) is also<is-guid> {
    so g_dbus_is_guid($string);
  }

  method is_interface_name (Str() $string) is also<is-interface-name> {
    so g_dbus_is_interface_name($string);
  }

  method is_member_name (Str() $string) is also<is-member-name> {
    so g_dbus_is_member_name($string);
  }

  method is_name (Str() $string) is also<is-name> {
    so g_dbus_is_name($string);
  }

  method is_unique_name (Str() $string) is also<is-unique-name> {
    so g_dbus_is_unique_name($string);
  }

  method own_name (
    Int()          $bus_type,
    Str()          $name,
    Int()          $flags                  = 0,
                   &bus_acquired_handler   = Callable,
                   &name_acquired_handler  = Callable,
                   &name_lost_handler      = Callable,
    gpointer       $user_data              = gpointer,
    GDestroyNotify &user_data_free_func    = Callable
  ) {
    my GBusType           $b = $bus_type;
    my GBusNameOwnerFlags $f = $flags;

    g_bus_own_name(
      $b,
      $name,
      $f,
      &bus_acquired_handler,
      &name_acquired_handler,
      &name_lost_handler,
      $user_data,
      &user_data_free_func
    );
  }

  method own_name_on_connection (
    GDBusConnection() $connection,
    Str()             $name,
    Int()             $flags,
                      &name_acquired_handler = Callable,
                      &name_lost_handler     = Callable,
    gpointer          $user_data             = gpointer,
                      &user_data_free_func   = Callable
  ) {
    my GBusNameOwnerFlags $f = $flags;

    g_bus_own_name_on_connection(
      $connection,
      $name,
      $f,
      &name_acquired_handler,
      &name_lost_handler,
      $user_data,
      &user_data_free_func
    );
  }

  method own_name_on_connection_with_closures (
    GDBusConnection() $connection,
    Str()             $name,
    Int()             $flags                 = 0,
    GClosure()        $name_acquired_closure = GClosure,
    GClosure()        $name_lost_closure     = GClosure
  ) {
    my GBusNameOwnerFlags $f = $flags;

    g_bus_own_name_on_connection_with_closures(
      $connection,
      $name,
      $f,
      $name_acquired_closure,
      $name_lost_closure
    );
  }

  method own_name_with_closures (
    Int()      $bus_type,
    Str()      $name,
    Int()      $flags                 = 0,
    GClosure() $bus_acquired_closure  = GClosure,
    GClosure() $name_acquired_closure = GClosure,
    GClosure() $name_lost_closure     = GClosure
  ) {
    my GBusType           $b = $bus_type;
    my GBusNameOwnerFlags $f = $flags;

    g_bus_own_name_with_closures(
      $b,
      $name,
      $f,
      $bus_acquired_closure,
      $name_acquired_closure,
      $name_lost_closure
    );
  }

  method unown_name (Int() $owner_id) {
    my guint $o = $owner_id;

    g_bus_unown_name($o);
  }

  method unwatch_name (guint $watcher_id) {
    my guint $w = $watcher_id;

    g_bus_unwatch_name($w);
  }

  proto method watch_name (|)
  { * }

  # cw: -XXX- Apply this treatment on all similar, please!
  #     2022/09/16
  multi method watch_name (
    Int()          $bus_type,
    Str()          $name,
    gpointer       $user_data               = gpointer,
    Int()          :$flags                  = 0,
                   :name-appeared-handler(
                      :&name_appeared_handler
                    ) = Callable,
                   :name-vanished-handler(
                      :&name_vanished_handler
                    ) = Callable,
                   :user-data-free-func(
                      :&user_data_free_func
                    ) = Callable
  ) {
    samewith(
      $bus_type,
      $name,
      $flags,
      &name_appeared_handler,
      &name_vanished_handler,
      $user_data,
      &user_data_free_func
    );
  }
  multi method watch_name (
    Int()          $bus_type,
    Str()          $name,
    Int()          $flags                  = 0,
                   &name_appeared_handler  = Callable,
                   &name_vanished_handler  = Callable,
    gpointer       $user_data              = gpointer,
                   &user_data_free_func    = Callable
  ) {
    my GBusType $b = $bus_type;
    my GBusNameWatcherFlags $f = $flags;

    g_bus_watch_name(
      $b,
      $name,
      $f,
      &name_appeared_handler,
      &name_vanished_handler,
      $user_data,
      &user_data_free_func
    );
  }

  method watch_name_on_connection (
    GDBusConnection() $connection,
    Str()             $name,
    Int()             $flags                  = 0,
                      &name_appeared_handler  = Callable,
                      &name_vanished_handler  = Callable,
    gpointer          $user_data              = gpointer,
                      &user_data_free_func    = Callable
  ) {
    my GBusNameWatcherFlags $f = $flags;

    g_bus_watch_name_on_connection(
      $connection,
      $name,
      $f,
      &name_appeared_handler,
      &name_vanished_handler,
      $user_data,
      &user_data_free_func
    );
  }

  method watch_name_on_connection_with_closures (
    GDBusConnection() $connection,
    Str()             $name,
    Int()             $flags                 = 0,
    GClosure()        $name_appeared_closure = GClosure,
    GClosure()        $name_vanished_closure = GClosure
  ) {
    my GBusNameWatcherFlags $f = $flags;

    g_bus_watch_name_on_connection_with_closures(
      $connection,
      $name,
      $f,
      $name_appeared_closure,
      $name_vanished_closure
    );
  }

  method watch_name_with_closures (
    Int()      $bus_type,
    Str()      $name,
    Int()      $flags                 = 0,
    GClosure() $name_appeared_closure = GClosure,
    GClosure() $name_vanished_closure = GClosure
  ) {
    my GBusType             $b = $bus_type;
    my GBusNameWatcherFlags $f = $flags;

    g_bus_watch_name_with_closures(
      $b,
      $name,
      $f,
      $name_appeared_closure,
      $name_vanished_closure
    );
  }

}
