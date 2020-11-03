use v6.c;

use Method::Also;
use NativeCall;

use GIO::Raw::Types;

use GLib::Value;

use GLib::Roles::Object;

role GIO::Roles::DtlsServerConnection {
  has GDtlsServerConnection $!dtsc;

  method roleInit-DtlsServerConnection is also<roleInit_DtlsServerConnection> {
    return if $!dtsc;

    my \i  = findProperImplementor(self.^attributes);
    $!dtsc = cast( GDtlsServerConnection, i.get_value(self) );
  }

  method GIO::Raw::Definitions::GDtlsServerConnection
    is also<GDtlsServerConnection>
  { $!dtsc }

  # Type: GDtlsAuthenticationMode
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

    unstable_get_type( self.^name, &g_dtls_server_connection_get_type, $n, $t );
  }

}

our subset GDtlsServerConnectionAncestry is export of Mu
  where GDtlsServerConnection | GObject;

class GIO::DtlsServerConnection does GLib::Roles::Object
                                does GIO::Roles::DtlsServerConnection
{

  submethod BUILD (:$server-connection) {
    self.setGDtlsServerConnection($server-connection) if $server-connection;
  }

  method setGDtlsServerConnection (GDtlsServerConnectionAncestry $_) {
    my $to-parent;

    $!dtsc = do {
      when GDtlsServerConnection {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GDtlsServerConnection, $_);
      }
    }
    self!setObject($to-parent);
  }

  multi method new (GDtlsServerConnection $server-connection, :$ref = True) {
    return Nil unless $server-connection;

    my $o = self.bless( :$server-connection );
    $o.ref if $ref;
    $o;
  }
  multi method new (
    GDatagramBased()        $base,
    GTlsCertificate()       $certificate,
    CArray[Pointer[GError]] $error        = gerror
  ) {
    clear_error;
    my $server-connection = g_dtls_server_connection_new(
      $base,
      $certificate,
      $error
    );
    set_error($error);
    $server-connection ?? self.bless( :$server-connection ) !! Nil;
  }

}

sub g_dtls_server_connection_get_type ()
  returns GType
  is native(gio)
  is export
{ * }

sub g_dtls_server_connection_new (
  GIOStream               $base_io_stream,
  GTlsCertificate         $certificate,
  CArray[Pointer[GError]] $error
)
  returns GDtlsServerConnection
  is native(gio)
  is export
{ * }

# our %GIO::Roles::DTlsServerConnection::RAW-DEFS;
# for MY::.pairs {
#   %GIO::Roles::DTlsServerConnection::RAW-DEFS{.key} := .value
#     if .key.starts-with('&g_dtls_server_connection_');
# }
