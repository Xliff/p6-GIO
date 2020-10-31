use v6.c;

use Method::Also;

use NativeCall;

use GIO::Raw::Types;
use GIO::Raw::Drive;

use GLib::GList;

use GLib::Roles::Object;
use GLib::Roles::ListData;
use GLib::Roles::Signals::Generic;
use GIO::Roles::Icon;
use GIO::Roles::Volume;

role GIO::Roles::Drive {
  has GDrive $!d;

  method roleInit-Drive is also<roleInit_Drive> {
    return if $!d;

    my \i = findProperImplementor(self.^attributes);
    $!d = cast( GDrive, i.get_value(self) );
  }

  method GIO::Raw::Definitions::GDrive
  #  is also<GDrive>
  { $!d }

  # cw: Remove when Method::Also is fixed
  method GDrive { $!d }

  # Is originally:
  # GDrive, gpointer --> void
  method changed {
    self.connect($!d, 'changed');
  }

  # Is originally:
  # GDrive, gpointer --> void
  method disconnected {
    self.connect($!d, 'disconnected');
  }

  # Is originally:
  # GDrive, gpointer --> void
  method eject-button is also<eject_button> {
    self.connect($!d, 'eject-button');
  }

  # Is originally:
  # GDrive, gpointer --> void
  method stop-button is also<stop_button> {
    self.connect($!d, 'stop-button');
  }

  method can_eject is also<can-eject> {
    so g_drive_can_eject($!d);
  }

  method can_poll_for_media is also<can-poll-for-media> {
    so g_drive_can_poll_for_media($!d);
  }

  method can_start is also<can-start> {
    so g_drive_can_start($!d);
  }

  method can_start_degraded is also<can-start-degraded> {
    so g_drive_can_start_degraded($!d);
  }

  method can_stop is also<can-stop> {
    so g_drive_can_stop($!d);
  }

  proto method eject_with_operation (|)
      is also<eject-with-operation>
  { * }

  multi method eject_with_operation (
    Int()               $flags,
    Int()               $mount_operation,
                        &callback,
    gpointer            $user_data        = gpointer
  ) {
    samewith($flags, $mount_operation, GCancellable, &callback, $user_data);
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

    g_drive_eject_with_operation(
      $!d,
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
    my $rv = so g_drive_eject_with_operation_finish($!d, $result, $error);
    set_error($error);
    $rv;
  }

  method enumerate_identifiers is also<enumerate-identifiers> {
    CStringArrayToArray( g_drive_enumerate_identifiers($!d) );
  }

  method get_icon (:$raw = False) is also<get-icon> {
    my $i = g_drive_get_icon($!d);

    $i ??
      ( $raw ?? $i !! GIO::Icon.new($i, :!ref) )
      !!
      Nil;
  }

  method get_identifier (Str() $kind) is also<get-identifier> {
    g_drive_get_identifier($!d, $kind);
  }

  method get_name
    is also<
      get-name
      name
    >
  {
    g_drive_get_name($!d);
  }

  method get_sort_key
    is also<
      get-sort-key
      sort-key
      sort_key
    >
  {
    g_drive_get_sort_key($!d);
  }

  method get_start_stop_type
    is also<
      get-start-stop-type
      start_stop_type
      start-stop-type
    >
  {
    GDriveStartStopTypeEnum( g_drive_get_start_stop_type($!d) );
  }

  method get_symbolic_icon (:$raw = False)
    is also<
      get-symbolic-icon
      symbolic_icon
      symbolic-icon
    >
  {
    my $i = g_drive_get_symbolic_icon($!d);

    $i ??
      ( $raw ?? $i !! GIO::Icon.new($i, :!ref) )
      !!
      Nil;
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_drive_get_type, $n, $t );
  }

  method get_volumes (:$glist = False, :$raw = False)
    is also<
      get-volumes
      volumes
    >
  {
    my $vl = g_drive_get_volumes($!d);

    return Nil unless $vl;
    return $vl if     $glist && $raw;

    $vl = GLib::GList.new($vl) but GLib::Roles::ListData[GVolume];
    return $vl if $glist;

    $raw ?? $vl.Array
         !! $vl.Array.map({ GIO::Volume.new($_) });
  }

  method has_media is also<has-media> {
    so g_drive_has_media($!d);
  }

  method has_volumes is also<has-volumes> {
    so g_drive_has_volumes($!d);
  }

  method is_media_check_automatic is also<is-media-check-automatic> {
    so g_drive_is_media_check_automatic($!d);
  }

  method is_media_removable is also<is-media-removable> {
    so g_drive_is_media_removable($!d);
  }

  method is_removable is also<is-removable> {
    so g_drive_is_removable($!d);
  }

  proto method poll_for_media (|)
      is also<poll-for-media>
  { * }

  multi method poll_for_media (
             &callback,
    gpointer $user_data = gpointer
  ) {
    samewith(GCancellable, &callback, $user_data);
  }
  multi method poll_for_media (
    GCancellable() $cancellable,
                   &callback,
    gpointer       $user_data = gpointer
  ) {
    g_drive_poll_for_media($!d, $cancellable, &callback, $user_data);
  }

  method poll_for_media_finish (
    GAsyncResult()          $result,
    CArray[Pointer[GError]] $error   = gerror
  )
    is also<poll-for-media-finish>
  {
    clear_error;
    my $rv = so g_drive_poll_for_media_finish($!d, $result, $error);
    set_error($error);
    $rv;
  }

  multi method start (
    Int()    $flags,
    Int()    $mount_operation,
             &callback,
    gpointer $user_data        = gpointer
  ) {
    samewith($flags, $mount_operation, GCancellable, &callback, $user_data);
  }
  multi method start (
    Int()          $flags,
    Int()          $mount_operation,
    GCancellable() $cancellable,
                   &callback,
    gpointer       $user_data        = gpointer
  ) {
    my GDriveStartFlags $f = $flags;
    my GMountOperation  $m = $mount_operation;

    g_drive_start($!d, $f, $m, $cancellable, &callback, $user_data);
  }

  method start_finish (
    GAsyncResult()          $result,
    CArray[Pointer[GError]] $error   = gerror
  )
    is also<start-finish>
  {
    clear_error;
    my $rv = so g_drive_start_finish($!d, $result, $error);
    set_error($error);
    $rv;
  }

  multi method stop (
    Int()               $flags,
    Int()               $mount_operation,
                        &callback,
    gpointer            $user_data = gpointer
  ) {
    samewith($flags, $mount_operation, GCancellable, &callback, $user_data);
  }
  multi method stop (
    Int()               $flags,
    Int()               $mount_operation,
    GCancellable()      $cancellable,
                        &callback,
    gpointer            $user_data = gpointer
  ) {
    my GMountUnmountFlags $f = $flags;
    my GMountOperation    $m = $mount_operation;

    g_drive_stop($!d, $f, $m, $cancellable, &callback, $user_data);
  }

  method stop_finish (
    GAsyncResult()          $result,
    CArray[Pointer[GError]] $error   = gerror
  )
    is also<stop-finish>
  {
    clear_error;
    my $rv = so g_drive_stop_finish($!d, $result, $error);
    set_error($error);
    $rv;
  }

}

our subset GDriveAncestry is export of Mu
  when GDrive | GObject;

class GIO::Drive does GLib::Roles::Object does GIO::Roles::Drive {

  submethod BUILD (:$drive) {
    self.setGDrive($drive) if $drive;
  }

  method setGDrive (GDriveAncestry $_) {
    my $to-parent;

    $!d = do {
      when GDrive {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GDrive, $_);
      }
    }
    self!setObject($to-parent);
  }

  method new (GDriveAncestry $drive, :$ref = True) {
    return Nil unless $drive;

    my $o = self.bless( :$drive );
    $o.ref if $ref;
    $o;
  }

}
