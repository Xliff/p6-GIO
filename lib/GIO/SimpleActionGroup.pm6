use v6.c;

use Method::Also;
use NativeCall;

use GIO::Raw::Types;

use GLib::Roles::Object;
use GIO::Roles::ActionGroup;
use GIO::Roles::ActionMap;

our subset GSimpleActionGroupAncestry is export of Mu
  where GSimpleActionGroup | GActionGroup | GActionMap;

class GIO::SimpleActionGroup {
  also does GLib::Roles::Object;
  also does GIO::Roles::ActionGroup;
  also does GIO::Roles::ActionMap;

  has GSimpleActionGroup $!sag is implementor;

  submethod BUILD (:$group) {
    self.setGSimpleActionGroup($group) if $group;
  }

  method setGSimpleActionGroup (GSimpleActionGroupAncestry $_) {
    my $to-parent;

    $!sag = do {
      when GSimpleActionGroup {
          $to-parent = cast(GObject, $_);
          $_
      }

      when GActionGroup {
        $to-parent = cast(GObject, $_);
        $!ag = $_;
        cast(GSimpleActionGroup, $_)
      }

      when GActionMap {
        $to-parent = cast(GObject, $_);
        $!actmap = $_;
        cast(GSimpleActionGroup, $_);
      }

      default {
        $to-parent = $_;
        cast(GSimpleActionGroup, $_)
      }
    }
    self!setObject($to-parent);
    self.roleInit-ActionMap;
    self.roleInit-ActionGroup;
  }

  multi method new (GSimpleActionGroupAncestry $group, :$ref = True) {
    return Nil unless $group;

    my $o = self.bless( :$group );
    $o.ref if $ref;
    $o;
  }
  multi method new {
    my $group = g_simple_action_group_new();

    $group ?? self.bless( :$group ) !! Nil;
  }


  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^new, &g_simple_action_group_get_type, $n, $t );
  }

}

sub g_simple_action_group_get_type ()
  returns GType
  is native(gio)
  is export
  { * }

sub g_simple_action_group_new ()
  returns GSimpleActionGroup
  is native(gio)
  is export
  { * }

# our %GIO::SimpleActionGroup::RAW-DEFS;
# for MY::.pairs {
#   %GIO::SimpleActionGroup::RAW-DEFS{.key} := .value
#     if .key.starts-with('&g_simple_action_group_');
# }
