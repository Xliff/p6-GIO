use v6.c;

use Method::Also;
use NativeCall;

use GIO::Raw::Types;
use GIO::Raw::ProxyResolver;

use GLib::Roles::Object;

role GIO::Roles::ProxyResolver does GLib::Roles::Object {
  has GProxyResolver $!pr;

  method roleInit-ProxyResolver {
    return if $!pr;

    my \i = findProperImplementor(self.^attributes);
    $!pr = cast( GProxyResolver, i.get-value(self) );
  }

  method GIO::Raw::Definitions::GProxyResolver
    is also<GProxyResolver>
  { $!pr }

  method get_proxyresolver_type is also<get-proxyresolver-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_proxy_resolver_get_type, $n, $t );
  }

  method is_supported is also<is-supported> {
    so g_proxy_resolver_is_supported($!pr);
  }

  method lookup (
    Str()                   $uri,
    GCancellable()          $cancellable = GCancellable,
    CArray[Pointer[GError]] $error       = gerror
  ) {
    clear_error;
    my $sa = g_proxy_resolver_lookup($!pr, $uri, $cancellable, $error);
    set_error($error);

    CStringArrayToArray($sa);
  }

  proto method lookup_async (|)
    is also<lookup-async>
  { * }

  multi method lookup_async (
    Str()          $uri,
                   &callback,
    gpointer       $user_data = gpointer,
    GCancellable() :$cancellable = GCancellable
  ) {
    samewith($uri, $cancellable, &callback, $user_data);
  }
  multi method lookup_async (
    Str()          $uri,
    GCancellable() $cancellable,
                   &callback,
    gpointer       $user_data    = gpointer
  ) {
    g_proxy_resolver_lookup_async(
      $!pr,
      $uri,
      $cancellable,
      &callback,
      $user_data
    );
  }

  method lookup_finish (
    GAsyncResult()          $result,
    CArray[Pointer[GError]] $error   = gerror
  )
    is also<lookup-finish>
  {
    clear_error;
    my $sa = g_proxy_resolver_lookup_finish($!pr, $result, $error);
    set_error($error);

    CStringArrayToArray($sa);
  }

}

our subset GProxyResolverAncestry is export of Mu
  where GProxyResolver | GObject;

class GIO::ProxyResolver does GIO::Roles::ProxyResolver {

  submethod BUILD (:$resolver) {
    self.setGProxyResolver($resolver) if $resolver;
  }

  method setGProxyResolver (GProxyResolverAncestry $_) {
    my $to-parent;

    $!pr = do {
      when GProxyResolver {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GProxyResolver, $_);
      }
    }
    self!setObject($to-parent);
  }

  method new (GProxyResolverAncestry $resolver, :$ref = True) {
    return Nil unless $resolver;

    my $o = self.bless( :$resolver );
    $o.ref if $ref;
    $o;
  }

  method get_default is also<get-default> {
    GIO::ProxyResolver.new( g_proxy_resolver_get_default(), :!ref );
  }

}
