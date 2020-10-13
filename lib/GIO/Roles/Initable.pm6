use v6.c;

use Method::Also;

use NativeCall;

use GIO::Raw::Types;

use GLib::Roles::Object;

role GIO::Roles::Initable does GLib::Roles::Object {
  has GInitable $!i;

  method roleInit-Initable (:$init = True, :$cancellable = GCancellable) {
    # cw: No early return since self.init call must be conditionally made.
    unless $!i {
      my \i = findProperImplementor(self.^attributes);

      $!i = cast(GInitable, i.get_value(self) );
    }
    self.init($cancellable) if $init;
  }

  method GIO::Raw::Definitions::GInitable
    is also<GInitable>
  { $!i }

  method initable_get_type is also<initable-get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_initable_get_type, $n, $t );
  }

  multi method init (
    GCancellable()          $cancellable = GCancellable,
    CArray[Pointer[GError]] $error       = gerror
  ) {
    so g_initable_init($!i, $cancellable, $error);
  }

  method new_initable (|) { ... }

}

our subset GInitableAncestry is export of Mu
  where GInitable | GObject;

class GIO::Initable does GIO::Roles::Initable {

  submethod BUILD (:$initable, :$cancellable, :$init) {
    self.setGInitable($initable) if $initable;
    self.init($cancellable)      if $init;
  }

  method setGInitable (GInitableAncestry $_) {
    my $to-parent;

    $!i = do {
      when GInitable {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GInitable, $_);
      }
    }
    self!setObject($to-parent);
  }

  method new (
    GInitableAncestry $initable,
    GCancellable      :$cancellable = GCancellable,
                      :$init        = False,
                      :$ref         = True
  ) {
    return Nil unless $initable;

    my $o = self.bless(:$initable, $cancellable, :$init);
    $o.ref if $ref;
    $o;
  }

  method new_initable {
    die qq:to/DIE/;
      .new_initable is not to be called from the Role-based object!{
      ''} Please use the subclass constructor, if available!
      DIE
  }

}

sub g_initable_get_type ()
  returns GType
  is native(gio)
  is export
{ * }

sub g_initable_init (
  GInitable               $initable,
  GCancellable            $cancellable,
  CArray[Pointer[GError]] $error
)
  returns uint32
  is native(gio)
  is export
{ * }

# our %GIO::Roles::Initable::RAW-DEFS;
# for MY::.pairs {
#   %GIO::Roles::Initable::RAW-DEFS{.key} := .value
#     if .key.starts-with('&g_initable_');
# }
