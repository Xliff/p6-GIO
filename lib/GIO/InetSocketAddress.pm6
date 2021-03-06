use v6.c;

use Method::Also;

use GIO::Raw::Types;
use GIO::Raw::InetSocketAddress;

use GIO::InetAddress;
use GIO::SocketAddress;

our subset GInetSocketAddressAncestry is export
  where GInetSocketAddress | GSocketAddressAncestry;

class GIO::InetSocketAddress is GIO::SocketAddress {
  has GInetSocketAddress $!isa is implementor;

  submethod BUILD (:$inetsocketaddr) {
    self.setGInetSocketAddr($inetsocketaddr) if $inetsocketaddr;
  }

  method setGInetSocketAddr(GInetSocketAddressAncestry $_) {
    my $to-parent;

    $!isa = do {
      when GInetSocketAddress {
        $to-parent = cast(GSocketAddress, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GInetSocketAddress, $_);
      }
    };
    self.setGSocketAddress($to-parent);
  }

  method GIO::Raw::Definitions::GInetSocketAddress
    is also<GInetSocketAddress>
  { $!isa }

  multi method new (GInetSocketAddressAncestry $inetsocketaddr, :$ref = True) {
    return Nil unless $inetsocketaddr;

    my $o = self.bless( :$inetsocketaddr );
    $o.ref if $ref;
    $o;
  }
  multi method new (
    GInetAddress() $address,
    Int()          $port     = 0,
    Int()          $flowinfo = 0,
    Int()          $scope_id = 0
  ) {
    my guint16 ($p, $f, $s) = ($port, $flowinfo, $scope_id);
    my $inetsocketaddr = ($flowinfo || $scope_id) ??
      g_object_new_inet_socket_address(
        self.get-type,
        'address',  $address,
        'port',     $p,
        'flowinfo', $f,
        'scope-id', $s,
        Str
      )
      !!
      g_inet_socket_address_new($address, $p);

    $inetsocketaddr ?? self.bless( :$inetsocketaddr ) !! Nil;
  }

  method new_from_string (Str() $addr, Int() $port = 0)
    is also<new-from-string>
  {
    my guint $p = $port;
    my $inetsocketaddr = g_inet_socket_address_new_from_string($addr, $port);

    $inetsocketaddr ?? self.bless( :$inetsocketaddr ) !! Nil;
  }

  method get_address (:$raw = False)
    is also<
      get-address
      address
    >
  {
    my $a = g_inet_socket_address_get_address($!isa);

    $a ??
      ( $raw ?? $a !! GIO::InetAddress.new($a, :!ref) )
      !!
      Nil;
  }

  method get_flowinfo
    is also<
      get-flowinfo
      flowinfo
    >
  {
    g_inet_socket_address_get_flowinfo($!isa);
  }

  method get_port
    is also<
      get-port
      port
    >
  {
    g_inet_socket_address_get_port($!isa);
  }

  method get_scope_id
    is also<
      get-scope-id
      scope_id
      scope-id
    >
  {
    g_inet_socket_address_get_scope_id($!isa);
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_inet_socket_address_get_type, $n, $t );
  }

}
