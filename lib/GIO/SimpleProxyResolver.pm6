use v6.c;

use Method::Also;
use NativeCall;

use GIO::Raw::Types;
use GIO::Raw::SimpleProxyResolver;

use GLib::Value;

use GLib::Roles::Object;
use GIO::Roles::ProxyResolver;

our subset GSimpleProxyResolverAncestry is export of Mu
  where GSimpleProxyResolver | GProxyResolver | GObject;

class GIO::SimpleProxyResolver {
  also does GLib::Roles::Object;
  also does GIO::Roles::ProxyResolver;

  has GSimpleProxyResolver $!spr is implementor;

  submethod BUILD (:$simple-resolver) {
    self.setGSimpleProxyResolver($simple-resolver) if $simple-resolver;
  }

  method setGSimpleProxyResolver (GSimpleProxyResolverAncestry $_) {
    my $to-parent;

    $!spr = do {
      when GSimpleProxyResolver {
        $to-parent = cast(GObject, $_);
        $_;
      }

      when GProxyResolver {
        $to-parent = cast(GObject, $_);
        $!pr = $_;
        cast(GSimpleProxyResolver, $_);
      }

      default {
        $to-parent = $_;
        cast(GSimpleProxyResolver, $_);
      }
    }
    self!setObject($to-parent);
    self.roleInit-ProxyResolver;
  }

  method GIO::Raw::Definitions::GSimpleProxyResolver
    is also<GSimpleProxyResolver>
  { $!spr }

  multi method new (
    GSimpleProxyResolverAncestry $simple-resolver,
                                 :$ref             = True
  ) {
    return Nil unless $simple-resolver;

    my $o = self.bless( :$simple-resolver );
    $o.ref if $ref;
    $o;
  }
  multi method new (Str() $default_proxy, @ignore_hosts) {
    samewith( $default_proxy, resolve-gstrv(@ignore_hosts) );
  }
  multi method new (Str() $default_proxy, CArray[Str] $ignore_hosts) {
    my $simple-resolver = g_simple_proxy_resolver_new(
      $default_proxy,
      $ignore_hosts
    );

    $simple-resolver ?? self.bless( :$simple-resolver ) !! Nil;
  }

  # Type: Str
  method default-proxy is rw  {
    my GLib::Value $gv .= new( G_TYPE_STRING );
    Proxy.new(
      FETCH => -> $ {
        $gv = GLib::Value.new(
          self.prop_get('default-proxy', $gv)
        );
        $gv.string;
      },
      STORE => -> $, Str() $val is copy {
        $gv.string = $val;
        self.prop_set('default-proxy', $gv);
      }
    );
  }

  # Type: GStrv
  method ignore-hosts is rw  {
    my GLib::Value $gv .= new( G_TYPE_POINTER );
    Proxy.new(
      FETCH => -> $ {
        $gv = GLib::Value.new(
          self.prop_get('ignore-hosts', $gv)
        );

        CStringArrayToArray( cast(CArray[Str], $gv.pointer) );
      },
      STORE => -> $, @val is copy {
        $gv.pointer = resolve-gstrv(@val);
        self.prop_set('ignore-hosts', $gv);
      }
    );
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_simple_proxy_resolver_get_type, $n, $t );
  }

  method set_default_proxy (Str() $default_proxy) is also<set-default-proxy> {
    g_simple_proxy_resolver_set_default_proxy($!spr, $default_proxy);
  }

  proto method set_ignore_hosts (|)
    is also<set-ignore-hosts>
  { * }

  multi method set_ignore_hosts (@ignore_hosts) {
    samewith( resolve-gstrv(@ignore_hosts) );
  }
  multi method set_ignore_hosts (CArray[Str] $ignore_hosts) {
    g_simple_proxy_resolver_set_ignore_hosts($!spr, $ignore_hosts);
  }

  method set_uri_proxy (Str() $uri_scheme, Str() $proxy)
    is also<set-uri-proxy>
  {
    g_simple_proxy_resolver_set_uri_proxy($!spr, $uri_scheme, $proxy);
  }

}
