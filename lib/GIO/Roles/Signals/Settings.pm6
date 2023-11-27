use v6.c;

use NativeCall;

use GIO::Raw::Types;

use GLib::Raw::ReturnedValue;

use GLib::Roles::Signals::Generic;

role GIO::Roles::Signals::Settings {
  also does GLib::Roles::Signals::Generic;

  has %!signals-s;

  # GSettings, gpointer, gint, gpointer --> gboolean
  method connect-change-event (
    $obj,
    $signal = 'change-event',
    &handler?
  ) {
    my $hid;
    %!signals-s{$signal} //= do {
      my $s = Supplier.new;
      $hid = g-connect-change-event($obj, $signal,
        -> $, $p, $i, $ud --> gboolean {
          CATCH {
            default { $s.note($_) }
          }

          my $r = ReturnedValue.new;
          $s.emit( [self, $p, $i, $ud, $r] );
          $r.r;
        },
        Pointer, 0
      );
      [ $s.Supply, $obj, $hid ];
    };
    %!signals-s{$signal}[0].tap(&handler) with &handler;
    %!signals-s{$signal}[0];
  }

}

# GSettings, gpointer, gint, gpointer --> gboolean
sub g-connect-change-event(
  Pointer $app,
  Str     $name,
          &handler (Pointer, gpointer, gint, Pointer --> gboolean),
  Pointer $data,
  uint32  $flags
)
  returns uint64
  is native(gobject)
  is symbol('g_signal_connect_object')
{ * }
