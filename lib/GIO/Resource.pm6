use v6.c;

use Method::Also;
use NativeCall;

use GIO::Raw::Types;
use GIO::Raw::Resource;

use GLib::Bytes;

use GLib::Roles::Implementor;

use GLib::Roles::StaticClass;

class GIO::Resources {
  also does GLib::Roles::StaticClass;

  method enumerate_children (
    Str()                   $path,
    Int()                   $lookup_flags,
    CArray[Pointer[GError]] $error         = gerror,
                            :$raw          = False
  )
    is also<enumerate-children>
  {
    my GResourceLookupFlags $l = $lookup_flags;

    clear_error;
    my $c = g_resources_enumerate_children($path, $l, $error);
    set_error($error);

    # Should be offering this for all CArray[Str]...
    $c ??
      ( $raw ?? $c !! CStringArrayToArray($c) )
      !!
      Nil;
  }

  proto method get_info (|)
    is also<get-info>
  { * }

  multi method get_info (
    Str()                   $path,
    Int()                   $lookup_flags,
    CArray[Pointer[GError]] $error         = gerror,
  ) {
    return-with-all(
      samewith($path, $lookup_flags, $, $, $error, :all)
    );
  }
  multi method get_info (
    Str()                   $path,
    Int()                   $lookup_flags,
                            $size          is rw,
                            $flags         is rw,
    CArray[Pointer[GError]] $error         =  gerror,
                            :$all          =  False
  ) {
    my gsize                $s = 0;
    my guint                $f = 0;
    my GResourceLookupFlags $l = $lookup_flags;

    clear_error;
    my $rv = so g_resources_get_info($path, $l, $s, $f, $error);
    set_error($error);
    ($size, $flags) = ($s, $f);
    $all.not ?? $rv !! ($rv, $size, $flags);
  }

  method lookup_data (
    Str()                   $path,
    Int()                   $lookup_flags,
    CArray[Pointer[GError]] $error         = gerror,
                            :$raw          = False
  )
    is also<lookup-data>
  {
    my GResourceLookupFlags $l = $lookup_flags;

    clear_error;
    my $b = g_resources_lookup_data($path, $l, $error);
    set_error($error);

    $b ??
      ( $raw ?? $b !! GLib::Bytes.new($b, :!ref) )
      !!
      Nil;
  }

  method open_stream (
    Str()                   $path,
    Int()                   $lookup_flags,
    CArray[Pointer[GError]] $error         = gerror,
                            :$raw          = False
  )
    is also<open-stream>
  {
    my GResourceLookupFlags $l = $lookup_flags;

    clear_error;
    my $i = g_resources_open_stream($path, $l, $error);
    set_error($error);

    $i ??
      ( $raw ?? $i !! GIO::InputStream.new($i, :!ref) )
      !!
      Nil;
  }

  method register (GResource() $r) {
    g_resources_register($r);
  }

  method unregister (GResource $r) {
    g_resources_unregister($r);
  }

}

# BOXED
class GIO::Resource {
  also does GLib::Roles::Implementor;

  has GResource $!r is implementor;

  submethod BUILD (:$resource) {
    $!r = $resource;
  }

  method GIO::Raw::Definitions::GResource
    is also<GResource>
  { $!r }

  multi method new (GResource $resource, :$ref = True) {
    return Nil unless $resource;

    my $o = self.bless( :$resource );
    $o.ref if $ref;
    $o;
  }
  multi method new (Str() $filename, CArray[Pointer[GError]] $error = gerror)
    is also<load>
  {
    clear_error;
    my $resource = g_resource_load($filename, $error);
    set_error($error);

    $resource ?? self.bless( :$resource ) !! Nil;
  }

  method new_from_data (
    GBytes() $data,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<new-from-data>
  {
    clear_error;
    my $resource = g_resource_new_from_data($data, $error);
    set_error($error);

    $resource ?? self.bless( :$resource ) !! Nil;
  }

  method enumerate_children (
    Str()                   $path,
    Int()                   $lookup_flags  = 0,
    CArray[Pointer[GError]] $error         = gerror,
                            :$raw          = False
  )
    is also<enumerate-children>
  {
    my GResourceLookupFlags $l = $lookup_flags;

    clear_error;
    my $c = g_resource_enumerate_children($!r, $path, $lookup_flags, $error);
    set_error($error);

    # Should be offering this for all CArray[Str]...
    $c ??
      ( $raw ?? $c !! CStringArrayToArray($c) )
      !!
      Nil;
  }

  method error_quark is also<error-quark> {
    g_resource_error_quark();
  }

  proto method get_info (|)
    is also<get-info>
  { * }

  multi method get_info (
    Str()                   $path,
    Int()                   $lookup_flags,
    CArray[Pointer[GError]] $error        = gerror,
  ) {
    return-with-all(
      samewith($path, $lookup_flags, $, $, $error, :all)
    )
  }
  multi method get_info (
    Str()                   $path,
    Int()                   $lookup_flags,
                            $size          is rw,
                            $flags         is rw,
    CArray[Pointer[GError]] $error         = gerror,
                            :$all          = False
  ) {
    my gsize                $s = 0;
    my guint                $f = 0;
    my GResourceLookupFlags $l = $lookup_flags;

    clear_error;
    my $rv = so g_resource_get_info($!r, $path, $l, $s, $f, $error);
    set_error($error);
    ($size, $flags) = ($s, $f);
    $all.not ?? $rv !! ($rv, $size, $flags);
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_resource_get_type, $n, $t )
  }

  method lookup_data (
    Str()                   $path,
    Int()                   $lookup_flags  = 0,
    CArray[Pointer[GError]] $error         = gerror,
                            :$raw          = False
  )
    is also<lookup-data>
  {
    my GResourceLookupFlags $l = $lookup_flags;

    clear_error;
    my $b = g_resource_lookup_data($!r, $path, $l, $error);
    set_error($error);

    $b ??
      ( $raw ?? $b !! GLib::Bytes.new($b, :!ref) )
      !!
      Nil;

  }

  method open_stream (
    Str()                   $path,
    Int()                   $lookup_flags,
    CArray[Pointer[GError]] $error         = gerror,
                            :$raw          = False
  )
    is also<open-stream>
  {
    my GResourceLookupFlags $l = $lookup_flags;

    clear_error;
    my $i = g_resource_open_stream($!r, $path, $l, $error);

    $i ??
      ( $raw ?? $i !! GIO::InputStream.new($i, :!ref) )
      !!
      Nil;
  }

  method ref {
    g_resource_ref($!r);
    self;
  }

  method register {
    GIO::Resources.register($!r);
  }

  method unregister {
    GIO::Resources.unregister($!r);
  }

  method unref {
    g_resource_unref($!r);
  }

}

our %GIO::Resource::CLASSES = (
  'GIO::Resource'  => GIO::Resource,
  'GIO::Resources' => GIO::Resources
);
