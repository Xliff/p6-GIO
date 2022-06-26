use v6.c;

use Method::Also;

use GIO::Raw::Types;
use GIO::Raw::AppInfo;

use GLib::Roles::Object;
use GLib::Roles::Signals::Generic;

our subset GAppInfoMonitorAncestry is export of Mu
  where GAppInfoMonitor | GObject;

class GIO::AppInfoMonitor {
  also does GLib::Roles::Object;
  also does GLib::Roles::Signals::Generic;

  has GAppInfoMonitor $!aim is implementor;

  submethod BUILD (:$monitor) {
    self.setGAppInfoMonitor($monitor) if $monitor;
  }

  method setGAppInfoMonitor (GAppInfoMonitorAncestry $_) {
    my $to-parent;

    $!aim = do {
      when GAppInfoMonitor {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GAppInfoMonitor, $_);
      }
    }
    self!setObject($to-parent);
  }

  method GIO::Raw::Definitions::GAppInfoMonitor
    is also<GAppInfoMonitor>
  { $!aim }

  method new (GAppInfoMonitorAncestry $monitor, :$ref = True)
    is also<new-appinfomonitor-obj>
  {
    return Nil unless $monitor;

    my $o = self.bless( :$monitor );
    $o.ref if $ref;
    $o;
  }

  method monitor_get (
    GIO::AppInfoMonitor:U:
    :$raw                  = False
  )
    is also<
      monitor-get
      get
    >
  {
    my $m = g_app_info_monitor_get();

    $m ??
      ( $raw ?? $m !! GIO::AppInfoMonitor.new($m) )
      !!
      Nil;
  }

  # Is originally:
  # GAppInfoMonitor, gpointer --> void
  method changed {
    self.connect($!aim, 'changed');
  }

  method monitor_get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_app_info_monitor_get_type, $n, $t );
  }
}
