use v6.c;

use Method::Also;

use GIO::Raw::Types;
use GIO::Raw::TlsBackend;

use GIO::TlsDatabase;

use GLib::Roles::Object;

role GIO::Roles::TlsBackend does GLib::Roles::Object {
  has GTlsBackend $!tb;

  method roleInit-TlsBackend is also<roleInit_TlsBackend> {
    return if $!tb;

    my \i = findProperImplementor(self.^attributes);
    $!tb = cast( GTlsBackend, i.get_value(self) );
  }

  method GIO::Raw::Definitions::GTlsBackend
    is also<GTlsBackend>
  { $!tb }

  method get_default (
    GIO::Roles::TlsBackend:U:
    :$raw = False;
  )
    is also<get-default>
  {
    my $backend = g_tls_backend_get_default();

    $backend ??
      ( $raw ?? $backend !! self.bless( :$backend , :!ref) )
      !!
      Nil;
  }

  method default_database (:$raw = False) is rw is also<default-database> {
    Proxy.new(
      FETCH => sub ($) {
        my $d = g_tls_backend_get_default_database($!tb);

        $d ??
          ( $raw ?? $d !! GIO::TlsDatabase.new($d, :!ref) )
          !!
          Nil;
      },
      STORE => sub ($, GTlsDatabase() $database is copy) {
        g_tls_backend_set_default_database($!tb, $database);
      }
    );
  }

  # I would hope that these do NOT need unstable_get_type ↓↓↓
  method get_certificate_type is also<get-certificate-type> {
    g_tls_backend_get_certificate_type($!tb);
  }

  method get_client_connection_type is also<get-client-connection-type> {
    g_tls_backend_get_client_connection_type($!tb);
  }

  method get_dtls_client_connection_type
    is also<get-dtls-client-connection-type>
  {
    g_tls_backend_get_dtls_client_connection_type($!tb);
  }

  method get_dtls_server_connection_type
    is also<get-dtls-server-connection-type>
  {
    g_tls_backend_get_dtls_server_connection_type($!tb);
  }

  method get_file_database_type is also<get-file-database-type> {
    g_tls_backend_get_file_database_type($!tb);
  }

  method get_server_connection_type is also<get-server-connection-type> {
    g_tls_backend_get_server_connection_type($!tb);
  }
  # I would hope that these do NOT need unstable_get_type ↑↑↑

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_tls_backend_get_type, $n, $t );
  }

  method supports_dtls is also<supports-dtls> {
    so g_tls_backend_supports_dtls($!tb);
  }

  method supports_tls is also<supports-tls> {
    so g_tls_backend_supports_tls($!tb);
  }

}

our subset GTlsBackendAncestry is export of Mu
  where GTlsBackend | GObject;

class GIO::TlsBackend does GIO::Roles::TlsBackend {

  submethod BUILD (:$backend) {
    self.setGTlsBackend($backend) if $backend;
  }

  method selfSetGTlsBackend (GTlsBackendAncestry $_) {
    my $to-parent;

    $!tb = do {
      when GTlsBackend {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GTlsBackend, $_);
      }
    }
    self!setObject($to-parent);
  }

  method new (GTlsBackendAncestry $backend, :$ref = True) {
    return Nil unless $backend;

    my $o = self.bless( :$backend );
    $o.ref if $ref;
    $o;
  }


}
