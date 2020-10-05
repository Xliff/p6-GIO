use v6.c;

use Method::Also;

use NativeCall;

use GIO::Raw::Types;
use GIO::Raw::SocketAddress;

use GLib::Roles::Object;
use GIO::Roles::SocketConnectable;

our subset GSocketAddressAncestry is export of Mu
  where GSocketAddress | GSocketConnectable | GObject;

class GIO::SocketAddress {
  also does GLib::Roles::Object;
  also does GIO::Roles::SocketConnectable;

  has GSocketAddress $!sa is implementor;

  submethod BUILD (:$address) {
    self.setSocketAddress($address) if $address;
  }

  method setSocketAddress (GSocketAddressAncestry $_) {
    my $to-parent;

    $!sa = do {
      when GSocketConnectable {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GSocketConnectable, $_);
      }
    }
    self!setObject($to-parent);
    self.roleInit-SocketConnectable;
  }

  method GIO::Raw::Definitions::GSocketAddress
    is also<GSocketAddress>
  { $!sa }

  method new (GSocketAddressAncestry $address, :$ref = True) {
    return Nil unless $address;

    my $o = self.bless( :$address );
    $o.ref if $ref;
    $o;
  }

  method new_from_native (Pointer $native, Int() $len)
    is also<new-from-native>
  {
    my gsize $l = $len;
    my $address = g_socket_address_new_from_native($native, $l);

    $address ?? self.bless( :$address ) !! Nil;
  }

  method get_family
    is also<
      get-family
      family
    >
  {
    GSocketFamilyEnum( g_socket_address_get_family($!sa) );
  }

  method get_native_size
    is also<
      get-native-size
      native_size
      native-size
    >
  {
    g_socket_address_get_native_size($!sa);
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_socket_address_get_type, $n, $t );
  }

  method to_native (
    Pointer                 $dest,
    Int()                   $destlen,
    CArray[Pointer[GError]] $error    = gerror
  )
    is also<to-native>
  {
    my gsize $dl = $destlen;

    clear_error;
    my $rv = so g_socket_address_to_native($!sa, $dest, $dl, $error);
    set_error($error);
    $rv;
  }

}
