use v6.c;

use Method::Also;
use NativeCall;

use GIO::Raw::Types;
use GIO::Raw::TlsPassword;

use GLib::Roles::Object;

our subset GTlsPasswordAncestry is export of Mu
  where GTlsPassword | GObject;

class GIO::TlsPassword {
  also does GLib::Roles::Object;

  has GTlsPassword $!tp is implementor;

  submethod BUILD (:$tls-password) {
    self.setGTlsPassword($tls-password) if $tls-password;
  }

  method setGTlsPassword (GTlsPasswordAncestry $_) {
    my $to-parent;

    $!tp = do {
      when GTlsPassword {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GTlsPassword, $_);
      }
    }
    self!setObject($to-parent);
  }

  multi method new (GTlsPasswordAncestry $tls-password, :$ref = True) {
    return Nil unless $tls-password;

    my $o = self.bless( :$tls-password );
    $o.ref if $ref;
    $o;
  }
  multi method new (Int() $flags, Str() $description) {
    my GTlsPasswordFlags $f            = $flags;
    my                   $tls-password = g_tls_password_new($f, $description);

    $tls-password ?? self.bless( :$tls-password ) !! Nil;
  }

  method GIO::Raw::Definitions::GTlsPassword
    is also<GTlsPassword>
  { $!tp }

  method description is rw {
    Proxy.new(
      FETCH => sub ($) {
        g_tls_password_get_description($!tp);
      },
      STORE => sub ($, Str() $description is copy) {
        g_tls_password_set_description($!tp, $description);
      }
    );
  }

  method flags is rw {
    Proxy.new(
      FETCH => sub ($) {
        GTlsPasswordFlagsEnum( g_tls_password_get_flags($!tp) );
      },
      STORE => sub ($, Int() $flags is copy) {
        my GTlsPasswordFlags $f = $flags;

        g_tls_password_set_flags($!tp, $f);
      }
    );
  }

  method warning is rw {
    Proxy.new(
      FETCH => sub ($) {
        g_tls_password_get_warning($!tp);
      },
      STORE => sub ($, Str() $warning is copy) {
        g_tls_password_set_warning($!tp, $warning);
      }
    );
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_tls_password_get_type, $n, $t );
  }

  method get_value (Int() $length) is also<get-value> {
    my gsize $l = $length;

    g_tls_password_get_value($!tp, $l);
  }

  method set_value (Str() $value, Int() $length) is also<set-value> {
    my gsize $l = $length;

    g_tls_password_set_value($!tp, $value, $l);
  }

  method set_value_full (
    Str() $value,
    Int() $length,
          &destroy
  )
    is also<set-value-full>
  {
    my gsize $l = $length;

    g_tls_password_set_value_full($!tp, $value, $l, &destroy);
  }

}
