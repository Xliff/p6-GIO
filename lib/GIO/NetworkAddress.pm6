use v6.c;

use Method::Also;

use NativeCall;

use GIO::Raw::Types;
use GIO::Raw::NetworkAddress;

use GLib::Roles::Object;
use GIO::Roles::SocketConnectable;

our subset GNetworkAddressAncestry is export of Mu
  where GNetworkAddress | GSocketConnectable | GObject;

class GIO::NetworkAddress {
  also does GLib::Roles::Object;
  also does GIO::Roles::SocketConnectable;

  has GNetworkAddress $!a is implementor;

  submethod BUILD (:$address) {
    self.setGNetworkAddress($address) if $address;
  }

  method setGNetworkAddress (GNetworkAddressAncestry $_) {
    my $to-parent;

    $!a = do {
      when GNetworkAddress {
        $to-parent = cast(GObject, $_);
        $_;
      }

      when GSocketConnectable {
        $to-parent = cast(GObject, $_);
        $!sc = $_;
        cast(GNetworkAddress, $_);
      }

      default {
        $to-parent = $_;
        cast(GNetworkAddress, $_);
      }
    }
    self.roleInit-SocketConnectable unless $!sc;
  }

  method GIO::Raw::Definitions::GNetworkAddress
    is also<GNetworkAddress>
  { $!a }

  multi method new (GNetworkAddress $address, :$ref = True) {
    return unless $address;

    my $o = self.bless( :$address );
    $o.ref if $ref;
    $o;
  }
  multi method new (Str() $hostname, Int() $port) {
    my guint16 $p       = $port;
    my         $address = g_network_address_new($hostname, $p);

    $address ?? self.bless( :$address ) !! Nil;
  }

  method new_loopback (Int() $port) is also<new-loopback> {
    my guint16 $p        = $port;
    my          $address = g_network_address_new_loopback($p);

    $address ?? self.bless( :$address ) !! Nil;
  }

  method get_hostname
    is also<
      get-hostname
      hostname
    >
  {
    g_network_address_get_hostname($!a);
  }

  method get_port
    is also<
      get-port
      port
    >
  {
    g_network_address_get_port($!a);
  }

  method get_scheme
    is also<
      get-scheme
      scheme
    >
  {
    g_network_address_get_scheme($!a);
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_network_address_get_type, $n, $t );
  }

  method parse (GIO::NetworkAddress:U:
    Str()                   $host_port,
    Int()                   $default_port,
    CArray[Pointer[GError]] $error         = gerror,
                            :$raw          = False
  ) {
    my guint16 $dp = $default_port;

    clear_error;
    my $a = g_network_address_parse($host_port, $dp, $error);
    set_error($error);

    $a ??
      ( $raw ?? $a !! GIO::NetworkAddress.new($a, :!ref) )
      !!
      Nil;
  }

  method parse_uri (
    GIO::NetworkAddress:U:
    Str()                   $host_port,
    Int()                   $default_port,
    CArray[Pointer[GError]] $error         = gerror,
    :$raw = False
  )
    is also<parse-uri>
  {
    my guint16 $dp = $default_port;

    clear_error;
    my $a = g_network_address_parse_uri($host_port, $dp, $error);
    set_error($error);

    $a ??
      ( $raw ?? $a !! GIO::NetworkAddress.new($a, :!ref) )
      !!
      Nil;
  }

}
