use v6.c;

use Method::Also;
use NativeCall;

use GIO::Raw::Types;
use GIO::Raw::Seekable;

use GLib::Roles::Object;

role GIO::Roles::Seekable does GLib::Roles::Object {
  has GSeekable $!s;

  method roleInit-Seekable is also<roleInit_Seekable> {
    return if $!s;

    my \i = findProperImplementor(self.^attributes);
    $!s = cast( GSeekable, i.get_value(self) );
  }

  method GIO::Raw::Definitions::GSeekable
    is also<GSeekable>
  { $!s }

  method can_seek is also<can-seek> {
    so g_seekable_can_seek($!s);
  }

  method can_truncate is also<can-truncate> {
    so g_seekable_can_truncate($!s);
  }

  method seekable_get_type is also<seekable-get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_seekable_get_type, $n, $t );
  }

  method seek (
    Int()                   $offset,
    GSeekType               $type,
    GCancellable()          $cancellable = GCancellable,
    CArray[Pointer[GError]] $error       = gerror
  ) {
    my goffset   $o = $offset;
    my GSeekType $t = $type;

    clear_error;
    my $rv = so g_seekable_seek($!s, $o, $t, $cancellable, $error);
    set_error($error);
    $rv;
  }

  method tell {
    g_seekable_tell($!s);
  }

  method truncate (
    Int()                   $offset,
    GCancellable()          $cancellable = GCancellable,
    CArray[Pointer[GError]] $error       = gerror
  ) {
    my goffset $o = $offset;

    clear_error;
    my $rv = so g_seekable_truncate($!s, $o, $cancellable, $error);
    set_error($error);
    $rv;
  }

}

our subset GSeekableAncestry is export of Mu
  where GSeekable | GObject;

class GIO::Seekable does GIO::Roles::Seekable {

  submethod BUILD (:$seekable) {
    self.setGSeekable($seekable) if $seekable;
  }

  method setGSeekable (GSeekableAncestry $_) {
    my $to-parent;

    $!s = do {
      when GSeekable {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GSeekable, $_);
      }
    }
    self!setObject($to-parent);
  }

  method new (GSeekableAncestry $seekable, :$ref = True) {
    return Nil unless $seekable;

    my $o = self.bless( :$seekable );
    $o.ref if $ref;
    $o;
  }

}
