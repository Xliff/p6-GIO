use v6.c;

use Method::Also;

use NativeCall;

use GIO::Raw::Types;
use GIO::DBus::Raw::Types;

use GLib::GList;

use GIO::DBus::Roles::Interface;

use GLib::Roles::ListData;

use GLib::Roles::Object;
use GIO::DBus::Roles::Signals::Object;

role GIO::DBus::Roles::Object does GLib::Roles::Object {
  also does GIO::DBus::Roles::Signals::Object;

  has GDBusObject $!do;

  method roleInit-DBusObject is also<roleInit_DBusObject> {
    my \i = findProperImplementor(self.^attributes);

    $!do = cast( GDBusObject, i.get_value(self) );
  }

  method GIO::Raw::Definitions::GDBusObject
    is also<GDBusObject>
  { $!do }

  # Is originally:
  # GDBusObject, GDBusInterface, gpointer --> void
  method interface-added {
    self.connect-interface($!do, 'interface-added');
  }

  # Is originally:
  # GDBusObject, GDBusInterface, gpointer --> void
  method interface-removed {
    self.connect-interface($!do, 'interface-removed');
  }

  method get_interface (Str() $interface_name, :$raw = False)
    is also<get-interface>
  {
    my $i = g_dbus_object_get_interface($!do, $interface_name);

    $i ??
      ( $raw ?? $i !! GIO::DBus::Interface.new($i, :!ref) )
      !!
      Nil;
  }

  method get_interfaces (:$glist = False, :$raw = False) is also<get-interfaces> {
    my $il = g_dbus_object_get_interfaces($!do);

    return Nil unless $il;
    return $il if     $glist && $raw;

    $il = $il but GLib::Roles::ListData[GDBusInterface];
    return $il if $glist;

    $raw ?? $il.Array
         !! $il.Array.map({ GIO::DBus::Interface.new($_, :!ref) });
  }

  method get_object_path is also<get-object-path> {
    g_dbus_object_get_object_path($!do);
  }

  method dbusobject_get_type is also<dbusobject-get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_dbus_object_get_type, $n, $t );
  }

}

our subset GDBusObjectAncestry is export of Mu
  where GDBusObject | GObject;

class GIO::DBus::Object does GIO::DBus::Roles::Object {

  submethod BUILD ( :$dbus-object ) {
    self.setGDBusObject($dbus-object) if $dbus-object;
  }

  method setGDBusObject (GDBusObjectAncestry $_) {
    my $to-parent;

    $!do = do {
      when GDBusMethodInvocation {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GDBusObject, $_);
      }
    }

    self!setObject($to-parent);
    self.roleInit-DBusObject;
  }

  method new (GDBusObjectAncestry $dbus-object, :$ref = True) {
    return Nil unless $dbus-object;

    my $o = self.bless( :$dbus-object );
    $o.ref if $ref;
    $o;
  }

}

sub g_dbus_object_get_interface (GDBusObject $object, Str $interface_name)
  returns GDBusInterface
  is native(gio)
  is export
{ * }

sub g_dbus_object_get_interfaces (GDBusObject $object)
  returns GList
  is native(gio)
  is export
{ * }

sub g_dbus_object_get_object_path (GDBusObject $object)
  returns Str
  is native(gio)
  is export
{ * }

sub g_dbus_object_get_type ()
  returns GType
  is native(gio)
  is export
{ * }

# our %GIO::DBus::Object::RAW-DEFS;
# for MY::.pairs {
#   %GIO::DBus::Object::RAW-DEFS{.key} := .value
#     if .key.starts-with('&g_dbus_object_');
# }
