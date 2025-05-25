use v6.c;

use NativeCall;

use GLib::Raw::Definitions;
use GLib::Raw::Enums;
use GLib::Raw::Object;
use GLib::Raw::Structs;
use GIO::Raw::Definitions;
use GIO::Raw::Enums;
use GIO::Raw::Structs;

unit package GIO::Raw::SimpleProxyResolver;

### /usr/src/glib/gio/gsocketoutputstream.h

sub g_simple_proxy_resolver_get_type ()
  returns GType
  is native(gio)
  is export
{ * }

sub g_simple_proxy_resolver_new (Str $default_proxy, CArray[Str] $ignore_hosts)
  returns GSimpleProxyResolver
  is native(gio)
  is export
{ * }

sub g_simple_proxy_resolver_set_default_proxy (
  GSimpleProxyResolver $resolver,
  Str                  $default_proxy
)
  is native(gio)
  is export
{ * }

sub g_simple_proxy_resolver_set_ignore_hosts (
  GSimpleProxyResolver $resolver,
  CArray[Str]          $ignore_hosts
)
  is native(gio)
  is export
{ * }

sub g_simple_proxy_resolver_set_uri_proxy (
  GSimpleProxyResolver $resolver,
  Str                  $uri_scheme,
  Str                  $proxy
)
  is native(gio)
  is export
{ * }
