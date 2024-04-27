use v6.c;

use NativeCall;
use Method::Also;

use GIO::Raw::Types;
use GIO::DBus::Raw::Types;

use GIO::DBus::Raw::Server;

use GLib::Value;
use GIO::DBus::AuthObserver;

use GLib::Roles::Object;
use GIO::DBus::Roles::Signals::Server;

our subset GDBusServerAncestry is export of Mu
  where GDBusServer | GObject;

class GIO::DBus::Server {
  also does GLib::Roles::Object;
  also does GIO::DBus::Roles::Signals::Server;

  has GDBusServer $!ds is implementor;

  submethod BUILD (:$server) {
    self.setGDBusServer($server) if $server;
  }

  method setGDBusObjectSkeleton (GDBusServerAncestry $_) {
    my $to-parent;

    $!ds = do {
      when GDBusServer {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GDBusServer, $_);
      }
    }
    self!setObject($to-parent);
  }

  method GIO::Raw::Definitions::GDBusServer
    is also<GDBusServer>
  { $!ds }

  multi method new (GDBusServerAncestry $server, :$ref = True) {
    return Nil unless $server;

    my $o = self.bless( :$server );
    $o.ref if $ref;
    $o;
  }

  proto method new_sync (|)
    is also<new-sync>
  { * }

  multi method new (
    Str()                   $address,
    Str()                   $guid,
                            :$sync        is required,
    Int()                   :$flags       =  0,
    GDBusAuthObserver()     :$observer    =  GDBusAuthObserver,
    GCancellable()          :$cancellable =  GCancellable,
    CArray[Pointer[GError]] :$error       =  gerror
  ) {
    self.new_sync(
      $address,
      $flags,
      $guid,
      $observer,
      $cancellable,
      $error
    );
  }
  multi method new (
    Str()                   $address,
    Int()                   $flags,
    Str()                   $guid,
    GDBusAuthObserver()     $observer    =  GDBusAuthObserver,
    GCancellable()          $cancellable =  GCancellable,
    CArray[Pointer[GError]] $error       =  gerror,
                            :$sync       is required
  ) {
    self.new_sync(
      $address,
      $flags,
      $guid,
      $observer,
      $cancellable,
      $error
    );
  }
  multi method new_sync (
    Str()                   $address,
    Str()                   $guid,
    Int()                   :$flags       = 0,
    GDBusAuthObserver()     :$observer    = GDBusAuthObserver,
    GCancellable()          :$cancellable = GCancellable,
    CArray[Pointer[GError]] :$error       = gerror
  ) {
    samewith(
      $address,
      $flags,
      $guid,
      $observer,
      $cancellable,
      $error
    );
  }
  multi method new_sync (
    Str()                   $address,
    Int()                   $flags,
    Str()                   $guid,
    GDBusAuthObserver()     $observer    = GDBusAuthObserver,
    GCancellable()          $cancellable = GCancellable,
    CArray[Pointer[GError]] $error       = gerror
  )

  {
    my GDBusServerFlags $f = $flags;

    clear_error;
    my $s = g_dbus_server_new_sync(
      $address,
      $f,
      $guid,
      $observer,
      $cancellable,
      $error
    );
    set_error($error);

    $s ?? self.bless( server => $s ) !! Nil;
  }

  # Type: Str
  method address is rw  {
    my GLib::Value $gv .= new( G_TYPE_STRING );
    Proxy.new(
      FETCH => -> $ {
        $gv = GLib::Value.new(
          self.prop_get('address', $gv)
        );
        $gv.string;
      },
      STORE => -> $, Str() $val is copy {
        warn 'GIO::DBus::Server.address is read/only.';
      }
    );
  }

  # Type: GDBusAuthObserver
  method authentication-observer (:$raw = False) is rw is also<authentication_observer> {
    my GLib::Value $gv .= new( G_TYPE_OBJECT );
    Proxy.new(
      FETCH => -> $ {
        $gv = GLib::Value.new(
          self.prop_get('authentication-observer', $gv)
        );
        return Nil unless $gv.object;

        my $ao = cast(GDBusAuthObserver, $gv.object);
        return $ao if $raw;

        GIO::DBus::AuthObserver.new($ao, :!ref);
      },
      STORE => -> $, GDBusAuthObserver() $val is copy {
        warn 'GIO::DBus::Server.authentication-observer is read/only.';
      }
    );
  }

  # Is originally:
  # GDBusServer, GDBusConnection, gpointer --> gboolean
  method new-connection is also<new_connection> {
    self.connect-new-connection($!ds);
  }

  method get_client_address
    is also<
      get-client-address
      client_address
      client-address
    >
  {
    g_dbus_server_get_client_address($!ds);
  }

  method get_flags
    is also<
      get-flags
      flags
    >
  {
    g_dbus_server_get_flags($!ds);
  }

  method get_guid
    is also<
      get-guid
      guid
    >
  {
    g_dbus_server_get_guid($!ds);
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_dbus_server_get_type, $n, $t );
  }

  method is_active
    is also<
      is-active
      active
    >
  {
    so g_dbus_server_is_active($!ds);
  }

  method start {
    g_dbus_server_start($!ds);
  }

  method stop {
    g_dbus_server_stop($!ds);
  }

}
