use v6.c;

use Method::Also;

use NativeCall;

use GIO::Raw::Types;
use GIO::Raw::NetworkMonitor;

use GLib::Value;

use GLib::Roles::Object;
use GIO::Roles::Signals::NetworkMonitor;

use GIO::Roles::NetworkMonitorBase;

class GIO::NetworkMonitor { ... }

role GIO::Roles::NetworkMonitor {
  also does GIO::Roles::Signals::NetworkMonitor;

  has GNetworkMonitor $!nm is implementor;

  method roleInit-GNetworkMonitor
    is also<
      roleInit_NetworkMonitor
      roleInit-NetworkMonitor
    >
  {
    return if $!nm;

    my \i = findProperImplementor(self.^attributes);
    $!nm = cast( GNetworkMonitor, i.get_value(self) );
  }

  method GIO::Raw::Definitions::GNetworkMonitor
    is also<GNetworkMonitor>
  { $!nm }
  # <also> not yet working for roles!
  method GNetworkMonitor
  { $!nm }

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
    my $rv = so g_network_monitor_can_reach(
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
     $connectable,
     &callback,
     $user_data    = gpointer,
    :$cancellable  = GCancellable
  ) {
    samewith($connectable, $cancellable, &callback, $user_data);
  }
  multi method can_reach_async (
    GSocketConnectable() $connectable,
    GCancellable()       $cancellable,
                         &callback,
    gpointer             $user_data    = gpointer
  ) {
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
    my $rv = so g_network_monitor_can_reach_finish($!nm, $result, $error);
    set_error($error);
    $rv;
  }

  method get_connectivity
    is also<
      get-connectivity
      connectivity
    >
  {
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

  method get_network_available is also<get-network-available> {
    so g_network_monitor_get_network_available($!nm);
  }

  method get_network_metered is also<get-network-metered> {
    so g_network_monitor_get_network_metered($!nm);
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_network_monitor_get_type, $n, $t );
  }

}

our subset GNetworkMonitorAncestry is export of Mu
  where GNetworkMonitor | GNetworkMonitorBaseAncestry;

class GIO::NetworkMonitor is GIO::NetworkMonitorBase {
  also does GIO::Roles::NetworkMonitor;

  submethod BUILD ( :initable-object(:$monitor), :$init, :$cancellable ) {
    say "Network Monitor Build! ($monitor/{ $init // '!INIT' }/{ $cancellable // '!CANCEL' })";

    self.setGNetworkMonitor($monitor, :$init, :$cancellable) if $monitor;
  }

  method setGNetworkMonitor (GNetworkMonitorAncestry $_, :$init, :$cancellable) {
    my $to-parent;

    $!nm = do {
      when GNetworkMonitor {
        $to-parent = cast(GNetworkMonitorBase, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GNetworkMonitor, $_);
      }
    }

    say "NM-TP ({ self }): { $to-parent }";

    self.setGNetworkMonitorBase($to-parent, :$init, :$cancellable);
  }

  multi method new (GNetworkMonitorAncestry $monitor, :$ref = True) {
    return Nil unless $monitor;

    my $o = self.bless( :$monitor );
    $o.ref if $ref;
    $o;
  }

}
