use v6.c;

use Method::Also;

use NativeCall;

use GIO::Raw::Types;
use GIO::Raw::NetworkMonitor;

use GLib::Value;

use GLib::Roles::Object;
use GIO::Roles::Initable;
use GIO::Roles::Signals::NetworkMonitor;

class GIO::NetworkMonitor { ... }

role GIO::Roles::NetworkMonitor does GLib::Roles::Object {
  also does GIO::Roles::Initable;
  also does GIO::Roles::Signals::NetworkMonitor;

  has GNetworkMonitor $!nm;

  method roleInit-NetworkMonitor is also<roleInit_NetworkMonitor> {
    return if $!nm;

    my \i = findProperImplementor(self.^attributes);
    $!nm = cast( GNetworkMonitor, i.get_value(self) );
  }

  method GIO::Raw::Definitions::GNetworkMonitor
    is also<GNetworkMonitor>
  { $!nm }

  # Type: GNetworkConnectivity
  method connectivity is rw {
    my $gv = GLib::Value.new( GLib::Value.gtypeFromType(GNetworkConnectivity) );
    Proxy.new(
      FETCH => sub ($) {
        $gv = GLib::Value.new(
          self.prop_get('connectivity', $gv)
        );
        GNetworkConnectivityEnum( $gv.enum );
      },
      STORE => -> $, $ {
        warn 'connectivity does not allow writing'
      }
    );
  }

  # Type: gboolean
  method network-available is rw  {
    my $gv = GLib::Value.new( G_TYPE_BOOLEAN );
    Proxy.new(
      FETCH => sub ($) {
        $gv = GLib::Value.new(
          self.prop_get('network-available', $gv)
        );
        $gv.boolean;
      },
      STORE => -> $, $ {
        warn 'network-available does not allow writing'
      }
    );
  }

  # Type: gboolean
  method network-metered is rw  {
    my $gv = GLib::Value.new( G_TYPE_BOOLEAN );
    Proxy.new(
      FETCH => sub ($) {
        $gv = GLib::Value.new(
          self.prop_get('network-metered', $gv)
        );
        $gv.boolean;
      },
      STORE => -> $, $ {
        warn 'network-metered does not allow writing'
      }
    );
  }

  # Is originally:
  # GNetworkMonitor, gboolean, gpointer --> void
  method network-changed {
    self.connect-network-changed($!nm);
  }

  method can_reach (
    GSocketConnectable()    $connectable,
    GCancellable()          $cancellable  = GCancellable,
    CArray[Pointer[GError]] $error        = gerror
  )
    is also<can-reach>
  {
    clear_error;
    my $rv = g_network_monitor_can_reach(
      $!nm,
      $connectable,
      $cancellable,
      $error
    );
    set_error($error);
    $rv;
  }

  proto method can_reach_async (|)
    is also<can-reach-async>
  { * }

  multi method can_reach_async (
    GSocketConnectable() $connectable,
                         &callback,
    gpointer             $user_data    = gpointer,
    GCancellable()       :$cancellable = GCancellable
  ) {
    samewith($connectable, $cancellable, &callback, $user_data);
  }
  multi method can_reach_async (
    GSocketConnectable() $connectable,
    GCancellable()       $cancellable,
                         &callback,
    gpointer             $user_data    = gpointer
  )
    is also<can-reach-async>
  {
    g_network_monitor_can_reach_async(
      $!nm,
      $connectable,
      $cancellable,
      &callback,
      $user_data
    );
  }

  method can_reach_finish (
    GAsyncResult()          $result,
    CArray[Pointer[GError]] $error   = gerror
  )
    is also<can-reach-finish>
  {
    clear_error;
    my $rv = g_network_monitor_can_reach_finish($!nm, $result, $error);
    set_error($error);
    $rv;
  }

  method get_connectivity is also<get-connectivity> {
    GNetworkConnectivityEnum( g_network_monitor_get_connectivity($!nm) );
  }

  method get_default (:$raw = False)
    is also<
      get-default
      default
    >
  {
    my $nm = g_network_monitor_get_default();

    $nm ??
      ( $raw ?? $nm !! GIO::NetworkMonitor.new($nm, :!ref) )
      !!
      Nil;
  }

  method get_network_available
    is also<
      get-network-available
      network_available
      network-available
    >
  {
    so g_network_monitor_get_network_available($!nm);
  }

  method get_network_metered
    is also<
      get-network-metered
      network_metered
      network-metered
    >
  {
    so g_network_monitor_get_network_metered($!nm);
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_network_monitor_get_type, $n, $t );
  }

}

our subset GNetworkMonitorAncestry is export of Mu
  where GNetworkMonitor | GInitable | GObject;

class GIO::NetworkMonitor does GIO::Roles::NetworkMonitor {

  submethod BUILD (:$monitor, :$init, :$cancellable) {
    self.setGMonitor($monitor, :$init, :$cancellable) if $monitor;
  }

  method setGMonitor (GNetworkMonitorAncestry $_, :$init, :$cancellable) {
    my $to-parent;

    $!nm = do {
      when GNetworkMonitor {
        $to-parent = cast(GObject, $_);
        $_;
      }

      when GInitable {
        $to-parent = cast(GObject, $_);
        $!i = $_;
        cast(GNetworkMonitor, $_);
      }

      default {
        $to-parent = $_;
        cast(GNetworkMonitor, $_);
      }
    }
    self!setObject($to-parent);
    self.roleInit-Initable($init, $cancellable);
  }

  multi method new (GNetworkMonitorAncestry $monitor, :$ref = True) {
    return Nil unless $monitor;

    my $o = self.bless( :$monitor );
    $o.ref if $ref;
    $o;
  }

}
