use v6.c;

use NativeCall;

use GLib::Raw::Definitions;
use GLib::Raw::Enums;
use GLib::Raw::Object;
use GLib::Raw::Structs;
use GIO::Raw::Definitions;
use GIO::Raw::Enums;
use GIO::Raw::Structs;

unit package GIO::Raw::UnixCredentialsMessage;

sub g_unix_credentials_message_get_credentials (GUnixCredentialsMessage $message)
  returns GCredentials
  is native(gio)
  is export
{ * }

sub g_unix_credentials_message_get_type ()
  returns GType
  is native(gio)
  is export
{ * }

sub g_unix_credentials_message_is_supported ()
  returns uint32
  is native(gio)
  is export
{ * }

sub g_unix_credentials_message_new ()
  returns GUnixCredentialsMessage
  is native(gio)
  is export
{ * }

sub g_unix_credentials_message_new_with_credentials (GCredentials $credentials)
  returns GUnixCredentialsMessage
  is native(gio)
  is export
{ * }
