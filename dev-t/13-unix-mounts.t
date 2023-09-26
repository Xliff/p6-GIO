use v6.c;

use Test;

use GIO::UnixMount;

my @type-tests = [Z](
  <tmpfs ext4 cifs nfs nfs4 smbfs>,
  (True, False, False, False, False)
);

my @system-tests = <devpts /> Z (True, False);

for @type-tests {
  my $r = GIO::UnixMount.is-system-fs-type( .[0] );
  my $msg = "FS type {.[0]} { $r ?? 'is' !! 'is not' } a system fs type";
  .[1] ?? ok $r,  $msg 
       !! nok $r, $msg;
}

for @system-tests {
  my $r = GIO::UnixMount.is-system-device-path( .[0] );
  my $msg = "FS type {.[0]} { $r ?? 'is' !! 'is not' } a system device path";
  .[1] ?? ok $r,  $msg 
       !! nok $r, $msg;
}
