use v6.c;

use NativeCall;
use Method::Also;

use GIO::Raw::Types;

use GIO::SocketService;

use GIO::Roles::Signals::ThreadedSocketService;

our subset GThreadedSocketServiceAncestry is export of Mu
  where GThreadedSocketService | GSocketServiceAncestry;

class GIO::ThreadedSocketService is GIO::SocketService {
  also does GIO::Roles::Signals::ThreadedSocketService;

  has GThreadedSocketService $!tss is implementor;

  submethod BUILD (:$socket-service) {
    self.setGThreadSocketService($socket-service) if $socket-service;
  }

  method setGThreadSocketService (GThreadedSocketServiceAncestry $_) {
    my $to-parent;

    $!tss = do {
      when GThreadedSocketService {
        $to-parent = cast(GSocketService, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GThreadedSocketService, $_);
      }
    }
    self.setSocketService($to-parent);
  }

  method GIO::Raw::Definitions::GThreadedSocketService
    is also<GThreadedSocketService>
  { $!tss }

  multi method new (
    GThreadedSocketServiceAncestry $socket-service,
                                   :$ref = True
  ) {
    return Nil unless $socket-service;

    my $o = self.bless( :$socket-service );
    $o.ref if $ref;
    $o;
  }
  multi method new (Int() $max) {
    my gint $m              = $max;
    my      $socket-service = g_threaded_socket_service_new($max);

    $socket-service ?? self.bless( :$socket-service ) !! Nil;
  }

  # Type: gint
  method max-threads is rw  {
    my $gv = GLib::Value.new( G_TYPE_INT );
    Proxy.new(
      FETCH => sub ($) {
        $gv = GLib::Value.new(
          self.prop_get('max-threads', $gv)
        );
        $gv.int;
      },
      STORE => -> $, Int() $val is copy {
        warn 'max-threads is a construct-only attribute'
      }
    );
  }

  # Is originally:
  # GThreadedSocketService, GSocketConnection, GObject, gpointer --> gboolean
  method run {
    self.connect-run($!tss);
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type(
      self.^name,
      &g_threaded_socket_service_get_type,
      $n,
      $t
    );
  }

}

### /usr/src/glib/gio/gthreadedsocketservice.h

sub g_threaded_socket_service_get_type ()
  returns GType
  is native(gio)
  is export
{ * }

sub g_threaded_socket_service_new (gint $max_threads)
  returns GThreadedSocketService
  is native(gio)
  is export
{ * }

# our %GIO::ThreadedSocketService::RAW-DEFS;
# for MY::.pairs {
#   %GIO::ThreadedSocketService::RAW-DEFS{.key} := .value
#     if .key.starts-with('&g_threaded_socket_service_');
# }
