use v6.c;

use Method::Also;
use NativeCall;

use GIO::Raw::Types;

use GIO::SocketConnection;

our subset GTcpConnectionAncestry is export of Mu
  where GTcpConnection | GSocketConnectionAncestry;

class GIO::TcpConnection is GIO::SocketConnection {
  has GTcpConnection $!tc is implementor;

  submethod BUILD (:$tcp-connection) {
    self.setGTcpConnection($tcp-connection) if $tcp-connection;
  }

  method setTcpConnection (GTcpConnectionAncestry $_) {
    my $to-parent;

    $!tc = do {
      when GTcpConnection {
        $to-parent = cast(GSocketConnection, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GTcpConnection, $_);
      }
    }
    self.setGSocketConnection($to-parent);
  }

  method GIO::Raw::Definitions::GTcpConnection
    is also<GTcpConnection>
  { $!tc }

  method new (GTcpConnectionAncestry $tcp-connection, :$ref = True) {
    return Nil unless $tcp-connection;

    my $o = self.bless( :$tcp-connection );
    $o.ref if $ref;
    $o;
  }

  method graceful_disconnect is rw is also<graceful-disconnect> {
    Proxy.new:
      FETCH => -> $           { self.get_graceful_disconnect    },
      STORE => -> $, Int() \g { self.set_graceful_disconnect(g) };
  }

  method get_graceful_disconnect {
    so g_tcp_connection_get_graceful_disconnect($!tc);
  }

  method set_graceful_disconnect (Int() $graceful_disconnect) {
    my gboolean $g = $graceful_disconnect.so.Int;

    g_tcp_connection_set_graceful_disconnect($!tc, $g);
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_tcp_connection_get_type, $n, $t );
  }

}

sub g_tcp_connection_get_type ()
  returns GType
  is native(gio)
  is export
{ * }

sub g_tcp_connection_get_graceful_disconnect (GTcpConnection $connection)
  returns uint32
  is native(gio)
  is export
{ * }

sub g_tcp_connection_set_graceful_disconnect (
  GTcpConnection $connection,
  gboolean       $graceful_disconnect
)
  is native(gio)
  is export
{ * }

# our %GIO::TcpConnection::RAW-DEFS;
# for MY::.pairs {
#   %GIO::TcpConnection::RAW-DEFS{.key} := .value
#     if .key.starts-with('&g_tcp_connection_');
# }
