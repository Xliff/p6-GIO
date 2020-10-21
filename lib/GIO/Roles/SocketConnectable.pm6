use v6.c;

use Method::Also;
use NativeCall;

use GIO::Raw::Types;

use GIO::SocketAddressEnumerator;

use GLib::Roles::Object;

role GIO::Roles::SocketConnectable does GLib::Roles::Object {
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

    $raw ?? $se !! GIO::SocketAddressEnumerator.new($se);
  }

  method socketconnectable_get_type is also<socketconnectable-get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_socket_connectable_get_type, $n, $t );
  }

  method proxy_enumerate (:$raw = False) is also<proxy-enumerate> {
    my $se = g_socket_connectable_proxy_enumerate($!sc);

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

class GIO::SocketConnectable does GIO::Roles::SocketConnectable {

  submethod BUILD (:$connectable) {
    self.setGSocketConnectable($connectable) if $connectable;
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

  method new (GSocketConnectableAncestry $connectable, :$ref = True) {
    return Nil unless $connectable;

    my $o = self.bless( :$connectable );
    $o.ref if $ref;
    $o;
  }


}

sub g_socket_connectable_enumerate (GSocketConnectable $connectable)
  returns GSocketAddressEnumerator
  is native(gio)
  is export
{ * }

sub g_socket_connectable_get_type ()
  returns GType
  is native(gio)
  is export
{ * }

sub g_socket_connectable_proxy_enumerate (GSocketConnectable $connectable)
  returns GSocketAddressEnumerator
  is native(gio)
  is export
{ * }

sub g_socket_connectable_to_string (GSocketConnectable $connectable)
  returns Str
  is native(gio)
  is export
{ * }

# our %GIO::Roles::SocketConnection::RAW-DEFS;
# for MY::.pairs {
#   %GIO::Roles::SocketConncetion::RAW-DEFS{.key} := .value
#     if .key.starts-with('&g_socket_connection_');
# }
