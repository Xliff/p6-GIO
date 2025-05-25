use v6.c;

use Method::Also;
use NativeCall;

use GIO::Raw::Types;
use GIO::DBus::Raw::Proxy;

use GIO::DBus::Connection;

use GLib::Roles::Object;
use GIO::Roles::Initable;
use GIO::Roles::AsyncInitable;
use GIO::DBus::Roles::Object;
use GIO::DBus::Roles::Signals::Proxy;
use GIO::DBus::Roles::Interface;
use GIO::DBus::Roles::SupplyCallback;

our subset GDBusProxyAncestry is export of Mu
  where GDBusProxy | GAsyncInitable | GInitable | GObject;

class GIO::DBus::Proxy {
  also does GLib::Roles::Object;
  also does GIO::Roles::Initable;
  also does GIO::Roles::AsyncInitable;
  also does GIO::DBus::Roles::Signals::Proxy;
  also does GIO::DBus::Roles::SupplyCallback;

  has GDBusProxy $!dp      is implementor;

  submethod BUILD (
    :initable-object( :$proxy ),
    :$init,
    :$cancellable,
    :$!supply
  ) {
    self.setGDBusProxy($proxy, :$init, :$cancellable) if $proxy;
  }

  method setGDBusProxy (
    GDBusProxyAncestry $_,
                       :$init,
                       :$cancellable
  ) {
    my $to-parent;

    $!dp = do {
      when GDBusProxy {
        $to-parent = cast(GObject, $_);
        $_;
      }

      when GAsyncInitable {
        $to-parent = cast(GObject, $_);
        $!ai = $_;
        cast(GDBusProxy, $_);
      }

      when GInitable {
        $to-parent = cast(GObject, $_);
        $!i = $_;
        cast(GDBusProxy, $_);
      }

      default {
        $to-parent = $_;
        cast(GDBusProxy, $_);
      }
    }

    self!setObject($to-parent);
    self.roleInit-AsyncInitable;
    self.roleInit-Initable(:$init, :$cancellable);
  }

  method GIO::Raw::Definitions::GDBusProxy
    is also<GDBusProxy>
  { $!dp }

  multi method new (GDBusProxyAncestry $proxy, :$ref = True) {
    return Nil unless $proxy;

    my $o = self.bless( :$proxy );
    $o.ref if $ref;
    $o;
  }

  proto method new_sync (|)
    is also<new-sync>
  { * }

  multi method new (
    GDBusConnection()       $connection,
    Str()                   $object_path,
    Str()                   $interface_name,
    CArray[Pointer[GError]] $error           =  gerror,
                            :$sync           is required,
    Int()                   :$flags          =  0,
    GDBusInterfaceInfo      :$info           =  GDBusInterfaceInfo,
    Str()                   :$name           =  Str,
    GCancellable()          :$cancellable    =  GCancellable
  ) {
    self.new_sync(
      $connection,
      $flags,
      $info,
      $name,
      $object_path,
      $interface_name,
      $cancellable,
      $error
    );
  }
  multi method new_sync (
    GDBusConnection()       $connection,
    Str()                   $object_path,
    Str()                   $interface_name,
    CArray[Pointer[GError]] $error           = gerror,
    Int()                   :$flags          = 0,
    GDBusInterfaceInfo      :$info           = GDBusInterfaceInfo,
    Str()                   :$name           = Str,
    GCancellable()          :$cancellable    = GCancellable
  ) {
    samewith(
      $connection,
      $flags,
      $info,
      $name,
      $object_path,
      $interface_name,
      $cancellable,
      $error
    );
  }
  multi method new_sync (
    GDBusConnection()       $connection,
    Int()                   $flags,
    GDBusInterfaceInfo      $info,
    Str()                   $name,
    Str()                   $object_path,
    Str()                   $interface_name,
    GCancellable()          $cancellable     =  GCancellable,
    CArray[Pointer[GError]] $error           =  gerror,
                            :$sync           is required
  ) {
    self.new_sync(
      $connection,
      $flags,
      $info,
      $name,
      $object_path,
      $interface_name,
      $cancellable,
      $error
    );
  }
  multi method new_sync (
    GDBusConnection()       $connection,
    Int()                   $flags,
    GDBusInterfaceInfo      $info,
    Str()                   $name,
    Str()                   $object_path,
    Str()                   $interface_name,
    GCancellable()          $cancellable     = GCancellable,
    CArray[Pointer[GError]] $error           = gerror
  ) {
    my GDBusProxyFlags $f = $flags;

    clear_error;
    my $proxy = g_dbus_proxy_new_sync(
      $connection,
      $f,
      $info,
      $name,
      $object_path,
      $interface_name,
      $cancellable,
      $error
    );
    set_error($error);

    $proxy ?? self.bless( :$proxy ) !! Nil;
  }

  proto method new (|)
      is also<new-async>
  { * }

  multi method new (
    GDBusConnection()   $connection,
    Str()               $object_path,
    Str()               $interface_name,
                        &callback        is copy      = Callable,
    gpointer            $user_data                    = gpointer,
                        :$async          is required,
    Int()               :$flags                       = 0,
    GDBusInterfaceInfo  :$info                        = GDBusInterfaceInfo,
    Str()               :$name                        = Str,
    GCancellable()      :$cancellable                 = GCancellable,
                        :$supply                      = False
  ) {
    self.new_async(
      $connection,
      $flags,
      $info,
      $name,
      $object_path,
      $interface_name,
      $cancellable,
      &callback,
      $user_data,
      :$supply
    );
  }
  multi method new_async (
    GDBusConnection()   $connection,
    Str()               $object_path,
    Str()               $interface_name,
                        &callback        is copy = Callable,
    gpointer            $user_data               = gpointer,
    Int()               :$flags                  = 0,
    GDBusInterfaceInfo  :$info                   = GDBusInterfaceInfo,
    Str()               :$name                   = Str,
    GCancellable()      :$cancellable            = GCancellable,
                        :$supply                 = False
  ) {
    samewith(
      $connection,
      $flags,
      $info,
      $name,
      $object_path,
      $interface_name,
      $cancellable,
      &callback,
      $user_data,
      :$supply
    );
  }
  multi method new (
    GDBusConnection()   $connection,
    Int()               $flags,
    GDBusInterfaceInfo  $info,
    Str()               $name,
    Str()               $object_path,
    Str()               $interface_name,
    GCancellable()      $cancellable                  = GCancellable,
                        &callback        is copy      = Callable,
    gpointer            $user_data                    = gpointer,
                        :$async          is required,
                        :$supply                      = False
  ) {
    self.new_async(
      $connection,
      $flags,
      $info,
      $name,
      $object_path,
      $interface_name,
      $cancellable,
      &callback,
      $user_data,
      :$supply
    );
  }
  multi method new_async (
    GDBusConnection()   $connection,
    Int()               $flags,
    GDBusInterfaceInfo  $info,
    Str()               $name,
    Str()               $object_path,
    Str()               $interface_name,
    GCancellable()      $cancellable             = GCancellable,
                        &callback        is copy = Callable,
    gpointer            $user_data               = gpointer,
                        :$supply                 = False,
  ) {
    my GDBusProxyFlags $f = $flags;

    prep-supply($supply, &callback, &?ROUTINE.^name);

    my $proxy = g_dbus_proxy_new(
      $connection,
      $f,
      $info,
      $name,
      $object_path,
      $interface_name,
      $cancellable,
      &callback,
      $user_data
    );

    $proxy ?? self.bless( :$proxy, :$supply ) !! Nil;
  }

  multi method new (
    GAsyncResult()          $res,
    CArray[Pointer[GError]] $error = gerror
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
    my $proxy = g_dbus_proxy_new_finish($res, $error);
    set_error($error);

    $proxy ?? self.bless( :$proxy ) !! Nil;
  }

  proto method new_for_bus (|)
      is also<new-for-bus>
  { * }

  multi method new (
    GDBusConnection()       $connection,
    Str()                   $name,
    Str()                   $object_path,
    Str()                   $interface_name,
    CArray[Pointer[GError]] $error           =  gerror,
                            :$bus            is required,
    Int()                   :$flags          =  0,
    GDBusInterfaceInfo      :$info           =  GDBusInterfaceInfo,
    GCancellable()          :$cancellable    =  GCancellable
  ) {
    self.new_for_bus(
      $connection,
      $flags,
      $info,
      $name,
      $object_path,
      $interface_name,
      $cancellable,
      $error
    );
  }
  multi method new_for_bus (
    GDBusConnection()       $connection,
    Str()                   $name,
    Str()                   $object_path,
    Str()                   $interface_name,
    CArray[Pointer[GError]] $error           = gerror,
    Int()                   :$flags          = 0,
    GDBusInterfaceInfo      :$info           = GDBusInterfaceInfo,
    GCancellable()          :$cancellable    = GCancellable,
  ) {
    samewith(
      $connection,
      $flags,
      $info,
      $name,
      $object_path,
      $interface_name,
      $cancellable,
      $error
    );
  }
  multi method new (
    GDBusConnection()       $connection,
    Int()                   $flags,
    GDBusInterfaceInfo      $info,
    Str()                   $name,
    Str()                   $object_path,
    Str()                   $interface_name,
    GCancellable()          $cancellable     =  GCancellable,
    CArray[Pointer[GError]] $error           =  gerror,
                            :$bus            is required,
  ) {
    self.new_for_bus(
      $connection,
      $flags,
      $info,
      $name,
      $object_path,
      $interface_name,
      $cancellable,
      $error
    );
  }
  multi method new_for_bus (
    GDBusConnection()       $connection,
    Int()                   $flags,
    GDBusInterfaceInfo      $info,
    Str()                   $name,
    Str()                   $object_path,
    Str()                   $interface_name,
    GCancellable()          $cancellable    = GCancellable,
    CArray[Pointer[GError]] $error          = gerror
  ) {
    my GDBusProxyFlags $f = $flags;

    clear_error;
    my $p = g_dbus_proxy_new_for_bus_sync(
      $connection,
      $f,
      $info,
      $name,
      $object_path,
      $interface_name,
      $cancellable,
      $error
    );
    set_error($error);

    $p ?? self.bless( proxy => $p ) !! Nil;
  }

  proto method new_for_bus_async (|)
    is also<new-for-bus-async>
  { * }

  multi method new_for_bus_async (
    GDBusConnection()  $connection,
    Int()              $flags,
    GDBusInterfaceInfo $info,
    Str()              $name,
    Str()              $object_path,
    Str()              $interface_name,
    GCancellable()     $cancellable             = GCancellable,
                       &callback        is copy = Callable,
    gpointer           $user_data               = gpointer,
                       :$supply                 = False
  ) {
    my GDBusProxyFlags $f = $flags;

    prep-supply($supply, &callback, &?ROUTINE.^name);

    my $proxy = g_dbus_proxy_new_for_bus(
      $connection,
      $f,
      $info,
      $name,
      $object_path,
      $interface_name,
      $cancellable,
      &callback,
      $user_data
    );

    $proxy ?? self.bless(:$proxy, :$supply) !! Nil;
  }

  multi method new (
    GAsyncResult()          $res,
    CArray[Pointer[GError]] $error                    =  gerror,
                            :bus_finish(:$bus-finish) is required
  ) {
    self.new_for_bus_finish($res, $error);
  }
  method new_for_bus_finish (
    GAsyncResult()          $res,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<new-for-bus-finish>
  {
    clear_error;
    my $proxy = g_dbus_proxy_new_for_bus_finish($res, $error);
    set_error($error);

    $proxy ?? self.bless( :$proxy ) !! Nil;
  }

  method default_timeout is rw is also<default-timeout> {
    Proxy.new(
      FETCH => sub ($) {
        g_dbus_proxy_get_default_timeout($!dp);
      },
      STORE => sub ($, $timeout_msec is copy) {
        g_dbus_proxy_set_default_timeout($!dp, $timeout_msec);
      }
    );
  }

  method interface_info is rw is also<interface-info> {
    Proxy.new(
      FETCH => sub ($) {
        g_dbus_proxy_get_interface_info($!dp);
      },
      STORE => sub ($, $info is copy) {
        g_dbus_proxy_set_interface_info($!dp, $info);
      }
    );
  }

  # Type: GDBusConnection
  method g-connection (:$raw = False) is rw  {
    my $gv = GLib::Value.new( GIO::DBus::Connection.get-type );
    Proxy.new(
      FETCH => sub ($) {
        $gv = GLib::Value.new(
          self.prop_get('g-connection', $gv)
        );

        my $o = $gv.object;
        return Nil unless $o;

        $o = cast(GDBusConnection, $o);
        return $o if $raw;

        GIO::DBus::Connection.new($o, :!ref);
      },
      STORE => -> $, $val is copy {
        warn 'g-connection is a construct-only attribute'
      }
    );
  }

  # Type: gint
  method g-default-timeout is rw  {
    my $gv = GLib::Value.new( G_TYPE_INT );
    Proxy.new(
      FETCH => sub ($) {
        $gv = GLib::Value.new(
          self.prop_get('g-default-timeout', $gv)
        );
        $gv.int;
      },
      STORE => -> $, Int() $val is copy {
        warn 'g-default-timeout is a construct-only attribute'
      }
    );
  }

  # Type: GDBusProxyFlags
  method g-flags is rw  {
    my $gv = GLib::Value.new( GLib::Value.typeFromEnum(GDBusProxyFlags) );
    Proxy.new(
      FETCH => sub ($) {
        $gv = GLib::Value.new(
          self.prop_get('g-flags', $gv)
        );
        $gv.valueFromEnum(GDBusProxyFlags);
      },
      STORE => -> $, $val is copy {
        warn 'g-flags is a construct-only attribute'
      }
    );
  }

  # Type: GDBusInterfaceInfo
  method g-interface-info is rw  {
    my $gv = GLib::Value.new( G_TYPE_POINTER );
    Proxy.new(
      FETCH => sub ($) {
        $gv = GLib::Value.new(
          self.prop_get('g-interface-info', $gv)
        );
        cast(GDBusInterfaceInfo, $gv.pointer);
      },
      STORE => -> $, GDBusInterfaceInfo $val is copy {
        $gv.pointer = $val;
        self.prop_set('g-interface-info', $gv);
      }
    );
  }

  # Type: Str
  method g-interface-name is rw  {
    my $gv = GLib::Value.new( G_TYPE_STRING );
    Proxy.new(
      FETCH => sub ($) {
        $gv = GLib::Value.new(
          self.prop_get('g-interface-name', $gv)
        );
        $gv.string;
      },
      STORE => -> $, $val is copy {
        warn 'g-interface-name is a construct-only attribute'
      }
    );
  }

  # Type: Str
  method g-name is rw  {
    my $gv = GLib::Value.new( G_TYPE_STRING );
    Proxy.new(
      FETCH => sub ($) {
        $gv = GLib::Value.new(
          self.prop_get('g-name', $gv)
        );
        $gv.string;
      },
      STORE => -> $, $val is copy {
        warn 'g-name is a construct-only attribute'
      }
    );
  }

  # Type: Str
  method g-name-owner is rw  {
    my $gv = GLib::Value.new( G_TYPE_STRING );
    Proxy.new(
      FETCH => sub ($) {
        $gv = GLib::Value.new(
          self.prop_get('g-name-owner', $gv)
        );
        $gv.string;
      },
      STORE => -> $, $val is copy {
        warn 'g-name-owner does not allow writing'
      }
    );
  }

  # Type: Str
  method g-object-path is rw  {
    my $gv = GLib::Value.new( G_TYPE_STRING );
    Proxy.new(
      FETCH => sub ($) {
        $gv = GLib::Value.new(
          self.prop_get('g-object-path', $gv)
        );
        $gv.string;
      },
      STORE => -> $, $val is copy {
        warn 'g-object-path is a construct-only attribute'
      }
    );
  }

  # Is originally:
  # GDBusProxy, GVariant, GStrv, gpointer --> void
  method g-properties-changed
    is also<
      g_properties_changed
      properties_changed
      properties-changed
    >
  {
    self.connect-g-properties-changed($!dp);
  }

  # Is originally:
  # GDBusProxy, Str, gchar, GVariant, gpointer --> void
  method g-signal
    is also<
      g_signal
      signal
    >
  {
    self.connect-g-signal($!dp);
  }

  proto method call_async (|)
      is also<call-async>
  { * }

  # cw: Callback handling needs to be done like it is with the
  #     *unix_fd_list_async multis!
  multi method call (
    Str()          $method_name,
                   :&callback      =  Callable,
    gpointer       :$user_data     =  gpointer,
                   :$async        is required,
    GVariant()     :$parameters   =  GVariant,
    Int()          :$flags        =  0,
    Int()          :$timeout_msec =  1,
    GCancellable() :$cancellable  =  GCancellable,
                   :$supply       is copy      = False
  ) {
    self.call_async(
      $method_name,
      $parameters,
      $flags,
      $timeout_msec,
      $cancellable,
      &callback,
      $user_data,
      :$supply
    );
  }
  multi method call_async (
    Str()          $method_name,
                   :&callback              = Callable,
    gpointer       :$user_data             = gpointer,
    GVariant()     :$parameters           = GVariant,
    Int()          :$flags                = 0,
    Int()          :$timeout_msec         = 1,
    GCancellable() :$cancellable          = GCancellable,
                   :$supply       is copy = False
  ) {
    samewith(
      $method_name,
      $parameters,
      $flags,
      $timeout_msec,
      $cancellable,
      &callback,
      $user_data,
      :$supply
    );
  }
  multi method call (
    Str()          $method_name,
    GVariant()     $parameters,
    Int()          $flags,
    Int()          $timeout_msec,
    GCancellable() :$cancellable               = GCancellable,
                   :&callback                  = Callable,
    gpointer       :$user_data                 = gpointer,
                   :$supply       is copy      = False,
                   :$async        is required
  ) {
    self.call_async(
      $method_name,
      $parameters,
      $flags,
      $timeout_msec,
      $cancellable,
      &callback,
      $user_data,
      :$supply
    );
  }
  multi method call_async (
    Str()           $method_name,
    GVariant()      $parameters,
    Int()           $flags,
    Int()           $timeout_msec,
    GCancellable()  $cancellable           = GCancellable,
                    &callback              = Callable,
    gpointer        $user_data             = gpointer,
                   :$supply       is copy  = False,
  ) {
    my GDBusCallFlags $f = $flags;
    my gint           $t = $timeout_msec;

    my ($nc, $ns) = prep-supply($supply, &callback, &?ROUTINE.^name);

    g_dbus_proxy_call(
      $!dp,
      $method_name,
      $parameters,
      $f,
      $t,
      $cancellable,
      $nc,
      $user_data
    );
    $ns.Supply if $supply;
  }

  multi method call (
    GAsyncResult()          $res,
    CArray[Pointer[GError]] $error   =  gerror,
                            :$finish is required
  ) {
    self.call_finish($res, $error)
  }
  method call_finish (
    GAsyncResult()          $res,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<call-finish>
  {
    g_dbus_proxy_call_finish($!dp, $res, $error);
  }

  proto method call_sync (|)
    is also<call-sync>
  { * }

  multi method call (
    Str()                    $method_name,
    CArray[Pointer[GError]]  $error         =  gerror,
                            :$sync         is required,
    GVariant()              :$parameters                =  GVariant,
    Int()                   :$flags                     =  0,
    Int()                   :$timeout_msec              =  -1,
    GCancellable()          :$cancellable               =  GCancellable,
  ) {
    self.call_sync(
      $method_name,
      $parameters,
      $flags,
      $timeout_msec,
      $cancellable,
      $error
    );
  }
  multi method call_sync (
    Str()                    $method_name,
    CArray[Pointer[GError]]  $error        = gerror,
    GVariant()              :$parameters   = GVariant,
    Int()                   :$flags        = 0,
    Int()                   :$timeout_msec = -1,
    GCancellable()          :$cancellable  = GCancellable,
                            :$raw          = False
  ) {
    samewith(
       $method_name,
       $parameters,
       $flags,
       $timeout_msec,
       $cancellable,
       $error,
      :$raw
    );
  }
  multi method call (
    Str()                   $method_name,
    GVariant()              $parameters   =  GVariant,
    Int()                   $flags        =  0,
    Int()                   $timeout_msec =  -1,
    GCancellable()          $cancellable  =  GCancellable,
    CArray[Pointer[GError]] $error        =  gerror,
                            :$sync        is required,
  ) {
    self.call_sync(
      $method_name,
      $parameters,
      $flags,
      $timeout_msec,
      $cancellable,
      $error
    );
  }
  multi method call_sync (
    Str()                    $method_name,
    GVariant()               $parameters   = GVariant,
    Int()                    $flags        = 0,
    Int()                    $timeout_msec = -1,
    GCancellable()           $cancellable  = GCancellable,
    CArray[Pointer[GError]]  $error        = gerror,
                            :$raw          = False
  ) {
    my GDBusCallFlags $f = $flags;
    my gint           $t = $timeout_msec;

    propReturnObject(
      g_dbus_proxy_call_sync(
        $!dp,
        $method_name,
        $parameters,
        $f,
        $t,
        $cancellable,
        $error
      ),
      $raw,
      |GLib::Variant.getTypePair
    );
  }

  proto method call_with_unix_fd_list_async (|)
      is also<call-with-unix-fd-list-async>
  { * }

  multi method call (
    Str()          $method_name,
                   :unix_fd_list_async(
                     :unix-fd-list-async(
                       :fd_list_async(
                         :$fd-list-async
                       )
                     )
                   ) is required,
    GVariant()     :$parameters    = GVariant,
                   :&callback      = Callable,
    Int()          :$flags         = 0,
    Int()          :$timeout_msec  = -1,
    GUnixFDList()  :$fd_list       = GUnixFDList,
    GCancellable() :$cancellable   = GCancellable,
    gpointer       :$user_data     = gpointer,
                   :$supply       = False
  ) {
    self.call_with_unix_fd_list_async(
      $method_name,
      $parameters,
      $flags,
      $timeout_msec,
      $fd_list,
      $cancellable,
      &callback,
      $user_data,
      :$supply
    );
  }
  multi method call_with_unix_fd_list_async (
    Str()          $method_name,
    GVariant()     :$parameters    = GVariant,
                   :&callback      = Callable,
    Int()          :$flags         = 0,
    Int()          :$timeout_msec  = -1,
    GUnixFDList()  :$fd_list       = GUnixFDList,
    GCancellable() :$cancellable   = GCancellable,
    gpointer       :$user_data     = gpointer,
                   :$supply        = False
  ) {
    samewith(
      $method_name,
      $parameters,
      $flags,
      $timeout_msec,
      $fd_list,
      $cancellable,
      &callback,
      $user_data,
      :$supply
    );
  }
  multi method call (
    Str()          $method_name,
    GVariant()     $parameters,
    Int()          $flags,
    Int()          $timeout_msec,
    GUnixFDList()  $fd_list,
    GCancellable() $cancellable,
                   &callback,
    gpointer       $user_data     = gpointer,
                   :$supply       = False,
                   :unix_fd_list_async(
                     :unix-fd-list-async(
                       :fd_list_async(
                         :$fd-list-async
                       )
                     )
                   ) is required,
  ) {
    self.call_with_unix_fd_list_async(
      $method_name,
      $parameters,
      $flags,
      $timeout_msec,
      $fd_list,
      $cancellable,
      &callback,
      $user_data,
      :$supply
    );
  }
  multi method call_with_unix_fd_list_async (
    Str()          $method_name,
    GVariant()     $parameters,
    Int()          $flags,
    Int()          $timeout_msec,
    GUnixFDList()  $fd_list,
    GCancellable() $cancellable,
                   &callback,
    gpointer       $user_data     = gpointer,
                   :$supply       = False
  ) {
    my GDBusCallFlags $f = $flags;
    my gint $t           = $timeout_msec;

    prep-supply($supply, &callback, &?ROUTINE.^name);

    g_dbus_proxy_call_with_unix_fd_list(
      $!dp,
      $method_name,
      $parameters,
      $flags,
      $timeout_msec,
      $fd_list,
      $cancellable,
      &callback,
      $user_data
    );

    $supply.Supply if $supply;
  }

  proto method call_with_unix_fd_list_finish (|)
      is also<call-with-unix-fd-list-finish>
  { * }

  multi method call (
    GAsyncResult()          $res,
    CArray[Pointer[GError]] $error       =  gerror,
                            :unix_fd_list_finish(
                              :unix-fd-list-finish(
                                :fd_list_finish(
                                  :$fd-list-finish
                                )
                              )
                            ) is required,
                            :$raw        =  False,
  ) {
    self.call_with_unix_fd_list_finish($, $res, $error, :$raw);
  }
  multi method call (
                            $out_fd_list is rw,
    GAsyncResult()          $res,
    CArray[Pointer[GError]] $error       =  gerror,
                            :$all        =  False,
                            :$raw        =  False,
                            :unix_fd_list_finish(
                              :unix-fd-list-finish(
                                :fd_list_finish(
                                  :$fd-list-finish
                                )
                              )
                            ) is required
  ) {
    self.call_with_unix_fd_list_finish(
      $out_fd_list,
      $res,
      $error,
      :$all,
      :$raw
    );
  }
  multi method call_with_unix_fd_list_finish (
    GAsyncResult()          $res,
    CArray[Pointer[GError]] $error       =  gerror,
                            :$all        =  False,
                            :$raw        =  False
  ) {
    samewith($, $res, $error, :$all, :$raw);
  }
  multi method call_with_unix_fd_list_finish (
                            $out_fd_list is rw,
    GAsyncResult()          $res,
    CArray[Pointer[GError]] $error       =  gerror,
                            :$all        =  False,
                            :$raw        =  False
  ) {
    my $oca = CArray[Pointer[GUnixFDList]].new;
    $oca[0] = Pointer[GUnixFDList];

    clear_error;
    my $rv = g_dbus_proxy_call_with_unix_fd_list_finish(
      $!dp,
      $oca,
      $res,
      $error
    );
    set_error($error);
    $out_fd_list = $oca[0] ??
      ( $raw ?? $oca[0] !! GIO::UnixFDList.new( $oca[0] ) )
      !!
      Nil;

    $rv = $rv ??
      ( $raw ?? $rv !! GLib::Variant.new($_, :!ref) )
      !!
      Nil;

    $all.not ?? $rv !! ($rv, $out_fd_list)
  }

  proto method call_with_unix_fd_list (|)
      is also<call-with-unix-fd-list>
  { * }

  multi method call (
    Str()                   $method_name,
    CArray[Pointer[GError]] $error         =  gerror,
                            :with_unix_fd_list(
                              :with-unix-fd-list(
                                :fd_list(
                                  :$fd-list
                                )
                              )
                            ) is required,
    GVariant()              :$parameters   =  GVariant,
    Int()                   :$flags        =  0,
    Int()                   :$timeout_msec =  -1,
    GUnixFDList()           :$fdlist       =  GUnixFDList,
    GCancellable()          :$cancellable  =  GCancellable,
                            :$raw          =  False
  ) {
    self.call_with_unix_fd_list(
      $method_name,
      $parameters,
      $flags,
      $timeout_msec,
      $fdlist,
      $,
      $cancellable,
      $error,
      :all,
      :$raw
    );
  }
  multi method call_with_unix_fd_list (
    Str()                   $method_name,
    CArray[Pointer[GError]] $error         =  gerror,
    GVariant()              :$parameters   =  GVariant,
    Int()                   :$flags        =  0,
    Int()                   :$timeout_msec =  -1,
    GUnixFDList()           :$fd_list      =  GUnixFDList,
    GCancellable()          :$cancellable  =  GCancellable,
                            :$raw          =  False
  ) {
    samewith(
      $method_name,
      $parameters,
      $flags,
      $timeout_msec,
      $fd_list,
      $,
      $cancellable,
      $error,
      :all,
      :$raw
    );
  }
  multi method call (
    Str()                   $method_name,
    GVariant()              $parameters,
    Int()                   $flags,
    Int()                   $timeout_msec,
    GUnixFDList()           $fd_list,
                            $out_fd_list  is rw,
    GCancellable()          $cancellable  =  GCancellable,
    CArray[Pointer[GError]] $error        =  gerror,
                            :$all         =  False,
                            :$raw         =  False,
                            :with_unix_fd_list(
                              :with-unix-fd-list(
                                :fd_list(
                                  :$fd-list
                                )
                              )
                            ) is required,
  ) {
    self.call_with_unix_fd_list(
      $method_name,
      $parameters,
      $flags,
      $timeout_msec,
      $fd_list,
      $out_fd_list,
      $cancellable,
      $error,
      :$all,
      :$raw
    );
  }
  multi method call_with_unix_fd_list (
    Str()                   $method_name,
    GVariant()              $parameters,
    Int()                   $flags,
    Int()                   $timeout_msec,
    GUnixFDList()           $fd_list,
                            $out_fd_list  is rw,
    GCancellable()          $cancellable  =  GCancellable,
    CArray[Pointer[GError]] $error        =  gerror,
                            :$all         =  False,
                            :$raw         =  False
  ) {
    my GDBusCallFlags $f   = $flags;
    my gint           $t   = $timeout_msec;
    my                $ofl = CArray[Pointer[GUnixFDList]].new;
    $ofl[0]                = Pointer[GUnixFDList];

    clear_error;
    my $v = g_dbus_proxy_call_with_unix_fd_list_sync(
      $!dp,
      $method_name,
      $parameters,
      $f,
      $t,
      $fd_list,
      $ofl // CArray[Pointer[GUnixFDList]],
      $cancellable,
      $error
    );
    set_error($error);
    $out_fd_list  = $ofl ?? CArrayToArray($ofl) !! Nil;
    $out_fd_list .= map({ GIO::UnixFDList.new($_) }) unless $raw;

    $v = $raw ?? $v !! GLib::Variant.new($v, :!ref) if $v;

    $all.not ?? $v !! ($v, $out_fd_list);
  }

  method get_cached_property (Str() $property_name, :$raw = False)
    is also<get-cached-property>
  {
    my $v = g_dbus_proxy_get_cached_property($!dp, $property_name);

    $v ??
      ( $raw ?? $v !! GLib::Variant.new($v, :!ref) )
      !!
      Nil;
  }

  method get_cached_property_names (:$raw = False)
    is also<
      get-cached-property-names
      cached_property_names
      cached-property-names
    >
  {
    my $sa = g_dbus_proxy_get_cached_property_names($!dp);

    $raw ?? $sa !! CStringArrayToArray($sa);
  }

  method get_connection (:$raw = False)
    is also<
      get-connection
      connection
    >
  {
    my $c = g_dbus_proxy_get_connection($!dp);

    $c ??
      ( $raw ?? $c !! GIO::DBus::Connection.new($c, :!ref) )
      !!
      Nil;
  }

  method get_flags
    is also<
      get-flags
      flags
    >
  {
    g_dbus_proxy_get_flags($!dp);
  }

  method get_interface_name
    is also<
      get-interface-name
      interface_name
      interface-name
    >
  {
    g_dbus_proxy_get_interface_name($!dp);
  }

  method get_name
    is also<
      get-name
      name
    >
  {
    g_dbus_proxy_get_name($!dp);
  }

  method get_name_owner
    is also<
      get-name-owner
      name_owner
      name-owner
    >
  {
    g_dbus_proxy_get_name_owner($!dp);
  }

  method get_object_path
    is also<
      get-object-path
      object_path
      object-path
    >
  {
    g_dbus_proxy_get_object_path($!dp);
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_dbus_proxy_get_type, $n, $t );
  }

  method set_cached_property (Str() $property_name, GVariant() $value)
    is also<set-cached-property>
  {
    g_dbus_proxy_set_cached_property($!dp, $property_name, $value);
  }

}
