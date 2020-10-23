use v6.c;

use Method::Also;
use NativeCall;

use GIO::Raw::Types;

use GIO::Roles::ActionGroup;

use GLib::Roles::Object;

role GIO::Roles::RemoteActionGroup {
  also does GIO::Roles::ActionGroup;

  has GRemoteActionGroup $!rag;

  method GIO::Raw::Definitions::GRemoteActionGroup
    is also<GRemoteActionGroup>
  { $!rag }

  method roleInit-RemoteActionGroup is also<roleInit_RemoteActionGroup> {
    return if $!rag;

    my \i = findProperImplementor(self.^attributes);
    $!rag = cast( GRemoteActionGroup, i.get_value(self) );
  }

  method activate_action_full (
    Str()      $action_name,
    GVariant() $parameter,
    GVariant() $platform_data
  )
    is also<activate-action-full>
  {
    g_remote_action_group_activate_action_full(
      $!rag,
      $action_name,
      $parameter,
      $platform_data
    );
  }

  method change_action_state_full (
    Str()      $action_name,
    GVariant() $value,
    GVariant() $platform_data
  )
    is also<change-action-state-full>
  {
    g_remote_action_group_change_action_state_full(
      $!rag,
      $action_name,
      $value,
      $platform_data
    );
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_remote_action_group_get_type, $n, $t );
  }

}

our subset GRemoteActionGroupAncestry is export of Mu
  where GRemoteActionGroup | GObject;

class GIO::RemoteActionGroup does GLib::Roles::Object
                             does GIO::Roles::RemoteActionGroup
{

  submethod BUILD (:$group) {
    self.setGRemoteActionGroup($group) if $group;
  }

  method setGRemoteActionGroup (GRemoteActionGroupAncestry $_) {
    my $to-parent;

    $!rag = do {
      when GRemoteActionGroup {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GRemoteActionGroup, $_);
      }
    }
    self!setObject($to-parent);
  }

  method new (GRemoteActionGroupAncestry $group, :$ref = True) {
    return Nil unless $group;

    my $o = self.bless( :$group );
    $o.ref if $ref;
    $o;
  }

}


### /usr/include/glib-2.0/gio/gremoteactiongroup.h

sub g_remote_action_group_activate_action_full (
  GRemoteActionGroup $remote,
  Str                $action_name,
  GVariant           $parameter,
  GVariant           $platform_data
)
  is native(gio)
  is export
{ * }

sub g_remote_action_group_change_action_state_full (
  GRemoteActionGroup $remote,
  Str                $action_name,
  GVariant           $value,
  GVariant           $platform_data
)
  is native(gio)
  is export
{ * }

sub g_remote_action_group_get_type ()
  returns GType
  is native(gio)
  is export
{ * }

# our %GIO::RemoteActionGroup::RAW-DEFS;
# for MY::.pairs {
#   %GIO::RemoteActionGroup::RAW-DEFS{.key} := .value
#     if .key.starts-with('&g_remote_action_group_');
# }
