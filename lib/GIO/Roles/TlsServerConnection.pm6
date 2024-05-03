use v6.c;

use Method::Also;
use NativeCall;

use GIO::Raw::Types;

use GLib::Value;

use GLib::Roles::Object;

role GIO::Roles::TlsServerConnection {
  has GTlsServerConnection $!tsc;

  method roleInit-TlsServerConnection is also<roleInit_TlsServerConnection> {
    return if $!tsc;

    my \i = findProperImplementor(self.^attributes);
    $!tsc = cast( GTlsServerConnection, i.get_value(self) );
  }

  method GIO::Raw::Definitions::GTlsServerConnection
    is also<GTlsServerConnection>
  { $!tsc }

  # Type: GTlsAuthenticationMode
  method authentication-mode is rw  is also<authentication_mode> {
    my GLib::Value $gv .= new( G_TYPE_UINT );
    Proxy.new(
      FETCH => -> $ {
        $gv = GLib::Value.new(
          self.prop_get('authentication-mode', $gv)
        );
        GTlsAuthenticationModeEnum( $gv.uint );
      },
      STORE => -> $, Int() $val is copy {
        $gv.uint = $val;
        self.prop_set('authentication-mode', $gv);
      }
    );
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_tls_server_connection_get_type, $n, $t );
  }

}

our subset GTlsServerConnectionAncestry is export of Mu
  where GTlsServerConnection | GObject;

class GIO::TlsServerConnection
  does GLib::Roles::Object
  does GIO::Roles::TlsServerConnection
{

  submethod BUILD (:$server-connection) {
    self.setGTlsServerConnection($server-connection) if $server-connection;
  }

  method setGTlsServerConnection (GTlsServerConnectionAncestry $_) {
    my $to-parent;

    $!tsc = do {
      when GTlsServerConnection {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GTlsServerConnection, $_);
      }
    }
    self!setObject($to-parent);
  }

  multi method new (
    GTlsServerConnectionAncestry $server-connection,
                                 :$ref               = True
  ) {
    return Nil unless $server-connection;

    my $o = self.bless( :$server-connection );
    $o.ref if $ref;
    $o;
  }
  multi method new (
    GIOStream()             $base,
    GTlsCertificate()       $certificate,
    CArray[Pointer[GError]] $error        = gerror
  ) {
    clear_error;
    my $server-connection = g_tls_server_connection_new(
      $base,
      $certificate,
      $error
    );
    set_error($error);
    $server-connection ?? self.bless( :$server-connection ) !! Nil;
  }
}

### /usr/src/glib/gio/gtlsserverconnection.h

sub g_tls_server_connection_get_type ()
  returns GType
  is native(gio)
  is export
{ * }

sub g_tls_server_connection_new (
  GIOStream               $base_io_stream,
  GTlsCertificate         $certificate,
  CArray[Pointer[GError]] $error
)
  returns GIOStream
  is native(gio)
  is export
{ * }

# our %GIO::Roles::TlsServerConnection::RAW-DEFS;
# for MY::.pairs {
#   %GIO::Roles::TlsServerConnection::RAW-DEFS{.key} := .value
#     if .key.starts-with('&g_tls_server_connection_');
# }
