use v6.c;

use Method::Also;
use NativeCall;

use GLib::Raw::Traits;
use GIO::Raw::Types;
use GIO::Raw::Permission;

use GLib::Roles::Object;

our subset GPermissionAncestry is export of Mu
  where GPermission | GObject;

class GIO::Permission {
  also does GLib::Roles::Object;

  has GPermission $!p is implementor;

  submethod BUILD (:$permission) {
    self.setGPermission($permission) if $permission;
  }

  method setGPermission (GPermissionAncestry $_) {
    my $to-parent;

    $!p = do {
      when GPermission {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GPermission, $_);
      }
    }
    say "P: { $!p } / O: { $to-parent }";
    self!setObject($to-parent);
  }

  multi method new (GPermissionAncestry $permission, :$ref = True) {
    return Nil unless $permission;

    my $o = self.bless( :$permission );
    $o.ref if $ref;
    $o;
  }
  multi method new {
    my $permission = GLib::Object.new-object-ptr( self.get_type );

    $permission ?? self.bless( :$permission ) !! Nil;
  }

  method GIO::Raw::Structs::GPermission
    is also<GPermission>
  { $!p }

  # ↓↓↓↓ SIGNALS ↓↓↓↓
  # ↑↑↑↑ SIGNALS ↑↑↑↑

  # ↓↓↓↓ ATTRIBUTES ↓↓↓↓
  # Type: boolean
  method allowed is rw  is g-property {
    my $gv = GLib::Value.new( G_TYPE_BOOLEAN );
    Proxy.new(
      FETCH => sub ($) {
        self.prop_get('allowed', $gv);
        $gv.boolean;
      },
      STORE => -> $, Int() $val is copy {
        warn 'allowed does not allow writing'
      }
    );
  }

  # Type: boolean
  method can-acquire is rw  is g-property {
    my $gv = GLib::Value.new( G_TYPE_BOOLEAN );
    Proxy.new(
      FETCH => sub ($) {
        self.prop_get('can-acquire', $gv);
        $gv.boolean;
      },
      STORE => -> $, Int() $val is copy {
        warn 'can-acquire does not allow writing'
      }
    );
  }

  # Type: boolean
  method can-release is rw  is g-property {
    my $gv = GLib::Value.new( G_TYPE_BOOLEAN );
    Proxy.new(
      FETCH => sub ($) {
        self.prop_get('can-release', $gv);
        $gv.boolean;
      },
      STORE => -> $, Int() $val is copy {
        warn 'can-release does not allow writing'
      }
    );
  }
  # ↑↑↑↑ ATTRIBUTES ↑↑↑↑

  # ↓↓↓↓ METHODS ↓↓↓↓
  method acquire (
    GCancellable()          $cancellable = GCancellable,
    CArray[Pointer[GError]] $error       = gerror()
  ) {
    clear_error;
    my $rv = so g_permission_acquire($!p, $cancellable, $error);
    set_error($error);
    $rv;
  }

  proto method acquire_async (|)
    is also<acquire-async>
  { * }

  multi method acquire_async (
             &callback,
    gpointer $user_data = gpointer
  ) {
    samewith(GCancellable, &callback, $user_data);
  }
  multi method acquire_async  (
    GCancellable() $cancellable,
                   &callback,
    gpointer       $user_data    = gpointer
  ) {
    g_permission_acquire_async($!p, $cancellable, &callback, $user_data);
  }

  method acquire_finish  (
    GAsyncResult()          $result,
    CArray[Pointer[GError]] $error   = gerror()
  )
    is also<acquire-finish>
  {
    clear_error;
    my $rv = so g_permission_acquire_finish($!p, $result, $error);
    set_error($error);
    $rv;
  }

  method get_allowed is also<get-allowed> {
    so g_permission_get_allowed($!p);
  }

  method get_can_acquire is also<get-can-acquire>
  {
    so g_permission_get_can_acquire($!p);
  }

  method get_can_release is also<get-can-release> {
    so g_permission_get_can_release($!p);
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_permission_get_type, $n, $t );
  }

  method impl_update (
    Int() $allowed,
    Int() $can_acquire,
    Int() $can_release
  )
    is also<impl-update>
  {
    my gboolean ($a, $ca, $cr) =
      ($allowed, $can_acquire, $can_release).map( *.so.Int );

    g_permission_impl_update($!p, $a, $ca, $cr);
  }

  method release (
    GCancellable            $cancellable = GCancellable,
    CArray[Pointer[GError]] $error       = gerror
  ) {
    clear_error;
    my $rv = so g_permission_release($!p, $cancellable, $error);
    set_error($error);
    $rv;
  }

  proto method release_async (|)
    is also<release-async>
  { * }

  multi method release_async  (
                   &callback,
    gpointer       $user_data = gpointer
  ) {
    samewith(GCancellable, &callback, $user_data);
  }
  multi method release_async  (
    GCancellable() $cancellable,
                   &callback,
    gpointer       $user_data    = gpointer
  ) {
    g_permission_release_async($!p, $cancellable, &callback, $user_data);
  }

  method release_finish (
    GAsyncResult()          $result,
    CArray[Pointer[GError]] $error   = gerror()
  )
    is also<release-finish>
  {
    clear_error;
    my $rv = so g_permission_release_finish($!p, $result, $error);
    set_error($error);
    $rv;
  }
  # ↑↑↑↑ METHODS ↑↑↑↑

}
