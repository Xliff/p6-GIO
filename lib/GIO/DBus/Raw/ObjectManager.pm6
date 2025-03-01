use v6.c;

use NativeCall;

use GIO::Raw::Types;
use GIO::DBus::Raw::Types;

unit package GIO::DBus::Raw::ObjectManager;

### /usr/src/glib/gio/gdbusobjectmanager.h

sub g_dbus_object_manager_get_interface (
  GDBusObjectManager $manager,
  Str                $object_path,
  Str                $interface_name
)
  returns GDBusInterface
  is native(glib)
  is export
{ * }

sub g_dbus_object_manager_get_object (
  GDBusObjectManager $manager,
  Str                $object_path
)
  returns GDBusObject
  is native(glib)
  is export
{ * }

sub g_dbus_object_manager_get_object_path (GDBusObjectManager $manager)
  returns Str
  is native(glib)
  is export
{ * }

sub g_dbus_object_manager_get_objects (GDBusObjectManager $manager)
  returns GList
  is native(glib)
  is export
{ * }

sub g_dbus_object_manager_get_type ()
  returns GType
  is native(glib)
  is export
{ * }
