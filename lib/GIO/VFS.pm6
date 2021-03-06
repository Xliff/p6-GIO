use v6.c;

use Method::Also;

use GIO::Raw::Types;
use GIO::Raw::VFS;

use GLib::Roles::Object;

our subset GVfsAncestry is export of Mu
  where GVfs | GObject;

class GIO::VFS {
  also does GLib::Roles::Object;

  has GVfs $!fs is implementor;

  submethod BUILD (:$vfs) {
    self.setGVfs($vfs) if $vfs;
  }

  method setGVfs (GVfsAncestry $_) {
    my $to-parent;

    $!fs = do {
      when GVfs {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GVfs, $_);
      }
    }
    self!setObject($to-parent);
  }

  method GIO::Raw::Definitions::GVfs
    is also<GVfs>
  { $!fs }

  method new (GVfs $vfs, :$ref = True) {
    return Nil unless $vfs;

    my $o = self.bless(:$vfs);
    $o.ref if $ref;
    $o;
  }

  method get_default is also<get-default> {
    my $vfs = g_vfs_get_default();

    $vfs ?? self.bless(:$vfs) !! Nil;
  }

  method get_local is also<get-local> {
    my $vfs = g_vfs_get_local();

    $vfs ?? self.bless(:$vfs) !! Nil;
  }

  method get_file_for_path (Str() $path, :$raw = False)
    is also<get-file-for-path>
  {
    my $f = g_vfs_get_file_for_path($!fs, $path);

    $f ??
      ( $raw ?? $f !! GIO::File.new($f, :!ref) )
      !!
      Nil;
  }

  method get_file_for_uri (Str() $uri, :$raw = False)
    is also<get-file-for-uri>
  {
    my $f = g_vfs_get_file_for_uri($!fs, $uri);

    $f ??
      ( $raw ?? $f !! GIO::File.new($f, :!ref) )
      !!
      Nil;
  }

  method get_supported_uri_schemes
    is also<
      get-supported-uri-schemes
      supported_uri_schemes
      supported-uri-schemes
    >
  {
    CStringArrayToArray( g_vfs_get_supported_uri_schemes($!fs) );
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_vfs_get_type, $n, $t );
  }

  method is_active is also<is-active> {
    so g_vfs_is_active($!fs);
  }

  method parse_name (Str() $parse_name, :$raw = False) is also<parse-name> {
    my $f = g_vfs_parse_name($!fs, $parse_name);

    $f ??
      ( $raw ?? $f !! GIO::File.new($f, :!ref) )
      !!
      Nil;
  }

  method register_uri_scheme (
    Str()              $scheme,
                       &uri_func,
    gpointer           $uri_data,
                       &uri_destroy,
                       &parse_name_func,
    gpointer           $parse_name_data,
                       &parse_name_destroy
  )
    is also<register-uri-scheme>
  {
    so g_vfs_register_uri_scheme(
      $!fs,
      $scheme,
      &uri_func,
      $uri_data,
      &uri_destroy,
      &parse_name_func,
      $parse_name_data,
      &parse_name_destroy
    );
  }

  method unregister_uri_scheme (Str() $scheme) is also<unregister-uri-scheme> {
    so g_vfs_unregister_uri_scheme($!fs, $scheme);
  }

}
