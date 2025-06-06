use v6.c;

use Method::Also;
use NativeCall;

use GIO::Raw::Types;
use GIO::Raw::SettingsBackend;

use GLib::Roles::Object;

our subset GSettingsBackendAncestry is export of Mu
  where GSettingsBackend | GObject;

class GIO::Settings::Backend {
  also does GLib::Roles::Object;

  has GSettingsBackend $!sb is implementor;

  submethod BUILD (:$backend) {
    self.setGSettingsBackend($backend) if $backend;
  }

  method setGSettingsBackend (GSettingsBackendAncestry $_) {
    my $to-parent;

    $!sb = do {
      when GSettingsBackend {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GSettingsBackend, $_);
      }
    }
    self!setObject($to-parent);
  }

  method GIO::Raw::Definitions::GSettingsBackend
    is also<GSettingsBackend>
  { $!sb }

  multi method new (GSettingsBackend $backend, :$ref = True) {
    return Nil unless $backend;

    my $o = self.bless( :$backend );
    $o.upref if $ref;
    $o;
  }

  multi method new (
    Str() $filename,
    Str() $root_path,
    Str() $root_group,
          :$keyfile    is required
  ) {
    self.new_keyfile_backend($filename, $root_path, $root_group);
  }
  method new_keyfile_backend (
    Str() $filename,
    Str() $root_path,
    Str() $root_group
  )
    is also<new-keyfile-backend>
  {
    my $backend = g_settings_backend_keyfile_new(
      $filename,
      $root_path,
      $root_group
    );

    $backend ?? self.bless( :$backend ) !! Nil;
  }

  multi method new ( :$memory is required ) {
    self.new_memory_backend;
  }
  method new_memory_backend is also<new-memory-backend> {
    my $backend = g_settings_backend_memory_new();

    $backend ?? self.bless( :$backend ) !! Nil;
  }

  multi method new ( :$null is required ) {
    self.new_null_backend;
  }
  method new_null_backend is also<new-null-backend> {
    my $backend = g_settings_backend_null_new();

    $backend ?? self.bless( :$backend ) !! Nil;
  }

  multi method new {
    self.get_default;
  }
  method get_default
    is also<
      get-default
      default
    >
  {
    my $backend = g_settings_backend_get_default();

    $backend ?? self.bless( :$backend ) !! Nil;
  }

  proto method backend_keys_changed (|)
      is also<backend-keys-changed>
  { * }

  multi method backend_keys_changed (
    Str()    $path,
             @items,
    gpointer $origin_tag
  ) {
    samewith($path, resolve-gstrv(@items), $origin_tag);
  }
  multi method backend_keys_changed (
    Str              $path,
    CArray[Str]      $items,
    gpointer         $origin_tag
  ) {
    g_settings_backend_keys_changed ($!sb, $path, $items, $origin_tag);
  }

  method changed (Str() $key, gpointer $origin_tag) {
    g_settings_backend_changed($!sb, $key, $origin_tag);
  }

  method changed_tree (GTree() $tree, gpointer $origin_tag)
    is also<changed-tree>
  {
    g_settings_backend_changed_tree($!sb, $tree, $origin_tag);
  }

  proto method flatten_tree (|)
      is also<flatten-tree>
  { * }

  multi method flatten_tree (
    GIO::Settings::Backend:U:
    GTree()                 $tree,
                            :$raw = False
  ) {
    GIO::Settings::Backend.flatten_tree($tree, $, $, $, :$raw);
  }
  multi method flatten_tree (
    GIO::Settings::Backend:U:
    GTree()                 $tree,
                            $path   is rw,
                            $keys   is rw,
                            $values is rw,
                            :$raw   =  False;
  ) {
    my $pa = CArray[Str].new;
    $pa[0] = Str;

    my $ka = CArray[CArray[Str]].new;
    $ka[0] = CArray[Str];

    my $va = CArray[CArray[GVariant]].new;
    $va[0] = CArray[GVariant];

    g_settings_backend_flatten_tree($tree, $pa, $ka, $va);

    $path   = $pa[0] ?? $pa[0]                      !! Nil;
    $keys   = $ka[0] ?? CStringArrayToArray($ka[0]) !! Nil;

    $values = do if $va[0] {
      my @v = CArrayToArray( $va[0] );
      @v .= map({ GLib::Variant.new($_) }) unless $raw;
      @v;
    } else {
      Nil
    };
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_settings_backend_get_type, $n, $t );
  }

  method path_changed (Str() $path, gpointer $origin_tag)
    is also<path-changed>
  {
    g_settings_backend_path_changed($!sb, $path, $origin_tag);
  }

  method path_writable_changed (Str() $path)
    is also<path-writable-changed>
  {
    g_settings_backend_path_writable_changed($!sb, $path);
  }

  method writable_changed (Str() $key)
    is also<writable-changed>
  {
    g_settings_backend_writable_changed($!sb, $key);
  }

}
