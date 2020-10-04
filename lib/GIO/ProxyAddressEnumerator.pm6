use v6.c;

use Method::Also;

use GIO::Raw::Types;

use GLib::Value;

use GLib::Roles::Object;

use GIO::Roles::ProxyResolver;
use GIO::Roles::SocketConnectable;

our subset GProxyAddressEnumeratorAncestry is export of Mu
  where GProxyAddressEnumerator | GProxyResolver | GObject;

class GIO::ProxyAddressEnumerator {
  also does GLib::Roles::Object;
  also does GIO::Roles::ProxyResolver;

  has GProxyAddressEnumerator $!pae is implementor;

  submethod BUILD (:$proxy-enumerator) {
    self.setGProxyAddressEnumerator($proxy-enumerator) if $proxy-enumerator;
  }

  method setGProxyAddressEnumerator (GProxyAddressEnumeratorAncestry $_) {
    my $to-parent;

    $!pae = do {
      when GProxyAddressEnumerator {
        $to-parent = cast(GObject, $_);
        $_;
      }

      when GProxyResolver {
        $to-parent = cast(GObject, $_);
        $!pr = $_;
        cast(GProxyAddressEnumerator, $_);

      }
      default {
        $to-parent = $_;
        cast(GProxyAddressEnumerator, $_);
      }
    }
    self!setObject($to-parent);
    self.roleInit-ProxyResolver;
  }

  method GIO::Raw::Definitions::GProxyAddressEnumerator
    is also<GProxyAddressEnumerator>
  { $!pae }

  method new (GProxyAddressEnumerator $proxy-enumerator, :$ref = True) {
    return Nil unless $proxy-enumerator;

    my $o = self.bless( :$proxy-enumerator );
    $o.ref if $ref;
    $o;
  }

  # Type: GSocketConnectable
  method connectable (:$raw = False) is rw {
    my GLib::Value $gv .= new( G_TYPE_OBJECT );
    Proxy.new(
      FETCH => -> $ {
        $gv = GLib::Value.new(
          self.prop_get('connectable', $gv)
        );

        my $o = $gv.object;
        return Nil unless $o;

        $o = cast(GSocketConnectable, $o);
        return $o if $raw;

        GIO::Roles::SocketConnectable.new-socketconnectable-obj($o, :!ref);
      },
      STORE => -> $, GSocketConnectable() $val is copy {
        $gv.object = $val;
        self.prop_set('connectable', $gv);
      }
    );
  }

  # Type: guint
  method default-port is rw  is also<default_port> {
    my GLib::Value $gv .= new( G_TYPE_UINT );
    Proxy.new(
      FETCH => -> $ {
        $gv = GLib::Value.new(
          self.prop_get('default-port', $gv)
        );
        $gv.uint;
      },
      STORE => -> $, Int() $val is copy {
        $gv.uint = $val;
        self.prop_set('default-port', $gv);
      }
    );
  }

  # Type: GProxyResolver
  method proxy-resolver (:$raw = False) is rw is also<proxy_resolver> {
    my GLib::Value $gv .= new( G_TYPE_OBJECT );
    Proxy.new(
      FETCH => -> $ {
        $gv = GLib::Value.new(
          self.prop_get('proxy-resolver', $gv)
        );

        my $o = $gv.object;
        return Nil unless $o;

        $o = cast(GProxyResolver, $o);
        return $o if $raw;

        GIO::Roles::ProxyResolver.new-proxyresolver-obj($o, :!ref)
      },
      STORE => -> $, GProxyResolver() $val is copy {
        $gv.object = $val;
        self.prop_set('proxy-resolver', $gv);
      }
    );
  }

  # Type: Str
  method uri is rw  {
    my GLib::Value $gv .= new( G_TYPE_STRING );
    Proxy.new(
      FETCH => -> $ {
        $gv = GLib::Value.new(
          self.prop_get('uri', $gv)
        );
        $gv.string;
      },
      STORE => -> $, Str() $val is copy {
        $gv.string = $val;
        self.prop_set('uri', $gv);
      }
    );
  }

}
