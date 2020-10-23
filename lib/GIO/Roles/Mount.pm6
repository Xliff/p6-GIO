use v6.c;

use Method::Also;
use NativeCall;

use GIO::Raw::Types;
use GIO::Raw::Mount;

use GLib::Roles::Object;
use GLib::Roles::Signals::Generic;
use GIO::Roles::Icon;
use GIO::Roles::Volume;
use GIO::Roles::Drive;

role GIO::Roles::Mount {
  has GMount $!m;

  method roleInit-Mount is also<roleInit_Mount> {
    return if $!m;

    my \i = findProperImplementor(self.^attributes);
    $!m = cast(GMount, i.get_value(self) );
  }

  method GIO::Raw::Definitions::GMount
    is also<GMount>
  { $!m }

  # Is originally:
  # GMount, gpointer --> void
  method changed {
    self.connect($!m, 'changed');
  }

  # Is originally:
  # GMount, gpointer --> void
  method pre-unmount is also<pre_unmount> {
    self.connect($!m, 'pre-unmount');
  }

  # Is originally:
  # GMount, gpointer --> void
  method unmounted {
    self.connect($!m, 'unmounted');
  }

  method can_eject is also<can-eject> {
    so g_mount_can_eject($!m);
  }

  method can_unmount is also<can-unmount> {
    so g_mount_can_unmount($!m);
  }

  proto method eject_with_operation (|)
      is also<eject-with-operation>
  { * }

  multi method eject_with_operation (
    Int()               $mount_operation,
                        &callback,
    gpointer            $user_data         = gpointer,
    GCancellable()      :$cancellable      = GCancellable,
    Int()               :$flags,
  ) {
    samewith($flags, $mount_operation, $cancellable, &callback, $user_data);
  }
  multi method eject_with_operation (
    Int()               $flags,
    Int()               $mount_operation,
    GCancellable()      $cancellable,
                        &callback,
    gpointer            $user_data        = gpointer
  ) {
    my GMountUnmountFlags $f = $flags;
    my GMountOperation    $m = $mount_operation;

    g_mount_eject_with_operation(
      $!m,
      $f,
      $m,
      $cancellable,
      &callback,
      $user_data
    );
  }

  method eject_with_operation_finish (
    GAsyncResult()          $result,
    CArray[Pointer[GError]] $error   = gerror
  )
    is also<eject-with-operation-finish>
  {
    clear_error;
    my $rv = so g_mount_eject_with_operation_finish($!m, $result, $error);
    set_error($error);
    $rv;
  }

  method get_default_location (:$raw = False) is also<get-default-location> {
    my $f = g_mount_get_default_location($!m);

    $f ??
      ( $raw ?? $f !! ::('GIO::GFile').new($f, :!ref) )
      !!
      Nil;
  }

  method get_drive (:$raw = False) is also<get-drive> {
    my $d = g_mount_get_drive($!m);

    $d ??
      ( $raw ?? $d !! GIO::Drive.new($d, :!ref) )
      !!
      Nil;
  }

  method get_icon (:$raw = False) is also<get-icon> {
    my $i = g_mount_get_icon($!m);

    $i ??
      ( $raw ?? $i !! GIO::Icon.new($i, :!ref) )
      !!
      Nil;
  }

  method get_name is also<get-name> {
    g_mount_get_name($!m);
  }

  method get_root ($raw = False) is also<get-root> {
    my $f = g_mount_get_root($!m);

    $f ??
      ( $raw ?? $f !! ::('GIO::GFile').new($f, :!ref) )
      !!
      Nil;
  }

  method get_sort_key is also<get-sort-key> {
    g_mount_get_sort_key($!m);
  }

  method get_symbolic_icon (:$raw = False) is also<get-symbolic-icon> {
    my $i = g_mount_get_symbolic_icon($!m);

    $i ??
      ( $raw ?? $i !! GIO::Icon.new($i, :!ref) )
      !!
      Nil;
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_mount_get_type, $n, $t );
  }

  method get_uuid is also<get-uuid> {
    g_mount_get_uuid($!m);
  }

  method get_volume (:$raw = False) is also<get-volume> {
    my $v = g_mount_get_volume($!m);

    $v ??
      ( $raw ?? $v !! GIO::Volume.new($v, :!ref) )
      !!
      Nil;
  }

  proto method guess_content_type (|)
      is also<guess-content-type>
  { * }

  multi method guess_content_type (
                   &callback,
    gpointer       $user_data     = gpointer,
    Int()          :$force_rescan = False,
    GCancellable() :$cancellable  = GCancellable
  ) {
    samewith($force_rescan, $cancellable, &callback, $user_data);
  }
  multi method guess_content_type (
    Int()          $force_rescan,
    GCancellable() $cancellable,
                   &callback,
    gpointer       $user_data     = gpointer
  ) {
    my gboolean $f = $force_rescan.so.Int;

    g_mount_guess_content_type($!m, $f, $cancellable, &callback, $user_data);
  }

  method guess_content_type_finish (
    GAsyncResult()          $result,
    CArray[Pointer[GError]] $error   = gerror
  )
    is also<guess-content-type-finish>
  {
    clear_error;
    my $sa = g_mount_guess_content_type_finish($!m, $result, $error);
    set_error($error);

    CStringArrayToArray($sa);
  }

  proto method guess_content_type_sync (|)
    is also<guess-content-type-sync>
  { * }

  multi method guess_content_type_sync (
    CArray[Pointer[GError]] $error         = gerror,
    Int()                   :$force_rescan = False,
    GCancellable()          :$cancellable  = GCancellable,
  ) {
    samewith($force_rescan, $cancellable, $error);
  }
  multi method guess_content_type_sync (
    Int()                   $force_rescan,
    GCancellable()          $cancellable,
    CArray[Pointer[GError]] $error         = gerror
  ) {
    my gboolean $f = $force_rescan.so.Int;

    clear_error;
    my $sa = g_mount_guess_content_type_sync($!m, $f, $cancellable, $error);
    set_error($error);

    CStringArrayToArray($sa);
  }

  method is_shadowed is also<is-shadowed> {
    so g_mount_is_shadowed($!m);
  }

  multi method remount (
    Int()               $mount_operation,
                        &callback,
    gpointer            $user_data        = gpointer,
    GCancellable()      :$cancellable     = GCancellable,
    Int()               :$flags           = 0
  ) {
    samewith($flags, $mount_operation, $cancellable, &callback, $user_data);
  }
  multi method remount (
    Int()               $flags,
    Int()               $mount_operation,
    GCancellable()      $cancellable,
                        &callback,
    gpointer            $user_data        = gpointer
  ) {
    my GMountUnmountFlags $f = $flags;
    my GMountOperation    $m = $mount_operation;

    g_mount_remount($!m, $f, $m, $cancellable, &callback, $user_data);
  }

  method remount_finish (
    GAsyncResult()          $result,
    CArray[Pointer[GError]] $error   = gerror
  )
    is also<remount-finish>
  {
    clear_error;
    my $rv = so g_mount_remount_finish($!m, $result, $error);
    set_error($error);
    $rv;
  }

  method shadow {
    g_mount_shadow($!m);
  }

  proto method unmount_with_operation (|)
      is also<unmount-with-operation>
  { * }

  multi method unmount_with_operation (
    Int()               $mount_operation,
                        &callback,
    gpointer            $user_data        = gpointer,
    Int()               :$flags           = 0,
    GCancellable()      :$cancellable     = GCancellable
  ) {
    samewith($flags, $mount_operation, $cancellable, &callback, $user_data);
  }
  multi method unmount_with_operation (
    Int()               $flags,
    Int()               $mount_operation,
    GCancellable()      $cancellable,
                        &callback,
    gpointer            $user_data        = gpointer
  ) {
    my GMountUnmountFlags $f = $flags;
    my GMountOperation    $m = $mount_operation;

    g_mount_unmount_with_operation(
      $!m,
      $f,
      $m,
      $cancellable,
      &callback,
      $user_data
    );
  }

  method unmount_with_operation_finish (
    GAsyncResult()          $result,
    CArray[Pointer[GError]] $error   = gerror
  )
    is also<unmount-with-operation-finish>
  {
    clear_error;
    my $rv = so g_mount_unmount_with_operation_finish($!m, $result, $error);
    set_error($error);
    $rv;
  }

  method unshadow {
    g_mount_unshadow($!m);
  }

}

our subset GMountAncestry is export of Mu
  where GMount | GObject;

class GIO::Mount does GLib::Roles::Object does GIO::Roles::Mount {

  submethod BUILD (:$mount) {
    self.setGMount($mount) if $mount;
  }

  method setGMount (GMountAncestry $_) {
    my $to-parent;

    $!m = do {
      when GMount {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GMount, $_);
      }
    }
    self!setObject($to-parent);
  }

  method new (GMountAncestry $mount, :$ref = True) {
    return Nil unless $mount;

    my $o = self.bless( :$mount );
    $o.ref if $ref;
    $o
  }

}
