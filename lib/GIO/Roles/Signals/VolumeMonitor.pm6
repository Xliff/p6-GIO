use v6.c;

use NativeCall;

use GIO::Raw::Types;

role GIO::Roles::Signals::VolumeMonitor {
  has %!signals-vm;

  # GVolumeMonitor, GDrive, gpointer
  method connect-drive (
    $obj,
    $signal,
    &handler?
  ) {
    my $hid;
    %!signals-vm{$signal} //= do {
      my $s = Supplier.new;
      $hid = g-connect-drive($obj, $signal,
        -> $, $d, $ud {
          CATCH {
            default { $s.note($_) }
          }

          $s.emit( [self, $d, $ud ] );
        },
        Pointer, 0
      );
      [ $s.Supply, $obj, $hid ];
    };
    %!signals-vm{$signal}[0].tap(&handler) with &handler;
    %!signals-vm{$signal}[0];
  }

  # GVolumeMonitor, GMount, gpointer
  method connect-mount (
    $obj,
    $signal,
    &handler?
  ) {
    my $hid;
    %!signals-vm{$signal} //= do {
      my $s = Supplier.new;
      $hid = g-connect-mount($obj, $signal,
        -> $, $m, $ud {
          CATCH {
            default { $s.note($_) }
          }

          $s.emit( [self, $m, $ud ] );
        },
        Pointer, 0
      );
      [ $s.Supply, $obj, $hid ];
    };
    %!signals-vm{$signal}[0].tap(&handler) with &handler;
    %!signals-vm{$signal}[0];
  }

  # GVolumeMonitor, GVolume, gpointer
  method connect-volume (
    $obj,
    $signal,
    &handler?
  ) {
    my $hid;
    %!signals-vm{$signal} //= do {
      my $s = Supplier.new;
      $hid = g-connect-volume($obj, $signal,
        -> $, $v, $ud {
          CATCH {
            default { $s.note($_) }
          }

          $s.emit( [self, $v, $ud ] );
        },
        Pointer, 0
      );
      [ $s.Supply, $obj, $hid ];
    };
    %!signals-vm{$signal}[0].tap(&handler) with &handler;
    %!signals-vm{$signal}[0];
  }

}


# GVolumeMonitor, GDrive, gpointer
sub g-connect-drive(
  Pointer $app,
  Str $name,
  &handler (Pointer, GDrive, Pointer),
  Pointer $data,
  uint32 $flags
)
  returns uint64
  is native(gobject)
  is symbol('g_signal_connect_object')
{ * }

# GVolumeMonitor, GMount, gpointer
sub g-connect-mount(
  Pointer $app,
  Str $name,
  &handler (Pointer, GMount, Pointer),
  Pointer $data,
  uint32 $flags
)
  returns uint64
  is native(gobject)
  is symbol('g_signal_connect_object')
{ * }

# GVolumeMonitor, GVolume, gpointer
sub g-connect-volume(
  Pointer $app,
  Str $name,
  &handler (Pointer, GVolume, Pointer),
  Pointer $data,
  uint32 $flags
)
  returns uint64
  is native(gobject)
  is symbol('g_signal_connect_object')
{ * }
