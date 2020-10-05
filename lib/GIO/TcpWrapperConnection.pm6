use v6.c;

use Method::Also;
use NativeCall;

use GIO::Raw::Types;

use GIO::Stream;
use GIO::TcpConnection;

our subset GTcpWrapperConnectionAncestry is export of Mu
  where GTcpWrapperConnection | GTcpConnectionAncestry;

class GIO::TcpWrapperConnection is GIO::TcpConnection {
  has GTcpWrapperConnection $!twc is implementor;

  submethod BUILD (:$wrapper-connection) {
    self.setGTcpWrapperConnection($wrapper-connection) if $wrapper-connection;
  }

  method setGTcpWrapperConnection (GTcpWrapperConnectionAncestry $_) {
    my $to-parent;

    $!twc = do {
      when GTcpWrapperConnection {
        $to-parent = cast(GTcpConnection, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GTcpWrapperConnection, $_);
      }
    }
    self.setGTcpConnection($to-parent);
  }

  method GIO::Raw::Definitions::GTcpWrapperConnection
    is also<GTcpWrapperConnection>
  { $!twc }

  multi method new (
    GTcpWrapperConnectionAncestry $wrapper-connection,
                                  :$ref = True
  ) {
    return Nil unless $wrapper-connection;

    my $o = self.bless( :$wrapper-connection );
    $o.ref if $ref;
    $o;
  }
  multi method new (GIOStream() $base_io_stream, GSocket() $socket) {
    my $wrapper-connection = g_tcp_wrapper_connection_new(
      $base_io_stream,
      $socket
    );

    $wrapper-connection ?? self.bless( :$wrapper-connection ) !! Nil;
  }

  method get_base_io_stream (:$raw = False) is also<get-base-io-stream> {
    my $ios = g_tcp_wrapper_connection_get_base_io_stream($!twc);

    $ios ??
      ( $raw ?? $ios !! GIO::Stream.new($ios, :!ref) )
      !!
      Nil;
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_tcp_wrapper_connection_get_type, $n, $t );
  }

}

sub g_tcp_wrapper_connection_get_base_io_stream (GTcpWrapperConnection $conn)
  returns GIOStream
  is native(gio)
  is export
{ * }

sub g_tcp_wrapper_connection_get_type ()
  returns GType
  is native(gio)
  is export
{ * }

sub g_tcp_wrapper_connection_new (GIOStream $base_io_stream, GSocket $socket)
  returns GTcpWrapperConnection
  is native(gio)
  is export
{ * }

# our %GIO::TcpWrapperConnection::RAW-DEFS;
# for MY::.pairs {
#   %GIO::TcpWrapperConnection::RAW-DEFS{.key} := .value
#     if .key.starts-with('&g_tcp_wrapper_connection_');
# }
