use v6.c;

use NativeCall;

use GIO::Raw::Types;

class GIO::Enums::ActionFlags {

  method get_type {
    state ($n, $t);

    unstable_get_type( self.^name, &g_application_flags_get_type, $n, $t );
  }

}

sub g_application_flags_get_type
  returns GType
  is      native(gio)
  is      export
{ * }
