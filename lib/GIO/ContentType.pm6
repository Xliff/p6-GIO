use v6.c;

use Method::Also;
use NativeCall;

use GIO::Raw::Types;
use GIO::Raw::ContentType;

use GLib::GList;
use GIO::ThemedIcon;

use GLib::Roles::ListData;
use GLib::Roles::Object;
use GLib::Roles::StaticClass;

# STATIC CATCH-ALL
class GIO::ContentType {
  also does GLib::Roles::StaticClass;

  method can_be_executable (Str() $type) is also<can-be-executable> {
    so g_content_type_can_be_executable($type);
  }

  method equals (Str() $type1, Str() $type2) {
    so g_content_type_equals($type1, $type2);
  }

  method from_mime_type (Str() $mime_type) is also<from-mime-type> {
    g_content_type_from_mime_type($mime_type);
  }

  method get_registered (:$glist = False, :$raw = False)
    is also<
      get-registered
      registered
    >
  {
    my $list = g_content_types_get_registered();

    return Nil   unless $list;
    return $list if     $glist && $raw;

    $list = GLib::GList.new($list) but GLib::Roles::ListData[Str];
    return $list if $glist;

    $list.Array;
  }

  method get_description (Str() $type) is also<get-description> {
    g_content_type_get_description($type);
  }

  method get_generic_icon_name (Str() $type) is also<get-generic-icon-name> {
    g_content_type_get_generic_icon_name($type);
  }

  method get_icon (Str() $type, :$raw = False) is also<get-icon> {
    my $i = g_content_type_get_icon($type);

    # cw: Returned value is a GThemedIcon, from the source.
    $i ??
      ( $raw ?? $i !! GIO::ThemedIcon.new($i, :!ref) )
      !!
      Nil;
  }

  method get_mime_type (Str() $type) is also<get-mime-type> {
    g_content_type_get_mime_type($type);
  }

  method get_symbolic_icon (Str() $type, :$raw = False)
    is also<get-symbolic-icon>
  {
    my $si = g_content_type_get_symbolic_icon($type);

    # cw: Returned value is a GThemedIcon, from the source.
    $si ??
      ( $raw ?? $si !! GIO::ThemedIcon.new($si, :!ref) )
      !!
      Nil;
  }

  multi method guess (
    Str() $filename,
    Str() $data      = Str,
    Int() $data_size = 0,
  ) {
    samewith($filename, $data, $data_size, $, :all);
  }
  multi method guess (
    Str() $filename,
    Str() $data,
    Int() $data_size,
          $result_uncertain is rw,
          :$all             =  False
  ) {
    my gulong $ds = $data_size;
    my guint $ru  = 0;
    my $ct        = g_content_type_guess($filename, $data, $ds, $ru);

    $result_uncertain = $ru;
    # GLib::Memory.free($rc);
    $all.not ?? $ct !! ($ct, $result_uncertain);
  }

  method guess_for_tree (GFile() $root) is also<guess-for-tree> {
    CStringArrayToArray( g_content_type_guess_for_tree($root) );
  }

  method is_a (Str() $type, Str() $supertype) is also<is-a> {
    so g_content_type_is_a($type, $supertype);
  }

  method is_mime_type (Str() $type, Str() $mime_type) is also<is-mime-type> {
    so g_content_type_is_mime_type($type, $mime_type);
  }

  method is_unknown (Str() $type) is also<is-unknown> {
    so g_content_type_is_unknown($type);
  }

}
