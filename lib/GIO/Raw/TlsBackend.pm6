use v6.c;

use NativeCall;

use GLib::Raw::Definitions;
use GLib::Raw::Enums;
use GLib::Raw::Object;
use GLib::Raw::Structs;
use GIO::Raw::Definitions;
use GIO::Raw::Enums;
use GIO::Raw::Structs;

unit package GIO::Raw::TlsBackend;

### /usr/src/glib/gio/gtlsbackend.h

sub g_tls_backend_get_certificate_type (GTlsBackend $backend)
  returns GType
  is native(gio)
  is export
{ * }

sub g_tls_backend_get_client_connection_type (GTlsBackend $backend)
  returns GType
  is native(gio)
  is export
{ * }

sub g_tls_backend_get_default ()
  returns GTlsBackend
  is native(gio)
  is export
{ * }

sub g_tls_backend_get_dtls_client_connection_type (GTlsBackend $backend)
  returns GType
  is native(gio)
  is export
{ * }

sub g_tls_backend_get_dtls_server_connection_type (GTlsBackend $backend)
  returns GType
  is native(gio)
  is export
{ * }

sub g_tls_backend_get_file_database_type (GTlsBackend $backend)
  returns GType
  is native(gio)
  is export
{ * }

sub g_tls_backend_get_server_connection_type (GTlsBackend $backend)
  returns GType
  is native(gio)
  is export
{ * }

sub g_tls_backend_get_type ()
  returns GType
  is native(gio)
  is export
{ * }

sub g_tls_backend_supports_dtls (GTlsBackend $backend)
  returns uint32
  is native(gio)
  is export
{ * }

sub g_tls_backend_supports_tls (GTlsBackend $backend)
  returns uint32
  is native(gio)
  is export
{ * }

sub g_tls_backend_get_default_database (GTlsBackend $backend)
  returns GTlsDatabase
  is native(gio)
  is export
{ * }

sub g_tls_backend_set_default_database (GTlsBackend $backend, GTlsDatabase $database)
  is native(gio)
  is export
{ * }
