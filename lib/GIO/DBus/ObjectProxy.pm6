use v6.c;

use Method::Also;

use NativeCall;

use GIO::Raw::Types;
use GIO::DBus::Raw::Types;

use GLib::Value;
use GIO::DBus::Connection;

use GLib::Roles::Object;

our subset GDBusObjectProxyAncestry is export of Mu
  where GDBusObjectProxy | GObject;

class GIO::DBus::ObjectProxy {
  also does GLib::Roles::Object;

  has GDBusObjectProxy $!dop is implementor;

  method BUILD (:$object-proxy) {
    self.setGDBusObjectProxy($object-proxy) if $object-proxy;
  }

  method setGDBusObjectProxy (GDBusObjectProxyAncestry $_) {
    my $to-parent;

    $!dop = do {
      when GDBusObjectProxy {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GDBusObjectProxy, $_);
      }
    }
    self!setObject($to-parent);
  }

  method GIO::Raw::Definitions::GDBusObjectProxy
    is also<GDBusObjectProxy>
  { $!dop }

  multi method new (GDBusObjectProxyAncestry $object-proxy, :$ref = True) {
    return Nil unless $object-proxy;

    my $o = self.bless( :$object-proxy );
    $o.ref if $ref;
    $o;
  }
  multi method new (GDBusConnection() $connection, Str() $object_path) {
    my $op = g_dbus_object_proxy_new($connection, $object_path);

    $op ?? self.bless( object-proxy => $op ) !! Nil;
  }

  # Type: Str
  method g-object-path is rw
    is also<
      g_object_path
      object-path
      object_path
    >
  {
    my GLib::Value $gv .= new( G_TYPE_STRING );
    Proxy.new(
      FETCH => -> $ {
        $gv = GLib::Value.new(
          self.prop_get('g-object-path', $gv)
        );
        $gv.string;
      },
      STORE => -> $, Str() $val is copy {
        $gv.string = $val;
        self.prop_set('g-object-path', $gv);
      }
    );
  }

  method get_connection (:$raw = False)
    is also<
      get-connection
      connection
    >
  {
    my $c = g_dbus_object_proxy_get_connection($!dop);

    $c ??
      ( $raw ?? $c !! GIO::DBus::Connection.new($c, :!ref) )
      !!
      Nil;
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_dbus_object_proxy_get_type, $n, $t );
  }

}

sub g_dbus_object_proxy_get_connection (GDBusObjectProxy $proxy)
  returns GDBusConnection
  is native(gio)
  is export
{ * }

sub g_dbus_object_proxy_get_type ()
  returns GType
  is native(gio)
  is export
{ * }

sub g_dbus_object_proxy_new (GDBusConnection $connection, Str $object_path)
  returns GDBusObjectProxy
  is native(gio)
  is export
{ * }

# our %GIO::DBus::ObjectProxy::RAW-DEFS;
# for MY::.pairs {
#   %GIO::DBus::ObjectProxy::RAW-DEFS{.key} := .value
#     if .key.starts-with('&g_dbus_object_proxy_');
# }
