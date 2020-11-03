use v6.c;

use NativeCall;

use GIO::Raw::Types;

use GLib::Roles::Object;
# Only need this role, since it includes ActionGroup
use GIO::Roles::RemoteActionGroup;

our subset GDBusActionGroupAncestry is export of Mu
  where GDBusActionGroup | GRemoteActionGroup | GActionGroup | GObject;

class GIO::DBus::ActionGroup {
  also does GIO::Roles::RemoteActionGroup;

  has GDBusActionGroup $!dag is implementor;

  submethod BUILD (:$dbus-action-group) {
    self.setDBusActionGroup($dbus-action-group) if $dbus-action-group;
  }

  method setDBusActionGroup (GDBusActionGroupAncestry $_) {
    my $to-parent;

    $!dag = do {
      $to-parent = cast(GObject, $_);

      when GDBusActionGroup    { $_ }
      when GRemoteActionGroup  { $!rag = $_; proceed }
      when GActionGroup        { $!ag  = $_; proceed }

      when GRemoteActionGroup | GActionGroup | GObject {
        $to-parent = $_ if $_ ~~ GObject;

        cast(GDBusActionGroup, $_)
      }
    }

    self.roleInit-Object;
    self.roleInit-ActionGroup;
    self.roleInit-RemoteActionGroup;
  }

  multi method new (GDBusActionGroupAncestry $dbus-action-group, :$ref = True) {
    return Nil unless $dbus-action-group;

    my $o = self.bless( :$dbus-action-group );
    $o.ref if $ref;
    $o;
  }
  multi method new (
    GDBusConnection() $conn,
    Str()             $bus_name,
    Str()             $object_path
  ) {
    self.get($conn, $bus_name, $object_path);
  }

  method get (GDBusConnection() $conn, Str() $bus_name, Str() $object_path) {
    my $dag = g_dbus_action_group_get($conn, $bus_name, $object_path);

    $dag ?? self.bless( dbus-action-group => $dag ) !! Nil;
  }

  method get_type {
    state ($n, $t);

    unstable_get_type( self.^name, &g_dbus_action_group_get_type, $n, $t );
  }

}


### /usr/include/glib-2.0/gio/gdbusactiongroup.h

sub g_dbus_action_group_get (
  GDBusConnection $connection,
  Str $bus_name,
  Str $object_path
)
  returns GDBusActionGroup
  is native(gio)
  is export
{ * }

sub g_dbus_action_group_get_type ()
  returns GType
  is native(gio)
  is export
{ * }

# our %GIO::DBus::ActionGroup::RAW-DEFS;
# for MY::.pairs {
#   %GIO::DBus::ActionGroup::RAW-DEFS{.key} := .value
#     if .key.starts-with('&g_dbus_action_group_');
# }
