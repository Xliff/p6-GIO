use v6.c;

use Test;

use GIO::Raw::Types;

use GIO::Roles::NetworkMonitor;

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

sub assert-signals (
  $monitor,
  $should-emit-notify,
  $should-emit-changed,
  $expected-network-available
) {
  my ($emit-notify, $emit-changed) = False xx 2;

  $monitor.notify('network-available').tap(-> *@a { $emit-notify = True });
  $monitor.network-changed            .tap(-> *@a { $emit-changed = True });

  GLib::MainContext.iteration;
  $monitor.disconnect-object-signal('notify::network-available');
  $monitor.disconnect-network-monitor-signal('network-changed');

  is $emit-notify,                   $should-emit-notify,         'Notify signal operated correctly';
  is $emit-changed,                  $should-emit-changed,        'Network Change signal operated correctly';
  is $monitor.get-network-availalbe, $expected-network-available, 'Expected network detected';
}

class CanReachData {
  has $.monitor             is rw;
  has $.loop                is rw;
  has $.sockaddr            is rw;
  has $.should-be-reachable is rw;
}

sub reach-cb ($d, $r) {
  my $reachable = $d.monitor.can-reach-finish($r);

  $d.should-be-reachable ?? ok no-error, 'No error during reach callback'
                         !! ok $ERROR,   'Error detected during reach callback';

  is $reachable, $d.should-be-reachable, 'Reachable return matches expected value';
  $d.loop.quit;
}

sub test-reach-async ($d) {
  $d.monitor.can-reach-async($d.sockaddr, -> *@a { reach-cb($d, @a[1]) });
  G_SOURCE_REMOVE
}

sub run-tests ($monitor, @addresses, $should-be-reachable) {
  my $data   = CanReachData.new;
  $data.loop = GLib::MainLoop.new;

  for @addresses {
    $data.sockaddr = GIO::SocketAddress.new( .address );

    my $reachable = $monitor.can-reach($data.sockaddr);
    $data.should-be-reachable = $should-be-reachable;
    GLib::Timeout.idle-add(-> $ { test-reach-async($data) });
    $data.loop.run;

    $data.sockaddr.unref;
    is $reachable, $should-be-reachable, 'Returned reachable matches expected value';
    if $should-be-reachable {
      ok  no-error,                      'No error detected with mandatort reachable'
    } else {
      ok  $ERROR,                        'Error detection as expected with no mandatory reachable';
    }
  }
  $data.loop.unref;
}

sub test-default {
  my $monitor = GIO::NetworkMonitor.get_default;
  ok $monitor ~~ GIO::Roles::NetworkMonitor, 'Default Monitor object is the correct type';

  # 2020 10 16 -- Depends on missing NetworkMonitorBase. Further work deferred until it exists.

}
