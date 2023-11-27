use v6.c;

use NativeCall;

use GLib::Raw::ReturnedValue;
use GIO::Raw::Types;

role GIO::Roles::Signals::ThreadedSocketService {
  has %!signals-tss;

  # GThreadedSocketService, GSocketConnection, GObject, gpointer --> gboolean
  method connect-run (
    $obj,
    $signal = 'run',
    &handler?
  ) {
    my $hid;
    %!signals-tss{$signal} //= do {
      my \𝒮 = Supplier.new;
      $hid = g-connect-run($obj, $signal,
        -> $, $c, $o, $ud --> gboolean {
          CATCH {
            default { 𝒮.note($_) }
          }

          my $r = ReturnedValue.new;
          𝒮.emit( [self, $c, $o, $ud, $r] );
          $r.r;
        },
        Pointer, 0
      );
      [ 𝒮.Supply, $obj, $hid ];
    };
    %!signals-tss{$signal}[0].tap(&handler) with &handler;
    %!signals-tss{$signal}[0];
  }

}

# GThreadedSocketService, GSocketConnection, GObject, gpointer --> gboolean
sub g-connect-run(
  Pointer $app,
  Str     $name,
          &handler (Pointer, GSocketConnection, GObject, Pointer --> gboolean),
  Pointer $data,
  uint32  $flags
)
  returns uint64
  is native(gobject)
  is symbol('g_signal_connect_object')
{ * }
