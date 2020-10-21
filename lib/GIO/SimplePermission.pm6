use v6.c;

use Method::Also;
use NativeCall;

use GIO::Raw::Types;

use GIO::Permission;

our subset GSimplePermissionAncestry is export of Mu
  where GSimplePermission | GPermission | GObject;

class GIO::SimplePermission is GIO::Permission {
  has GSimplePermission $!sp is implementor;

  submethod BUILD (:$simple-permission) {
    self.setGSimplePermission($simple-permission) if $simple-permission;
  }

  method setGSimplePermission (GSimplePermissionAncestry $_) {
    my $to-parent;
    $!sp = do {
      when GSimplePermission {
        $to-parent = cast(GPermission, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GSimplePermission, $_);
      }
    };
    self.setPermission($to-parent);
  }

  method GIO::Raw::Definitions::GSimplePermission
    is also<GSimplePermission>
  { $!sp }

  multi method new (GSimplePermissionAncestry $simple-permission, :$ref = True) {
    return Nil unless $simple-permission,;

    my $o = self.bless( :$simple-permission );
    $o.upref if $ref;
    $o;
  }
  multi method new (Int() $allowed) {
    my gboolean $a                 = $allowed.so.Int;
    my          $simple-permission = g_simple_permission_new($a);

    $simple-permission ?? self.bless( $simple-permission) !! Nil;
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_simple_permission_get_type, $n, $t );
  }

}

### /usr/include/glib-2.0/gio/gsimplepermission.h

sub g_simple_permission_get_type ()
  returns GType
  is native(gio)
  is export
{ * }

sub g_simple_permission_new (gboolean $allowed)
  returns GSimplePermission
  is native(gio)
  is export
{ * }

# our %GIO::SimplePermission::RAW-DEFS;
# for MY::.pairs {
#   %GIO::SimplePermission::RAW-DEFS{.key} := .value
#     if .key.starts-with('&g_simple_permission_');
# }
