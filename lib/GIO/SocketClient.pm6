use v6.c;

use Method::Also;
use NativeCall;

use GIO::Raw::Types;
use GIO::Raw::SocketClient;

use GLib::Roles::Object;

use GIO::SocketAddress;
use GIO::SocketConnection;

use GIO::Roles::ProxyResolver;

our subset GSocketClientAncestry is export of Mu
  where GSocketClient | GObject;

class GIO::SocketClient {
  also does GLib::Roles::Object;

  has GSocketClient $!sc is implementor;

  submethod BUILD (:$client) {
    self.setGSocketClient($client) if $client;
  }

  method setGSocketClient (GSocketClientAncestry $_) {
    my $to-parent;

    $!sc = do {
      when GSocketClient {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GSocketClient, $_);
      }
    }
    self!setObject($to-parent);
  }

  method GIO::Raw::Definitions::GSocketClient
    is also<GSocketClient>
  { $!sc }

  multi method new (GSocketClient $client, :$ref = True) {
    return Nil unless $client;

    my $o = self.bless( :$client );
    $o.ref if $ref;
    $o;
  }
  multi method new {
    my $client = g_socket_client_new();

    $client ?? self.bless( :$client ) !! Nil;
  }

  method enable_proxy is rw is also<enable-proxy> {
    Proxy.new(
      FETCH => sub ($) {
        so g_socket_client_get_enable_proxy($!sc);
      },
      STORE => sub ($, Int() $enable is copy) {
        my gboolean $e = $enable.so.Int;

        g_socket_client_set_enable_proxy($!sc, $e);
      }
    );
  }

  method family is rw {
    Proxy.new(
      FETCH => sub ($) {
        GSocketFamilyEnum( g_socket_client_get_family($!sc) );
      },
      STORE => sub ($, Int() $family is copy) {
        my GSocketFamily $f = $family;

        g_socket_client_set_family($!sc, $f);
      }
    );
  }

  method local_address (:$raw = False) is rw is also<local-address> {
    Proxy.new(
      FETCH => sub ($) {
        my $s = g_socket_client_get_local_address($!sc);

        $s ??
          ( $raw ?? $s !! GIO::SocketAddress.new($s, :!ref) )
          !!
          Nil;
      },
      STORE => sub ($, GSocketAddress() $address is copy) {
        g_socket_client_set_local_address($!sc, $address);
      }
    );
  }

  method protocol is rw {
    Proxy.new(
      FETCH => sub ($) {
        GSocketProtocolEnum( g_socket_client_get_protocol($!sc) );
      },
      STORE => sub ($, Int() $protocol is copy) {
        my GSocketProtocol $p = $protocol;

        g_socket_client_set_protocol($!sc, $p);
      }
    );
  }

  method proxy_resolver (:$raw = False) is rw is also<proxy-resolver> {
    Proxy.new(
      FETCH => sub ($) {
        my $pr = g_socket_client_get_proxy_resolver($!sc);

        $pr ??
          ( $raw ?? $pr !! GIO::ProxyResolver.new($pr, :!ref) )
          !!
          Nil;
      },
      STORE => sub ($, GProxyResolver() $proxy_resolver is copy) {
        g_socket_client_set_proxy_resolver($!sc, $proxy_resolver);
      }
    );
  }

  method socket_type is rw is also<socket-type> {
    Proxy.new(
      FETCH => sub ($) {
        GSocketTypeEnum( g_socket_client_get_socket_type($!sc) );
      },
      STORE => sub ($, Int() $type is copy) {
        my GSocketType $t = $type;

        g_socket_client_set_socket_type($!sc, $t);
      }
    );
  }

  method timeout is rw {
    Proxy.new(
      FETCH => sub ($) {
        g_socket_client_get_timeout($!sc);
      },
      STORE => sub ($, Int() $timeout is copy) {
        my gint $t = $timeout;

        g_socket_client_set_timeout($!sc, $t);
      }
    );
  }

  method tls is rw {
    Proxy.new(
      FETCH => sub ($) {
        so g_socket_client_get_tls($!sc);
      },
      STORE => sub ($, Int() $tls is copy) {
        my gboolean $t = $tls.so.Int;

        g_socket_client_set_tls($!sc, $t);
      }
    );
  }

  method tls_validation_flags is rw is also<tls-validation-flags> {
    Proxy.new(
      FETCH => sub ($) {
        GTlsCertificateFlagsEnum(
          g_socket_client_get_tls_validation_flags($!sc)
        );
      },
      STORE => sub ($, Int() $flags is copy) {
        my GTlsCertificateFlags $f = $flags;

        g_socket_client_set_tls_validation_flags($!sc, $f);
      }
    );
  }

  method add_application_proxy (Str() $protocol)
    is also<add-application-proxy>
  {
    g_socket_client_add_application_proxy($!sc, $protocol);
  }

  multi method connect (
    GSocketConnectable()    $connectable,
    GCancellable()          $cancellable  = GCancellable,
    CArray[Pointer[GError]] $error        = gerror,
                            :$raw         = False,

                            :socket_client(
                              :socket-client(
                                :$socketclient
                              )
                            ) is required
  ) {
    samewith($connectable, $cancellable, $error, :$raw);
  }
  method connect_socketclient (
    GSocketConnectable()    $connectable,
    GCancellable()          $cancellable  = GCancellable,
    CArray[Pointer[GError]] $error        = gerror,
                            :$raw         = False
  ) {
    clear_error;
    my $rv = g_socket_client_connect($!sc, $connectable, $cancellable, $error);
    set_error($error);

    $rv ??
      ( $raw ?? $rv !! GIO::SocketConnection.new($rv, :!ref) )
      !!
      Nil;
  }

  proto method connect_async (|)
    is also<connect-async>
  { * }

  multi method connect_async (
    GSocketConnectable() $connectable,
                         &callback,
    gpointer             $user_data   = gpointer
  ) {
    samewith($connectable, GCancellable, &callback, $user_data);
  }
  multi method connect_async (
    GSocketConnectable() $connectable,
    GCancellable()       $cancellable,
                         &callback,
    gpointer             $user_data    = gpointer
  )
  {
    g_socket_client_connect_async(
      $!sc,
      $connectable,
      $cancellable,
      &callback,
      $user_data
    );
  }

  method connect_finish (
    GAsyncResult()          $result,
    CArray[Pointer[GError]] $error   = gerror,
                            :$raw    = False
  )
    is also<connect-finish>
  {
    clear_error;
    my $rv = g_socket_client_connect_finish($!sc, $result, $error);
    set_error($error);

    $rv ??
      ( $raw ?? $rv !! GIO::SocketConnection.new($rv, :!ref) )
      !!
      Nil;
  }

  method connect_to_host (
    Str()                   $host_and_port,
    Int()                   $default_port,
    GCancellable()          $cancellable    = GCancellable,
    CArray[Pointer[GError]] $error          = gerror,
                            :$raw           = False;
  )
    is also<connect-to-host>
  {
    my guint16 $dp = $default_port;

    clear_error;
    my $rv = g_socket_client_connect_to_host(
      $!sc,
      $host_and_port,
      $dp,
      $cancellable,
      $error
    );
    set_error($error);

    $rv ??
      ( $raw ?? $rv !! GIO::SocketConnection.new($rv, :!ref) )
      !!
      Nil;
  }

  proto method connect_to_host_async (|)
    is also<connect-to-host-async>
  { * }

  multi method connect_to_host_async (
    Str()               $host_and_port,
    Int()               $default_port,
                        &callback,
    gpointer            $user_data      = gpointer
  ) {
    samewith(
      $host_and_port,
      $default_port,
      GCancellable,
      &callback,
      $user_data
    );
  }
  multi method connect_to_host_async (
    Str()               $host_and_port,
    Int()               $default_port,
    GCancellable()      $cancellable,
                        &callback,
    gpointer            $user_data      = gpointer
  )
  {
    my guint16 $dp = $default_port;

    g_socket_client_connect_to_host_async(
      $!sc,
      $host_and_port,
      $dp,
      $cancellable,
      &callback,
      $user_data
    );
  }

  method connect_to_host_finish (
    GAsyncResult()          $result,
    CArray[Pointer[GError]] $error   = gerror,
                            :$raw    = False
  )
    is also<connect-to-host-finish>
  {
    clear_error;
    my $rv = g_socket_client_connect_to_host_finish($!sc, $result, $error);
    set_error($error);

    $rv ??
      ( $raw ?? $rv !! GIO::SocketConnection.new($rv, :!ref) )
      !!
      Nil;
  }

  proto method connect_to_service (|)
    is also<connect-to-service>
  { * }

  multi method connect_to_service (
    Str()                   $domain,
    Str()                   $service,
    CArray[Pointer[GError]] $error    = gerror,
                            :$raw     = False
  ) {
    samewith($domain, $service, GCancellable, $error, :$raw);
  }
  multi method connect_to_service (
    Str()                   $domain,
    Str()                   $service,
    GCancellable()          $cancellable,
    CArray[Pointer[GError]] $error        = gerror,
                            :$raw         = False
  ) {
    clear_error;
    my $rv = g_socket_client_connect_to_service(
      $!sc,
      $domain,
      $service,
      $cancellable,
      $error
    );
    set_error($error);

    $rv ??
      ( $raw ?? $rv !! GIO::SocketConnection.new($rv, :!ref) )
      !!
      Nil;
  }

  method connect_to_service_async (
    Str()          $domain,
    Str()          $service,
    GCancellable() $cancellable,
                   &callback,
    gpointer       $user_data    = gpointer
  )
    is also<connect-to-service-async>
  {
    g_socket_client_connect_to_service_async(
      $!sc,
      $domain,
      $service,
      $cancellable,
      &callback,
      $user_data
    );
  }

  method connect_to_service_finish (
    GAsyncResult()          $result,
    CArray[Pointer[GError]] $error   = gerror,
                            :$raw    = False
  )
    is also<connect-to-service-finish>
  {
    clear_error;
    my $rv = g_socket_client_connect_to_service_finish($!sc, $result, $error);
    set_error($error);

    $rv ??
      ( $raw ?? $rv !! GIO::SocketConnection.new($rv, :!ref) )
      !!
      Nil;
  }

  method connect_to_uri (
    Str()                   $uri,
    Int()                   $default_port,
    GCancellable()          $cancellable   = GCancellable,
    CArray[Pointer[GError]] $error         = gerror,
                            :$raw          = False
  )
    is also<connect-to-uri>
  {
    my guint16 $dp = $default_port;

    clear_error;
    my $rv = g_socket_client_connect_to_uri(
      $!sc,
      $uri,
      $dp,
      $cancellable,
      $error
    );
    set_error($error);

    $rv ??
      ( $raw ?? $rv !! GIO::SocketConnection.new($rv, :!ref) )
      !!
      Nil;
  }

  proto method connect_to_uri_async (|)
    is also<connect-to-uri-async>
  { * }

  multi method connect_to_uri_async (
    Str()               $uri,
    Int()               $default_port,
                        &callback,
    gpointer            $user_data     = gpointer
  ) {
    samewith($uri, $default_port, GCancellable, &callback, $user_data);
  }
  multi method connect_to_uri_async (
    Str()               $uri,
    Int()               $default_port,
    GCancellable()      $cancellable,
                        &callback,
    gpointer            $user_data     = gpointer
  ) {
    my guint16 $dp = $default_port;

    g_socket_client_connect_to_uri_async(
      $!sc,
      $uri,
      $dp,
      $cancellable,
      &callback,
      $user_data
    );
  }

  method connect_to_uri_finish (
    GAsyncResult()          $result,
    CArray[Pointer[GError]] $error   = gerror,
    :$raw = False
  )
    is also<connect-to-uri-finish>
  {
    clear_error;
    my $rv = g_socket_client_connect_to_uri_finish($!sc, $result, $error);
    set_error($error);

    $rv ??
      ( $raw ?? $rv !! GIO::SocketConnection.new($rv, :!ref) )
      !!
      Nil;
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_socket_client_get_type, $n, $t )
  }

}
