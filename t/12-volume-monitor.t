use v6.c;

use Test;

use GIO::Raw::Types;

use GLib::Env;
use GIO::VolumeMonitor;

use GIO::Roles::Drive;
use GIO::Roles::Mount;
use GIO::Roles::Volume;

sub do-mount-tests ($do, $vo, $mo) {
  #diag "——— Mount tests START for '{ $do.get_name // 'NODRIVE' }:{ $vo.get_name // 'NOVOL' }:{ $mo.get_name // 'NOMNT' }'";

  ok $mo.get_name,               "Mount has a name: '{ $mo.get_name }'";
  .unref with $vo;

  ok $mo.get_drive.equals($do),  'Mount drive is the same as the supplied drive';
  nok $mo.get_drive.equals($vo), 'Mount and volume DO NOT equal';
  .unref with $do;

  if $mo.get_uuid -> $u {
    my $mount = $*monitor.get-mount-for-uuid($u);
    ok $mount.equals($mo),       "Mount at '$u' is the same as the supplied mount";
    $mount.unref;
  }

  #diag "——— Mount tests END for '{ $do.get_name // 'NODRIVE' }:{ $vo.get_name // 'NOVOL' }:{ $mo.get_name // 'NOMNT' }'";
}

sub do-volume-tests ($do, $vo) {
  #diag "——— Volume tests START for '{ $do.get_name // 'NODRIVE' }:{ $vo.get_name // 'NOVOL' }'";

  ok $vo.get_name,               "Volume has a name: '{ $vo.get_name }'";
  ok $vo.get_drive.equals($do),  'Volume drive is the same as the supplied drive';

  if $vo.get_mount -> $m {
    do-mount-tests($do, $vo, $m);
    $m.unref;
  }

  if $vo.get_uuid -> $u {
    my $volume = $*monitor.get-volume-for-uuid($u);
    ok $volume.equals($vo),      "Volume at '$u' is the same as the supplied volume";
    $volume.unref;
  }

  #diag "——— Volume tests END for '{ $do.get_name // 'NODRIVE' }:{ $vo.get_name // 'NOVOL' }'";
}

sub do-drive-tests ($do) {
  #diag "——— Drive tests START for '{ $do.get_name // 'NODRIVE' }'";
  ok $do.get_name,               "Drive has a name: '{ $do.get_name }'";

  if $do.has_volumes {
    do-volume-tests($do, $_) for $do.get_volumes;
  }
  # cw: Ideally, $do.get-volumes will free the GList so no need for g_list-free_full
  #diag "——— Drive tests END FOR '{ $do.get_name // 'NODRIVE' }'";
}

sub test-connected-drives {
  do-drive-tests($_) for $*monitor.connected-drives;
}

sub test-volumes {
  for $*monitor.get_volumes -> $v {
    if $v.get_drive -> $d {
      do-volume-tests($d, $v);
      $d.unref;
    }
  }
}

sub test-mounts {
  for $*monitor.mounts -> $m {
    my ($d, $v) = ($m.get_drive, $m.get_volume);
    if $d && $v {
      do-mount-tests($d, $v, $m);
      .unref with $d;
      .unref with $v;
    }
  }
}

sub MAIN {
  GLib::Env.setenv('GIO_USE_VFS', 'local');

  my $*monitor = GIO::VolumeMonitor.get;

  test-connected-drives;
  test-volumes;
  test-mounts;
}
