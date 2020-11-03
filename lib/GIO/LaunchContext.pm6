use v6.c;

use Method::Also;
use NativeCall;

use GIO::Raw::Types;
use GIO::Raw::AppInfo;

use GLib::Roles::Object;

our subset GAppLaunchContextAncestry is export of Mu
  where GAppLaunchContext | GObject;

class GIO::LaunchContext {
  also does GLib::Roles::Object;

  has GAppLaunchContext $!lc is implementor;

  submethod BUILD(:$context) {
    self.setGAppLaunchContext($context) if $context;
  }

  method setGAppLaunchContext (GAppLaunchContextAncestry $_) {
    my $to-parent;

    $!lc = do {
      when GAppLaunchContext {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GAppLaunchContext, $_);
      }
    }
    self!setObject($to-parent);
  }

  multi method new(GAppLaunchContext $context, :$ref = True) {
    return Nil unless $context;

    my $o = self.bless(:$context);
    $o.ref if $ref;
    $o;
  }
  multi method new {
    my $context = g_app_launch_context_new();

    $context ?? self.bless(:$context) !! Nil;
  }

  # ↓↓↓↓ SIGNALS ↓↓↓↓

  # Is originally
  # GAppLaunchContext, Str, gpointer
  method launch-failed is also<launch_failed> {
    self.connect($!lc, 'launch-failed');
  }

  method launched {
    self.connect($!lc, 'launched');
  }

  # ↑↑↑↑ SIGNALS ↑↑↑↑

  # ↓↓↓↓ ATTRIBUTES ↓↓↓↓
  # ↑↑↑↑ ATTRIBUTES ↑↑↑↑

  # ↓↓↓↓ METHODS ↓↓↓↓

  method get_display (GAppInfo() $info, GList() $files)
    is also<get-display>
  {
    g_app_launch_context_get_display($!lc, $info, $files);
  }

  method get_environment is also<get-environment> {
    CStringArrayToArray( g_app_launch_context_get_environment($!lc) );
  }

  method get_startup_notify_id (GAppInfo() $info, GList() $files)
    is also<get-startup-notify-id>
  {
    g_app_launch_context_get_startup_notify_id($!lc, $info, $files);
  }

  method emit_launch_failed (Str() $startup_notify_id)
    is also<eemit-launch-failed>
  {
    so g_app_launch_context_launch_failed($!lc, $startup_notify_id);
  }

  method setenv (Str() $variable, Str() $value) {
    g_app_launch_context_setenv($!lc, $variable, $value);
  }

  method unsetenv (Str() $variable) {
    g_app_launch_context_unsetenv($!lc, $variable);
  }
  # ↑↑↑↑ METHODS ↑↑↑↑

}
