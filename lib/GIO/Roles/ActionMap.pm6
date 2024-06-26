use v6.c;

use NativeCall;

use GLib::Raw::Traits;
use GIO::Raw::Types;

use GIO::SimpleAction;

use GLib::Roles::Object;
use GLib::Roles::TypedBuffer;

role GIO::Roles::ActionMap {
  has GActionMap $!actmap;

  method GIO::Raw::Definitions::GActionMap { $!actmap }

  method GActionMap { $!actmap }

  method roleInit-GActionMap {
    return if $!actmap;

    my \i = findProperImplementor(self.^attributes);
    $!actmap = cast( GActionMap, i.get_value(self) );
  }
  method roleInit-ActionMap {
    self.roleInit-GActionMap;
  }

  method add_action (GAction() $action) {
    g_action_map_add_action($!actmap, $action);
  }

  proto method add_action_entries (|)
  { * }

  multi method add_action_entries (
    @entries,
    gpointer $user_data = Pointer
  ) {
    @entries .= map({
      do {
        when GActionEntry                { $_ }
        when .^can('GActionEntry').elems { .GActionEntry }
        default {
          die '@entries should only consist of GActionEntry compatible objects'
        }
      }
    });
    my $lb = GLib::Roles::TypedBuffer[GActionEntry].new(@entries);

    samewith($lb.p, @entries.elems, $user_data);
  }
  multi method add_action_entries (
    Pointer  $entries,              # BLOCK of GActionEntry structs
    Int()    $n_entries,
    gpointer $user_data  = Pointer
  ) {
    my gint $n = $n_entries;

    g_action_map_add_action_entries($!actmap, $entries, $n, $user_data);
  }

  method get_gactionmap_type {
    state ($n, $t);

    unstable_get_type( self.^name, &g_action_map_get_type, $n, $t );
  }

  method lookup_action (Str() $action_name, :$raw = False) {
    propReturnObject(
      g_action_map_lookup_action($!actmap, $action_name),
      $raw,
      |GIO::SimpleAction.getTypePair
    );
  }

  method remove_action (Str() $action_name) {
    g_action_map_remove_action($!actmap, $action_name);
  }

  method add-action (|c) {
    self.add_action(|c)
  }

  method add-action-entries (|c) {
    self.add_action_entries(|c)
  }

  method lookup-action (|c) {
    self.lookup_action(|c)
  }

  method remove-action (|c) {
    self.remove_action(|c)
  }

}

our subset GActionMapAncestry is export of Mu
  where GActionMap | GObject;

class GIO::ActionMap {
  also does GLib::Roles::Object;
  also does GIO::Roles::ActionMap;

  submethod BUILD (:$action-map) {
    self.setGActionMap($action-map) if $action-map;
  }

  method setGActionMap (GActionMapAncestry $_) {
    my $to-parent;

    $!actmap = do {
      when GActionMap {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GActionMap, $_);
      }
    }
    self!setObject($to-parent);
  }

  method new (GActionMapAncestry $action-map, :$ref = True) {
    return Nil unless $action-map;

    my $o = self.bless( :$action-map );
    $o.ref if $ref;
    $o;
  }

  method get_type is static {
    self.get_gactionmap_type
  }
}

### /usr/src/glib/gio/gactionmap.h

sub g_action_map_add_action (
  GActionMap $action_map,
  GAction    $action
)
  is native(gio)
  is export
  { * }

sub g_action_map_add_action_entries (
  GActionMap $action_map,
  Pointer    $entries,                   # BLOCK of GActionEntry
  gint       $n_entries,
  gpointer   $user_data
)
  is native(gio)
  is export
  { * }

sub g_action_map_get_type ()
  returns GType
  is      native(gio)
  is      export
  { * }

sub g_action_map_lookup_action (
  GActionMap $action_map,
  Str        $action_name
)
  returns GAction
  is      native(gio)
  is      export
  { * }

sub g_action_map_remove_action (
  GActionMap $action_map,
  Str        $action_name
)
  is native(gio)
  is export
  { * }

# our %GIO::Roles::ActionMap::RAW-DEFS;
# for MY::.pairs {
#   %GIO::Roles::ActionMap::RAW-DEFS{.key} := .value
#     if .key.starts-with('&g_action_map_');
# }
