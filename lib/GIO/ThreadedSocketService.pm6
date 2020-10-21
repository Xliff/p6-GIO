use v6.c;

use NativeCall;
use Method::Also;

use GIO::Raw::Types;

use GIO::SocketService;

our subset GThreadedSocketServiceAncestry is export of Mu
  where GThreadedSocketService | GSocketServiceAncestry;

class GIO::ThreadedSocketService is GIO::SocketService {
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
