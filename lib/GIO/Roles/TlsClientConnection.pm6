use v6.c;

use Method::Also;
use NativeCall;

use GIO::Raw::Types;
use GIO::Raw::TlsClientConnection;

use GLib::GList;
use GLib::ByteArray;

use GLib::Roles::ListData;
use GLib::Roles::Object;
use GIO::Roles::SocketConnectable;

role GIO::Roles::TlsClientConnection {
  also does GIO::Roles::SocketConnectable;

  has GTlsClientConnection $!tcc;

  method roleInit-TlsClientConnection
    is also<roleInit_TlsClientConnection>
  {
    return if $!tcc;

    my \i = findProperImplementor(self.^attributes);
    $!tcc = cast( GTlsClientConnection, i.get_value(self) );
  }

  method GIO::Raw::Definitions::GTlsClientConnection
    is also<GTlsClientConnection>
  { $!tcc }

  method server_identity (:$raw = False) is rw is also<server-identity> {
    Proxy.new(
      FETCH => sub ($) {
        my $sc = g_tls_client_connection_get_server_identity($!tcc);

        $sc ??
          ( $raw ?? $sc !!
                    GIO::SocketConnectable.new($sc, :!ref) )
          !!
          Nil;
      },
      STORE => sub ($, GSocketConnectable() $identity is copy) {
        g_tls_client_connection_set_server_identity($!tcc, $identity);
      }
    );
  }

  method use_ssl3 is rw is also<use-ssl3> {
    Proxy.new(
      FETCH => sub ($) {
        so g_tls_client_connection_get_use_ssl3($!tcc);
      },
      STORE => sub ($, Int() $use_ssl3 is copy) {
        my gboolean $u = $use_ssl3;

        g_tls_client_connection_set_use_ssl3($!tcc, $u);
      }
    );
  }

  method validation_flags is rw is also<validation-flags> {
    Proxy.new(
      FETCH => sub ($) {
        GTlsCertificateFlagsEnum(
          g_tls_client_connection_get_validation_flags($!tcc)
        );
      },
      STORE => sub ($, Int() $flags is copy) {
        my GTlsCertificateFlags $f = $flags;

        g_tls_client_connection_set_validation_flags($!tcc, $f);
      }
    );
  }

  method copy_session_state (GTlsClientConnection() $source)
    is also<copy-session-state>
  {
    g_tls_client_connection_copy_session_state($!tcc, $source);
  }

  method get_accepted_cas (:$glist = False, :$raw = False)
    is also<
      get-accepted-cas
      accepted_cas
      accepted-cas
    >
  {
    my $cal = g_tls_client_connection_get_accepted_cas($!tcc);

    return Nil  unless $cal;
    return $cal if     $glist;

    $cal = GLib::GList.new($cal) but GLib::Roles::ListData[GByteArray];

    $raw ?? $cal.Array !! $cal.Array.map({ GLib::ByteArray.new($_, :!ref) });
  }

  method tlsclientconnection_get_type  is also<tlsclientconnection-get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_tls_client_connection_get_type, $n, $t );
  }

}

our subset GTlsClientConnectionAncestry is export of Mu
  where GTlsClientConnection | GObject;

class GIO::TlsClientConnection does GLib::Roles::Object
                               does GIO::Roles::TlsClientConnection
{
  
  submethod BUILD (:$client-connection) {
    self.setGTlsClientConnection($client-connection) if $client-connection;
  }

  method setGTlsClientConnection (GTlsClientConnectionAncestry $_) {
    my $to-parent;

    $!tcc = do {
      when GTlsClientConnection {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GTlsClientConnection, $_);
      }
    }
    self!setObject($to-parent);
  }

  proto method new (|)
    is also<new_tlsclientconnection_obj>
  { * }

  multi method new (
    GTlsClientConnectionAncestry $client-connection,
                                              :$ref  = True
  ) {
    return Nil unless $client-connection;

    my $o = self.bless( :$client-connection );
    $o.ref if $ref;
    $o;
  }
  multi method new (
    GIOStream()             $base,
    GSocketConnectable()    $server_identity,
    CArray[Pointer[GError]] $error            = gerror
  ) {
    clear_error;
    my $cc = g_tls_client_connection_new($base, $server_identity, $error);
    set_error($error);
    $cc ?? self.bless( client-connection => $cc ) !! Nil;
  }

}
