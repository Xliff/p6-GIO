use v6.c;

use MONKEY-TYPING;

use GIO::Raw::Definitions;
use GIO::Raw::Structs;

augment class GDBusNodeInfo {

  method nodes (:$raw = False) is rw {
    my $outer-nodes     = $!nodes;
    my $outer-attribute = self.^attributes(:local)[3];

    Proxy.new:
      FETCH => -> $ {
        return $outer-nodes if $raw;
        my $n = cast(CArray[Pointer[GDBusNodeInfo]], $outer-nodes);

        (class :: does Positional {

          method AT-POS (Int() $k) {
            $n[$k].deref;
          }

          method EXISTS-POS (Int() $k) {
            $n[$k].defined;
          }

          method STORE {
            warn 'Cannot set GDBusNodeInfo.nodes!';
          }
        }).new
      },

      # cw: -XXX- -TODO-
      # Since Raku-ish array is offered for FETCH, should be supported for
      # STORE. Currently NYI!
      STORE => -> $, CArray[Pointer[GDBusInterfaceInfo]] $val {
        $outer-attribute.set_value(self, $val)
      };
  }

}
