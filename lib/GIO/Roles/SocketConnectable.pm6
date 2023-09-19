use v6.c;

use Method::Also;
use NativeCall;

use GIO::Raw::Types;

use GIO::SocketAddressEnumerator;

use GLib::Roles::Object;

role GIO::Roles::SocketConnectable {
  has GSocketConnectable $!sc;

  method GIO::Raw::Definitions::GSocketConnectable
    is also<GSocketConnectable>
  { $!sc }

  method roleInit-SocketConnectable {
    return if $!sc;

    my \i = findProperImplementor(self.^attributes);
    $!sc = cast( GSocketConnectable, i.get_value(self) );
  }

  method enumerate (:$raw = False) {
    my $se = g_socket_connectable_enumerate($!sc);

    return Nil unless $se;

    $raw ?? $se !! GIO::SocketAddressEnumerator.new($se);
  }

  method socketconnectable_get_type is also<socketconnectable-get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_socket_connectable_get_type, $n, $t );
  }

  method proxy_enumerate (:$raw = False) is also<proxy-enumerate> {
    my $se = g_socket_connectable_proxy_enumerate($!sc);

    return Nil unless $se;

    $raw ?? $se !! GIO::SocketAddressEnumerator.new($se);
  }

  method to_string
    is also<
      to-string
      Str
    >
  {
    g_socket_connectable_to_string($!sc);
  }

}

our subset GSocketConnectableAncestry is export of Mu
  where GSocketConnectable | GObject;

class GIO::SocketConnectable {
  also does GLib::Roles::Object;
  also does GIO::Roles::SocketConnectable;

  submethod BUILD ( :$socket-connectable ) {
    self.setGSocketConnectable($socket-connectable) if $socket-connectable;
  }

  method setGSocketConnectable (GSocketConnectableAncestry $_) {
    my $to-parent;

    $!sc = do {
      when GSocketConnectable {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GSocketConnectable, $_);
      }
    }
    self!setObject($to-parent);
  }

  method new (GSocketConnectableAncestry $socket-connectable, :$ref = True) {
    return Nil unless $socket-connectable;

    my $o = self.bless( :$socket-connectable );
    $o.ref if $ref;
    $o;
  }

}

sub g_socket_connectable_enumerate (GSocketConnectable $socket-connectable)
  returns GSocketAddressEnumerator
  is native(gio)
  is export
{ * }

sub g_socket_connectable_get_type ()
  returns GType
  is native(gio)
  is export
{ * }

sub g_socket_connectable_proxy_enumerate (
  GSocketConnectable $socket-connectable
)
  returns GSocketAddressEnumerator
  is native(gio)
  is export
{ * }

sub g_socket_connectable_to_string (GSocketConnectable $socket-connectable)
  returns Str
  is native(gio)
  is export
{ * }

# cw: Hmmm... having all raw defs as introspectable objects at runtime?
#     I can see the nifty-ness of it, but not much real utility.
#
#     I guess that would depend on the use case, and something like this
#     could always be done externally.
#
# our %GIO::Roles::SocketConnection::RAW-DEFS;
# for MY::.pairs {
#   %GIO::Roles::SocketConncetion::RAW-DEFS{.key} := .value
#     if .key.starts-with('&g_socket_connection_');
# }
