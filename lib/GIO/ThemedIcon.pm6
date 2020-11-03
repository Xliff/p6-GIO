use v6.c;

use Method::Also;
use NativeCall;

use GIO::Raw::Types;
use GIO::Raw::ThemedIcon;

use GLib::Value;

use GLib::Roles::Object;
use GIO::Roles::Icon;

our subset GThemedIconAncestry is export of Mu
  where GThemedIcon | GIcon | GObject;

class GIO::ThemedIcon {
  also does GLib::Roles::Object;
  also does GIO::Roles::Icon;

  has GThemedIcon $!ti is implementor;

  submethod BUILD (:$themed-icon, :$icon) {
    self.setGThemedIcon($themed-icon // $icon) if $themed-icon || $icon;
  }

  method setGThemedIcon (GThemedIconAncestry $_) {
    my $to-parent;

    $!ti = do {
      when GThemedIcon {
        $to-parent = cast(GObject, $_);
        $_;
      }

      when GIcon {
        $to-parent = cast(GObject, $_);
        $!icon = $_;
        cast(GObject, $_);
      }

      default {
        $to-parent = $_;
        cast(GObject, $_);
      }
    }
    self!setObject($to-parent);
    self.roleInit-Icon;
  }

  method GIO::Raw::Definitions::GThemedIcon
    is also<GThemedIcon>
  { $!ti }

  # cw: XXX - XXX - XXX
  #     The following two multi's illustrate a potential bug in Raku.
  #     Given the more restrictive nature of the following multi:
  multi method new (GThemedIconAncestry $themed-icon, :$ref = True) {
    return Nil unless $themed-icon;

    my $o = self.bless( :$themed-icon );
    $o.ref if $ref;
    $o;
  }
  # ... why is it that this multi (if made coercive) is used?
  multi method new (Str $icon-name) {
    my $themed-icon = g_themed_icon_new($icon-name);

    $themed-icon ?? self.bless( :$themed-icon ) !! Nil;
  }

  proto method new_from_names (|)
      is also<new-from-names>
  { * }

  multi method new (
    @names,
    :from-names(
      :from_names( :$names )
    ) is required
  ) {
    self.new_from_names(@names);
  }
  multi method new_from_names(@names) {
    samewith(
      ArrayToCArray(Str, @names),
      @names.elems
    );
  }
  multi method new (
    CArray[Str] $n,
    Int() $len,
    :from-names(
      :from_names( :$names )
    ) is required
  ) {
    self.new_from_names($n, $len);
  }
  multi method new_from_names (CArray[Str] $names, Int() $len) {
    my gint $l            = $len;
    my       $themed-icon = g_themed_icon_new_from_names($names, $l);

    $themed-icon ?? self.bless( :$themed-icon ) !! Nil;
  }

  multi method new (
    Str() $icon-name,
    :with_defaut_fallbacks(
      :with-default-fallbacks(
        :default_fallbacks(
          :default-fallbacks( :$fallbacks )
        )
      )
    ) is required
  ) {
    self.new_with_default_fallbacks($icon-name);
  }
  method new_with_default_fallbacks (Str() $icon-name)
    is also<new-with-default-fallbacks>
  {
    my $themed-icon = g_themed_icon_new_with_default_fallbacks($icon-name);

    $themed-icon ?? self.bless( :$themed-icon ) !! Nil;
  }

  # Type: gboolean
  method use-default-fallbacks is rw  {
    my GLib::Value $gv .= new( G_TYPE_BOOLEAN );
    Proxy.new(
      FETCH => -> $ {
        $gv = GLib::Value.new(
          self.prop_get('use-default-fallbacks', $gv)
        );
        $gv.boolean;
      },
      STORE => -> $, $val is copy {
        warn 'use-default-fallbacks does not allow writing';
      }
    );
  }

  method append_name (Str() $iconname) is also<append-name> {
    g_themed_icon_append_name($!ti, $iconname);
  }

  method get_names
    is also<
      get-names
      names
    >
  {
    my $sl = g_themed_icon_get_names($!ti);

    CStringArrayToArray( $sl );
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_themed_icon_get_type, $n, $t );
  }

  method prepend_name (Str() $iconname) is also<prepend-name> {
    g_themed_icon_prepend_name($!ti, $iconname);
  }

}
