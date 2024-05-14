use v6.c;

use Method::Also;

use GIO::Raw::Types;

use GIO::Raw::UnixMounts;

use GLib::Roles::Object;
use GIO::Roles::Icon;
use GLib::Roles::Signals::Generic;

class GIO::UnixMountMonitor { ... }

our subset GUnixMountEntryAncestry is export of Mu
  where GUnixMountEntry | GObject;

class GIO::UnixMount {
  also does GLib::Roles::Object;

  has GUnixMountEntry $!um is implementor;

  submethod BUILD (:$mount-entry) {
    self.setGUnixMountEntry($mount-entry) if $mount-entry;
  }

  method setGUnixMountEntry (GUnixMountEntryAncestry $_) {
    my $to-parent;

    $!um = do {
      when GUnixMountEntry {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GUnixMountEntry, $_);
      }
    }
    self!setObject($to-parent);
  }

  method GIO::Raw::Definitions::GUnixMountEntry
    is also<GUnixMountEntry>
  { $!um }

  method new (GUnixMountEntry $mount-entry, :$ref = True) {
    return Nil unless $mount-entry;

    my $o = self.bless( :$mount-entry );
    $o.ref if $ref;
    $o;
  }

  multi method at (
    GIO::UnixMount:U:
    Str() $path,
          :$raw = False
  ) {
    GIO::UnixMount.at($path, $, :all, :$raw);
  }
  multi method at (
    GIO::UnixMount:U:
    Str() $path,
          $time-read is rw,
          :$all      =  False;
          :$raw      =  False
  ) {
    my guint64 $tr = 0;
    my $m = g_unix_mount_at($path, $tr);
    $time-read = $tr;

    $m = $m ??
      ( $raw ?? $m !! GIO::UnixMount.new($m, :!ref) )
      !!
      Nil;

    $all.not ?? $m !! ($m, $time-read);
  }

  method compare (GUnixMountEntry() $mount2) {
    g_unix_mount_compare($!um, $mount2);
  }

  method copy {
    g_unix_mount_copy($!um);
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_unix_mount_entry_get_type, $n, $t );
  }

  multi method for (
    GIO::UnixMount:U:
    Str() $path,
          :$raw = False
  ) {
    GIO::UnixMount.for($path, $, :all, :$raw);
  }
  multi method for (
    Str() $path,
          $time-read is rw,
          :$all      =  False,
          :$raw      =  False
  ) {
    my guint64 $tr = 0;
    my         $e  = g_unix_mount_for($path, $tr);
    $time-read     = $tr;

    $e = $e ??
      ($raw ?? $e !! GIO::UnixMount.new($e, :!ref) )
      !!
      Nil;

    $all.not ?? $e !! ($e, $tr)
  }

  method free {
    g_unix_mount_free($!um);
  }

  method is_mount_path_system_internal (
    GIO::UnixMount:U:
    Str()             $path
  )
    is also<is-mount-path-system-internal>
  {
    so g_unix_is_mount_path_system_internal($path);
  }

  method is_system_device_path (
    GIO::UnixMount:U:
    Str()             $path
  )
    is also<is-system-device-path>
  {
    so g_unix_is_system_device_path($path);
  }

  method is_system_fs_type (
    GIO::UnixMount:U:
    Str()             $path
  )
    is also<is-system-fs-type>
  {
    so g_unix_is_system_fs_type($path);
  }

  method changed_since (Int() $datetime) is also<changed-since> {
    my uint64 $dt = $datetime;

    so g_unix_mounts_changed_since($dt);
  }

  proto method mounts_get (|)
      is also<
        mounts-get
        get_mounts
        get-mounts
      >
  { * }

  multi method mounts_get (
    :$glist = False,
    :$all   = False,
    :$raw   = False
  ) {
    samewith($, :$glist, :$all, :$raw);
  }
  multi method mounts_get (
    GIO::UnixMount:U:
    $time-read        is rw,
    :$glist           =  False,
    :$all             =  False,
    :$raw             =  False
  ) {
    my guint64 $tr = 0;
    my $ml         = g_unix_mounts_get($tr);

    $time-read = $tr;
    return Nil unless $ml;
    return $ml if     $glist && $raw;

    $ml = GLib::GList.new($ml) but GLib::Roles::ListData[GUnixMountEntry];
    return $ml if $raw;

    my $retVal = $raw ?? $ml.Array
                      !! $ml.Array.map({ GIO::UnixMounts.new($_) });

    $all.not ?? $retVal !! ($retVal, $time-read);
  }

  method get_device_path
    is also<
      get-device-path
      device_path
      device-path
    >
  {
    g_unix_mount_get_device_path($!um);
  }

  method get_fs_type
    is also<
      get-fs-type
      fs_type
      fs-type
    >
  {
    g_unix_mount_get_fs_type($!um);
  }

  method get_mount_path
    is also<
      get-mount-path
      mount_path
      mount-path
    >
  {
    g_unix_mount_get_mount_path($!um);
  }

  method get_options
    is also<
      get-options
      options
    >
  {
    g_unix_mount_get_options($!um);
  }

  method get_root_path
    is also<
      get-root-path
      root_path
      root-path
    >
  {
    g_unix_mount_get_root_path($!um);
  }

  method guess_can_eject is also<guess-can-eject> {
    so g_unix_mount_guess_can_eject($!um);
  }

  method guess_icon (:$raw = False) is also<guess-icon> {
    my $i = g_unix_mount_guess_icon($!um);

    $i ??
      ( $raw ?? $i !! GIO::Roles::Icon.new-icon-obj($i, :!ref) )
      !!
      Nil;
  }

  method guess_name is also<guess-name> {
    g_unix_mount_guess_name($!um);
  }

  method guess_should_display is also<guess-should-display> {
    so g_unix_mount_guess_should_display($!um);
  }

  method guess_symbolic_icon (:$raw = False) is also<guess-symbolic-icon> {
    my $si = g_unix_mount_guess_symbolic_icon($!um);

    $si ??
      ( $raw ?? $si !! GIO::Roles::Icon.new-icon-obj($si, :!ref) )
      !!
      Nil;
  }

  method is_readonly is also<is-readonly> {
    so g_unix_mount_is_readonly($!um);
  }

  method is_system_internal is also<is-system-internal> {
    so g_unix_mount_is_system_internal($!um);
  }

  method monitor_get (:$raw = False)
    is also<
      monitor-get
      get_monitor
      get-monitor
      monitor
    >
  {
    my $mm = g_unix_mount_monitor_get();

    $mm ??
      ( $raw ?? $mm !! GIO::MountMonitor.new($mm, :!ref) )
      !!
      Nil;
  }

}

# BOXED
class GIO::UnixMountPoint {
  has GUnixMountPoint $!mp;

  submethod BUILD (:$mount-point) {
    $!mp = $mount-point;
  }

  method GIO::Raw::Definitions::GUnixMountPoint
    is also<GUnixMountPoint>
  { $!mp }

  method new (GUnixMountPoint $mount-point) {
    $mount-point ?? self.bless( :$mount-point ) !! Nil;
  }

  multi method compare (GUnixMountPoint() $point2) {
    GIO::UnixMount.compare($!mp, $point2);
  }
  multi method compare (
    GUnixMountPoint() $point1,
    GUnixMountPoint() $point2
  ) {
    g_unix_mount_point_compare($point1, $point2);
  }

  method copy (:$raw) {
    my $pc = g_unix_mount_point_copy($!mp);

    $pc ??
      ( $raw ?? $pc !! GIO::UnixMountPoint.new($pc, :!ref) )
      !!
      Nil;
  }

  method free {
    g_unix_mount_point_free($!mp);
  }

  method get_device_path
    is also<
      get-device-path
      device_path
      device-path
    >
  {
    g_unix_mount_point_get_device_path($!mp);
  }

  method get_fs_type
    is also<
      get-fs-type
      fs_type
      fs-type
    >
  {
    g_unix_mount_point_get_fs_type($!mp);
  }

  method get_mount_path
    is also<
      get-mount-path
      mount_path
      mount-path
    >
  {
    g_unix_mount_point_get_mount_path($!mp);
  }

  method get_options
    is also<
      get-options
      options
    >
  {
    g_unix_mount_point_get_options($!mp);
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_unix_mount_point_get_type, $n, $t );
  }

  method guess_can_eject is also<guess-can-eject> {
    so g_unix_mount_point_guess_can_eject($!mp);
  }

  method guess_icon (:$raw = False) is also<guess-icon> {
    my $i = g_unix_mount_point_guess_icon($!mp);

    $i ??
      ( $raw ?? $i !! GIO::Roles::Icon.new-icon-obj($i, :!ref) )
      !!
      Nil;
  }

  method guess_name is also<guess-name> {
    g_unix_mount_point_guess_name($!mp);
  }

  method guess_symbolic_icon (:$raw = False) is also<guess-symbolic-icon> {
    my $si = g_unix_mount_point_guess_symbolic_icon($!mp);

    $si ??
      ( $raw ?? $si !! GIO::Roles::Icon.new-icon-obj($si, :!ref) )
      !!
      Nil;
  }

  method is_loopback is also<is-loopback> {
    so g_unix_mount_point_is_loopback($!mp);
  }

  method is_readonly is also<is-readonly> {
    so g_unix_mount_point_is_readonly($!mp);
  }

  method is_user_mountable is also<is-user-mountable> {
    so g_unix_mount_point_is_user_mountable($!mp);
  }

  method changed_since (GIO::UnixMountPoint:U:) is also<changed-since> {
    g_unix_mount_points_changed_since($!mp);
  }

  proto method points_get(|)
    is also<
      points-get
      get_points
      get-points
    >
  { * }

  multi method points_get (
    GIO::UnixMount:U:
    :$glist           = False,
    :$raw             = False
  ) {
    samewith($, :$glist, :all, :$raw);
  }
  multi method points_get (
    GIO::UnixMount:U:
    $time-read        is rw,
    :$glist           =  False,
    :$all             =  False,
    :$raw             =  False
  ) {
    my guint64 $tr = 0;
    my $pl         = g_unix_mount_points_get($tr);

    $time-read = $tr;
    return Nil unless $pl;
    return $pl if     $glist && $raw;

    $pl = GLib::GList.new($pl) but GLib::Roles::ListData[GUnixMountPoint];
    return $pl if $glist;

    my $retVal = $raw ??
      $pl.Array
      !!
      $pl.Array.map({ GIO::UnixMountPoint.new($_, :!ref) });

    $all.not ?? $retVal !! ($retVal, $time-read);
  }

}

our subset GUnixMountMonitorAncestry is export of Mu
  where GUnixMountMonitor | GObject;

class GIO::UnixMountMonitor {
  also does GLib::Roles::Object;
  also does GLib::Roles::Signals::Generic;

  has GUnixMountMonitor $!mm;

  submethod BUILD (:$monitor) {
    self.setGUnixMountMonitor($monitor) if $monitor;
  }

  method setGUnixMountMonitor (GUnixMountMonitorAncestry $_) {
    my $to-parent;

    $!mm = do {
      when GUnixMountMonitor {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GUnixMountMonitor, $_);
      }
    }
    self!setObject($to-parent);
  }

  method GIO::Raw::Definitions::GUnixMountMonitor
    is also<GUnixMountMonitor>
  { $!mm }

  method new (GUnixMountMonitorAncestry $monitor, :$ref = True) {
    return Nil unless $monitor;

    my $o = self.bless( :$monitor );
    $o.ref if $ref;
    $o;
  }

  # Is originally:
  # GUnixMountMonitor, gpointer --> void
  method mountpoints-changed is also<mountpoints_changed> {
    self.connect($!mm, 'mountpoints-changed');
  }

  # Is originally:
  # GUnixMountMonitor, gpointer --> void
  method mounts-changed is also<mounts_changed> {
    self.connect($!mm, 'mounts-changed');
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_unix_mount_monitor_get_type, $n, $t );
  }

}
