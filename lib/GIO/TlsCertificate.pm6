use v6.c;

use Method::Also;
use NativeCall;

use GIO::Raw::Types;
use GIO::Raw::TlsCertificate;

use GLib::ByteArray;
use GLib::Value;
use GLib::GList;

use GLib::Roles::ListData;
use GLib::Roles::Object;

our subset GTlsCertificateAncestry is export of Mu
  where GTlsCertificate | GObject;

class GIO::TlsCertificate {
  also does GLib::Roles::Object;

  has GTlsCertificate $!c is implementor;

  submethod BUILD (:$tls) {
    self.setGTlsCertificate($tls) if $tls;
  }

  method setGTlsCertificate (GTlsCertificateAncestry $_) {
    my $to-parent;

    $!c = do {
      when GTlsCertificate {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GTlsCertificate, $_);
      }
    }
    self!setObject($to-parent);
  }

  method GIO::Raw::Definitions::GTlsCertificate
    is also<GTlsCertificate>
  { $!c }

  multi method new (GTlsCertificateAncestry $tls, :$ref = True) {
    return Nil unless $tls;

    my $o = self.bless( :$tls );
    $o.ref if $ref;
    $o;
  }
  multi method new (
    Str()                   $f,
    CArray[Pointer[GError]] $error = gerror,
    :from_file(
      :from-file( :$file )
    ) is required
  ) {
    self.new_from_file($f, $error);
  }
  method new_from_file (Str() $file, CArray[Pointer[GError]] $error = gerror)
    is also<new-from-file>
  {
    clear_error;
    my $tls = g_tls_certificate_new_from_file($file, $error);
    set_error($error);

    $tls ?? self.bless( :$tls ) !! Nil;
  }

  multi method new (
    Str()                   $cert_file,
    Str()                   $key_file,
    CArray[Pointer[GError]] $error      = gerror,
    :from_files(
      :from-files( :$files )
    ) is required
  ) {
    self.new_from_files($cert_file, $key_file, $error);
  }
  method new_from_files (
    Str()                   $cert_file,
    Str()                   $key_file,
    CArray[Pointer[GError]] $error      = gerror
  )
    is also<new-from-files>
  {
    clear_error;
    my $tls = g_tls_certificate_new_from_files($cert_file, $key_file, $error);
    set_error($error);

    $tls ?? self.bless( :$tls ) !! Nil;
  }

  multi method new (
    Str                     $data,
    Int()                   $length    = $data.chars,
    CArray[Pointer[GError]] $error     = gerror,
                            :$encoding = 'utf-8',
    :from_pem(
      :from-pem( :$pem )
    ) is required
  ) {
    self.new_from_pem($data, $length, $error, :$encoding);
  }
  multi method new (
    Blob                    $data,
    Int()                   $length,
    CArray[Pointer[GError]] $error   = gerror,
    :from_pem(
      :from-pem( :$pem )
    ) is required
  ) {
    self.new_from_pem($data, $length, $error);
  }
  multi method new (
    CArray[uint8]           $data,
    Int()                   $length,
    CArray[Pointer[GError]] $error   = gerror,
    :from_pem(
      :from-pem( :$pem )
    ) is required
  ) {
    self.new_from_pem($data, $length, $error);
  }
  multi method new (
    Pointer                 $data,
    Int()                   $length,
    CArray[Pointer[GError]] $error   = gerror,
    :from_pem(
      :from-pem( :$pem )
    ) is required
  ) {
    self.new_from_pem($data, $length, $error);
  }

  proto method new_from_pem (|)
    is also<new-from-pem>
  { * }

  multi method new_from_pem (
    Str                     $data,
    Int()                   $length    = $data.chars,
    CArray[Pointer[GError]] $error     = gerror,
                            :$encoding = 'utf-8'
  ) {
    samewith( $data.encode($encoding), $length, $error );
  }
  multi method new_from_pem (
    Blob                    $data,
    Int()                   $length,
    CArray[Pointer[GError]] $error   = gerror
  ) {
    samewith( cast(Pointer, $data), $length, $error );
  }
  multi method new_from_pem (
    CArray[uint8]           $data,
    Int()                   $length,
    CArray[Pointer[GError]] $error   = gerror
  ) {
    samewith( cast(Pointer, $data), $length, $error);
  }
  multi method new_from_pem (
    Pointer                 $data,
    Int()                   $length,
    CArray[Pointer[GError]] $error   = gerror
  ) {
    my gssize $l = $length;

    clear_error;
    my $tls = g_tls_certificate_new_from_pem($data, $length, $error);
    set_error($error);

    $tls ?? self.bless( :$tls ) !! Nil;
  }

  method list_new_from_file (
    GIO::TlsCertificate:U:
    Str()                   $file,
    CArray[Pointer[GError]] $error  = gerror,
                            :$glist = False,
                            :$raw   = False
  )
    is also<list-new-from-file>
  {
    my $la = g_tls_certificate_list_new_from_file($file, $error);

    return Nil unless $la;
    return $la if     $glist && $raw;

    $la = GLib::GList.new($la) but GLib::Roles::ListData[GTlsCertificate];
    return $la if $glist;

    $raw ?? $la.Array !! $la.Array.map({ GIO::TlsCertificate.new($_) });
  }

  # Type: GByteArray
  method certificate (:$raw = False) is rw  {
    my GLib::Value $gv .= new( G_TYPE_OBJECT );
    Proxy.new(
      FETCH => -> $ {
        $gv = GLib::Value.new(
          self.prop_get('certificate', $gv)
        );

        my $o = $gv.object;
        return Nil unless $o;

        $o = cast(GByteArray, $o);
        return $o if $raw;

        GLib::ByteArray.new($o, :!ref);
      },
      STORE => -> $, GByteArray() $val is copy {
        $gv.object = $val;
        self.prop_set('certificate', $gv);
      }
    );
  }

  # Type: Str
  method certificate-pem is rw  is also<certificate_pem> {
    my GLib::Value $gv .= new( G_TYPE_STRING );
    Proxy.new(
      FETCH => -> $ {
        $gv = GLib::Value.new(
          self.prop_get('certificate-pem', $gv)
        );
        $gv.string;
      },
      STORE => -> $, Str() $val is copy {
        $gv.string = $val;
        self.prop_set('certificate-pem', $gv);
      }
    );
  }

  # Type: GTlsCertificate
  method issuer (:$raw = False) is rw  {
    my GLib::Value $gv .= new( G_TYPE_OBJECT );
    Proxy.new(
      FETCH => -> $ { self.get_issuer(:$raw) },
      STORE => -> $, GTlsCertificate() $val is copy {
        $gv.object = $val;
        self.prop_set('issuer', $gv);
      }
    );
  }

  # Type: GByteArray
  method private-key is rw  is also<private_key> {
    my GLib::Value $gv .= new( G_TYPE_OBJECT );
    Proxy.new(
      FETCH => -> $ {
        warn 'private-key does not allow reading' if $DEBUG;
        0;
      },
      STORE => -> $, GByteArray() $val is copy {
        $gv.object = $val;
        self.prop_set('private-key', $gv);
      }
    );
  }

  # Type: Str
  method private-key-pem is rw  is also<private_key_pem> {
    my GLib::Value $gv .= new( G_TYPE_STRING );
    Proxy.new(
      FETCH => -> $ {
        warn 'private-key-pem does not allow reading' if $DEBUG;
        '';
      },
      STORE => -> $, Str() $val is copy {
        $gv.string = $val;
        self.prop_set('private-key-pem', $gv);
      }
    );
  }

  method get_issuer (:$raw = False) is also<get-issuer> {
    my $i = g_tls_certificate_get_issuer($!c);

    $i ??
      ($raw ?? $i !! GIO::TlsCertificate.new($i, :!ref) )
      !!
      Nil;
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_tls_certificate_get_type, $n, $t );
  }

  proto method is_same (|)
      is also<is-same>
  { * }

  multi method is_same (GTlsCertificate() $cert_two) {
    GIO::TlsCertificate.is_same($!c, $cert_two);
  }
  multi method is_same (
    GIO::TlsCertificate:U:
    GTlsCertificate()      $cert_one,
    GTlsCertificate()      $cert_two
  ) {
    so g_tls_certificate_is_same($cert_one, $cert_two);
  }

  method verify (
    GSocketConnectable() $identity,
    GTlsCertificate()    $trusted_ca
  ) {
    GTlsCertificateFlagsEnum(
      g_tls_certificate_verify($!c, $identity, $trusted_ca)
    );
  }

}
