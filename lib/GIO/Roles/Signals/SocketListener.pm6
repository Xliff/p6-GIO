use v6.c;

use NativeCall;

use GIO::Raw::Types;

role GIO::Roles::Signals::SocketListener {
  has %!signals-sl;

  # GSocketListener, GSocketListenerEvent, GSocket, gpointer
  method connect-event (
    $obj,
    $signal = 'event',
    &handler?
  ) {
    my $hid;
    %!signals-sl{$signal} //= do {
      my \𝒮 = Supplier.new;
      $hid = g-connect-event($obj, $signal,
        -> $, $e, $s, $ud {
          CATCH {
            default { 𝒮.note($_) }
          }

          𝒮.emit( [self, $e, $s, $ud ] );
        },
        Pointer, 0
      );
      [ 𝒮.Supply, $obj, $hid ];
    };
    %!signals-sl{$signal}[0].tap(&handler) with &handler;
    %!signals-sl{$signal}[0];
  }

}

# GSocketListener, GSocketListenerEvent, GSocket, gpointer
sub g-connect-event(
  Pointer $app,
  Str     $name,
          &handler (Pointer, GSocketListenerEvent, GSocket, Pointer),
  Pointer $data,
  uint32  $flags
  )
returns uint64
is native(gobject)
is symbol('g_signal_connect_object')
{ * }
