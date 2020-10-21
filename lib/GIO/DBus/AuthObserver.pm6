use v6.c;

use Method::Also;

use NativeCall;

use GIO::Raw::Types;

use GLib::Roles::Object;
use GIO::DBus::Roles::Signals::AuthObserver;

our subset GDBusAuthObeserverAncestry is export of Mu
  where GDBusAuthObserver | GObject;

class GIO::DBus::AuthObserver {
  also does GLib::Roles::Object;
  also does GIO::DBus::Roles::Signals::AuthObserver;

  has GDBusAuthObserver $!dao is implementor;

  submethod BUILD (:$observer) {
    self.setGDBusAuthObserver($observer) if $observer;
  }

  method setGDBusAuthObserver (GDBusAuthObeserverAncestry $_) {
     my $to-parent;

     $!dao = do {
       when GDBusAuthObserver {
         $to-parent = cast(GObject, $_);
         $_;
       }

       default {
         $to-parent = $_;
         cast(GDBusAuthObserver, $_);
       }
     }
     self!setObject($to-parent);
  }

  method GIO::Raw::Definitions::GDbusAuthObserver
    is also<GDBusAuthObserver>
  { $!dao }

  multi method new (GDBusAuthObeserverAncestry $observer, :$ref = True) {
    return Nil unless $observer;

    my $o = self.bless( :$observer );
    $o.ref if $ref;
    $o;
  }
  multi method new {
    my $observer = g_dbus_auth_observer_new();

    $observer ?? self.bless( :$observer ) !! Nil;
  }

  # Is originally:
  # GDBusAuthObserver, Str, gpointer --> gboolean
  method allow-mechanism is also<allow_mechanism> {
    self.connect-allow-mechanism($!dao);
  }

  # Is originally:
  # GDBusAuthObserver, GIOStream, GCredentials, gpointer --> gboolean
  method authorize-authenticated-peer is also<authorize_authenticated_peer> {
    self.connect-authorize-authenticated-peer($!dao);
  }

  method emit_allow_mechanism (Str() $mechanism) is also<emit-allow-mechanism> {
    g_dbus_auth_observer_allow_mechanism($!dao, $mechanism);
  }

  method emit_authorize_authenticated_peer (
    GIOStream()    $stream,
    GCredentials() $credentials = GCancellable
  )
    is also<emit-authorize-authenticated-peer>
  {
    g_dbus_auth_observer_authorize_authenticated_peer($!dao, $stream, $credentials);
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_dbus_auth_observer_get_type, $n, $t );
  }

}

sub g_dbus_auth_observer_allow_mechanism (GDBusAuthObserver $observer, Str $mechanism)
  returns uint32
  is native(gio)
  is export
{ * }

sub g_dbus_auth_observer_authorize_authenticated_peer (
  GDBusAuthObserver $observer,
  GIOStream         $stream,
  GCredentials      $credentials
)
  returns uint32
  is native(gio)
  is export
{ * }

sub g_dbus_auth_observer_get_type ()
  returns GType
  is native(gio)
  is export
{ * }

sub g_dbus_auth_observer_new ()
  returns GDBusAuthObserver
  is native(gio)
  is export
{ * }

# our %GIO::DBus::AuthObserver::RAW-DEFS;
# for MY::.pairs {
#   %GIO::DBus::AuthObserver::RAW-DEFS{.key} := .value
#     if .key.starts-with('&g_dbus_auth_observer_');
# }
