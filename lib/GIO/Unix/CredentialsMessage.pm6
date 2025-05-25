use v6.c;

use Method::Also;

use GIO::Raw::Types;
use GIO::Raw::UnixCredentialsMessage;

use GIO::SocketControlMessage;
use GIO::Credentials;

our subset GUnixCredentialsMessageAncestry is export of Mu
  where GUnixCredentialsMessage | GSocketControlMessageAncestry;

class GIO::Unix::CredentialsMessage is GIO::SocketControlMessage {
  has GUnixCredentialsMessage $!cm is implementor;

  submethod BUILD (:$cred-message) {
    self.setUnixCredentialsMessage($cred-message) if $cred-message;
  }

  method setUnixCredentialsMessage (GUnixCredentialsMessageAncestry $_) {
    my $to-parent;

    $!cm = do {
      when GUnixCredentialsMessage {
        $to-parent = cast(GSocketControlMessage, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GUnixCredentialsMessage, $_);
      }
    }
    self.setGSocketControlMessage($to-parent);
  }

  method GIO::Raw::Definitions::GUnixCredentialsMessage
    is also<GUnixCredentialsMessage>
  { $!cm }

  multi method new (
    GUnixCredentialsMessageAncestry $cred-message,
                                    :$ref          = True
  ) {
    return Nil unless $cred-message;

    my $o = self.bless( :$cred-message );
    $o.ref if $ref;
    $o;
  }
  multi method new {
    my $cred-message = g_unix_credentials_message_new();

    $cred-message ?? self.bless( :$cred-message ) !! Nil;
  }

  method new_with_credentials (GCredentials $credentials)
    is also<new-with-credentials>
  {
    my $cred-message = g_unix_credentials_message_new_with_credentials(
      $credentials
    );

    $cred-message ?? self.bless( :$cred-message ) !! Nil;
  }

  method get_credentials (:$raw = False)
    is also<
      get-credentials
      credentials
    >
  {
    my $c = g_unix_credentials_message_get_credentials($!cm);

    $c ??
      ( $raw ?? $c !! GIO::Credentials.new($c, :!ref) )
      !!
      Nil;
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type(
      self.^name,
      &g_unix_credentials_message_get_type,
      $n,
      $t
    );
  }

  method is_supported is also<is-supported> {
    so g_unix_credentials_message_is_supported();
  }

}
