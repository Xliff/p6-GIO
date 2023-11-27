use v6.c;

use Test;

use GIO::Raw::Types;

use GIO::InetAddress;
use GIO::InetSocketAddress;
use GIO::Socket;
use GIO::SocketListener;

use GLib::Roles::Object;

sub on-event ($l, $e, $s, $d) {
  state $expected = G_SOCKET_LISTENER_BINDING;

  my $so = GLib::Roles::Object.new-object-obj( cast(GObject, $s) );

  ok  $l.isType( GIO::SocketListener.get-type ),            'First parameter is a GSocketListener';
  ok $so.isType( GIO::Socket.get-type ),                    'Third parameter is a GSocket';
  is  GSocketListenerEventEnum($e),              $expected, "Event matches expected value { $expected }";

  $expected = do given $e {
    when G_SOCKET_LISTENER_BINDING   { G_SOCKET_LISTENER_BOUND     }
    when G_SOCKET_LISTENER_BOUND     { G_SOCKET_LISTENER_LISTENING }
    when G_SOCKET_LISTENER_LISTENING { G_SOCKET_LISTENER_LISTENED  }
    when G_SOCKET_LISTENER_LISTENED  { $*success = True;           }
  }
}

sub test-event-signal {
  my $*success = False;
  my $iaddr    = GIO::InetAddress.new-loopback(G_SOCKET_FAMILY_IPV4);
  my $saddr    = GIO::InetSocketAddress.new($iaddr);
  my $listener = GIO::SocketListener.new;

  # cw: $listener.event.tap(&on-event) throws an exception!
  $listener.event.tap(-> *@a {
    CATCH { default { .message.say; .backtrace.summary.say } }
    on-event(|@a)
  });

  $listener.add_address($saddr, G_SOCKET_TYPE_STREAM, G_SOCKET_PROTOCOL_TCP);
  nok $ERROR,   'No error detected when adding address to listener';
  ok $*success, 'Success flag set via events';

  .unref for $iaddr, $saddr, $listener;
}

test-event-signal;
