use v6.c;

use NativeCall;

use GLib::Raw::Definitions;
use GLib::Raw::Enums;
use GLib::Raw::Object;
use GLib::Raw::Structs;
use GIO::Raw::Definitions;
use GIO::Raw::Enums;
use GIO::Raw::Structs;

unit package GIO::Raw::TlsCertificate;

### /usr/src/glib/gio/gtlscertificate.h

sub g_tls_certificate_get_issuer (GTlsCertificate $cert)
  returns GTlsCertificate
  is native(gio)
  is export
{ * }

sub g_tls_certificate_get_type ()
  returns GType
  is native(gio)
  is export
{ * }

sub g_tls_certificate_is_same (
  GTlsCertificate $cert_one,
  GTlsCertificate $cert_two
)
  returns uint32
  is native(gio)
  is export
{ * }

sub g_tls_certificate_list_new_from_file (
  Str                     $file,
  CArray[Pointer[GError]] $error
)
  returns GList
  is native(gio)
  is export
{ * }

sub g_tls_certificate_new_from_file (Str $file, CArray[Pointer[GError]] $error)
  returns GTlsCertificate
  is native(gio)
  is export
{ * }

sub g_tls_certificate_new_from_files (
  Str                     $cert_file,
  Str                     $key_file,
  CArray[Pointer[GError]] $error
)
  returns GTlsCertificate
  is native(gio)
  is export
{ * }

sub g_tls_certificate_new_from_pem (
  Pointer                 $data,
  gssize                  $length,
  CArray[Pointer[GError]] $error
)
  returns GTlsCertificate
  is native(gio)
  is export
{ * }

sub g_tls_certificate_verify (
  GTlsCertificate    $cert,
  GSocketConnectable $identity,
  GTlsCertificate    $trusted_ca
)
  returns GTlsCertificateFlags
  is native(gio)
  is export
{ * }
