use v6.c;

use Method::Also;

use GIO::Raw::Types;
use GIO::Raw::UnixSocketAddress;

use GIO::SocketAddress;

our subset GUnixSocketAddressAncestry is export of Mu
  where GUnixSocketAddress | GSocketAddressAncestry;

class GIO::Unix::SocketAddress is GIO::SocketAddress {
  has GUnixSocketAddress $!us is implementor;

  submethod BUILD (:$unix-socket) {
    self.setUnixSocket($unix-socket);
  }

  method setUnixSocketAddress(GUnixSocketAddressAncestry $_) {
    my $to-parent;
    $!us = do {
      when GUnixSocketAddress {
        $to-parent = cast(GSocketAddress, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GUnixSocketAddress, $_);
      }
    }
    self.setGSocketAddress($to-parent);
  }

  method GIO::Raw::Definitions::GUnixSocketAddress
    is also<GUnixSocketAddress>
  { $!us }

  multi method new (GUnixSocketAddressAncestry $unix-socket, :$ref = True) {
    return Nil unless $unix-socket;

    my $o = self.bless( :$unix-socket );
    $o.ref if $ref;
    $o;
  }
  multi method new (Str() $path) {
    my $unix-socket = g_unix_socket_address_new($path);

    $unix-socket ?? self.bless( :$unix-socket ) !! Nil;
  }

  method new_with_type (
    Str() $path,
    Int() $path_len,
    Int() $type
  )
    is also<new-with-type>
  {
    my gint                   $pl = $path_len;
    my GUnixSocketAddressType $t  = $type;

    my $unix-socket = g_unix_socket_address_new_with_type(
      $path,
      $pl,
      $t
    );
    $unix-socket ?? self.bless( :$unix-socket ) !! Nil;
  }

  method abstract_names_supported is also<abstract-names-supported> {
    so g_unix_socket_address_abstract_names_supported();
  }

  method get_address_type
    is also<
      get-address-type
      address_type
      address-type
    >
  {
    GUnixSocketAddressTypeEnum( g_unix_socket_address_get_address_type($!us) );
  }

  method get_is_abstract
    is also<
      get-is-abstract
      is_abstract
      is-abstract
    >
  {
    so g_unix_socket_address_get_is_abstract($!us);
  }

  method get_path
    is also<
      get-path
      path
    >
  {
    g_unix_socket_address_get_path($!us);
  }

  method get_path_len
    is also<
      get-path-len
      path_len
      path-len
    >
  {
    g_unix_socket_address_get_path_len($!us);
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_unix_socket_address_get_type, $n, $t );
  }

}
