use v6.c;

use Method::Also;

use NativeCall;

use GIO::Raw::Types;

use GLib::Roles::Object;

role GIO::Roles::Initable {
  has GInitable $!i;

  method roleInit-Initable (:$init = True, :$cancellable = GCancellable) {
    # cw: No early return since self.init call must be conditionally made
    unless $!i {
      my \i = findProperImplementor(self.^attributes, :rev);
      $!i   = cast(GInitable, i.get_value(self) );
    }
    self.init($cancellable) if $init;
  }

  method GIO::Raw::Definitions::GInitable
    is also<GInitable>
  { $!i }

  proto method new (|)
  { * }

  multi method new (
    :$init        =  True,
    :$cancellable =  GCancellable,
    :$initable    is required,
    *%options
  ) {
    self.new_initable(
       TYPE => ::?CLASS.get_type,
      :$init,
      :$cancellable,
      |%options
    );
  }
  method new_initable (
    :$init        = True,
    :$cancellable = GCancellable,
    *%options
  )
    is also<new-initable>
  {
    my $initable-object = self.new_object_with_properties(
       TYPE => ::?CLASS.get_type,
      |%options,
      :RAW
    );

    $initable-object ?? self.bless( :$initable-object, :$init, :$cancellable)
                     !! Nil;
  }

  method initable_get_type is also<initable-get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_initable_get_type, $n, $t );
  }

  multi method init (
    GCancellable()          $cancellable = GCancellable,
    CArray[Pointer[GError]] $error       = gerror
  ) {
    clear_error;
    my $rv = so g_initable_init($!i, $cancellable, $error);
    set_error($error);

    $rv;
  }

  # Ala g_initable_new
  multi method construct (
    Str()                   $build-name,
    GCancellable()          $cancellable =  GCancellable,
    CArray[Pointer[GError]] $error       =  gerror
  ) {
    clear_error;
    my $o = g_initable_new(self.get_type, $cancellable, $error, Str);
    set_error($error);

    return Nil unless $o;

    my \i = findProperImplementor(self.^attributes);

    # Descendant classes will need to take this further.
    cast(i.type, $o);

    self.bless( |Pair.new($build-name, $o) );
  }

}

our subset GInitableAncestry is export of Mu
  where GInitable | GObject;

class GIO::Initable does GLib::Roles::Object does GIO::Roles::Initable {

  submethod BUILD (:$initable, :$cancellable, :$init) {
    self.setGInitable($initable) if $initable;
    self.init($cancellable)      if $init;
  }

  method setGInitable (
    GInitableAncestry $_,
                      :$init,
                      :$cancellable
  ) {
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
    self.roleInit-Initable($init, $cancellable);
  }

  multi method new (
    GInitableAncestry $initable,
    GCancellable      :$cancellable = GCancellable,
                      :$init        = False,
                      :$ref         = True
  ) {
    return Nil unless $initable;

    my $o = self.bless(:$initable, :$cancellable, :$init);
    $o.ref if $ref;
    $o;
  }

}

### /usr/src/glib/gio/ginitable.h

sub g_initable_get_type ()
  returns GType
  is      native(gio)
  is      export
{ * }

sub g_initable_new (
  GType                   $type,
  GCancellable            $cancellable,
  CArray[Pointer[GError]] $error,
  Str
)
  returns GObject
  is      native(gio)
  is      export
{ * }

sub g_initable_init (
  GInitable               $initable,
  GCancellable            $cancellable,
  CArray[Pointer[GError]] $error
)
  returns uint32
  is      native(gio)
  is      export
{ * }
