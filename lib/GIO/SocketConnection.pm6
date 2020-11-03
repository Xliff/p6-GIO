use v6.c;

use Method::Also;

use NativeCall;

use GIO::Raw::Types;
use GIO::Raw::SocketConnection;

use GIO::Stream;
use GIO::Socket;
use GIO::SocketAddress;

our subset GSocketConnectionAncestry is export of Mu
  where GSocketConnection | GIOStream;

class GIO::SocketConnection is GIO::Stream {
  has GSocketConnection $!sc is implementor;

  submethod BUILD (:$socket) {
    self.setGSocketConnection($socket) if $socket;
  }

  method setSocketConnection (GSocketConnectionAncestry $_) {
    my $to-parent;

    $!sc = do {
      when GSocketConnection {
        $to-parent = cast(GIOStream, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GSocketConnection, $_);
      }
    }
    self.setStream($to-parent);
  }

  method GIO::Raw::Definitions::GSocketConnection
    is also<GSocketConnection>
  { $!sc }

  proto method new (|)
  { * }

  multi method new (GSocketConnectionAncestry $connection, :$ref = True) {
    return Nil unless $connection;

    my $o = self.bless( :$connection );
    $o.ref if $ref;
    $o;
  }

  method connect (
    GSocketAddress()        $address,
    GCancellable()          $cancellable = GCancellable,
    CArray[Pointer[GError]] $error       = gerror
  ) {
    clear_error;
    my $rv = so g_socket_connection_connect(
      $!sc,
      $address,
      $cancellable,
      $error
    );
    set_error($error);
    $rv;
  }

  proto method connect_async (|)
    is also<connect-async>
  { * }

  multi method connect_async (
    GSocketAddress() $address,
                     &callback,
    gpointer         $user_data    = gpointer
  ) {
    samewith($address, GCancellable, &callback, $user_data);
  }
  multi method connect_async (
    GSocketAddress() $address,
    GCancellable()   $cancellable,
                     &callback,
    gpointer         $user_data    = gpointer
  ) {
    g_socket_connection_connect_async(
      $!sc,
      $address,
      $cancellable,
      &callback,
      $user_data
    );
  }

  method connect_finish (
    GAsyncResult()          $result,
    CArray[Pointer[GError]] $error   = gerror
  )
    is also<connect-finish>
  {
    clear_error;
    my $rv = so g_socket_connection_connect_finish($!sc, $result, $error);
    set_error($error);
    $rv;
  }

  method factory_create_connection (
    GIO::SocketConnection:U:
    GSocket()                $socket,
                             :$raw    = False
  )
    is also<factory-create-connection>
  {
    my $sc = g_socket_connection_factory_create_connection($socket);

    $sc ??
      ( $raw ?? $sc  !! GIO::SocketConnection.new($sc, :!ref) )
      !!
      Nil;
  }

  method factory_lookup_type (
    GIO::SocketConnection:U:
    Int()                    $family,
    Int()                    $type,
    Int()                    $protocol_id
  )
    is also<factory-lookup-type>
  {
    my GSocketFamily $f = $family;
    my GSocketType   $t = $type;
    my GSocketType   $p = $protocol_id;

    g_socket_connection_factory_lookup_type($f, $t, $p);
  }

  method factory_register_type (
    GIO::SocketConnection:U:
    Int()                    $g_type,
    Int()                    $family,
    Int()                    $type,
    Int()                    $protocol
  )
    is also<factory-register-type>
  {
    my GType         $g = $g_type;
    my GSocketFamily $f = $family;
    my GSocketType   $t = $type;
    my gint          $p = $protocol;

    g_socket_connection_factory_register_type($g, $f, $t, $p);
  }

  method get_local_address (
    CArray[Pointer[GError]] $error = gerror,
                            :$raw  = False
  )
    is also<get-local-address>
  {
    clear_error;
    my $l = g_socket_connection_get_local_address($!sc, $error);
    set_error($error);

    $l ??
      ( $l ?? $l !! GIO::SocketAddress.new($l, :!ref) )
      !!
      Nil;
  }

  method get_remote_address (
    CArray[Pointer[GError]] $error = gerror,
                            :$raw  = False
  )
    is also<get-remote-address>
  {
    clear_error;
    my $r = g_socket_connection_get_remote_address($!sc, $error);
    set_error($error);

    $r ??
      ( $raw ?? $r !! GIO::SocketAddress.new($r, :!ref) )
      !!
      Nil;
  }

  method get_socket (:$raw = False) is also<get-socket> {
    my $s = g_socket_connection_get_socket($!sc);

    $s ??
      ( $raw ?? $s !! GIO::Socket.new($s, :!ref) )
      !!
      Nil;
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_socket_connection_get_type, $n, $t );
  }

  method is_connected is also<is-connected> {
    so g_socket_connection_is_connected($!sc);
  }

}
