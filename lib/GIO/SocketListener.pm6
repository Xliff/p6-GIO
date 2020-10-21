use v6.c;

use Method::Also;

use NativeCall;

use GIO::Raw::Types;
use GIO::Raw::SocketListener;

use GLib::Value;
use GIO::Socket;
use GIO::SocketConnection;

use GLib::Roles::Object;

our subset GSocketListenerAncestry is export of Mu
  where GSocketListener | GObject;

class GIO::SocketListener {
  also does GLib::Roles::Object;

  has GSocketListener $!sl is implementor;

  submethod BUILD (:$listener) {
    self.setSocketListener($listener) if $listener;
  }

  method setSocketListener(GSocketListener $_) {
    my $to-parent;

    $!sl = do {
      when GSocketListener {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GSocketListener, $_);
      }
    }
    self!setObject($to-parent);
  }

  method GIO::Raw::Definitions::GSocketListener
    is also<GSocketListener>
  { $!sl }

  multi method new (GSocketListenerAncestry $listener, :$ref = True) {
    return Nil unless $listener;

    my $o = self.bless( :$listener );
    $o.ref if $ref;
    $o;
  }
  multi method new {
    my $listener = g_socket_listener_new();

    $listener ?? self.bless( :$listener ) !! Nil;
  }

  # Type: gint
  method listen-backlog is rw  is also<listen_backlog> {
    my GLib::Value $gv .= new( G_TYPE_INT );
    Proxy.new(
      FETCH => -> $ {
        $gv = GLib::Value.new(
          self.prop_get('listen-backlog', $gv)
        );
        $gv.int;
      },
      STORE => -> $, Int() $val is copy {
        $gv.int = $val;
        self.prop_set('listen-backlog', $gv);
      }
    );
  }

  method accept (
    GObject()               $source_object,
    GCancellable()          $cancellable    = GCancellable,
    CArray[Pointer[GError]] $error          = gerror,
                            :$raw           = False
  ) {
    clear_error;
    my $sc =
      g_socket_listener_accept($!sl, $source_object, $cancellable, $error);
    set_error($error);

    $sc ??
      ( $raw ?? $sc !! GIO::SocketConnection.new($sc, :!ref) )
      !!
      Nil;
  }

  proto method accept_async (|)
    is also<accept-async>
  { * }

  multi method accept_async (
                   &callback,
    gpointer       $user_data    = gpointer
  ) {
    samewith(GCancellable, &callback, $user_data);
  }
  multi method accept_async (
    GCancellable() $cancellable,
                   &callback,
    gpointer       $user_data    = gpointer
  ) {
    g_socket_listener_accept_async($!sl, $cancellable, &callback, $user_data);
  }

  method accept_finish (
    GAsyncResult()          $result,
    GObject()               $source_object,
    CArray[Pointer[GError]] $error          = gerror,
                            :$raw           = False
  )
    is also<accept-finish>
  {
    clear_error;
    my $sc = g_socket_listener_accept_finish(
      $!sl,
      $result,
      $source_object,
      $error
    );
    set_error($error);

    $sc ??
      ( $raw ?? $sc !! GIO::SocketConnection.new($sc, :!ref) )
      !!
      Nil;
  }

  method accept_socket (
    GObject()               $source_object,
    GCancellable            $cancellable    = GCancellable,
    CArray[Pointer[GError]] $error          = gerror,
                            :$raw           = False
  )
    is also<accept-socket>
  {
    clear_error;
    my $s = g_socket_listener_accept_socket(
      $!sl,
      $source_object,
      $cancellable,
      $error
    );
    set_error($error);

    $s ??
      ( $raw ?? $s !! GIO::Socket.new($s, :!ref) )
      !!
      Nil;
  }

  proto method accept_socket_async (|)
    is also<accept-socket-async>
  { * }

  multi method accept_socket_async (
                   &callback,
    gpointer       $user_data    = gpointer
  ) {
    samewith(GCancellable, &callback, $user_data);
  }
  multi method accept_socket_async (
    GCancellable() $cancellable,
                   &callback,
    gpointer       $user_data    = gpointer
  ) {
    g_socket_listener_accept_socket_async(
      $!sl,
      $cancellable,
      &callback,
      $user_data
    );
  }

  method accept_socket_finish (
    GAsyncResult()          $result,
    GObject()               $source_object,
    CArray[Pointer[GError]] $error          = gerror,
                            :$raw           = False
  )
    is also<accept-socket-finish>
  {
    clear_error;
    my $s = g_socket_listener_accept_socket_finish(
      $!sl,
      $result,
      $source_object,
      $error
    );
    set_error($error);

    $s ??
      ( $raw ?? $s !! GIO::Socket.new($s, :!ref) )
      !!
      Nil;
  }

  method add_address (
    GSocketAddress()        $address,
    Int()                   $type,
    Int()                   $protocol,
    GObject()               $source_object,
    GSocketAddress()        $effective_address,
    CArray[Pointer[GError]] $error              = gerror
  )
    is also<add-address>
  {
    my GSocketType     $t = $type;
    my GSocketProtocol $p = $protocol;

    clear_error;
    my $rv = so g_socket_listener_add_address(
      $!sl,
      $address,
      $t,
      $p,
      $source_object,
      $effective_address,
      $error
    );
    set_error($error);
    $rv;
  }

  method add_any_inet_port (
    GObject()               $source_object,
    CArray[Pointer[GError]] $error          = gerror
  )
    is also<add-any-inet-port>
  {
    clear_error;
    my $rv = so g_socket_listener_add_any_inet_port(
      $!sl,
      $source_object,
      $error
    );
    set_error($error);
    $rv;
  }

  method add_inet_port (
    Int()                   $port,
    GObject()               $source_object,
    CArray[Pointer[GError]] $error          = gerror
  )
    is also<add-inet-port>
  {
    my guint16 $p = $port;

    clear_error;
    my $rv = so g_socket_listener_add_inet_port(
      $!sl,
      $p,
      $source_object,
      $error
    );
    set_error($error);
    $rv;
  }

  method add_socket (
    GSocket()               $socket,
    GObject()               $source_object,
    CArray[Pointer[GError]] $error          = gerror
  )
    is also<add-socket>
  {
    clear_error;
    my $rv = so g_socket_listener_add_socket(
      $!sl,
      $socket,
      $source_object,
      $error
    );
    set_error($error);
    $rv;
  }

  method close {
    g_socket_listener_close($!sl);
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_socket_listener_get_type, $n, $t );
  }

  method set_backlog (Int() $listen_backlog) is also<set-backlog> {
    my gint $lb = $listen_backlog;

    g_socket_listener_set_backlog($!sl, $lb);
  }

}
