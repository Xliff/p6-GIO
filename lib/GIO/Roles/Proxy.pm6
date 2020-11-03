use v6.c;

use NativeCall;

use GIO::Raw::Types;
use GIO::Raw::Proxy;

use GIO::Stream;

use GLib::Roles::Object;

role GIO::Roles::Proxy {
  has GProxy $!p;

  submethod GIO::Raw::Definitions::GProxy
  { $!p }

  method roleInit-Proxy {
    return if $!p;

    my \i = findProperImplementor(self.^attributes);
    $!p = cast( GProxy, i.get_vale(self) );
  }

  method get_default_for_protocol (Str() $protocol) {
    self.bless( proxy => g_proxy_get_default_for_protocol($protocol) );
  }

  multi method connect (
    GIOStream()             $connection,
    GProxyAddress()         $proxy_address,
    GCancellable()          $cancellable    =  GCancellable,
    CArray[Pointer[GError]] $error          =  gerror,
                            :$raw           =  False,
                            :$proxy         is required
  ) {
    self.proxy_connect(
      $connection,
      $proxy_address,
      $cancellable,
      $error,
      :$raw
    );
  }
  method proxy_connect (
    GIOStream()             $connection,
    GProxyAddress()         $proxy_address,
    GCancellable()          $cancellable    = GCancellable,
    CArray[Pointer[GError]] $error          = gerror,
                            :$raw           = False
  ) 
  #  is also<proxy-connect>
  {
    clear_error;
    my $ios =
      g_proxy_connect($!p, $connection, $proxy_address, $cancellable, $error);
    set_error($error);
    $raw ?? $ios !! GIO::Stream.new($ios, :!ref);
  }

  proto method connect_async (|)
  { * }

  multi method connect_async (
    GIOStream()         $connection,
    GProxyAddress()     $proxy_address,
                        &callback,
    gpointer            $user_data      = Pointer,
    GCancellable()      :$cancellable   = GCancellable
  ) {
    samewith($connection, $proxy_address, &callback, $user_data);
  }
  multi method connect_async (
    GIOStream()         $connection,
    GProxyAddress()     $proxy_address,
    GCancellable()      $cancellable,
                        &callback,
    gpointer            $user_data      = Pointer
  ) {
    g_proxy_connect_async(
      $!p,
      $connection,
      $proxy_address,
      $cancellable,
      &callback,
      $user_data
    );
  }

  method connect_finish (
    GAsyncResult()          $result,
    CArray[Pointer[GError]] $error = gerror,
                            :$raw  = False;
  ) {
    clear_error;
    my $ios = g_proxy_connect_finish($!p, $result, $error);
    set_error($error);

    $ios ??
      ( $raw ?? $ios !! GIO::Stream.new($ios, :!ref) )
      !!
      Nil;
  }

  method proxy_get_type {
    state ($n, $t);

    unstable_get_type( self.^name, &g_proxy_get_type, $n, $t );
  }

  method supports_hostname {
    so g_proxy_supports_hostname($!p);
  }

}

our subset GProxyAncestry is export of Mu
  where GProxy | GObject;

class GIO::Proxy does GLib::Roles::Object does GIO::Roles::Proxy {

  submethod BUILD (:$proxy) {
    self.setGProxy($proxy) if $proxy;
  }

  method setGProxy (GProxyAncestry $_) {
    my $to-parent;

    $!p = do {
      when GProxy {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GProxy, $_);
      }
    }
    self!setObject($to-parent);
  }

  method new (GProxyAncestry $proxy, :$ref = True) {
    return Nil unless $proxy;

    my $o = self.bless( :$proxy );
    $o.ref if $ref;
    $o;
  }

}
