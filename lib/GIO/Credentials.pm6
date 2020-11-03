use v6.c;

use Method::Also;

use NativeCall;

use GIO::Raw::Types;
use GIO::Raw::Credentials;

use GLib::Roles::Object;

our subset GCredentialsAncestry is export of Mu
  where GCredentials | GObject;

class GIO::Credentials {
  also does GLib::Roles::Object;

  has GCredentials $!c is implementor;

  submethod BUILD (:$credentials) {
    self.setGCredentials($credentials) if $credentials;
  }

  method setGCredentials (GCredentialsAncestry $_) {
    my $to-parent;

    $!c = do {
      when GCredentials {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GCredentials, $_);
      }
    }
    self!setObject($to-parent);
  }

  method GIO::Raw::Definitions::GCredentials
    is also<GCredentials>
  { $!c }

  multi method new (GCredentials $credentials, :$ref = True) {
    return Nil unless $credentials;

    my $o = self.bless( :$credentials );
    $o.ref if $ref;
    $o;
  }
  multi method new {
    my $credentials = g_credentials_new();

    $credentials ?? self.bless( :$credentials ) !! Nil;
  }

  method get_native (Int() $native_type) is also<get-native> {
    my GCredentialsType $nt = $native_type;

    g_credentials_get_native($!c, $nt);

  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_credentials_get_type, $n, $t );
  }

  method get_unix_pid (
    CArray[Pointer[GError]] $error = gerror
  )
    is also<get-unix-pid>
  {
    clear_error;
    my $p = g_credentials_get_unix_pid($!c, $error);
    set_error($error);
    $p;
  }

  method get_unix_user (
    CArray[Pointer[GError]] $error = gerror
  )
    is also<get-unix-user>
  {
    clear_error;
    my $u = g_credentials_get_unix_user($!c, $error);
    set_error($error);
    $u;
  }

  method is_same_user (
    GCredentials()          $other_credentials,
    CArray[Pointer[GError]] $error              = gerror
  )
    is also<is-same-user>
  {
    clear_error;
    my $su = so g_credentials_is_same_user($!c, $other_credentials, $error);
    set_error($error);
    $su;
  }

  method set_native (Int() $native_type, gpointer $native)
    is also<set-native>
  {
    my GCredentialsType $nt = $native_type;

    g_credentials_set_native($!c, $nt, $native);
  }

  method set_unix_user (
    uid_t                   $uid,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<set-unix-user>
  {
    clear_error;
    my $rv = so g_credentials_set_unix_user($!c, $uid, $error);
    set_error($error);
    $rv;
  }

  method to_string
    is also<
      to-string
      Str
    >
  {
    g_credentials_to_string($!c);
  }

}
