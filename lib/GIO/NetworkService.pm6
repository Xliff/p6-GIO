use v6.c;

use Method::Also;

use GIO::Raw::Types;
use GIO::Raw::NetworkService;

use GLib::Roles::Object;
use GIO::Roles::SocketConnectable;

our subset GNetworkServiceAncestry is export of Mu
  where GNetworkService | GSocketConnectable | GObject;

class GIO::NetworkService {
  also does GLib::Roles::Object;
  also does GIO::Roles::SocketConnectable;

  has GNetworkService $!s is implementor;

  submethod BUILD (:$service) {
    self.setGNetworkService($service) if $service;
  }

  method setGNetworkService (GNetworkServiceAncestry $_) {
    my $to-parent;

    $!s = do {
      when GNetworkService {
        $to-parent = cast(GObject, $_);
        $_;
      }

      when GSocketConnectable {
        $to-parent = cast(GObject, $_);
        $!sc = $_;
        cast(GNetworkService, $_);
      }

      default {
        $to-parent = $_;
        cast(GNetworkService, $_);
      }
    }
    self.roleInit-SocketConnectable unless $!sc;
  }

  method GIO::Raw::Definitions::GNetworkService
    is also<GNetworkService>
  { $!s }

  multi method new (GNetworkServiceAncestry $service, :$ref = True) {
    return Nil unless $service;

    my $o = self.bless(:$service);
    $o.ref if $ref;
    $o;
  }
  multi method new (Str() $ser, Str() $protocol, Str() $domain) {
    my $service = g_network_service_new($ser, $protocol, $domain);

    $service ?? self.bless( :$service ) !! Nil;
  }

  method scheme is rw {
    Proxy.new(
      FETCH => sub ($) {
        g_network_service_get_scheme($!s);
      },
      STORE => sub ($, Str() $scheme is copy) {
        g_network_service_set_scheme($!s, $scheme);
      }
    );
  }

  method get_domain
    is also<
      get-domain
      domain
    >
  {
    g_network_service_get_domain($!s);
  }

  method get_protocol
    is also<
      get-protocol
      protocol
    >
  {
    g_network_service_get_protocol($!s);
  }

  method get_service
    is also<
      get-service
      service
    >
  {
    g_network_service_get_service($!s);
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_network_service_get_type, $n, $t );
  }

}
