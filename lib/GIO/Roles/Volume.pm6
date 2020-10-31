use v6.c;

use Method::Also;
use NativeCall;

use GIO::Raw::Types;
use GIO::Raw::Volume;

use GIO::Roles::Icon;
use GLib::Roles::Signals::Generic;

role GIO::Roles::Volume {
  also does GLib::Roles::Signals::Generic;

  has GVolume $!v;

  method roleInit-Volume is also<roleInit_Volume> {
    return if $!v;

    my \i = findProperImplementor(self.^attributes);
    $!v = cast( GVolume, i.get_value(self) );
  }

  method GIO::Raw::Definitions::GVolume
  #  is also<GVolume>
  { $!v }

  # cw: Remove when Method::Also is fixed
  method GVolume { $!v }

  # Is originally:
  # GVolume, gpointer --> void
  method changed {
    self.connect($!v, 'changed');
  }

  # Is originally:
  # GVolume, gpointer --> void
  method removed {
    self.connect($!v, 'removed');
  }

  method can_eject is also<can-eject> {
    so g_volume_can_eject($!v);
  }

  method can_mount is also<can-mount> {
    so g_volume_can_mount($!v);
  }

  proto method eject_with_operation (|)
      is also<eject-with-operation>
  { * }

  multi method eject_with_operation (
    Int()          $flags,
    Int()          $mount_operation,
                   &callback,
    gpointer       $user_data        = gpointer,
    GCancellable() $cancellable      = GCancellable
  ) {
    samewith($flags, $mount_operation, $cancellable, &callback, $user_data);
  }
  multi method eject_with_operation (
    Int()          $flags,
    Int()          $mount_operation,
    GCancellable() $cancellable,
                   &callback,
    gpointer       $user_data        = gpointer
  ) {
    my GMountUnmountFlags $f = $flags;
    my GMountOperation    $m = $mount_operation;

    g_volume_eject_with_operation(
      $!v,
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
    my $rv = so g_volume_eject_with_operation_finish($!v, $result, $error);
    set_error($error);
    $rv;
  }

  method enumerate_identifiers is also<enumerate-identifiers> {
    CStringArrayToArray( g_volume_enumerate_identifiers($!v) );
  }

  method get_activation_root (:$raw = False) is also<get-activation-root> {
    my $f = g_volume_get_activation_root($!v);

    $f ??
      ( $raw ?? $f !! GIO::File.new($f, :!ref) )
      !!
      Nil;
  }

  method get_drive (:$raw = False) is also<get-drive> {
    my $d = g_volume_get_drive($!v);

    $d ??
      ( $raw ?? $d !! ::('GIO::Drive').new($d, :!ref) )
      !!
      Nil;
  }

  method get_icon (:$raw = False) is also<get-icon> {
    my $i = g_volume_get_icon($!v);

    $i ??
      ( $raw ?? $i !! GIO::Icon.new($i, :!ref) )
      !!
      Nil;
  }

  method get_identifier (Str() $kind) is also<get-identifier> {
    g_volume_get_identifier($!v, $kind);
  }

  method get_mount (:$raw = False) is also<get-mount> {
    my $m = g_volume_get_mount($!v);

    $m ??
      ( $raw ?? $m !! ::('GIO::Mount').new($m, :!ref) )
      !!
      Nil;
  }

  method get_name is also<get-name> {
    g_volume_get_name($!v);
  }

  method get_sort_key is also<get-sort-key> {
    g_volume_get_sort_key($!v);
  }

  method get_symbolic_icon (:$raw = False) is also<get-symbolic-icon> {
    my $i = g_volume_get_symbolic_icon($!v);

    $i ??
      ( $raw ?? $i !! GIO::Icon.new($i, :!ref) )
      !!
      Nil;
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_volume_get_type, $n, $t );
  }

  method get_uuid is also<get-uuid> {
    g_volume_get_uuid($!v);
  }

  multi method mount (
    Int()        $flags,
    Int()        $mount_operation,
                 &callback,
    gpointer     $user_data                                   = gpointer,
    GCancellable :$cancellable                                = GCancellable

  ) {
    samewith($flags, $mount_operation, $cancellable, &callback, $user_data);
  }
  multi method mount (
    Int()          $flags,
    Int()          $mount_operation,
    GCancellable() $cancellable,
                   &callback,
    gpointer       $user_data = gpointer
  ) {
    my GMountUnmountFlags $f = $flags;
    my GMountOperation    $m = $mount_operation;

    g_volume_mount(
      $!v,
      $flags,
      $mount_operation,
      $cancellable,
      &callback,
      $user_data
    );
  }

  method mount_finish (
    GAsyncResult()          $result,
    CArray[Pointer[GError]] $error   = gerror
  )
    is also<mount-finish>
  {
    clear_error;
    my $rv = so g_volume_mount_finish($!v, $result, $error);
    set_error($error);
    $rv;
  }

  method should_automount is also<should-automount> {
    so g_volume_should_automount($!v);
  }

}

our subset GVolumeAncestry is export of Mu
  where GVolume | GObject;

class GIO::Volume does GLib::Roles::Object does GIO::Roles::Volume {

  submethod BUILD (:$volume) {
    self.setGVolume($volume) if $volume;
  }

  method setGVolume (GVolumeAncestry $_) {
    my $to-parent;

    $!v = do {
      when GVolume {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GVolume, $_);
      }
    }
    self!setObject($to-parent);
  }

  method new (GVolumeAncestry $volume, :$ref = True) {
    return Nil unless $volume;

    my $o = self.bless(:$volume);
    $o.ref if $ref;
    $o;
  }

}
