use v6.c;

use NativeCall;

use GIO::Raw::Types;

role GIO::Roles::Signals::NetworkMonitor {
  has %!signals-nm;

  method disconnect-network-monitor-signal ($name) {
    self.disconnect($name, %!signals-nm);
  }

  # GNetworkMonitor, gboolean, gpointer
  method connect-network-changed (
    $obj,
    $signal = 'network-changed',
    &handler?
  ) {
    my $hid;
    %!signals-nm{$signal} //= do {
      my \𝒮 = Supplier.new;
      $hid = g-connect-network-changed($obj, $signal,
        -> $, $g, $ud {
          CATCH {
            default { 𝒮.note($_) }
          }

          𝒮.emit( [self, $g, $ud ] );
        },
        Pointer, 0
      );
      [ 𝒮.Supply, $obj, $hid ];
    };
    %!signals-nm{$signal}[0].tap(&handler) with &handler;
    %!signals-nm{$signal}[0];
  }

}

# GNetworkMonitor, gboolean, gpointer
sub g-connect-network-changed(
  Pointer $app,
  Str     $name,
          &handler (Pointer, gboolean, Pointer),
  Pointer $data,
  uint32  $flags
)
  returns uint64
  is native(gobject)
  is symbol('g_signal_connect_object')
{ * }
