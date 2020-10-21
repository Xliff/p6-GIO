use v6.c;

use Method::Also;

use GIO::Raw::Types;
use GIO::DBus::Raw::Types;
use GIO::DBus::Raw::Interface;

use GLib::Roles::Object;

role GIO::DBus::Roles::Interface does GLib::Roles::Object {
  has GDBusInterface $!di;

  method roleInit-GDBusInterface is also<roleInit_DBusInterface> {
    my \i = findProperImplementor(self.^attributes);

    $!di = cast( GDBusInterface, i.get_value(self) );
  }

  method GIO::Raw::Definitions::GDBusInterface
    is also<GDBusInterface>
  { $!di }

  method object (:$raw = False) is rw {
    Proxy.new(
      FETCH => sub ($) {
        my $o = g_dbus_interface_get_object($!di);

        $o ??
          ( $raw ?? $o !! ::('GIO::DBus::Object').new($o, :!ref) )
          !!
          Nil;
      },
      STORE => sub ($, GDBusObject() $object is copy) {
        g_dbus_interface_set_object($!di, $object);
      }
    );
  }

  method dup_object () is also<dup-object> {
    g_dbus_interface_dup_object($!di);
  }

  method get_info () is also<get-info> {
    g_dbus_interface_get_info($!di);
  }

  method dbusinterface_get_type is also<dbusinterface-get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_dbus_interface_get_type, $n, $t );
  }

}

our subset GDBusInterfaceAncestry is export of Mu
  where GDBusInterface | GObject;

class GIO::DBus::Interface does GIO::DBus::Roles::Interface {

  submethod BUILD ( :$dbus-interface ) {
    self.setGDBusInterface($dbus-interface) if $dbus-interface;
  }

  method setGDBusInterface (GDBusInterfaceAncestry $_) {
    my $to-parent;

    $!di = do {
      when GDBusInterface {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GDBusInterface, $_);
      }
    }
    self!setObject($to-parent);
  }

  method new (GDBusInterfaceAncestry $dbus-interface, :$ref = True) {
    return Nil unless $dbus-interface;

    my $o = self.bless( :$dbus-interface );
    $o.ref if $ref;
    $o;
  }

}
