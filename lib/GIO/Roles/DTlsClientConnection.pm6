use v6.c;

use Method::Also;
use NativeCall;

use GIO::Raw::Types;
use GIO::Raw::DtlsClientConnection;

use GLib::GList;
use GLib::ByteArray;

use GLib::Roles::ListData;
use GLib::Roles::Object;
use GIO::Roles::SocketConnectable;

role GIO::Roles::DtlsClientConnection does GLib::Roles::Object {
  also does GIO::Roles::SocketConnectable;

  has GDtlsClientConnection $!tdcc;

  method roleInit-DtlsClientConnection
    is also<roleInit_DtlsClientConnection>
  {
    return if $!tdcc;

    my \i = findProperImplementor(self.^attributes);
    $!tdcc = cast( GDtlsClientConnection, i.get_value(self) );
  }

  method GIO::Raw::Definitions::GDtlsClientConnection
    is also<GDtlsClientConnection>
  { $!tdcc }

  # multi method new (
  #   GDatagramBased()        $base,
  #   GSocketConnectable()    $server_identity,
  #   CArray[Pointer[GError]] $error            = gerror
  # ) {
  #   ...
  # }

  method server_identity (:$raw = False) is rw is also<server-identity> {
    Proxy.new(
      FETCH => sub ($) {
        my $sc = g_dtls_client_connection_get_server_identity($!tdcc);

        $sc ??
          ( $raw ?? $sc !! GIO::SocketConnectable.new($sc,:!ref) )
          !!
          Nil;
      },
      STORE => sub ($, GSocketConnectable() $identity is copy) {
        g_dtls_client_connection_set_server_identity($!tdcc, $identity);
      }
    );
  }

  method validation_flags is rw is also<validation-flags> {
    Proxy.new(
      FETCH => sub ($) {
        GTlsCertificateFlagsEnum(
          g_dtls_client_connection_get_validation_flags($!tdcc)
        );
      },
      STORE => sub ($, Int() $flags is copy) {
        my GTlsCertificateFlags $f = $flags;

        g_dtls_client_connection_set_validation_flags($!tdcc, $f);
      }
    );
  }

  method get_accepted_cas (:$glist = False, :$raw = False)
    is also<
      get-accepted-cas
      accepted_cas
      accepted-cas
    >
  {
    my $cal = g_dtls_client_connection_get_accepted_cas($!tdcc);

    return Nil  unless $cal;
    return $cal if     $glist && $raw;

    $cal = GLib::GList.new($cal) but GLib::Roles::ListData[GByteArray];
    return $cal  if $glist;

    $raw ?? $cal.Array !! $cal.Array.map({ GLib::ByteArray.new($_, :!ref) });
  }

  method dtlsclientconnection_get_type
    is also<dtlsclientconnection-get-type>
  {
    state ($n, $t);

    unstable_get_type( self.^name, &g_dtls_client_connection_get_type, $n, $t );
  }

}

our subset GDtlsClientConnectionAncestry is export of Mu
  where GDtlsClientConnection | GObject;

class GIO::DTlsClientConnection does GIO::Roles::DtlsClientConnection {

  submethod BUILD (:$client-connection) {
    self.setGDtlsClientConnection($client-connection) if $client-connection;
  }

  method setGDtlsClientConnection (GDtlsClientConnectionAncestry $_) {
    my $to-parent;

    $!tdcc = do {
      when GDtlsClientConnection {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GDtlsClientConnection, $_);
      }
    }
    self!setObject($to-parent);
  }

  multi method new (
    GDtlsClientConnection $client-connection,
                          :$ref = True;
  ) {
    return Nil unless $client-connection;

    my $o = self.bless( :$client-connection );
    $o.ref if $ref;
    $o;
  }
  multi method new (
    GDatagramBased()        $base,
    GSocketConnectable()    $server_identity,
    CArray[Pointer[GError]] $error            = gerror
  ) {
    clear_error;
    my $client-connection = g_dtls_client_connection_new(
      $base,
      $server_identity,
      $error
    );
    set_error($error);

    $client-connection ?? self.bless( :$client-connection ) !! Nil;
  }

}
