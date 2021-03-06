use v6.c;

use NativeCall;

use GIO::Raw::Types;

use GLib::Roles::Signals::Generic;

role GIO::Roles::Signals::ActionGroup {
  has %!signals-ag;

  # GActionGroup, Str, gboolean, gpointer
  method connect-action-enabled-changed (
    $obj,
    $signal = 'action-enabled-changed',
    &handler?
  ) {
    my $hid;
    %!signals-ag{$signal} //= do {
      my \𝒮 = Supplier.new;
      $hid = g-connect-action-enabled-changed($obj, $signal,
        -> $, $s, $b, $ud {
          CATCH {
            default { $s.note($_) }
          }

          𝒮.emit( [self, $s, $b, $ud ] );
        },
        Pointer, 0
      );
      [ 𝒮.Supply, $obj, $hid ];
    };
    %!signals-ag{$signal}[0].tap(&handler) with &handler;
    %!signals-ag{$signal}[0];
  }

  # GActionGroup, Str, GVariant, gpointer
  method connect-action-state-changed (
    $obj,
    $signal = 'action-state-changed',
    &handler?
  ) {
    my $hid;
    %!signals-ag{$signal} //= do {
      my \𝒮 = Supplier.new;
      $hid = g-connect-action-state-changed($obj, $signal,
        -> $, $s, $v, $ud {
          CATCH {
            default { $s.note($_) }
          }

          𝒮.emit( [self, $s, $v, $ud ] );
        },
        Pointer, 0
      );
      [ 𝒮.Supply, $obj, $hid ];
    };
    %!signals-ag{$signal}[0].tap(&handler) with &handler;
    %!signals-ag{$signal}[0];
  }

}

# GActionGroup, Str, gboolean, gpointer
sub g-connect-action-enabled-changed(
  Pointer $app,
  Str $name,
  &handler (Pointer, Str, gboolean, Pointer),
  Pointer $data,
  uint32 $flags
)
  returns uint64
  is native(gobject)
  is symbol('g_signal_connect_object')
{ * }

# GActionGroup, Str, GVariant, gpointer
sub g-connect-action-state-changed(
  Pointer $app,
  Str $name,
  &handler (Pointer, Str, GVariant, Pointer),
  Pointer $data,
  uint32 $flags
)
  returns uint64
  is native(gobject)
  is symbol('g_signal_connect_object')
{ * }
