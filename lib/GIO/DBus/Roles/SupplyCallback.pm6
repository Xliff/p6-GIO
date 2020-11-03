use v6.c;

use GIO::Raw::Types;

role GIO::DBus::Roles::SupplyCallback {
  has $!supply;

  method tap(|c) {
    die "{ ::?CLASS.^name } not created with :\$supply" unless $!supply;
    state $s = $!supply.Supply;
    $s.tap(|c);
  }

}
