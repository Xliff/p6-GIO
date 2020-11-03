use v6.c;

use Method::Also;

use NativeCall;

use GIO::Raw::Types;

use GLib::Roles::Object;
use GIO::Roles::Initable;

role GIO::Roles::NetworkMonitorBase {
  has GNetworkMonitorBase $!nmb;

  method roleInit-NetworkMonitorBase is also<roleInit_NetworkMonitorBase> {
    return if $!nmb;

    my \i = findProperImplementor(self.^attributes);
    $!nmb = cast( GNetworkMonitorBase, i.get_value(self) );
  }

  method add_network (GInetAddressMask() $network) is also<add-network> {
    g_network_monitor_base_add_network($!nmb, $network);
  }

  method remove_network (GInetAddressMask() $network) is also<remove-network> {
    g_network_monitor_base_remove_network($!nmb, $network);
  }

  proto method set_networks (|)
    is also<set-networks>
  { *}

  multi method set_networks (@networks) {
    samewith(
      GLib::Roles::TypedBuffer[GInetAddressMask].new(@networks).p,
      @networks.elems;
    );
  }
  multi method set_networks (
    CArray[Pointer[GInetAddressMask]] $networks,
    Int()                             $length
  ) {
    samewith(
      cast(Pointer, $networks),
      $length
    );
  }
  multi method set_networks (Pointer $networks, Int() $length) {
    my gint $l = $length;
    g_network_monitor_base_set_networks($!nmb, $networks, $l);
  }

}

our subset GNetworkMonitorBaseAncestry is export of Mu
  where GNetworkMonitorBase | GInitable | GObject;

class GIO::NetworkMonitorBase {
  also does GLib::Roles::Object;
  also does GIO::Roles::Initable;
  also does GIO::Roles::NetworkMonitorBase;

  submethod BUILD (:$monitor-base, :$init, :$cancellable) {
    self.setGNetworkMonitorBase($monitor-base, :$init, :$cancellable)
      if $monitor-base;
  }

  method setGNetworkMonitorBase (
    GNetworkMonitorBaseAncestry $_,
                                :$init,
                                :$cancellable
  ) {
    my $to-parent;

    $!nmb = do {
      when GNetworkMonitorBase {
        $to-parent = cast(GObject, $_);
        $_;
      }

      when GInitable {
        $to-parent = cast(GObject, $_);
        $!i = $_;
        cast(GNetworkMonitorBase, $_);
      }

      default {
        $to-parent = $_;
        cast(GNetworkMonitorBase, $_);
      }
    }
    self!setObject($to-parent);
    self.roleInit-Initable($init, $cancellable);
  }

  multi method new (GNetworkMonitorBaseAncestry $monitor-base, :$ref = True) {
    return Nil unless $monitor-base;

    my $o = self.bless( :$monitor-base );
    $o.ref if $ref;
    $o;
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_network_monitor_base_get_type, $n, $t );
  }

}

### /usr/src/glib/gio/gnetworkmonitorbase.h

sub g_network_monitor_base_add_network (
  GNetworkMonitorBase $monitor,
  GInetAddressMask    $network
)
  is native(gio)
  is export
{ * }

sub g_network_monitor_base_get_type ()
  returns GType
  is native(gio)
  is export
{ * }

sub g_network_monitor_base_remove_network (
  GNetworkMonitorBase $monitor,
  GInetAddressMask    $network
)
  is native(gio)
  is export
{ * }

sub g_network_monitor_base_set_networks (
  GNetworkMonitorBase $monitor,
  Pointer             $networks,
  gint                $length
)
  is native(gio)
  is export
{ * }

# our %GIO::NetworkMonitorBase::RAW-DEFS;
# for MY::.pairs {
#   %GIO::NetworkMonitorBase::RAW-DEFS{.key} := .value
#     if .key.starts-with('&g_network_monitor_base_');
# }
