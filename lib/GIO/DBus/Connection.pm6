use v6.c;

use NativeCall;
use Method::Also;

use GIO::Raw::Types;
use GIO::DBus::Raw::Types;

use GIO::DBus::Raw::Connection;

use GLib::Value;
use GLib::Variant;
use GIO::DBus::Message;
use GIO::DBus::Utils;

use GLib::Roles::Object;
use GIO::Roles::AsyncInitable;
use GIO::Roles::Initable;
use GIO::DBus::Roles::Signals::Connection;
use GIO::DBus::Roles::SupplyCallback;

our subset GDBusConnectionAncestry is export of Mu
  where GDBusConnection | GAsyncInitable | GInitable | GObject;

class GIO::DBus::Connection {
  also does GLib::Roles::Object;
  also does GIO::Roles::Initable;
  also does GIO::Roles::AsyncInitable;
  also does GIO::DBus::Roles::SupplyCallback;
  also does GIO::DBus::Roles::Signals::Connection;

  has GDBusConnection $!dc is implementor;

  submethod BUILD (
    :initable-object( :$connection ),
    :$init,
    :$cancellable,
    :$!supply
  ) {
    self.setGDBusConnection($connection, :$init, :$cancellable) if $connection;
  }

  method setGDBusConnection (
    GDBusConnectionAncestry $_,
                            :$init,
                            :$cancellable
  ) {
    my $to-parent;

    $!dc = do {
      when GDBusConnection {
        $to-parent = cast(GObject, $_);
        $_;
      }

      when GAsyncInitable {
        $to-parent = cast(GObject, $_);
        $!ai = $_;
        cast(GDBusConnection, $_);
      }

      when GInitable {
        $to-parent = cast(GObject, $_);
        $!i = $_;
        cast(GDBusConnection, $_);
      }

      default {
        $to-parent = $_;
        cast(GDBusConnection, $_);
      }
    }

    self!setObject($to-parent);
    self.roleInit-AsyncInitable;
    self.roleInit-Initable(:$init, :$cancellable);
  }

  method GIO::Raw::Definitions::GDBusConnection
    is also<GDBusConnection>
  { $!dc }

  multi method new (GDBusConnectionAncestry $connection, :$ref = True) {
    return Nil unless $connection;

    my $o =  self.bless( :$connection );
    $o.ref if $ref;
    $o;
  }

  proto method new_sync (|)
  { * }

  multi method new (
    GIOStream()             $io,
    Str()                   $guid,
    Int()                   $flags       =  0,
    GDBusAuthObserver()     $observer    =  GDBusAuthObserver,
    GCancellable()          $cancellable =  GCancellable,
    CArray[Pointer[GError]] $error       =  gerror,
                            :$sync       is required
  ) {
    self.new_sync(
      $io,
      $guid,
      $flags,
      $observer,
      $cancellable,
      $error
    );
  }
  multi method new_sync (
    GIOStream()             $io,
    Str()                   $guid,
    Int()                   $flags       = 0,
    GDBusAuthObserver()     $observer    = GDBusAuthObserver,
    GCancellable()          $cancellable = GCancellable,
    CArray[Pointer[GError]] $error       = gerror
  ) {
    my GDBusConnectionFlags $f = $flags;

    clear_error;
    my $connection = g_dbus_connection_new_sync(
      $io,
      $guid,
      $f,
      $observer,
      $cancellable,
      $error
    );
    set_error($error);

    $connection ?? self.bless( :$connection ) !! Nil;
  }

  proto method new_async (|)
      is also<new-async>
  { * }

  multi method new (
    GIOStream()         $io,
                        :$async       is required,
                        :&callback                 = Callable,
    gpointer            :$user_data                = gpointer,
    Str()               :$guid                     = Str,
    Int()               :$flags                    = 0,
    GDBusAuthObserver() :$observer                 = GDBusAuthObserver,
    GCancellable()      :$cancellable              = GCancellable,
                        :$supply      is copy      = False
  ) {
    self.new_async(
      $io,
      $guid,
      $flags,
      $observer,
      $cancellable,
      &callback,
      $user_data,
      :$supply
    );
  }
  multi method new_async (
    GIOStream()         $io,
                        :&callback             = Callable,
    gpointer            :$user_data            = gpointer,
    Str()               :$guid                 = Str,
    Int()               :$flags                = 0,
    GDBusAuthObserver() :$observer             = GDBusAuthObserver,
    GCancellable()      :$cancellable          = GCancellable,
                        :$supply      is copy  = False
  ) {
    samewith(
      $io,
      $guid,
      $flags,
      $observer,
      $cancellable,
      &callback,
      $user_data,
      :$supply
    );
  }
  multi method new (
    GIOStream()         $io,
                        &callback                 = Callable,
    gpointer            $user_data                = gpointer,
    Str()               $guid                     = Str,
    Int()               $flags                    = 0,
    GDBusAuthObserver() $observer                 = GDBusAuthObserver,
    GCancellable()      $cancellable              = GCancellable,
                        :$async      is required,
                        :$supply     is copy      = False
  ) {
    self.new_async(
      $io,
      $guid,
      $flags,
      $observer,
      $cancellable,
      &callback,
      $user_data,
      :$supply
    );
  }
  multi method new_async (
    GIOStream()         $io,
    Str()               $guid,
    Int()               $flags,
    GDBusAuthObserver() $observer,
    GCancellable()      $cancellable,
                        &callback     is copy,
    gpointer            $user_data             = gpointer,
                        :$supply      is copy  = True
  ) {
    my GDBusConnectionFlags $f = $flags;

    prep-supply($supply, &callback, &?ROUTINE.name);

    my $connection = g_dbus_connection_new(
      $io,
      $guid,
      $f,
      $observer,
      $cancellable,
      &callback,
      $user_data
    );

    $connection ?? self.bless( :$connection, :$supply ) !! Nil;
  }

  multi method new (
    CArray[Pointer[GError]] $error   =  gerror,
                            :$finish is required
  ) {
    GIO::DBus::Connection.new_finish($error);
  }
  method new_finish (
    GAsyncResult()          $res,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<new-finish>
  {
    clear_error;
    my $connection = g_dbus_connection_new_finish($res, $error);
    set_error($error);

    $connection ?? self.bless( :$connection ) !! Nil;
  }

  proto method new_for_address (|)
      is also<
        new-for-address
        new_for_address_async
        new-for-address-async
      >
  { * }

  # cw: Missing raku-ish set
  multi method new (
    Str()               $addr,
                        &callback     is copy = False,
    gpointer            $user_data            = gpointer,
                        :address_async(
                          :address-async(
                             :$address
                           )
                        )                    is required,
    Int()               :$flags               = 0,
    GDBusAuthObserver() :$observer            = GDBusAuthObserver,
    GCancellable()      :$cancellable         = GCancellable,
                        :$supply      is copy = False
  ) {
    self.new_for_address(
      $address,
      $flags,
      $observer,
      $cancellable,
      &callback,
      $user_data,
      :$supply
    );
  }
  multi method new_for_address (
    Str()               $address,
                        &callback     is copy = False,
    gpointer            $user_data            = gpointer,
    Int()               :$flags               = 0,
    GDBusAuthObserver() :$observer            = GDBusAuthObserver,
    GCancellable()      :$cancellable         = GCancellable,
                        :$supply      is copy = False
  ) {
    samewith(
      $address,
      $flags,
      $observer,
      $cancellable,
      &callback,
      $user_data,
      :$supply
    );
  }
  multi method new (
    Str()               $addr,
    Int()               $flags                            = 0,
                        &callback                         = Callable,
    GDBusAuthObserver() $observer                         = GDBusAuthObserver,
    GCancellable()      $cancellable                      = GCancellable,
    gpointer            $user_data                        = gpointer,
                        :$supply             is copy      = False,
                        :address_async(
                          :address-async(
                             :$address
                           )
                        )                    is required,
  ) {
    self.new_for_address(
      $address,
      $flags,
      $observer,
      $cancellable,
      &callback,
      $user_data,
      :$supply
    );
  }
  multi method new_for_address (
    Str()               $address,
    Int()               $flags                = 0,
    GDBusAuthObserver() $observer             = GDBusAuthObserver,
    GCancellable()      $cancellable          = GCancellable,
                        &callback     is copy = False,
    gpointer            $user_data            = gpointer,
                        :$supply      is copy = False
  ) {
    my GDBusConnectionFlags $f = $flags;

    prep-supply($supply, &callback, &?ROUTINE.name);

    my $connection = g_dbus_connection_new_for_address(
      $address,
      $f,
      $observer,
      $cancellable,
      &callback,
      $user_data
    );

    $connection ?? self.bless( :$connection, :$supply ) !! Nil;
  }

  multi method new (
    GAsyncResult()          $res,
    CArray[Pointer[GError]] $error             = gerror,
                            :address_finish(
                              :$address-finish
                            ) is required
  ) {
    self.new_finish($res, $error);
  }
  method new_for_address_finish (
    GAsyncResult()          $res,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<new-for-address-finish>
  {
    clear_error;
    my $connection = g_dbus_connection_new_for_address_finish($res, $error);
    set_error($error);

    $connection ?? self.bless( :$connection ) !! Nil;
  }

  proto method new_for_address_sync (|)
    is also<new-for-address-sync>
  { * }

  multi method new (
    Str()                   $address,
    CArray[Pointer[GError]] $error             =  gerror,
                            :address_sync(
                              :$address-sync
                            )                  is required,
    Int()                   :$flags            =  0,
    GDBusAuthObserver()     :$observer         =  GDBusAuthObserver,
    GCancellable()          :$cancellable      =  GCancellable,
  ) {
    self.new_with_addresss_sync(
      $address,
      $flags,
      $observer,
      $cancellable,
      $error
    );
  }
  multi method new_for_address_sync (
    Str()                   $address,
    CArray[Pointer[GError]] $error        = gerror,
    Int()                   :$flags       = 0,
    GDBusAuthObserver()     :$observer    = GDBusAuthObserver,
    GCancellable()          :$cancellable = GCancellable,
  ) {
    samewith(
      $address,
      $flags,
      $observer,
      $cancellable,
      $error
    );
  }
  multi method new (
    Str()                   $addr,
    Int()                   $flags             =  0,
    GDBusAuthObserver()     $observer          =  GDBusAuthObserver,
    GCancellable()          $cancellable       =  GCancellable,
    CArray[Pointer[GError]] $error             =  gerror,
                            :address_sync(
                              :$address-sync
                            )                  is required
  ) {
    self.new_for_address_sync(
      $addr,
      $flags,
      $observer,
      $cancellable,
      $error
    );
  }
  multi method new_for_address_sync (
    Str()                   $address,
    Int()                   $flags       = 0,
    GDBusAuthObserver()     $observer    = GDBusAuthObserver,
    GCancellable()          $cancellable = GCancellable,
    CArray[Pointer[GError]] $error       = gerror
  ) {
    my GDBusConnectionFlags $f = $flags;

    clear_error;
    my $connection = g_dbus_connection_new_for_address_sync(
      $address,
      $flags,
      $observer,
      $cancellable,
      $error
    );
    set_error($error);

    $connection ?? self.bless( :$connection ) !! Nil;
  }

  # Type: gboolean
  method exit-on-close is rw  is also<exit_on_close> {
    my GLib::Value $gv .= new( G_TYPE_BOOLEAN );
    Proxy.new(
      FETCH => -> $ {
        $gv = GLib::Value.new(
          self.prop_get('exit-on-close', $gv)
        );
        $gv.boolean;
      },
      STORE => -> $, Int() $val is copy {
        $gv.boolean = $val;
        self.prop_set('exit-on-close', $gv);
      }
    );
  }

  # Is originally:
  # GDBusConnection, gboolean, GError, gpointer --> void
  method closed {
    self.connect-closed($!dc);
  }

  method add_filter (
             &filter_function,
    gpointer $user_data           = gpointer,
             &user_data_free_func = Callable
  )
    is also<add-filter>
  {
    g_dbus_connection_add_filter(
      $!dc,
      &filter_function,
      $user_data,
      &user_data_free_func
    );
  }

  proto method call_async
    is also<call-async>
  { * }

  multi method call (
    Str()          $object_path,
    Str()          $interface_name,
    Str()          $method_name,
                   &callback                      = Callable,
    gpointer       $user_data                     = gpointer,
                   :$async           is required,
    Str()          :$bus_name                     = Str,
    GVariant()     :$parameters                   = GVariant,
    GCancellable() :$cancellable                  = GCancellable,
    Int()          :$flags                        = 0,
    GVariant()     :$reply_type                   = GVariant,
    Int()          :$timeout_msec                 = -1,
                   :$supply          is copy      = False
  ) {
    self.call_async(
      $bus_name,
      $object_path,
      $interface_name,
      $method_name,
      $parameters,
      $reply_type,
      $flags,
      $timeout_msec,
      $cancellable,
      &callback,
      $user_data,
      :$supply
    );
  }
  multi method call_async(
    Str()          $object_path,
    Str()          $interface_name,
    Str()          $method_name,
                   &callback                 = Callable,
    gpointer       $user_data                = gpointer,
    Str()          :$bus_name                = Str,
    GVariant()     :$parameters              = GVariant,
    GCancellable() :$cancellable             = GCancellable,
    Int()          :$flags                   = 0,
    GVariant()     :$reply_type              = GVariant,
    Int()          :$timeout_msec            = -1,
                   :$supply          is copy = False
  ) {
    self.call_async(
      $bus_name,
      $object_path,
      $interface_name,
      $method_name,
      $parameters,
      $reply_type,
      $flags,
      $timeout_msec,
      $cancellable,
      &callback,
      $user_data,
      :$supply
    );
  }
  multi method call (
    Str()          $bus_name,
    Str()          $object_path,
    Str()          $interface_name,
    Str()          $method_name,
    GVariant()     $parameters,
    Int()          $reply_type,
    Int()          $flags                       = 0,
    Int()          $timeout_msec                = -1,
    GCancellable() $cancellable                 = GCancellable,
                   &callback                    = Callable,
    gpointer       $user_data                   = gpointer,
                   :$supply         is copy     = False,
                   :$async          is required
  ) {
    self.call_async(
      $bus_name,
      $object_path,
      $interface_name,
      $method_name,
      $parameters,
      $reply_type,
      $flags,
      $timeout_msec,
      $cancellable,
      &callback,
      $user_data,
      :$supply
    );
  }
  multi method call_async (
    Str()          $bus_name,
    Str()          $object_path,
    Str()          $interface_name,
    Str()          $method_name,
    GVariant()     $parameters,
    Int()          $reply_type,
    Int()          $flags                   = 0,
    Int()          $timeout_msec            = -1,
    GCancellable() $cancellable             = GCancellable,
                   &callback        is copy = Callable,
    gpointer       $user_data               = gpointer,
                   :$supply         is copy = False,
  ) {
    my GVariantType   $r = $reply_type;
    my GDBusCallFlags $f = $flags;
    my gint           $t = $timeout_msec;

    &callback = prep-supply($supply, &callback, &?ROUTINE.name) if $supply;

    g_dbus_connection_call(
      $!dc,
      $bus_name,
      $object_path,
      $interface_name,
      $method_name,
      $parameters,
      $r,
      $f,
      $t,
      $cancellable,
      &callback,
      $user_data
    );
    $supply.Supply if $supply;
  }

  multi method call(
    GAsyncResult()          $res,
    CArray[Pointer[GError]] $error   =  gerror,
                            :$finish is required,
                            :$raw    =  False
  ) {
    self.call_finish($res, $error);
  }
  method call_finish (
    GAsyncResult()          $res,
    CArray[Pointer[GError]] $error = gerror,
                            :$raw  = False
  ) {
    clear_error;
    my $v = g_dbus_connection_call_finish($!dc, $res, $error);
    set_error($error);

    $v ??
      ( $raw ?? $v !! GLib::Variant.new($v, :!ref) )
      !!
      Nil
  }

  proto method call_sync
    is also<call-sync>
  { * }

  multi method call (
    Str()                   $object_path,
    Str()                   $interface_name,
    Str()                   $method_name,
    GCancellable()          $cancellable      =  GCancellable,
    CArray[Pointer[GError]] $error            =  gerror,
                            :$sync            is required,
    Str()                   :$bus_name        =  Str,
    GVariant()              :$parameters      =  GVariant,
    Int()                   :$flags           =  0,
    Int()                   :$timeout_msec    =  -1,
    Int()                   :$reply_type      =  GVariant,
                            :$raw             =  False,
  ) {
    self.call_sync(
      $bus_name,
      $object_path,
      $interface_name,
      $method_name,
      $parameters,
      $reply_type,
      $flags,
      $timeout_msec,
      $cancellable,
      $error
    )
  }
  multi method call_sync (
    Str()                   $object_path,
    Str()                   $interface_name,
    Str()                   $method_name,
    GCancellable()          $cancellable      = GCancellable,
    CArray[Pointer[GError]] $error            = gerror,
    Str()                   :$bus_name        = Str,
    GVariant()              :$parameters      = GVariant,
    Int()                   :$flags           = 0,
    Int()                   :$timeout_msec    = -1,
    Int()                   :$reply_type      = GVariant,
    :$raw = False
  ) {
    samewith(
      $bus_name,
      $object_path,
      $interface_name,
      $method_name,
      $parameters,
      $reply_type,
      $flags,
      $timeout_msec,
      $cancellable,
      $error
    );
  }
  multi method call (
    Str()                   $bus_name,
    Str()                   $object_path,
    Str()                   $interface_name,
    Str()                   $method_name,
    GVariant()              $parameters,
    Int()                   $reply_type,
    Int()                   $flags,
    Int()                   $timeout_msec,
    GCancellable()          $cancellable     =  GCancellable,
    CArray[Pointer[GError]] $error           =  gerror,
                            :$raw            =  False,
                            :$sync           is required
  ) {
    self.call_sync(
      $bus_name,
      $object_path,
      $interface_name,
      $method_name,
      $parameters,
      $reply_type,
      $flags,
      $timeout_msec,
      $cancellable,
      $error,
      :$raw
    );
  }
  multi method call_sync (
    Str()                   $bus_name,
    Str()                   $object_path,
    Str()                   $interface_name,
    Str()                   $method_name,
    GVariant()              $parameters,
    Int()                   $reply_type,
    Int()                   $flags,
    Int()                   $timeout_msec,
    GCancellable()          $cancellable     = GCancellable,
    CArray[Pointer[GError]] $error           = gerror,
    :$raw = False
  ) {
    my GVariantType   $r = $reply_type;
    my GDBusCallFlags $f = $flags;
    my gint           $t = $timeout_msec;

    clear_error;
    my $v = g_dbus_connection_call_sync(
      $!dc,
      $bus_name,
      $object_path,
      $interface_name,
      $method_name,
      $parameters,
      $r,
      $f,
      $t,
      $cancellable,
      $error
    );
    set_error($error);

    $v ??
      ( $raw ?? $v !! GLib::Variant.new($v, :!ref) )
      !!
      Nil;
  }

  proto method call_with_unix_fd_list (|)
    is also<
      call-with-unix-fd-list
      call_with_unx_fd_list_async
      call-with-unx-fd-list-async
    >
  { * }

  multi method call_with_unix_fd_list (
    Str()          $object_path,
    Str()          $interface_name,
    Str()          $method_name,
                   &callback                 = Callable,
    gpointer       $user_data                = gpointer,
    Str()          :$bus_name                = Str,
    GVariant()     :$parameters              = GVariant,
    GVariant()     :$reply_type              = GVariant,
    Int()          :$flags                   = 0,
    Int()          :$timeout_msec            = -1,
    GUnixFDList()  :$fd_list                 = GUnixFDList,
    GCancellable() :$cancellable             = GCancellable,
                   :$supply          is copy = False
  ) {
    self.call_with_unix_fd_list(
      $bus_name,
      $object_path,
      $interface_name,
      $method_name,
      $parameters,
      $reply_type,
      $flags,
      $timeout_msec,
      $fd_list,
      $cancellable,
      &callback,
      $user_data,
      :$supply
    );
  }
  multi method call_with_unix_fd_list (
    Str()          $object_path,
    Str()          $interface_name,
    Str()          $method_name,
                   &callback                      = Callable,
    gpointer       $user_data                     = gpointer,
                   :unix_fd_async(
                     :unix-fd-async(
                       :unix_fd_list_async(
                         :$unix-fd-list-async
                       )
                     )
                   )                 is required,
    Str()          :$bus_name                     = Str,
    GVariant()     :$parameters                   = GVariant,
    GVariant()     :$reply_type                   = GVariant,
    Int()          :$flags                        = 0,
    Int()          :$timeout_msec                 = -1,
    GUnixFDList()  :$fd_list                      = GUnixFDList,
    GCancellable() :$cancellable                  = GCancellable,
                   :$supply          is copy      = False
  ) {
    self.call_with_unix_fd_list(
      $bus_name,
      $object_path,
      $interface_name,
      $method_name,
      $parameters,
      $reply_type,
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
    Str()            $bus_name,
    Str()            $object_path,
    Str()            $interface_name,
    Str()            $method_name,
    GVariant()       $parameters                              = GVariant,
    GVariant()       $reply_type                              = GVariant,
    Int()            $flags                                   = 0,
    Int()            $timeout_msec                            = -1,
    GUnixFDList()    $fd_list                                 = GUnixFDList,
    GCancellable()   $cancellable                             = GCancellable,
                     &callback                                = Callable,
    gpointer         $user_data                               = gpointer,
                     :$supply                    is copy      = False,
                     :unix_fd_async(
                       :unix-fd-async(
                         :unix_fd_list_async(
                           :$unix-fd-list-async
                         )
                       )
                     )                           is required
  ) {
    self.call_with_unix_fd_list(
      $bus_name,
      $object_path,
      $interface_name,
      $method_name,
      $parameters,
      $reply_type,
      $flags,
      $timeout_msec,
      $fd_list,
      $cancellable,
      &callback,
      $user_data,
      :$supply
    );
  }
  multi method call_with_unix_fd_list (
    Str()          $bus_name,
    Str()          $object_path,
    Str()          $interface_name,
    Str()          $method_name,
    GVariant()     $parameters               = GVariant,
    GVariant()     $reply_type               = GVariant,
    Int()          $flags                    = 0,
    Int()          $timeout_msec             = -1,
    GUnixFDList()  $fd_list                  = GUnixFDList,
    GCancellable() $cancellable              = GCancellable,
                   &callback                 = Callable,
    gpointer       $user_data                = gpointer,
                   :$supply          is copy = False
  ) {
    my GVariantType   $r = $reply_type;
    my GDBusCallFlags $f = $flags;
    my gint           $t = $timeout_msec;

    prep-supply($supply, &callback, &?ROUTINE.name);

    g_dbus_connection_call_with_unix_fd_list(
      $!dc,
      $bus_name,
      $object_path,
      $interface_name,
      $method_name,
      $parameters,
      $r,
      $f,
      $t,
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

  # cw: Add call() aliases
  multi method call (
    GAsyncResult()          $res,
    CArray[Pointer[GError]] $error                   =  gerror,
                            :$raw                    =  False,
                            :unix_fd_list_finish(
                              :unix-fd-list-finish(
                                :fd_list_finish(
                                  :$fd-list-finish
                                )
                              )
                            )                        is required
  ) {
    self.call_with_unix_fd_list_finish($, $res, $error, :all, :$raw);
  }
  multi method call_with_unix_fd_list_finish (
    GAsyncResult()          $res,
    CArray[Pointer[GError]] $error       =  gerror,
                            :$raw        =  False
  ) {
    samewith($, $res, $error, :all, :$raw);
  }
  multi method call (
                            $out_fd_list             is rw,
    GAsyncResult()          $res,
    CArray[Pointer[GError]] $error                   =  gerror,
                            :unix_fd_list_finish(
                              :unix-fd-list-finish(
                                :fd_list_finish(
                                  :$fd-list-finish
                                )
                              )
                            )                        is required,
                            :$all                    =  False,
                            :$raw                    =  False
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
                            $out_fd_list is rw,
    GAsyncResult()          $res,
    CArray[Pointer[GError]] $error       =  gerror,
                            :$all        =  False,
                            :$raw        =  False
  ) {
    my $ofl    = CArray[Pointer[GUnixFDList]].new;
       $ofl[0] = Pointer[GUnixFDList];

    clear_error;
    my $v = g_dbus_connection_call_with_unix_fd_list_finish(
      $!dc,
      $ofl,
      $res,
      $error
    );
    set_error($error);
    $out_fd_list = ppr( $ofl[0] );

    $v = $v ??
      ( $raw ?? $v !! GLib::Variant.new($v, :!ref) )
      !!
      Nil;

    $all.not ?? $v !! ($v, $out_fd_list);
  }

  proto method call_with_unix_fd_list_sync (|)
      is also<call-with-unix-fd-list-sync>
  { * }

  multi method call_with_unix_fd_list_sync (
    Str()                   $bus_name,
    Str()                   $object_path,
    Str()                   $interface_name,
    Str()                   $method_name,
    GVariant()              $parameters,
    Int()                   $reply_type,
    Int()                   $flags,
    Int()                   $timeout_msec,
    GUnixFDList()           $fd_list,
                            $out_fd_list     is rw,
    GCancellable()          $cancellable     =  GCancellable,
    CArray[Pointer[GError]] $error           =  gerror,
                            :$all            =  False,
                            :$raw            =  False
  ) {
    my $ofl = CArray[Pointer[GUnixFDList]].new;
    $ofl[0] = Pointer[GUnixFDList];

    clear_error;
    my $v = g_dbus_connection_call_with_unix_fd_list_sync(
      $!dc,
      $bus_name,
      $object_path,
      $interface_name,
      $method_name,
      $parameters,
      $reply_type,
      $flags,
      $timeout_msec,
      $fd_list,
      $ofl,
      $cancellable,
      $error
    );
    set_error($error);

    $out_fd_list = ppr( $ofl[0] );

    $v = $v ??
      ( $raw ?? $v !! GLib::Variant.new($v, :!ref) )
      !!
      Nil;

    $all.not ?? $v !! ($v, $out_fd_list);
  }

  proto method close_async (|)
      is also<close-async>
  { * }

  multi method close (
                   &callback     =  Callable,
    gpointer       $user_data    =  gpointer,
                   :$async       is required,
    GCancellable() :$cancellable =  GCancellable,
                   :$supply      =  False
  ) {
    self.close_async(
      $cancellable,
      &callback,
      $user_data,
      :$supply
    );
  }
  multi method close_async (
                   &callback     = Callable,
    gpointer       $user_data    = gpointer,
    GCancellable() :$cancellable = GCancellable,
                   :$supply      = False
  ) {
    samewith(
      $cancellable,
      &callback,
      $user_data,
      :$supply
    );
  }
  multi method close (
    GCancellable() $cancellable             = GCancellable,
                   &callback                = Callable,
    gpointer       $user_data               = gpointer,
                   :$supply                 = False,
                   :$async      is required
  ) {
    self.close_async(
      $cancellable,
      &callback,
      $user_data,
      :$supply
    );
  }
  multi method close_async (
    GCancellable() $cancellable = GCancellable,
                   &callback    = Callable,
    gpointer       $user_data   = gpointer,
                   :$supply     = False
  ) {
    prep-supply($supply, &callback, &?ROUTINE.name);

    g_dbus_connection_close($!dc, $cancellable, &callback, $user_data);

    $supply.Supply if $supply;
  }

  multi method close (
    GAsyncResult() $res,
    CArray[Pointer[GError]] $error = gerror,
    :$finish is required
  ) {
    self.close_finish($res, $error);
  }
  method close_finish (
    GAsyncResult() $res,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<close-finish>
  {
    clear_error;
    my $rv = so g_dbus_connection_close_finish($!dc, $res, $error);
    set_error($error);
    $rv;
  }

  multi method close (
    GCancellable()          $cancellable = GCancellable,
    CArray[Pointer[GError]] $error       = gerror
  ) {
    g_dbus_connection_close_sync($!dc, $cancellable, $error);
  }

  method emit_signal (
    Str()                   $destination_bus_name,
    Str()                   $object_path,
    Str()                   $interface_name,
    Str()                   $signal_name,
    GVariant()              $parameters,
    CArray[Pointer[GError]] $error                 = gerror
  )
    is also<emit-signal>
  {
    so g_dbus_connection_emit_signal(
      $!dc,
      $destination_bus_name,
      $object_path,
      $interface_name,
      $signal_name,
      $parameters,
      $error
    );
  }

  proto method flush_async (|)
      is also<flush-async>
  { * }

  multi method flush (
                    &callback     =  Callable,
     gpointer       $user_data    =  gpointer,
                    :$supply      =  False,
                    :$async       is required,
    GCancellable()  :$cancellable =  GCancellable
  ) {
    self.flush_async($cancellable, &callback, $user_data, :$supply);
  }
  multi method flush_async (
                    &callback     =  Callable,
     gpointer       $user_data    =  gpointer,
                    :$supply      =  False,
    GCancellable()  :$cancellable =  GCancellable
  ) {
    samewith($cancellable, &callback, $user_data, :$supply);
  }
  multi method flush (
    GCancellable() $cancellable  =  GCancellable,
                   &callback     =  Callable,
    gpointer       $user_data    =  gpointer,
                   :$supply      =  False,
                   :$async       is required
  ) {
    self.flush_async($cancellable, &callback, $user_data, :$supply);
  }
  multi method flush_async (
    GCancellable() $cancellable = GCancellable,
                   &callback    = Callable,
    gpointer       $user_data   = gpointer,
                   :$supply     = False
  ) {
    prep-supply($supply, &callback);

    g_dbus_connection_flush($!dc, $cancellable, &callback, $user_data);

    $supply.Supply if $supply;
  }

  multi method flush (
    GAsyncResult()          $res,
    CArray[Pointer[GError]] $error   =  gerror,
                            :$finish is required
  ) {
    self.flush_finish($res, $error);
  }
  method flush_finish (
    GAsyncResult()          $res,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<flush-finish>
  {
    g_dbus_connection_flush_finish($!dc, $res, $error);
  }

  multi method flush (
    GCancellable()          $cancellable,
    CArray[Pointer[GError]] $error        = gerror
  ) {
    so g_dbus_connection_flush_sync($!dc, $cancellable, $error);
  }

  # Class methods. Returns a GDBusConnection
  multi method get (
    GIO::DBus::Connection:U:
    Int()                    $bus_type,
    GCancellable()           $cancellable =  GCancellable,
    CArray[Pointer[GError]]  $error       =  gerror,
                             :$sync       is required
  ) {
    self.get_sync($bus_type, $cancellable, $error);
  }
  method get_sync (
    GIO::DBus::Connection:U:
    Int()                    $bus_type,
    GCancellable()           $cancellable  = GCancellable,
    CArray[Pointer[GError]]  $error        = gerror
  )
    is also<get-sync>
  {
    my GBusType $b           = $bus_type;
    my           $connection = g_bus_get_sync($b, $cancellable, $error);

    $connection ?? self.bless( :$connection ) !! Nil;
  }

  # Helper methods
  method get_sync_system (GIO::DBus::Connection:U: )
    is also<
      get-sync-system
      system
    >
  {
    GIO::DBus::Connection.get_sync(G_BUS_TYPE_SYSTEM);
  }

  method get_sync_session (GIO::DBus::Connection:U: )
    is also<
      get-sync-session
      session
    >
  {
    GIO::DBus::Connection.get_sync(G_BUS_TYPE_SESSION);
  }

  method get_sync_starter (GIO::DBus::Connection:U: )
    is also<
      get-sync-starter
      starter
    >
  {
    GIO::DBus::Connection.get_sync(G_BUS_TYPE_STARTER);
  }

  method get_sync_none (GIO::DBus::Connection:U: )
    is also<
      get-sync-none
      none
    >
  {
    GIO::DBus::Connection.get_sync(G_BUS_TYPE_NONE);
  }

  proto method get_async (|)
    is also<get-async>
  { * }

  multi method get_async (
    GIO::DBus::Connection:U:
    Int()                    $bus_type,
                             &callback     = Callable,
    gpointer                 $user_data    = gpointer,
    GCancellable()           :$cancellable = GCancellable,
                             :$supply      = False,
  ) {
    samewith($bus_type, $cancellable, &callback, $user_data, :$supply);
  }
  multi method get_async (
    GIO::DBus::Connection:U:
    Int()                    $bus_type,
    GCancellable()           $cancellable,
                             &callback,
    gpointer                 $user_data = gpointer,
                             :$supply   = False
  ) {
    my GBusType $b = $bus_type;

    prep-supply($supply, &callback);

    g_bus_get($b, $cancellable, &callback, $user_data);

    $supply.Supply if $supply;
  }

  multi method get (
    GIO::DBus::Connection:U:
    GAsyncResult()           $res,
    CArray[Pointer[GError]]  $error   =  gerror,
                             :$finish is required
  ) {
    self.get_finish($res, $error);
  }
  method get_finish (
    GIO::DBus::Connection:U:
    GAsyncResult()           $res,
    CArray[Pointer[GError]]  $error = gerror
  )
    is also<get-finish>
  {
    my $c = g_bus_get_finish($res, $error);

    $c ?? self.bless( connection => $c ) !! Nil;
  }

  method get_capabilities
    is also<
      get-capabilities
      capabilities
    >
  {
    GDBusCapabilityFlagsEnum( g_dbus_connection_get_capabilities($!dc) );
  }

  method get_flags
    is also<
      get-flags
      flags
    >
  {
    GDBusConnectionFlagsEnum( g_dbus_connection_get_flags($!dc) );
  }

  method get_guid
    is also<
      get-guid
      guid
    >
  {
    g_dbus_connection_get_guid($!dc);
  }

  method get_last_serial
    is also<
      get-last-serial
      last_serial
      last-serial
    >
  {
    g_dbus_connection_get_last_serial($!dc);
  }

  method get_peer_credentials (:$raw = False)
    is also<
      get-peer-credentials
      peer_credentials
      peer-credentials
    >
  {
    my $c = g_dbus_connection_get_peer_credentials($!dc);

    $c ??
      ( $raw ?? $c !! GIO::Credentials.new($c, :!ref) )
      !!
      Nil
  }

  method get_stream ($raw = False)
    is also<
      get-stream
      stream
    >
  {
    my $s = g_dbus_connection_get_stream($!dc);

    $s ??
      ( $raw ?? $s !! GIO::Stream.new($s, :!ref) )
      !!
      Nil
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_dbus_connection_get_type, $n, $t );
  }

  method get_unique_name
    is also<
      get-unique-name
      unique_name
      unique-name
    >
  {
    g_dbus_connection_get_unique_name($!dc);
  }

  # Cannot offer the no-arg short-name since it is used by the signal handler
  # for signal:closed
  method is_closed
    is also<is-closed>
  {
    so g_dbus_connection_is_closed($!dc);
  }

  method register_object (
    Str()                   $object_path,
    GDBusInterfaceInfo      $interface_info,
    GDBusInterfaceVTable    $vtable              = GDBusInterfaceVTable,
    gpointer                $user_data           = gpointer,
                            &user_data_free_func = Callable,
    CArray[Pointer[GError]] $error               = gerror
  )
    is also<register-object>
  {
    clear_error;
    my $c = g_dbus_connection_register_object(
      $!dc,
      $object_path,
      $interface_info,
      $vtable,
      $user_data,
      &user_data_free_func,
      $error
    );
    set_error($error);
    $c;
  }

  method register_object_with_closures (
    Str()                   $object_path,
    GDBusInterfaceInfo      $interface_info,
    GClosure()              $method_call_closure  = GClosure,
    GClosure()              $get_property_closure = GClosure,
    GClosure()              $set_property_closure = GClosure,
    CArray[Pointer[GError]] $error                = gerror
  )
    is also<register-object-with-closures>
  {
    clear_error;
    my $c = g_dbus_connection_register_object_with_closures(
      $!dc,
      $object_path,
      $interface_info,
      $method_call_closure,
      $get_property_closure,
      $set_property_closure,
      $error
    );
    set_error($error);
    $c;
  }

  method register_subtree (
    Str()                   $object_path,
    GDBusSubtreeVTable      $vtable,
    Int()                   $flags               = 0,
    gpointer                $user_data           = gpointer,
                            &user_data_free_func = Callable,
    CArray[Pointer[GError]] $error               = gerror
  )
    is also<register-subtree>
  {
    my GDBusSubtreeFlags $f = $flags;

    clear_error;
    my $c = g_dbus_connection_register_subtree(
      $!dc,
      $object_path,
      $vtable,
      $f,
      $user_data,
      &user_data_free_func,
      $error
    );
    set_error($error);
    $c;
  }

  method remove_filter (Int() $filter_id) is also<remove-filter> {
    my guint $f = $filter_id;

    g_dbus_connection_remove_filter($!dc, $f);
  }

  proto method send_message_with_reply (|)
      is also<send-message-with-reply>
  { * }

  multi method send_message_with_reply (
    GDBusMessage()        $message,
                          &callback                 = Callable,
    gpointer              $user_data                = gpointer,
    Int()                 :$flags                   = 0,
    Int()                 :$timeout_msec            = -1,
    GCancellable()        :$cancellable             = GCancellable,
                          :$supply                  = False
  ) {
    samewith(
      $message,
      $,
      $flags,
      $timeout_msec,
      $cancellable,
      &callback,
      $user_data,
      :$supply
    )
  }
  multi method send_message_with_reply (
    GDBusMessage()        $message,
                          $out_serial        is rw,
                          &callback                 = Callable,
    gpointer              $user_data                = gpointer,
    Int()                 :$flags                   = 0,
    Int()                 :$timeout_msec            = -1,
    GCancellable()        :$cancellable             = GCancellable,
                          :$supply                  = False
  ) {
    samewith(
      $message,
      $flags,
      $timeout_msec,
      $out_serial,
      $cancellable,
      &callback,
      $user_data,
      :$supply
    )
  }
  multi method send_message_with_reply (
    GDBusMessage()        $message,
    Int()                 $flags,
    Int()                 $timeout_msec,
                          $out_serial    is rw,
    GCancellable()        $cancellable   =  GCancellable,
                          &callback      =  Callable,
    gpointer              $user_data     =  gpointer,
                          :$supply       =  False
  ) {
    my GDBusSendMessageFlags $f = $flags;
    my gint                  $t = $timeout_msec;
    my guint                 $o = 0;

    prep-supply($supply, &callback);

    g_dbus_connection_send_message_with_reply (
      $!dc,
      $message,
      $f,
      $t,
      $o,
      $cancellable,
      &callback,
      $user_data
    );
    $out_serial = $o;

    $supply.Supply if $supply;
  }

  method send_message_with_reply_finish (
    GAsyncResult()          $res,
    CArray[Pointer[GError]] $error = gerror,
                            :$raw  = False
  )
    is also<send-message-with-reply-finish>
  {
    clear_error;
    my $m = g_dbus_connection_send_message_with_reply_finish(
      $!dc,
      $res,
      $error
    );
    set_error($error);

    $m ??
      ( $raw ?? $m !! GIO::DBus::Message.new($m, :!ref) )
      !!
      Nil;
  }

  proto method signal_subscribe (|)
      is also<signal-subscribe>
  { * }

  multi method signal_subscribe (
                    &callback            = Callable,
    gpointer        $user_data           = gpointer,
    Str()          :$sender              = Str,
    Str()          :$interface_name      = Str,
    Str()          :$member              = Str,
    Str()          :$object_path         = Str,
    Str()          :$arg0                = Str,
    Int()          :$flags               = 0,
                   :&user_data_free_func = Callable,
                   :$supply              = False
  ) {
    samewith(
      $sender,
      $interface_name,
      $member,
      $object_path,
      $arg0,
      $flags,
      &callback,
      $user_data,
      &user_data_free_func,
      :$supply
    );
  }
  multi method signal_subscribe (
    Str()          $sender,
    Str()          $interface_name      = Str,
    Str()          $member              = Str,
    Str()          $object_path         = Str,
    Str()          $arg0                = Str,
    Int()          $flags               = Str,
                   &callback            = Callable,
    gpointer       $user_data           = gpointer,
                   &user_data_free_func = Callable,
                   :$supply             = False
  ) {
    my GDBusSignalFlags $f = $flags;

    prep-supply($supply, &callback);

    g_dbus_connection_signal_subscribe(
      $!dc,
      $sender,
      $interface_name,
      $member,
      $object_path,
      $arg0,
      $f,
      &callback,
      $user_data,
      &user_data_free_func
    );

    $supply.Supply if $supply;
  }

  method signal_unsubscribe (Int() $subscription_id)
    is also<signal-unsubscribe>
  {
    my guint $s = $subscription_id;

    g_dbus_connection_signal_unsubscribe($!dc, $s);
  }

  method start_message_processing
    is also<start-message-processing>
  {
    g_dbus_connection_start_message_processing($!dc);
  }

  method unregister_object (Int() $registration_id)
    is also<unregister-object>
  {
    my guint $r = $registration_id;

    g_dbus_connection_unregister_object($!dc, $r);
  }

  method unregister_subtree (Int() $registration_id)
    is also<unregister-subtree>
  {
    my guint $r = $registration_id;

    g_dbus_connection_unregister_subtree($!dc, $r);
  }

  method export_menu_model (
    Str()                   $object_path,
    GMenuModel()            $menu,
    CArray[Pointer[GError]] $error        = gerror
  ) {
    clear_error;
    my $r = g_dbus_connection_export_menu_model(
      $!dc,
      $object_path,
      $menu,
      $error
    );
    set_error($error);
    $r;
  }

  method unexport_menu_model (Int() $export_id) {
    my guint $e = $export_id;

    g_dbus_connection_unexport_menu_model($!dc, $e);
  }

  method export_action_group (
    Str()                   $object_path,
    GActionGroup()          $action_group,
    CArray[Pointer[GError]] $error         = gerror
  ) {
    clear_error;
    my $r = g_dbus_connection_export_action_group(
      $!dc,
      $object_path,
      $action_group,
      $error
    );
    set_error($error);
    $r;
  }

  method unexport_action_group (Int() $export_id) {
    my guint $e = $export_id;

    g_dbus_connection_unexport_action_group($!dc, $e);
  }

  method own_name (
    Str()    $name,
    Int()    $flags                  = 0,
             &name_acquired_handler  = Callable,
             &name_lost_handler      = Callable,
    gpointer $user_data              = gpointer,
             &user_data_free_func    = %DEFAULT-CALLBACKS<GDestroyNotify>
  ) {
    GIO::DBus::Utils.own_name_on_connection(
      self,
      $name,
      $flags,
      &name_acquired_handler,
      &name_lost_handler,
      $user_data,
      &user_data_free_func
    );
  }

}
