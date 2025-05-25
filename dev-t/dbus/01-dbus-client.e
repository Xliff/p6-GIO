use v6.c;

use GIO::DBus::Proxy;
use GLib::Variant;
use JSON::GLib::Variant;

sub test-ping {
  say 'Calling `Ping`...';
  
  my $response = JSON::GLib::Variant.serialize-data(
    $*p.call-sync('Ping')
  );

  say "The server answered with: { $response // '»NORESP«' }";
}

sub MAIN {
  my $*p = GIO::DBus::Proxy.new-sync(
    GIO::DBus::Connection.get-sync,
    name => 'org.example.TestServer',
    '/org/example/TestObject',
    'org.example.TestInterface',
  );

  test-ping
}
