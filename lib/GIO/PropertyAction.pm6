use v6.c;

use Method::Also;
use NativeCall;

use GIO::Raw::Types;

use GLib::Value;

use GLib::Roles::Object;
use GIO::Roles::Action;

our subset GPropertyActionAncestry is export of Mu
  where GPropertyAction | GAction | GObject;

class GIO::PropertyAction {
  also does GLib::Roles::Object;
  also does GIO::Roles::Action;

  has GPropertyAction $!pa is implementor;

  submethod BUILD (:$action) {
    self.setGPropertyAction($action) if $action;
  }

  method setGPropertyAction(GPropertyActionAncestry $_) {
    my $to-parent;

    $!pa = do {
      when GPropertyAction {
        $to-parent = cast(GObject, $_);
        $_;
      }

      when GAction {
        $to-parent = cast(GObject, $_);
        $!a = $_;
        cast(GPropertyAction, $_);
      }

      default {
        $to-parent = $_;
        cast(GPropertyAction, $_);
      }
    }
    self!setObject($to-parent);
    self.roleInit-Action;
  }

  method GIO::Raw::Definitions::GPropertyAction
    is also<GPropertyAction>
  { $!pa }

  proto method new (|)
  { * }

  multi method new (GPropertyActionAncestry $action, :$ref = True) {
    return Nil unless $action;

    my $o = self.bless( :$action );
    $o.ref if $ref;
    $o;
  }
  multi method new (
    Str()            $property_name,
    GObjectOrPointer $object is copy;
  ) {
    # Shortcut where <action-name> is also the <property-name>
    samewith($property_name, $object, $property_name);
  }
  multi method new (
    Str()            $name,
    Str()            $property_name,
    GObjectOrPointer $object         is copy
  ) {
    samewith($name, $object, $property_name);
  }
  multi method new (
    Str()            $name,
    GObjectOrPointer $object         is copy,
    Str()            $property_name
  ) {
    $object .= GObject if $object ~~ GLib::Roles::Object;
    my $action = g_property_action_new($name, $object, $property_name);

    $action ?? self.bless( :$action ) !! Nil;
  }

  # Type: gboolean
  method enabled is rw  {
    my GLib::Value $gv .= new( G_TYPE_BOOLEAN );
    Proxy.new(
      FETCH => -> $ {
        $gv = GLib::Value.new(
          self.prop_get('enabled', $gv)
        );
        $gv.boolean;
      },
      STORE => -> $, Int() $val is copy {
        warn '.enabled does not allow writing'
      }
    );
  }

  # Type: gboolean
  method invert-boolean is rw is also<invert_boolean> {
    my GLib::Value $gv .= new( G_TYPE_BOOLEAN );
    Proxy.new(
      FETCH => -> $ {
        $gv = GLib::Value.new(
          self.prop_get('invert-boolean', $gv)
        );
        $gv.boolean;
      },
      STORE => -> $, Int() $val is copy {
        $gv.boolean = $val.so.Int;
        self.prop_set('invert-boolean', $gv);
      }
    );
  }

  # Type: Str
  method name is rw  {
    my GLib::Value $gv .= new( G_TYPE_STRING );
    Proxy.new(
      FETCH => -> $ {
        $gv = GLib::Value.new(
          self.prop_get('name', $gv)
        );
        $gv.string;
      },
      STORE => -> $, Str() $val is copy {
        $gv.string = $val;
        self.prop_set('name', $gv);
      }
    );
  }

  # Type: GObject
  method object is rw  {
    my GLib::Value $gv .= new( G_TYPE_OBJECT );
    Proxy.new(
      FETCH => -> $ {
        warn '.object does not allow reading' if $DEBUG;
        GObject;
      },
      STORE => -> $, GObject() $val is copy {
        $gv.object = $val;
        self.prop_set('object', $gv);
      }
    );
  }

  # Type: GVariantType
  method parameter-type (:$raw = False) is rw is also<parameter_type> {
    my GLib::Value $gv .= new( G_TYPE_BOXED );
    Proxy.new(
      FETCH => -> $ {
        $gv = GLib::Value.new(
          self.prop_get('parameter-type', $gv)
        );

        my $o = $gv.object;
        return Nil unless $o;

        $o = cast(GVariantType, $o);
        return $o if $raw;

        GLib::VariantType.new($o, :!ref);
      },
      STORE => -> $,  $val is copy {
        warn '.parameter-type does not allow writing';
      }
    );
  }

  # Type: Str
  method property-name is rw  is also<property_name> {
    my GLib::Value $gv .= new( G_TYPE_STRING );
    Proxy.new(
      FETCH => -> $ {
        warn '.property-name does not allow reading' if $DEBUG;
        '';
      },
      STORE => -> $, Str() $val is copy {
        $gv.string = $val;
        self.prop_set('property-name', $gv);
      }
    );
  }

  # Type: GVariant
  method state (:$raw = False) is rw  {
    my GLib::Value $gv .= new( G_TYPE_OBJECT );
    Proxy.new(
      FETCH => -> $ {
        $gv = GLib::Value.new(
          self.prop_get('state', $gv)
        );

        my $o = $gv.object;
        return Nil unless $o;

        $o = cast(GVariant, $o);
        return $o if $raw;

        GLib::Variant.new($o, :!ref);
      },
      STORE => -> $,  $val is copy {
        warn '.state does not allow writing'
      }
    );
  }

  # Type: GVariantType
  method state-type (:$raw = False) is rw  is also<state_type> {
    my GLib::Value $gv .= new( G_TYPE_BOXED );
    Proxy.new(
      FETCH => -> $ {
        $gv = GLib::Value.new(
          self.prop_get('state-type', $gv)
        );

        my $o = $gv.object;
        return Nil unless $o;

        $o = cast(GVariantType, $o);
        return $o if $raw;

        GLib::VariantType.new($o, :!ref);
      },
      STORE => -> $, $val is copy {
        warn 'state-type does not allow writing';
      }
    );
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_property_action_get_type, $n, $t );
  }

}

sub g_property_action_get_type ()
  returns GType
  is native(gio)
  is export
  { * }

sub g_property_action_new (Str $name, gpointer $object, Str $property_name)
  returns GPropertyAction
  is native(gio)
  is export
  { * }

# our %GIO::PropertyAction::RAW-DEFS;
# for MY::.pairs {
#   %GIO::PropertyAction::RAW-DEFS{.key} := .value
#     if .key.starts-with('&g_property_action_');
# }
