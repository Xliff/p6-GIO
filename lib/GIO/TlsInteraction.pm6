use v6.c;

use Method::Also;
use NativeCall;

use GIO::Raw::Types;
use GIO::Raw::TlsInteraction;

use GLib::Roles::Object;

our subset GTlsInteractionAncestry is export of Mu
  where GTlsInteraction | GObject;

class GIO::TlsInteraction {
  also does GLib::Roles::Object;

  has GTlsInteraction $!ti is implementor;

  submethod BUILD (:$tls-interaction) {
    self.setGTlsInteraction($tls-interaction) if $tls-interaction;
  }

  method setGTlsInteraction (GTlsInteractionAncestry $_) {
    my $to-parent;

    $!ti = do {
      when GTlsInteraction {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GTlsInteraction, $_);
      }
    }
    self!setObject($to-parent);
  }

  method GIO::Raw::Definitions::GTlsInteraction
    is also<GTlsInteraction>
  { $!ti }

  method new (GTlsInteractionAncestry $tls-interaction, :$ref = True) {
    return Nil unless $tls-interaction;

    my $o = self.bless( :$tls-interaction );
    $o.ref if $ref;
    $o;
  }

  method ask_password (
    GTlsPassword()          $password,
    GCancellable()          $cancellable = GCancellable,
    CArray[Pointer[GError]] $error       = gerror
  )
    is also<ask-password>
  {
    clear_error;
    my $ir = g_tls_interaction_ask_password(
      $!ti,
      $password,
      $cancellable,
      $error
    );
    set_error($error);

    GTlsInteractionResult($ir);
  }

  proto method ask_password_async (|)
      is also<ask-password-async>
  { * }

  multi method ask_password_async (
    GTlsPassword() $password,
                   &callback,
    gpointer       $user_data = gpointer
  ) {
    samewith($password, GCancellable, &callback, $user_data);
  }
  multi method ask_password_async (
    GTlsPassword()      $password,
    GCancellable()      $cancellable,
                        &callback,
    gpointer            $user_data    = gpointer
  ) {
    g_tls_interaction_ask_password_async(
      $!ti,
      $password,
      $cancellable,
      &callback,
      $user_data
    );
  }

  method ask_password_finish (
    GAsyncResult()          $result,
    CArray[Pointer[GError]] $error   = gerror
  )
    is also<ask-password-finish>
  {
    clear_error;
    my $ir = g_tls_interaction_ask_password_finish($!ti, $result, $error);
    set_error($error);

    GTlsInteractionResult($ir);
  }

  method get_type is also<get-type> {
    my ($n, $t);

    unstable_get_type( self.^name, &g_tls_interaction_get_type, $n, $t );
  }

  method invoke_ask_password (
    GTlsPassword()          $password,
    GCancellable()          $cancellable = GCancellable,
    CArray[Pointer[GError]] $error       = gerror
  )
    is also<invoke-ask-password>
  {
    clear_error;
    my $ir = g_tls_interaction_invoke_ask_password(
      $!ti,
      $password,
      $cancellable,
      $error
    );
    set_error($error);

    GTlsInteractionResult($ir);
  }

  method invoke_request_certificate (
    GTlsConnection()        $connection,
    Int()                   $flags,
    GCancellable()          $cancellable  = GCancellable,
    CArray[Pointer[GError]] $error        = gerror
  )
    is also<invoke-request-certificate>
  {
    my GTlsCertificateRequestFlags $f = $flags;

    clear_error;
    my $ir = g_tls_interaction_invoke_request_certificate(
      $!ti,
      $connection,
      $flags,
      $cancellable,
      $error
    );
    set_error($error);

    GTlsInteractionResult($ir);
  }

  method request_certificate (
    GTlsConnection()        $connection,
    Int()                   $flags,
    GCancellable()          $cancellable = GCancellable,
    CArray[Pointer[GError]] $error       = gerror
  )
    is also<request-certificate>
  {
    my GTlsCertificateRequestFlags $f = $flags;

    clear_error;
    my $ir = g_tls_interaction_request_certificate(
      $!ti,
      $connection,
      $f,
      $cancellable,
      $error
    );
    set_error($error);

    GTlsInteractionResult($ir);
  }

  proto method request_certificate_async (|)
      is also<request-certificate-async>
  { * }

  multi method request_certificate_async (
    GTlsConnection()    $connection,
    Int()               $flags,
                        &callback,
    gpointer            $user_data   = gpointer
  ) {
    samewith($connection, $flags, GCancellable, &callback, $user_data);
  }
  multi method request_certificate_async (
    GTlsConnection()    $connection,
    Int()               $flags,
    GCancellable()      $cancellable,
                        &callback,
    gpointer            $user_data    = gpointer
  ) {
    my GTlsCertificateRequestFlags $f = $flags;

    g_tls_interaction_request_certificate_async(
      $!ti,
      $connection,
      $f,
      $cancellable,
      &callback,
      $user_data
    );
  }

  method request_certificate_finish (
    GAsyncResult()          $result,
    CArray[Pointer[GError]] $error   = gerror
  )
    is also<request-certificate-finish>
  {
    g_tls_interaction_request_certificate_finish($!ti, $result, $error);
  }

}
