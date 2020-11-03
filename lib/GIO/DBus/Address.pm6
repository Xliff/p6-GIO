use v6.c;

use Method::Also;
use NativeCall;

use GIO::Raw::Types;
use GIO::DBus::Raw::Types;

use GIO::Stream;
use GIO::DBus::Raw::Address;

use GLib::Roles::StaticClass;

class GIO::DBus::Address {
  also does GLib::Roles::StaticClass;

  method escape_value (Str() $string) is also<escape-value> {
    g_dbus_address_escape_value($string);
  }

  method is_address (Str() $string) is also<is-address> {
    so g_dbus_is_address($string);
  }

  method is_supported_address (
    Str()                   $string,
    CArray[Pointer[GError]] $error   = gerror
  )
    is also<is-supported-address>
  {
    clear_error;
    my $rv = so g_dbus_is_supported_address($string, $error);
    set_error($error);
    $rv;
  }

  method get_for_bus_sync (
    Int()                   $bus_type,
    GCancellable()          $cancellable = GCancellable,
    CArray[Pointer[GError]] $error       = gerror
  )
    is also<get-for-bus-sync>
  {
    my GBusType $b = $bus_type;
    g_dbus_address_get_for_bus_sync($b, $cancellable, $error);
  }

  proto method get_stream (|)
      is also<get-stream>
  { * }

  multi method get_stream (
    Str()               $address,
                        &callback,
    gpointer            $user_data    = gpointer,
    GCancellable()      :$cancellable = GCancellable
  ) {
    samewith($address, $cancellable, &callback, $user_data);
  }
  multi method get_stream (
    Str()               $address,
    GCancellable()      $cancellable,
                        &callback,
    gpointer            $user_data    = gpointer
  ) {
    g_dbus_address_get_stream($address, $cancellable, &callback, $user_data);
  }

  method get_stream_finish (
    GAsyncResult()          $res,
    Str()                   $out_guid,
    CArray[Pointer[GError]] $error     = gerror,
                            :$raw      = False
  )
    is also<get-stream-finish>
  {
    clear_error;
    my $ios = g_dbus_address_get_stream_finish($res, $out_guid, $error);
    set_error($error);

    $ios ??
      ( $raw ?? $ios !! GIO::Stream.new($ios, :!ref) )
      !!
      Nil;
  }

  method get_stream_sync (
    Str()                   $address,
    Str()                   $out_guid,
    GCancellable()          $cancellable = GCancellable,
    CArray[Pointer[GError]] $error       = gerror,
    :$raw = False
  )
    is also<get-stream-sync>
  {
    clear_error;
    my $ios = g_dbus_address_get_stream_sync(
      $address,
      $out_guid,
      $cancellable,
      $error
    );
    set_error($error);

    $ios ??
      ( $raw ?? $ios !! GIO::Stream.new($ios, :!ref) )
      !!
      Nil;
  }

}
