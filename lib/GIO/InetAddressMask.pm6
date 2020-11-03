use v6.c;

use NativeCall;
use Method::Also;

use GIO::Raw::Types;
use GIO::Raw::InetAddressMask;

use GIO::InetAddress;

use GLib::Roles::Object;

our subset GInetAddressMaskAncestry is export of Mu
  where GInetAddressMask | GObject;

class GIO::InetAddressMask {
  also does GLib::Roles::Object;

  has GInetAddressMask $!iam is implementor;

  submethod BUILD (:$mask) {
    self.setGInetAddressMask($mask) if $mask;
  }

  method setGInetAddressMask (GInetAddressMaskAncestry $_) {
    my $to-parent;

    $!iam = do {
      when GInetAddressMask {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GInetAddress, $_);
      }
    }
    self.roleInit-Object;
  }

  method GIO::Raw::Definitions::GInetAddressMask
    is also<GInetAddressMask>
  { $!iam }

  multi method new (GInetAddressMaskAncestry $mask, :$ref = True) {
    return Nil unless $mask;

    my $o = self.bless( :$mask );
    $o.ref if $ref;
    $o;
  }
  multi method new (
    GInetAddress()          $addr,
    Int()                   $length,
    CArray[Pointer[GError]] $error   = gerror
  ) {
    my guint $l = $length;

    clear_error;
    my $mask = g_inet_address_mask_new($addr, $l, $error);
    set_error($error);

    $mask ?? self.bless( :$mask ) !! Nil;
  }

  multi method new(
    Str()                   $mask_string,
    CArray[Pointer[GError]] $error        =  gerror,
                            :$string      is required
  ) {
    GIO::InetAddressMask.new_from_string($mask_string, $error);
  }
  method new_from_string (
    Str() $mask_string,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<new-from-string>
  {
    clear_error;
    my $mask = g_inet_address_mask_new_from_string($mask_string, $error);
    set_error($error);

    $mask ?? self.bless( :$mask ) !! Nil;
  }

  method equal (GInetAddressMask() $mask2) {
    so g_inet_address_mask_equal($!iam, $mask2);
  }

  method get_address (:$raw = False)
    is also<
      get-address
      address
    >
  {
    my $a = g_inet_address_mask_get_address($!iam);

    $a ??
      ( $raw ?? $a !! GIO::InetAddress.new($a, :!ref) )
      !!
      Nil;
  }

  method get_family
    is also<
      get-family
      family
    >
  {
    GSocketFamilyEnum( g_inet_address_mask_get_family($!iam) );
  }

  method get_length
    is also<
      get-length
      length
    >
  {
    g_inet_address_mask_get_length($!iam);
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_inet_address_mask_get_type, $n, $t );
  }

  method matches (GInetAddress() $address) {
    so g_inet_address_mask_matches($!iam, $address);
  }

  method to_string
    is also<
      to-string
      Str
    >
  {
    g_inet_address_mask_to_string($!iam);
  }

}
