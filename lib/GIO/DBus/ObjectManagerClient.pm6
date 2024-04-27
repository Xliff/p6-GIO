use v6.c;

use Method::Also;

use NativeCall;

use GIO::Raw::Types;
use GIO::DBus::Raw::Types;

use GIO::DBus::Raw::ObjectManagerClient;

use GLib::Value;
use GIO::DBus::Connection;

use GLib::Roles::Object;

our subset GDBusObjectManagerClientAncestry is export of Mu
  where GDBusObjectManagerClient | GObject;

class GIO::DBus::ObjectManagerClient {
  also does GLib::Roles::Object;

  has GDBusObjectManagerClient $!domc is implementor;

  submethod BUILD (:$client) {
    self.setGDBusObjectManagerClient($client) if $client;
  }

  method setGDBusObjectManagerClient (GDBusObjectManagerClientAncestry $_) {
    my $to-parent;

    $!domc = do {
      when GDBusObjectManagerClient {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GDBusObjectManagerClient, $_);
      }
    }
    self!setObject($to-parent);
  }

  method GIO::Raw::Definitions::GDBusObjectManagerClient
    is also<GDBusObjectManagerClient>
  { $!domc }

  multi method new (GDBusObjectManagerClientAncestry $client, :$ref = True) {
    return Nil unless $client;

    my $o = self.bless( :$client );
    $o.ref if $ref;
    $o;
  }
  multi method new (
    GDBusConnection()       $connection,
    Int()                   $flags,
    Str()                   $name,
    Str()                   $object_path,
                            &get_proxy_type_func           = Callable,
    gpointer                $get_proxy_type_user_data      = gpointer,
    GDestroyNotify          $get_proxy_type_destroy_notify = gpointer,
    GCancellable()          $cancellable                   = GCancellable,
    CArray[Pointer[GError]] $error                         = gerror
  ) {
    self.new(
      $connection,
      $flags,
      $name,
      $object_path,
      &get_proxy_type_func,
      $get_proxy_type_user_data,
      $get_proxy_type_destroy_notify,
      $cancellable,
      $error
    );
  }
  multi method new (
    GDBusConnection()       $connection,
    Int()                   $flags,
    Str()                   $name,
    Str()                   $object_path,
                            &get_proxy_type_func,
    gpointer                $get_proxy_type_user_data      = gpointer,
    GDestroyNotify          $get_proxy_type_destroy_notify = gpointer,
    GCancellable()          $cancellable                   = GCancellable,
    CArray[Pointer[GError]] $error                         = gerror
  ) {
    my GDBusObjectManagerClientFlags $f = $flags;

    clear_error;
    my $client = g_dbus_object_manager_client_new_sync(
      $connection,
      $f,
      $name,
      $object_path,
      &get_proxy_type_func,
      $get_proxy_type_user_data,
      $get_proxy_type_destroy_notify,
      $cancellable,
      $error
    );
    set_error($error);

    $client ?? self.bless( :$client ) !! Nil;
  }

  proto method new_async (|)
    is also<new-async>
  { * }

  multi method new (
    GDBusConnection() $connection,
    Str()             $name,
    Str()             $object_path,
                      &callback,
    gpointer          $user_data                      =  gpointer,
                      :$async                         is required,
    Int()             :$flags                         =  0,
                      :&get_proxy_type_func           =  Callable,
    gpointer          :$get_proxy_type_user_data      =  gpointer,
                      :&get_proxy_type_destroy_notify =  Callable,
    GCancellable()    :$cancellable                   =  GCancellable
  ) {
    self.new_async(
      $connection,
      $flags,
      $name,
      $object_path,
      &get_proxy_type_func,
      $get_proxy_type_user_data,
      &get_proxy_type_destroy_notify,
      $cancellable,
      &callback,
      $user_data
    );
  }
  multi method new (
    GDBusConnection() $connection,
    Int()             $flags,
    Str()             $name,
    Str()             $object_path,
                      &get_proxy_type_func,
    gpointer          $get_proxy_type_user_data,
                      &get_proxy_type_destroy_notify,
    GCancellable()    $cancellable,
                      &callback,
    gpointer          $user_data                      =  gpointer,
                      :$async                         is required
  ) {
    samewith(
      $connection,
      $flags,
      $name,
      $object_path,
      &get_proxy_type_func,
      $get_proxy_type_user_data,
      &get_proxy_type_destroy_notify,
      $cancellable,
      &callback,
      $user_data
    );
  }
  multi method new_async (
    GDBusConnection() $connection,
    Str()             $name,
    Str()             $object_path,
                      &callback,
    gpointer          $user_data                      = gpointer,
    Int()             :$flags                         = 0,
                      :&get_proxy_type_func           = Callable,
    gpointer          :$get_proxy_type_user_data      = gpointer,
                      :&get_proxy_type_destroy_notify = Callable,
    GCancellable()    :$cancellable                   = GCancellable
  ) {
    self.new_async(
      $connection,
      $flags,
      $name,
      $object_path,
      &get_proxy_type_func,
      $get_proxy_type_user_data,
      &get_proxy_type_destroy_notify,
      $cancellable,
      &callback,
      $user_data
    );
  }
  multi method new_async (
    GDBusConnection() $connection,
    Int()             $flags,
    Str()             $name,
    Str()             $object_path,
                      &get_proxy_type_func,
    gpointer          $get_proxy_type_user_data,
                      &get_proxy_type_destroy_notify,
    GCancellable()    $cancellable,
                      &callback,
    gpointer          $user_data                      = gpointer
  ) {
    my GDBusObjectManagerClientFlags $f = $flags;

    my $c = g_dbus_object_manager_client_new(
      $connection,
      $f,
      $name,
      $object_path,
      &get_proxy_type_func,
      $get_proxy_type_user_data,
      &get_proxy_type_destroy_notify,
      $cancellable,
      &callback,
      $user_data
    );

    $c ?? self.new( client => $c ) !! Nil;
  }

  multi method new (
    GAsyncResult()          $res,
    CArray[Pointer[GError]] $error   = gerror,
                            :$finish is required
  ) {
    self.new_finish($res, $error);
  }
  method new_finish (
    GAsyncResult()          $res,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<new-finish>
  {
    clear_error;
    my $client = g_dbus_object_manager_client_new_finish($res, $error);
    set_error($error);

    $client ?? self.bless( :$client ) !! Nil;
  }

  proto method new_for_bus (|)
    is also<new-for-bus>
  { * }

  multi method new (
    Int()                   $bus_type,
    Str()                   $name,
    Str()                   $object_path,
    CArray[Pointer[GError]] $error                          =  gerror,
                            :$bus                           is required,
    Int()                   :$flags                         =  0,
                            :$get_proxy_type_func           =  Callable,
    gpointer                :$get_proxy_type_user_data      =  gpointer,
    GDestroyNotify          :$get_proxy_type_destroy_notify =  gpointer,
    GCancellable()          :$cancellable                   =  GCancellable
  ) {
    self.new_for_bus(
      $bus_type,
      $flags,
      $name,
      $object_path,
      $get_proxy_type_func,
      $get_proxy_type_user_data,
      $cancellable,
      $error
    );
  }
  multi method new (
    Int()                   $bus_type,
    Int()                   $flags,
    Str()                   $name,
    Str()                   $object_path,
                            $get_proxy_type_func           =  Callable,
    gpointer                $get_proxy_type_user_data      =  gpointer,
    GDestroyNotify          $get_proxy_type_destroy_notify =  gpointer,
    GCancellable()          $cancellable                   =  GCancellable,
    CArray[Pointer[GError]] $error                         =  gerror,
                            :$bus                          is required
  ) {
    self.new_for_bus(
      $bus_type,
      $flags,
      $name,
      $object_path,
      $get_proxy_type_func,
      $get_proxy_type_user_data,
      $cancellable,
      $error
    );
  }
  multi method new_for_bus (
    Int()                   $bus_type,
    Str()                   $name,
    Str()                   $object_path,
    CArray[Pointer[GError]] $error                          = gerror,
    Int()                   :$flags                         = 0,
                            :$get_proxy_type_func           = Callable,
    gpointer                :$get_proxy_type_user_data      = gpointer,
    GDestroyNotify          :$get_proxy_type_destroy_notify = gpointer,
    GCancellable()          :$cancellable                   = GCancellable
  ) {
    self.new_for_bus($bus_type, $flags, $name, $object_path, gpointer);
  }
  multi method new_for_bus (
    Int()                   $bus_type,
    Int()                   $flags,
    Str()                   $name,
    Str()                   $object_path,
                            $get_proxy_type_func           = Callable,
    gpointer                $get_proxy_type_user_data      = gpointer,
    GDestroyNotify          $get_proxy_type_destroy_notify = gpointer,
    GCancellable()          $cancellable                   = GCancellable,
    CArray[Pointer[GError]] $error                         = gerror
  ) {
    my GBusType                      $b = $bus_type;
    my GDBusObjectManagerClientFlags $f = $flags;

    clear_error;
    my $client = g_dbus_object_manager_client_new_for_bus_sync(
      $!domc,
      $flags,
      $name,
      $object_path,
      $get_proxy_type_func,
      $get_proxy_type_user_data,
      $get_proxy_type_destroy_notify,
      $cancellable,
      $error
    );
    set_error($error);

    $client ?? self.bless( :$client ) !! Nil;
  }

  proto method new_for_bus_async (|)
    is also<new-for-bus-async>
  { * }

  multi method new (
    Int()          $bus_type,
    Str()          $name,
    Str()          $object_path,
                   &callback,
    gpointer       $user_data                       =  gpointer,
                   :bus_async(:$bus-async)          is required,
    GCancellable() :$cancellable                    =  GCancellable,
    Int()          :$flags                          =  0,
                   :&get_proxy_type_func            =  Callable,
    gpointer       :$get_proxy_type_user_data       =  gpointer,
                   :&get_proxy_type_destroy_notify  =  Callable
  ) {
    self.new_for_bus_async(
      $bus_type,
      $flags,
      $name,
      $object_path,
      &get_proxy_type_func,
      $get_proxy_type_user_data,
      $cancellable,
      &callback,
      $user_data
    );
  }
  multi method new (
    Int()          $bus_type,
    Int()          $flags,
    Str()          $name,
    Str()          $object_path,
                   &get_proxy_type_func,
    gpointer       $get_proxy_type_user_data,
                   &get_proxy_type_destroy_notify,
    GCancellable() $cancellable,
                   &callback,
    gpointer       $user_data                      =  gpointer,
                   :bus_async(:$bus-async)         is required
  ) {
    self.new_for_bus_async(
      $bus_type,
      $flags,
      $name,
      $object_path,
      &get_proxy_type_func,
      $get_proxy_type_user_data,
      $cancellable,
      &callback,
      $user_data
    );
  }
  multi method new_for_bus_async (
    Int()          $bus_type,
    Str()          $name,
    Str()          $object_path,
                   &callback,
    gpointer       $user_data                       = gpointer,
    GCancellable() :$cancellable                    = GCancellable,
    Int()          :$flags                          = 0,
                   :&get_proxy_type_func            = Callable,
    gpointer       :$get_proxy_type_user_data       = gpointer,
                   :&get_proxy_type_destroy_notify  = Callable,
  ) {
    samewith(
      $bus_type,
      $flags,
      $name,
      $object_path,
      &get_proxy_type_func,
      $get_proxy_type_user_data,
      $cancellable,
      &callback,
      $user_data
    );
  }
  multi method new_for_bus_async (
    Int()          $bus_type,
    Int()          $flags,
    Str()          $name,
    Str()          $object_path,
                   &get_proxy_type_func,
    gpointer       $get_proxy_type_user_data,
                   &get_proxy_type_destroy_notify,
    GCancellable() $cancellable,
                   &callback,
    gpointer       $user_data                      = gpointer
  ) {
    my GBusType                      $b = $bus_type;
    my GDBusObjectManagerClientFlags $f = $flags;

    g_dbus_object_manager_client_new_for_bus(
      $b,
      $f,
      $name,
      $object_path,
      &get_proxy_type_func,
      $get_proxy_type_user_data,
      &get_proxy_type_destroy_notify,
      $cancellable,
      &callback,
      $user_data
    );
  }

  multi method new (
    GAsyncResult()            $res,
    CArray[Pointer[GError]]   $error =  gerror,
    :bus_finish(:$bus-finish)        is required
  ) {
    self.new_for_bus_finish($res, $error);
  }
  method new_for_bus_finish (
    GAsyncResult()          $res,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<new-for-bus-finish>
  {
    g_dbus_object_manager_client_new_for_bus_finish($res, $error);
  }

  method get_connection (:$raw = False)
    is also<
      get-connection
      connection
    >
  {
    my $c = g_dbus_object_manager_client_get_connection($!domc);

    $c ??
      ( $raw ?? $c !! GIO::DBus::Connection.new($c, :!ref) )
      !!
      Nil;
  }

  # Type: Str
  method object-path is rw  is also<object_path> {
    my GLib::Value $gv .= new( G_TYPE_STRING );
    Proxy.new(
      FETCH => -> $ {
        $gv = GLib::Value.new(
          self.prop_get('object-path', $gv)
        );
        $gv.string;
      },
      STORE => -> $, Str() $val is copy {
        warn 'object-path is a CONSTRUCT-ONLY property' if $DEBUG;
      }
    );
  }

  # Is originally:
  # GDBusObjectManagerClient, GDBusObjectProxy, GDBusProxy, GVariant, GStrv, gpointer --> void
  method interface-proxy-properties-changed is also<interface_proxy_properties_changed> {
    self.connect-interface-proxy-properties-changed($!domc);
  }

  # Is originally:
  # GDBusObjectManagerClient, GDBusObjectProxy, GDBusProxy, Str, gchar, GVariant, gpointer --> void
  method interface-proxy-signal is also<interface_proxy_signal> {
    self.connect-interface-proxy-signal($!domc);
  }

  method get_flags
    is also<
      get-flags
      flags
    >
  {
    GDBusObjectManagerClientFlagsEnum(
      g_dbus_object_manager_client_get_flags($!domc)
    );
  }

  method get_name
    is also<
      get-name
      name
    >
  {
    g_dbus_object_manager_client_get_name($!domc)
  }

  method get_name_owner
    is also<
      get-name-owner
      name_owner
      name-owner
    >
  {
    g_dbus_object_manager_client_get_name_owner($!domc);
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type(
      self.^name,
      &g_dbus_object_manager_client_get_type,
      $n,
      $t
    );
  }

}
