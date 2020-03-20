use v6.c;

use NativeCall;

use GIO::Raw::Types;

use GLib::Raw::ReturnedValue;

use GLib::Roles::Signals::Generic;

role GIO::Roles::Signals::Application {
  also does GLib::Roles::Signals::Generic;

  has %!signals-a;

  # GApplication, GApplicationCommandLine, gpointer --> gint
  method connect-command-line (
    $obj,
    $signal = 'command-line',
    &handler?
  ) {
    my $hid;
    %!signals-a{$signal} //= do {
      my $s = Supplier.new;
      $hid = g-connect-command-line($obj, $signal,
        -> $, $ac, $ud --> gint {
          CATCH {
            default { $s.note($_) }
          }

          my $r = ReturnedValue.new;
          $s.emit( [self, $ac, $ud, $r] );
          $r.r;
        },
        Pointer, 0
      );
      [ $s.Supply, $obj, $hid ];
    };
    %!signals-a{$signal}[0].tap(&handler) with &handler;
    %!signals-a{$signal}[0];
  }

  # GApplication, GVariantDict, gpointer --> gint
  method connect-handle-local-options (
    $obj,
    $signal = 'handle-local-options',
    &handler?
  ) {
    my $hid;
    %!signals-a{$signal} //= do {
      my $s = Supplier.new;
      $hid = g-connect-handle-local-options($obj, $signal,
        -> $, $d, $ud --> gint {
          CATCH {
            default { $s.note($_) }
          }

          my $r = ReturnedValue.new;
          $s.emit( [self, $d, $ud, $r] );
          $r.r;
        },
        Pointer, 0
      );
      [ $s.Supply, $obj, $hid ];
    };
    %!signals-a{$signal}[0].tap(&handler) with &handler;
    %!signals-a{$signal}[0];
  }

  # GApplication, gpointer, gint, gchar, gpointer
  method connect-open (
    $obj,
    $signal = 'open',
    &handler?
  ) {
    my $hid;
    %!signals-a{$signal} //= do {
      my $s = Supplier.new;
      $hid = g-connect-open($obj, $signal,
        -> $, $p, $i, $s1, $ud {
          CATCH {
            default { $s.note($_) }
          }

          $s.emit( [self, $p, $i, $s1, $ud ] );
        },
        Pointer, 0
      );
      [ $s.Supply, $obj, $hid ];
    };
    %!signals-a{$signal}[0].tap(&handler) with &handler;
    %!signals-a{$signal}[0];
  }

}

# GApplication, GApplicationCommandLine, gpointer --> gint
sub g-connect-command-line(
  Pointer $app,
  Str $name,
  &handler (Pointer, GApplicationCommandLine, Pointer --> gint),
  Pointer $data,
  uint32 $flags
)
  returns uint64
  is native(gobject)
  is symbol('g_signal_connect_object')
{ * }

# GApplication, GVariantDict, gpointer --> gint
sub g-connect-handle-local-options(
  Pointer $app,
  Str $name,
  &handler (Pointer, GVariantDict, Pointer --> gint),
  Pointer $data,
  uint32 $flags
)
  returns uint64
  is native(gobject)
  is symbol('g_signal_connect_object')
{ * }

# GApplication, gpointer, gint, gchar, gpointer
sub g-connect-open(
  Pointer $app,
  Str $name,
  &handler (Pointer, CArray[Pointer[GFile]], gint, gchar, Pointer),
  Pointer $data,
  uint32 $flags
)
  returns uint64
  is native(gobject)
  is symbol('g_signal_connect_object')
{ * }
