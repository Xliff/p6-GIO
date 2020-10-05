use v6.c;

use Method::Also;

use GIO::Raw::Types;
use GIO::Raw::SocketService;

use GIO::SocketListener;

use GIO::Roles::Signals::SocketService;

our subset GSocketServiceAncestry is export of Mu
  where GSocketService | GSocketListener;

class GIO::SocketService is GIO::SocketListener {
  also does GIO::Roles::Signals::SocketService;

  has GSocketService $!ss is implementor;

  submethod BUILD (:$service) {
    self.setGSocketService($service) if $service;
  }

  method setSocketService(GSocketServiceAncestry $_) {
    my $to-parent;

    $!ss = do {
      when GSocketService {
        $to-parent = cast(GSocketListener, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GSocketService, $_);
      }
    };
    self.setSocketListener($to-parent);
  }

  method GIO::Raw::Definitions::GSocketService
    is also<GSocketService>
  { $!ss }

  multi method new (GSocketServiceAncestry $service, :$ref = True) {
    return unless $service;

    my $o = self.bless( :$service );
    $o.ref if $ref;
    $o;
  }
  multi method new {
    my $service = g_socket_service_new();

    $service ?? self.bless( :$service ) !! Nil;
  }

  # Is originally:
  # GSocketService, GSocketConnection, GObject, gpointer --> gboolean
  method incoming {
    self.connect-incoming($!ss);
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_socket_service_get_type, $n, $t );
  }

  method is_active is also<is-active> {
    so g_socket_service_is_active($!ss);
  }

  method start {
    g_socket_service_start($!ss);
  }

  method stop {
    g_socket_service_stop($!ss);
  }

}
