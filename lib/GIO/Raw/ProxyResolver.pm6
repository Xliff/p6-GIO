use v6.c;

use NativeCall;

use GLib::Raw::Definitions;
use GLib::Raw::Enums;
use GLib::Raw::Object;
use GLib::Raw::Structs;
use GIO::Raw::Definitions;
use GIO::Raw::Enums;
use GIO::Raw::Structs;

### /usr/src/glib/gio/gproxyresolver.h

unit package GIO::Raw::ProxyResolver;

sub g_proxy_resolver_get_default ()
  returns GProxyResolver
  is native(gio)
  is export
{ * }

sub g_proxy_resolver_get_type ()
  returns GType
  is native(gio)
  is export
{ * }

sub g_proxy_resolver_is_supported (GProxyResolver $resolver)
  returns uint32
  is native(gio)
  is export
{ * }

sub g_proxy_resolver_lookup (
  GProxyResolver          $resolver,
  Str                     $uri,
  GCancellable            $cancellable,
  CArray[Pointer[GError]] $error
)
  returns CArray[Str]
  is native(gio)
  is export
{ * }

sub g_proxy_resolver_lookup_async (
  GProxyResolver $resolver,
  Str            $uri,
  GCancellable   $cancellable,
                 &callback (GProxyResolver, GAsyncResult, gpointer),
  gpointer       $user_data
)
  is native(gio)
  is export
{ * }

sub g_proxy_resolver_lookup_finish (
  GProxyResolver          $resolver,
  GAsyncResult            $result,
  CArray[Pointer[GError]] $error
)
  returns CArray[Str]
  is native(gio)
  is export
{ * }
