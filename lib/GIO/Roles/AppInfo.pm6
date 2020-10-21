use v6.c;

use Method::Also;
use NativeCall;

use GIO::Raw::Types;
use GIO::Raw::AppInfo;

use GLib::GList;

use GLib::Roles::Object;

role GIO::Roles::AppInfo does GLib::Roles::Object {
  has GAppInfo $!ai;

  method roleInit-AppInfo {
    return if $!ai;

    my \i = findProperImplementor(self.^attributes);
    $!ai = cast( GAppInfo, i.get_value(self) );
  }

  method GIO::Raw::Definitions::GAppInfo
    is also<GAppInfo>
  { $!ai }

  # ↓↓↓↓ SIGNALS ↓↓↓↓
  # ↑↑↑↑ SIGNALS ↑↑↑↑

  # ↓↓↓↓ ATTRIBUTES ↓↓↓↓
  # ↑↑↑↑ ATTRIBUTES ↑↑↑↑

  # Static methods
  method create_from_commandline (
    ::?CLASS:U:
    Str()                   $application_name,
    Int()                   $flags,            # GAppInfoCreateFlags $flags,
    CArray[Pointer[GError]] $error             = gerror,
                            :$raw              = False
  )
    is also<create-from-commandline>
  {
    my GAppInfoCreateFlags $f = $flags;

    clear_error;
    my $appinfo = g_app_info_create_from_commandline(
      $application_name,
      $f,
      $error
    );
    set_error($error);

    $appinfo ??
      ( $raw ?? $appinfo !! self.bless( :$appinfo ) )
      !!
      Nil;
  }

  method get_all_for_type(Str() $content-type, :$glist = False, :$raw = False)
    is also<get-all-for-type>
  {
    my $at = g_app_info_get_all_for_type($content-type);

    return Nil unless $at;
    return $at if     $glist;

    my $atl = GLib::List.new($at) but GLib::Roles::ListData[GAppInfo];

    $raw ?? $atl.Array !!
            $atl.Array.map({ GIO::Roles::AppInfo.new_appinfo_obj($_, :!ref) });
  }

  method get_default_for_type (
    Str() $content-type,
    Int() $must_support_uris,
          :$raw               = False
  )
    is also<get-default-for-type>
  {
    my gboolean $m = $must_support_uris;
    my $ai = g_app_info_get_default_for_type(
      $content-type,
      $must_support_uris
    );

    $ai ??
      ( $raw ?? $ai !! GIO::Roles::AppInfo.new_appinfo_obj($ai) )
      !!
      Nil;
  }

  method get_default_for_uri_scheme(Str() $uri-scheme, :$raw = False)
    is also<get-default-for-uri-scheme>
  {
    my $ai = g_app_info_get_default_for_uri_scheme($uri-scheme);

    $ai ??
      ( $raw ?? $ai !! GIO::Roles::AppInfo.new_appinfo_obj($ai) )
      !!
      Nil;
  }

  method get_fallback_for_type(
    Str() $content-type,
          :$glist        = False,
          :$raw          = False
  )
    is also<get-fallback-for-type>
  {
    my $f = g_app_info_get_fallback_for_type($content-type);

    return Nil unless $f;
    return $f  if     $glist;

    my $fl = GLib::List.new($f) but GLib::Roles::ListData[GAppInfo];

    $raw ?? $fl.Array !!
            $fl.Array.map({ GIO::Roles::AppInfo.new_appinfo_obj($_, :!ref) });
  }

  method get_recommended_for_type(
    Str() $content-type,
          :$glist        = False,
          :$raw          = False
  )
    is also<get-recommended-for-type>
  {
    my $r = g_app_info_get_recommended_for_type($content-type);

    return Nil unless $r;
    return $r  if     $glist;

    my $rl = GLib::List.new($r) but GLib::Roles::ListData[GAppInfo];

    $raw ?? $rl.Array !!
            $rl.Array.map({ GIO::Roles::AppInfo.new_appinfo_obj($_, :!ref) });
  }

  method launch_default_for_uri (
    Str()                   $uri,
    GAppLaunchContext()     $context,
    CArray[Pointer[GError]] $error    = gerror()
  )
    is also<launch-default-for-uri>
  {
    clear_error;
    my $rv = so g_app_info_launch_default_for_uri($uri, $context, $error);
    set_error($error);
    $rv;
  }

  proto method launch_default_for_uri_async (|)
    is also<launch-default-for-uri-async>
  { * }

  multi launch_default_for_uri_async (
    Str()               $uri,
    GAppLaunchContext() $context,
                        &callback,
    gpointer            $user_data = gpointer
  ) {
    samewith($uri, $context, GCancellable, &callback, $user_data)
  }
  multi method launch_default_for_uri_async (
    Str()               $uri,
    GAppLaunchContext() $context,
    GCancellable        $cancellable,
                        &callback,
    gpointer            $user_data    = gpointer
  ) {
    g_app_info_launch_default_for_uri_async(
      $uri,
      $context,
      $cancellable,
      &callback,
      $user_data
    );
  }

  method launch_default_for_uri_finish (
    GAsyncResult()          $result,
    CArray[Pointer[GError]] $error   = gerror();
  )
    is also<launch-default-for-uri-finish>
  {
    clear_error;
    my $rv = so g_app_info_launch_default_for_uri_finish($result, $error);
    set_error($error);
    $rv;
  }

  method reset_type_associations(Str() $content-type)
    is also<reset-type-associations>
  {
    g_app_info_reset_type_associations($content-type);
  }

  # Static methods

  # ↓↓↓↓ METHODS ↓↓↓↓
  method add_supports_type (
    Str()                   $content_type,
    CArray[Pointer[GError]] $error         = gerror()
  )
    is also<add-supports-type>
  {
    clear_error;
    my $rv = so g_app_info_add_supports_type($!ai, $content_type, $error);
    set_error($error);
    $rv;
  }

  method can_delete is also<can-delete> {
    so g_app_info_can_delete($!ai);
  }

  method can_remove_supports_type is also<can-remove-supports-type> {
    so g_app_info_can_remove_supports_type($!ai);
  }

  method delete {
    so g_app_info_delete($!ai);
  }

  method dup (:$raw = False) {
    my $ai = g_app_info_dup($!ai);

    $ai ??
      ( $raw ?? $ai !! GIO::Roles::AppInfo.new_appinfo_obj($ai, :!ref) )
      !!
      Nil;
  }

  method equal (GAppInfo() $appinfo2) {
    so g_app_info_equal($!ai, $appinfo2);
  }

  method get_all (:$glist = False, :$raw = False)
    is also<
      get-all
      all
    >
  {
    my $al = g_app_info_get_all();

    return Nil unless $al;
    return $al  if     $glist && $raw;

    $al = GLib::GList.new($al) but GLib::Roles::ListData[GAppInfo];
    return $al if $glist;

    $raw ?? $al.Array !!
            $al.Array.map({ GIO::Roles::AppInfo.new_appinfo_obj($_, :!ref) });
  }

  method get_commandline
    is also<
      get-commandline
      commandline
    >
  {
    g_app_info_get_commandline($!ai);
  }

  method get_description
    is also<
      get-description
      description
    >
  {
    g_app_info_get_description($!ai);
  }

  method get_display_name
    is also<
      get-display-name
      display_name
      display-name
    >
  {
    g_app_info_get_display_name($!ai);
  }

  method get_executable
    is also<
      get-executable
      executable
    >
  {
    g_app_info_get_executable($!ai);
  }

  method get_icon (:$raw = False) is also<get-icon> {
    my $i = g_app_info_get_icon($!ai);

    $i ??
      ( $raw ?? $i !! GIO::Roles::Icon.new-icon-obj($i, :!ref) )
      !!
      Nil;
  }

  method get_id
    is also<
      get-id
      id
    >
  {
    g_app_info_get_id($!ai);
  }

  method get_name
    is also<
      get-name
      name
    >
  {
    g_app_info_get_name($!ai);
  }

  method get_supported_types
    is also<
      get-supported-types
      supported_types
      supported-types
    >
  {
    CStringArrayToArray( g_app_info_get_supported_types($!ai) );
  }

  method launch (
    GList()                 $files,
    GAppLaunchContext()     $context,
    CArray[Pointer[GError]] $error    = gerror()
  ) {
    clear_error;
    my $rv = so g_app_info_launch($!ai, $files, $context, $error);
    set_error($error);
    $rv;
  }

  method launch_uris (
    GList()                 $uris,
    GAppLaunchContext()     $context,
    CArray[Pointer[GError]] $error    is rw
  )
    is also<launch-uris>
  {
    clear_error;
    my $rv = so g_app_info_launch_uris($!ai, $uris, $context, $error);
    set_error($error);
    $rv;
  }

  method remove_supports_type (
    Str()                   $content_type,
    CArray[Pointer[GError]] $error         = gerror
  )
    is also<remove-supports-type>
  {
    g_app_info_remove_supports_type($!ai, $content_type, $error);
  }

  method set_as_default_for_extension (
    Str()                   $extension,
    CArray[Pointer[GError]] $error      = gerror
  )
    is also<set-as-default-for-extension>
  {
    clear_error;
    my $rv = so g_app_info_set_as_default_for_extension(
      $!ai,
      $extension,
      $error
    );
    set_error($error);
    $rv;
  }

  method set_as_default_for_type (
    Str()                   $content_type,
    CArray[Pointer[GError]] $error         = gerror
  )
    is also<set-as-default-for-type>
  {
    clear_error;
    my $rv = so g_app_info_set_as_default_for_type(
      $!ai,
      $content_type,
      $error
    );
    set_error($error);
    $rv;
  }

  method set_as_last_used_for_type (
    Str()                   $content_type,
    CArray[Pointer[GError]] $error         = gerror()
  )
    is also<set-as-last-used-for-type>
  {
    clear_error;
    my $rv = so g_app_info_set_as_last_used_for_type(
      $!ai,
      $content_type,
      $error
    );
    set_error($error);
    $rv;
  }

  method should_show is also<should-show> {
    so g_app_info_should_show($!ai);
  }

  method supports_files is also<supports-files> {
    so g_app_info_supports_files($!ai);
  }

  method supports_uris is also<supports-uris> {
    so g_app_info_supports_uris($!ai);
  }
  # ↑↑↑↑ METHODS ↑↑↑↑

}

our subset GAppInfoAncestry is export of Mu
  where GAppInfo | GObject;

class GIO::AppInfo does GIO::Roles::AppInfo {

   submethod BUILD (:$appinfo) {
     self.setGAppInfo($appinfo) if $appinfo;
   }

   method setGAppInfo (GAppInfoAncestry $_) {
     my $to-parent;

     $!ai = do {
       when GAppInfo {
         $to-parent = cast(GObject, $_);
         $_;
       }

       default {
         $to-parent = $_;
         cast(GAppInfo, $_);
       }
     }
     self!setObject($to-parent);
   }

   method new (GAppInfoAncestry $appinfo, :$ref = True)
     is also<new-appinfo-obj>
   {
     return Nil unless $appinfo;

     my $o = self.bless(:$appinfo);
     $o.ref if $ref;
     $o;
   }

 }
