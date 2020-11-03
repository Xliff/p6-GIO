use v6.c;

use Method::Also;

use GIO::Raw::Types;
use GIO::DBus::Raw::ObjectManagerServer;

use GIO::DBus::Connection;

use GLib::Roles::Object;

our subset GDBusObjectManagerServerAncestry is export of Mu
  where GDBusObjectManagerServer | GObject;

class GIO::DBus::ObjectManagerServer {
  also does GLib::Roles::Object;

  has GDBusObjectManagerServer $!doms is implementor;

  submethod BUILD (:$server) {
    self.setGDBusObjectManagerServer($server) if $server;
  }

  method setGDBusObjectManagerServer (GDBusObjectManagerServerAncestry $_) {
    my $to-parent;

    $!doms = do {
      when GDBusObjectManagerServer {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GDBusObjectManagerServer, $_);
      }
    }
    self!setObject($to-parent);
  }

  method GIO::Raw::Definitions::GDBusObjectManagerServer
    is also<GDBusObjectManagerServer>
  { $!doms }

  multi method new (GDBusObjectManagerServerAncestry $server, :$ref = True) {
    return Nil unless $server;

    my $o = self.bless( :$server );
    $o.ref if $ref;
    $o;
  }
  multi method new (Str() $object_path) {
    my $server = g_dbus_object_manager_server_new($object_path);

    $server ?? self.bless( :$server ) !! Nil;
  }

  method connection (:$raw = False) is rw {
    Proxy.new(
      FETCH => sub ($) {
        my $c = g_dbus_object_manager_server_get_connection($!doms);

        $c ??
          ( $raw ?? $c !! GIO::DBus::Connection.new($c, :!ref) )
          !!
          Nil;
      },
      STORE => sub ($, GDBusConnection() $connection is copy) {
        g_dbus_object_manager_server_set_connection($!doms, $connection);
      }
    );
  }

  method export (GDBusObjectSkeleton() $object) {
    g_dbus_object_manager_server_export($!doms, $object);
  }

  method export_uniquely (GDBusObjectSkeleton() $object) is also<export-uniquely> {
    g_dbus_object_manager_server_export_uniquely($!doms, $object);
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type(
      self.^name,
      &g_dbus_object_manager_server_get_type,
      $n,
      $t
    );
  }

  method is_exported (GDBusObjectSkeleton() $object) is also<is-exported> {
    so g_dbus_object_manager_server_is_exported($!doms, $object);
  }

  method unexport (Str() $object_path) {
    so g_dbus_object_manager_server_unexport($!doms, $object_path);
  }

}
