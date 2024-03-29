use v6.c;

use Test;

use GIO::Raw::Types;

use GLib::Env;
use GLib::MainContext;
use GLib::MainLoop;
use GLib::Signal;
use GLib::Source;
use GIO::InetAddress;
use GIO::InetAddressMask;
use GIO::InetSocketAddress;

use GIO::Roles::NetworkMonitor;
use GIO::Roles::NetworkMonitorBase;

class TestAddress {
  has $.string  is rw;
  has $.address is rw;

  submethod BUILD (:$!string) { }

  method new ($string) {
    self.bless(:$string);
  }
}

class TestMask {
  has $.mask-string is rw;
  has $.mask        is rw;
  has @.addresses;

  submethod BUILD (:$!mask-string, :$!mask, :@!addresses ) { }

  multi method new ($mask-string, $mask, @addresses) {
    self.bless( :$mask-string, :$mask, :@addresses);
  }
  multi method new ($mask-string, @addresses) {
    self.bless( :$mask-string, :@addresses);
  }
}

my @net127addrs = <
  127.0.0.1
  127.0.0.2
  127.0.0.255
  127.0.1.0
  127.0.255.0
  127.0.255.0
  127.255.255.255
>;
@net127addrs .= map({ TestAddress.new($_) });
my $net127 = TestMask.new('127.0.0.0/8', @net127addrs);

my @net10addrs = <
  10.0.0.1
  10.0.0.2
  10.0.0.255
>;
@net10addrs .= map({ TestAddress.new($_) });
my $net10 = TestMask.new('10.0.0.0/24', @net10addrs);

my @net192addrs = <
  192.168.0.1
  192.168.0.2
  192.168.0.255
  192.168.1.0
  192.168.15.0
>;
@net192addrs .= map({ TestAddress.new($_) });
my $net192 = TestMask.new('192.168.0.0/20', @net192addrs);

my @netlocal6addrs = <
  ::1
>;
@netlocal6addrs .= map({ TestAddress.new($_) });
my $netlocal6 = TestMask.new('::1/128', @netlocal6addrs);

my @netfe80addrs = <
  fe80::
  fe80::1
  fe80::21b:77ff:fea2:972a
>;
@netfe80addrs .= map({ TestAddress.new($_) });
my $netfe80 = TestMask.new('fe80::/64', @netfe80addrs);

my @unmatched = <
  10.0.1.0
  10.0.255.0
  10.255.255.255
  192.168.16.0
  192.168.255.0
  192.169.0.0
  192.255.255.255
  ::2
  1::1
  fe80::1:0:0:0:0
  fe80:8000::0:0:0:0
>;
@unmatched .= map({ TestAddress.new($_) });

my @all-net-addrs = (
  @net127addrs, @net10addrs, @net192addrs, @netlocal6addrs, @netfe80addrs,
  @unmatched
);
my @all-nets = ($net127, $net10, $net192, $netlocal6, $netfe80);

my ($ip4-default, $ip6-default);

sub assert-signals (
  $should-emit-notify         = False,
  $should-emit-changed        = False,
  $expected-network-available = False
) {
  my ($emit-notify, $emit-changed) = False xx 2;

  #$*monitor.notify('network-available').tap(-> *@a { $emit-notify  = True });
  my $nna = GLib::Signal.connect(
    $*monitor,
    'notify::network-available',
    -> *@ { $emit-notify = True }
  );
  $*monitor.network-changed            .tap(-> *@a { $emit-changed = True });

  diag $*monitor.^attributes.map( *.name );

  diag '--- preiteration';
  GLib::MainContext.iteration;
  diag '--- postiteration';
  GLib::Signal.handler_disconnect($*monitor, $nna);
  #$*monitor.disconnect-object-signal('notify::network-available');
  $*monitor.disconnect-network-monitor-signal('network-changed');

  is $emit-notify,                    $should-emit-notify,         'Notify signal operated correctly';
  is $emit-changed,                   $should-emit-changed,        'Network Change signal operated correctly';
  is $*monitor.get_network_available, $expected-network-available, 'Expected network detected';
}

class CanReachData {
  has $.monitor             is rw;
  has $.loop                is rw;
  has $.sockaddr            is rw;
  has $.should-be-reachable is rw;
}

sub reach-cb ($d, $r) {
  my $reachable = $d.monitor.can_reach_finish($r);

  $d.should-be-reachable ?? ok no-error, 'No error during reach callback'
                         !! ok $ERROR,   'Error detected during reach callback';

  is $reachable, $d.should-be-reachable, 'Reachable return matches expected value';
  $d.loop.quit;
}

sub test-reach-async ($d) {
  CATCH { default { .message.say; .backtrace.summary.say } }
  $d.monitor.can_reach_async($d.sockaddr, -> *@a { reach-cb($d, @a[1]) });
  G_SOURCE_REMOVE
}

sub run-tests (@addresses, $should-be-reachable) {
  my $data      = CanReachData.new;
  $data.monitor = $*monitor;
  $data.loop    = GLib::MainLoop.new;

  for @addresses {
    last unless .address;
    diag .address.to-string;
    $data.sockaddr = GIO::InetSocketAddress.new( .address );

    my $reachable = $*monitor.can_reach($data.sockaddr);
    $data.should-be-reachable = $should-be-reachable;
    GLib::Source.idle-add(-> $ --> gboolean {
      test-reach-async($data)
    });
    $data.loop.run;

    $data.sockaddr.unref;
    is $reachable, $should-be-reachable, 'Returned reachable matches expected value';
    if $should-be-reachable {
      ok  no-error,                      'No error detected with mandatory reachable'
    } else {
      ok  $ERROR,                        'Error detection as expected with no mandatory reachable';
    }
  }
  $data.loop.unref;
}

sub test-default {
  my $m = GIO::NetworkMonitor.get_default;
  ok $m ~~ GIO::Roles::NetworkMonitor, 'Default Monitor object is the correct type';

  my $*monitor = GIO::NetworkMonitorBase.new_initable;
  nok $ERROR,                          'Initializing Monitor as an initable works with no errors';

  # Tested initable, now we switch back to the created GIO::NetworkMonitor because
  # that's what these tests WANT.
  $*monitor = $m;

  for @all-net-addrs -> $a {
    run-tests($a, True) for $a;
  }

  assert-signals;
  $*monitor.unref;
}

sub remove-defaults {
  $*monitor.remove_network($ip4-default);
  assert-signals(False, True, True);

  $*monitor.remove_network($ip6-default);
  assert-signals(True, True, False);
}

sub test-remove-default {
  my $*monitor = GIO::NetworkMonitor.new_initable;
  nok $ERROR,                          'Initializing Monitor as an initable works with no errors';

  diag "MN: { $*monitor.^name }";

  #$*monitor = GIO::NetworkMonitor.get_default;

  assert-signals(False, False, True);
  # remove-defaults;
  #
  # run-tests($_, True) for @all-net-addrs;
  #
  $*monitor.unref;
}

sub test-add-networks {
  my $*monitor = GIO::NetworkMonitorBase.new_initable;
  nok $ERROR,                          'Initializing Monitor as an initable works with no errors';

  $*monitor = GIO::NetworkMonitor.get_default;

  assert-signals(False, False, True);
  remove-defaults;

  for @all-nets.head(* - 1).kv -> $k, $v {
    $*monitor.add_network($v.mask);
    assert-signals(False, True, False);

    for @all-net-addrs.kv -> $nk, $n {
      run-tests($n, ($nk <= $k).so);
    }
  }

  $*monitor.unref;
}

sub test-remove-networks {
  my $*monitor = GIO::NetworkMonitorBase.new_initable;
  nok $ERROR,                          'Initializing Monitor as an initable works with no errors';

  $*monitor = GIO::NetworkMonitor.get_default;

  assert-signals(False, False, True);
  remove-defaults;

  for @all-nets.head(* - 1).kv -> $k, $v {
    assert-signals(False, True, False);
    $*monitor.add_network($v.mask);
  }

  for @all-net-addrs.kv -> $nk, $na {
    run-tests($na, $na !=:= @unmatched) for $na;
  }

  for @all-nets.head(* - 1).kv -> $k, $v {
    $*monitor.remove-network($v.mask);
    for @all-net-addrs.kv -> $nk, $na {
      run-tests(
        $na,
        $na !=:= @unmatched ?? ($nk <= $k).so.not !! False
      ) for $na
    }
  }

  $*monitor.unref;
}

sub init-test ($tm) {
  $tm.mask = GIO::InetAddressMask.new-from-string($tm.mask-string);
  nok $ERROR,                        "Address mask created successfully from '{ $tm.mask }'";

  for $tm.addresses {
    .address = GIO::InetAddress.new_from_string(.string);
    my $e-family = .string.contains(':') ?? G_SOCKET_FAMILY_IPV6
                                         !! G_SOCKET_FAMILY_IPV4;
    is .address.family, $e-family,   "'{ .string } belongs to the expected family { $e-family }";
  }
}

sub cleanup-test ($tm) {
  $tm.mask.unref;
  .address.unref for $tm.addresses;
}

sub do-watch-network {
  my $monitor = GIO::NetworkMonitor.get_default;

  sub on-network-changed (*@a) {
    diag "Network is { @a[1] ?? 'up' !! 'down' }";
  }

  sub on-connectivity-changed (*@a) {
    diag "Connectivity is { $monitor.connectivity }";
  }

  sub on-metered-changed (*@a) {
    diag "Metered is { $monitor.network-metered }";
  }

  diag "Monitoring via { $monitor.objectType.name }";
  $monitor.network-changed.tap(-> *@a {
    CATCH { default { .message.say; .backtrace.summary.say } }
    &on-network-changed(|@a);
  });
  $monitor.notify('connectivity').tap(-> *@a {
    CATCH { default { .message.say; .backtrace.summary.say } }
    &on-connectivity-changed(|@a);
  });
  $monitor.notify('network-metered').tap(-> *@a {
    CATCH { default { .message.say; .backtrace.summary.say } }
    &on-metered-changed(|@a);
  });
  on-network-changed($, $monitor.network-available);
  on-connectivity-changed();
  on-metered-changed();

  my $loop = GLib::MainLoop.new;
  $loop.run;
}

sub MAIN (Bool :$watch) {
  if $watch {
    do-watch-network;
    exit 0;
  }

  GLib::Env.setenv('GIO_USE_PROXY_RESOLVER', 'dummy', True);

  subtest 'Initialization',  { init-test($_) for @all-nets }

  $ip4-default = GIO::InetAddressMask.new-from-string('0.0.0.0/0');
  $ip6-default = GIO::InetAddressMask.new-from-string('::/0');

  subtest 'Default',         { test-default         }
  subtest 'Remove Default',  { test-remove-default  }
  # subtest 'Add Networks',    { test-add-networks    }
  # subtest 'Remove Networks', { test-remove-networks }

  # cleanup-test($_) for @all-nets.head(* - 1);
  #.unref for $ip4-default, $ip6-default;
}
