use v6.c;

use Method::Also;
use NativeCall;

use GIO::Raw::Types;
use GIO::Raw::SimpleActionGroup;

use GLib::Roles::Object;
use GIO::Roles::ActionGroup;
use GIO::Roles::ActionMap;

our subset GSimpleActionGroupAncestry is export of Mu
  where GSimpleActionGroup | GActionGroup | GActionMap;

class GIO::SimpleActionGroup {
  also does GLib::Roles::Object;
  also does GIO::Roles::ActionGroup;
  also does GIO::Roles::ActionMap;

  has GSimpleActionGroup $!gsag is implementor;

  submethod BUILD (:$group) {
    self.setGSimpleActionGroup($group) if $group;
  }

  method setGSimpleActionGroup (GSimpleActionGroupAncestry $_) {
    my $to-parent;

    $!gsag = do {
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
    self.roleInit-GActionGroup;
  }

  method GIO::Raw::Definitions::GSimpleActionGroup
    is also<GSimpleActionGroup>
  { $!gsag }

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
  multi method new (*@entries where *.elems >= 1) {
    samewith(@entries);
  }
  multi method new (@entries, :$entries = False) {
    say "E: { @entries.gist }";
    my $o = samewith;
    $entries ?? $o.add_entries(@entries) !! $o.insert(@entries);
    $o;
  }

  multi method add_entries (@entries, gpointer $user_data = gpointer) {
    samewith(
      GLib::Roles::TypedBuffer[GActionEntry].new(
        @entries,
        typed => GActionEntry
      ).p,
      @entries.elems,
      $user_data
    )
  }
  multi method add_entries (
    gpointer $entries,
    Int()    $n_entries,
    gpointer $user_data = gpointer
  ) {
    my gint $n = $n_entries;

    g_simple_action_group_add_entries($!gsag, $entries, $n, $user_data);
  }

  multi method insert (@actions) {
    self.insert($_) for @actions;
  }
  multi method insert (GAction() $action) {
    g_simple_action_group_insert($!gsag, $action);
  }

  method lookup (Str() $action_name) {
    g_simple_action_group_lookup($!gsag, $action_name);
  }

  method remove (Str() $action_name) {
    g_simple_action_group_remove($!gsag, $action_name);
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^new, &g_simple_action_group_get_type, $n, $t );
  }

}
