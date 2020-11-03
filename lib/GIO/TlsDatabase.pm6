use v6.c;

use Method::Also;
use NativeCall;

use GIO::Raw::Types;
use GIO::Raw::TlsDatabase;

use GIO::TlsCertificate;

use GLib::Roles::Object;

our subset GTlsDatabaseAncestry is export of Mu
  where GTlsDatabase | GObject;

class GIO::TlsDatabase {
  also does GLib::Roles::Object;

  has GTlsDatabase $!td is implementor;

  submethod BUILD (:$tls-database) {
    self.setGTlsDatabase($tls-database) if $tls-database;
  }

  method setGtlsDatabase (GTlsDatabaseAncestry $_) {
    my $to-parent;

    $!td = do {
      when GTlsDatabase {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GTlsDatabase, $_);
      }
    }
    self!setObject($to-parent);
  }

  method GIO::Raw::Definitions::GTlsDatabase
    is also<GTlsDatabase>
  { $!td }

  method new (GTlsDatabaseAncestry $tls-database, :$ref = True) {
    return Nil unless $tls-database;

    my $o = self.bless( :$tls-database );
    $o.ref if $ref;
    $o;
  }

  method create_certificate_handle (GTlsCertificate $certificate)
    is also<create-certificate-handle>
  {
    g_tls_database_create_certificate_handle($!td, $certificate);
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_tls_database_get_type, $n, $t );
  }

  method lookup_certificate_for_handle (
    Str()                   $handle,
    GTlsInteraction()       $interaction,
    Int()                   $flags,
    GCancellable()          $cancellable  = GCancellable,
    CArray[Pointer[GError]] $error        = gerror,
                            :$raw         = False
  )
    is also<lookup-certificate-for-handle>
  {
    my GTlsDatabaseLookupFlags $f = $flags;

    clear_error;
    my $c = g_tls_database_lookup_certificate_for_handle(
      $!td,
      $handle,
      $interaction,
      $f,
      $cancellable,
      $error
    );
    set_error($error);

    $c ??
      ( $raw ?? $c !! GIO::TlsCertificate.new($c, :!ref) )
      !!
      Nil;
  }

  proto method lookup_certificate_for_handle_async (|)
      is also<lookup-certificate-for-handle-async>
  { * }

  multi method lookup_certificate_for_handle_async (
    Str()             $handle,
    GTlsInteraction() $interaction,
    Int()             $flags,
                      &callback,
    gpointer          $user_data    = gpointer
  ) {
    samewith(
      $handle,
      $interaction,
      $flags,
      GCancellable,
      &callback,
      $user_data
    );
  }
  multi method lookup_certificate_for_handle_async (
    Str()             $handle,
    GTlsInteraction() $interaction,
    Int()             $flags,
    GCancellable()    $cancellable,
                      &callback,
    gpointer          $user_data    = gpointer
  ) {
    my GTlsDatabaseLookupFlags $f = $flags;

    g_tls_database_lookup_certificate_for_handle_async(
      $!td,
      $handle,
      $interaction,
      $flags,
      $cancellable,
      &callback,
      $user_data
    );
  }

  method lookup_certificate_for_handle_finish (
    GAsyncResult()          $result,
    CArray[Pointer[GError]] $error   = gerror,
                            :$raw    = False
  )
    is also<lookup-certificate-for-handle-finish>
  {
    clear_error;
    my $c = g_tls_database_lookup_certificate_for_handle_finish(
      $!td,
      $result,
      $error
    );
    set_error($error);

    $c ??
      ( $raw ?? $c !! GIO::TlsCertificate.new($c, :!ref) )
      !!
      Nil;
  }

  method lookup_certificate_issuer (
    GTlsCertificate()       $certificate,
    GTlsInteraction()       $interaction,
    Int()                   $flags,
    GCancellable()          $cancellable  = GCancellable,
    CArray[Pointer[GError]] $error        = gerror,
                            :$raw         = False
  )
    is also<lookup-certificate-issuer>
  {
    my GTlsDatabaseLookupFlags $f = $flags;

    clear_error;
    my $c = g_tls_database_lookup_certificate_issuer(
      $!td,
      $certificate,
      $interaction,
      $f,
      $cancellable,
      $error
    );
    set_error($error);

    $c ??
      ( $raw ?? $c !! GIO::TlsCertificate.new($c, :!ref) )
      !!
      Nil;
  }

  proto method lookup_certificate_issuer_async (|)
      is also<lookup-certificate-issuer-async>
  { * }

  multi method lookup_certificate_issuer_async (
    GTlsCertificate() $certificate,
    GTlsInteraction() $interaction,
    Int()             $flags,
                      &callback,
    gpointer          $user_data    = gpointer
  ) {
    samewith(
      $certificate,
      $interaction,
      $flags,
      GCancellable,
      &callback,
      $user_data
    );
  }
  multi method lookup_certificate_issuer_async (
    GTlsCertificate()   $certificate,
    GTlsInteraction()   $interaction,
    Int()               $flags,
    GCancellable()      $cancellable,
                        &callback,
    gpointer            $user_data    = gpointer
  ) {
    my GTlsDatabaseLookupFlags $f = $flags;

    g_tls_database_lookup_certificate_issuer_async(
      $!td,
      $certificate,
      $interaction,
      $f,
      $cancellable,
      &callback,
      $user_data
    );
  }

  method lookup_certificate_issuer_finish (
    GAsyncResult()          $result,
    CArray[Pointer[GError]] $error   = gerror,
                            :$raw    = False
  )
    is also<lookup-certificate-issuer-finish>
  {
    clear_error;
    my $c = g_tls_database_lookup_certificate_issuer_finish(
      $!td,
      $result,
      $error
    );
    set_error($error);

    $c ??
      ( $raw ?? $c !! GIO::TlsCertificate.new($c, :!ref) )
      !!
      Nil;
  }

  method lookup_certificates_issued_by (
    GByteArray()            $issuer_raw_dn,
    GTlsInteraction()       $interaction,
    Int()                   $flags,
    GCancellable()          $cancellable    = GCancellable,
    CArray[Pointer[GError]] $error          = gerror,
                            :$glist         = False,
                            :$raw           = False
  )
    is also<lookup-certificates-issued-by>
  {
    my GTlsDatabaseLookupFlags $f = $flags;

    clear_error;
    my $cl = g_tls_database_lookup_certificates_issued_by(
      $!td,
      $issuer_raw_dn,
      $interaction,
      $f,
      $cancellable,
      $error
    );
    set_error($error);

    return Nil unless $cl;
    return $cl if     $glist && $raw;

    $cl = GLib::GList.new($cl) but GLib::Roles::ListData[GTlsCertificate];
    return $cl if $glist;

    $raw ?? $cl.Array
         !! $cl.Array.map({ GIO::TlsCertificate.new($_, :!ref) })
  }

  proto method lookup_certificates_issued_by_async (|)
      is also<lookup-certificates-issued-by-async>
  { * }

  multi method lookup_certificates_issued_by_async (
    GByteArray()        $issuer_raw_dn,
    GTlsInteraction()   $interaction,
    Int()               $flags,
                        &callback,
    gpointer            $user_data      = gpointer
  ) {
    samewith(
      $issuer_raw_dn,
      $interaction,
      $flags,
      GCancellable,
      &callback,
      $user_data
    );
  }
  multi method lookup_certificates_issued_by_async (
    GByteArray()        $issuer_raw_dn,
    GTlsInteraction()   $interaction,
    Int()               $flags,
    GCancellable()      $cancellable,
                        &callback,
    gpointer            $user_data      = gpointer
  ) {
    my GTlsDatabaseLookupFlags $f = $flags;

    g_tls_database_lookup_certificates_issued_by_async(
      $!td,
      $issuer_raw_dn,
      $interaction,
      $f,
      $cancellable,
      &callback,
      $user_data
    );
  }

  method lookup_certificates_issued_by_finish (
    GAsyncResult()          $result,
    CArray[Pointer[GError]] $error   = gerror,
                            :$glist  = False,
                            :$raw    = False
  )
    is also<lookup-certificates-issued-by-finish>
  {
    clear_error;
    my $cl = g_tls_database_lookup_certificates_issued_by_finish(
      $!td,
      $result,
      $error
    );
    set_error($error);

    return Nil unless $cl;
    return $cl if     $glist && $raw;

    $cl = GLib::GList.new($cl) but GLib::Roles::ListData[GTlsCertificate];
    return $cl if $raw;

    $raw ?? $cl.Array
         !! $cl.Array.map({ GIO::TlsCertificate.new($_, :!ref) })
  }

  method verify_chain (
    GTlsCertificate()       $chain,
    Str()                   $purpose,
    GSocketConnectable()    $identity,
    GTlsInteraction()       $interaction,
    Int()                   $flags,
    GCancellable            $cancellable  = GCancellable,
    CArray[Pointer[GError]] $error        = gerror
  )
    is also<verify-chain>
  {
    my GTlsDatabaseVerifyFlags $f = $flags;

    GTlsCertificateFlagsEnum(
      g_tls_database_verify_chain(
        $!td,
        $chain,
        $purpose,
        $identity,
        $interaction,
        $f,
        $cancellable,
        $error
      )
    );
  }

  proto method verify_chain_async (|)
      is also<verify-chain-async>
  { * }

  multi method verify_chain_async (
    GTlsCertificate()    $chain,
    Str()                $purpose,
    GSocketConnectable() $identity,
    GTlsInteraction()    $interaction,
    Int()                $flags,
                         &callback,
    gpointer             $user_data    = gpointer
  ) {
    samewith(
      $chain,
      $purpose,
      $identity,
      $interaction,
      $flags,
      GCancellable,
      &callback,
      $user_data
    );
  }
  multi method verify_chain_async (
    GTlsCertificate()    $chain,
    Str()                $purpose,
    GSocketConnectable() $identity,
    GTlsInteraction()    $interaction,
    Int()                $flags,
    GCancellable()       $cancellable,
                         &callback,
    gpointer             $user_data    = gpointer
  ) {
    my GTlsDatabaseVerifyFlags $f = $flags;

    g_tls_database_verify_chain_async(
      $!td,
      $chain,
      $purpose,
      $identity,
      $interaction,
      $flags,
      $cancellable,
      &callback,
      $user_data
    );
  }

  method verify_chain_finish (
    GAsyncResult()          $result,
    CArray[Pointer[GError]] $error   = gerror
  )
    is also<verify-chain-finish>
  {
    clear_error;
    my $cf = g_tls_database_verify_chain_finish($!td, $result, $error);
    set_error($error);

    GTlsCertificateFlagsEnum($cf);
  }

}
