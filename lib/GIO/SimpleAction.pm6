use v6.c;

use Method::Also;
use NativeCall;

use GIO::Raw::Types;
use GIO::Raw::SimpleAction;

use GLib::Value;

use GLib::Roles::Object;
use GIO::Roles::Action;

our subset GSimpleActionAncestry is export of Mu
  where GSimpleAction | GAction | GObject;

class GIO::SimpleAction {
  also does GLib::Roles::Object;
  also does GIO::Roles::Action;

  has GSimpleAction $!sa is implementor;

  submethod BUILD (:$simple-action) {
    self.setGSimpleAction($simple-action) if $simple-action;
  }

  method setGSimpleAction (GSimpleActionAncestry $_) {
    my $to-parent;
    $!sa = do {
      when GSimpleAction {
        $to-parent = cast(GObject, $_);
        $_;
      }

      when GAction {
        $to-parent = cast(GObject, $_);
        $!a = $_;
        cast(GSimpleAction, $_);
      }

      default {
        $to-parent = $_;
        cast(GSimpleAction, $_);
      }
    }

    self!setObject($to-parent);
    self.roleInit-GAction;
  }

  method GIO::Raw::Definitions::GSimpleAction
    is also<GSimpleAction>
  { $!sa }

  proto method new (|)
  { * }

  multi method new (GSimpleActionAncestry $simple-action, :$ref = True) {
    return Nil unless $simple-action;

    my $o = self.bless( :$simple-action );
    $o.ref if $ref;
    $o;
  }
  multi method new (Str $parameter_type) {
    my $p = ( CArray[uint8].allocate(1) )[0] = $parameter_type.substr(0, 1);

    my $simple-action = g_simple_action_new($p);

    $simple-action ?? self.bless( :$simple-action ) !! Nil;
  }

  method new_stateful (GVariantType() $parameter_type, GVariant() $state)
    is also<new-stateful>
  {
    my $simple-action = g_simple_action_new_stateful($parameter_type, $state);

    $simple-action ?? self.bless( :$simple-action ) !! Nil;
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
        $gv.boolean = $val;
        self.prop_set('enabled', $gv);
      }
    );
  }

  # CONSTRUCT-ONLY!
  #
  # Type: Str
  # method name is rw  {
  #   my GLib::Value $gv .= new( G_TYPE_STRING );
  #   Proxy.new(
  #     FETCH => -> $ {
  #       $gv = GLib::Value.new(
  #         self.prop_get('name', $gv)
  #       );
  #       $gv.string;
  #     },
  #     STORE => -> $, Str() $val is copy {
  #       $gv.string = $val;
  #       self.prop_set('name', $gv);
  #     }
  #   );
  # }
  #
  # # Type: GVariantType
  # method parameter-type is rw  {
  #   my GLib::Value $gv .= new( -type- );
  #   Proxy.new(
  #     FETCH => -> $ {
  #       $gv = GLib::Value.new(
  #         self.prop_get('parameter-type', $gv)
  #       );
  #       #$gv.TYPE
  #     },
  #     STORE => -> $,  $val is copy {
  #       #$gv.TYPE = $val;
  #       self.prop_set('parameter-type', $gv);
  #     }
  #   );
  # }

  # Type: GVariant
  method state (:$raw = False) is rw  {
    my GLib::Value $gv .= new( G_TYPE_VARIANT );
    Proxy.new(
      FETCH => -> $ {
        $gv = GLib::Value.new(
          self.prop_get('state', $gv)
        );
        propReturnObject($gv.variant, $raw, |GLib::Variant.getTypePair);
      },
      STORE => -> $, GVariant() $val is copy {
        $gv.variant = $val;
        self.prop_set('state', $gv);
      }
    );
  }

  # Type: GVariantType
  method state-type (:$raw = False) is rw is also<state_type> {
    my GLib::Value $gv .= new( G_TYPE_VARIANT );
    Proxy.new(
      FETCH => -> $ {
        $gv = GLib::Value.new(
          self.prop_get('state-type', $gv)
        );
        propReturnObject($gv.variant, $raw, GLib::Variant.getTypePair);
      },
      STORE => -> $, $val is copy {
        warn "state-type does not allow writing"
      }
    );
  }

  # Is originally:
  # GSimpleAction, GVariant, gpointer --> void
  method activate {
    self.connect-variant($!sa, 'activate');
  }

  # Is originally:
  # GSimpleAction, GVariant, Pointer
  method change-state is also<change_state> {
    self.connect-variant($!sa, 'change-state');
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_simple_action_get_type, $n, $t );
  }

  method set_enabled (Int() $enabled) is also<set-enabled> {
    my gboolean $e = $enabled.so.Int;

    g_simple_action_set_enabled($!sa, $e);
  }

  method set_state (GVariant() $value) is also<set-state> {
    g_simple_action_set_state($!sa, $value);
  }

  method set_state_hint (GVariant() $state_hint) is also<set-state-hint> {
    g_simple_action_set_state_hint($!sa, $state_hint);
  }

}
