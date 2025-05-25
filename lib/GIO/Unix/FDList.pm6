use v6.c;

use Method::Also;

use NativeCall;

use GIO::Raw::Types;
use GIO::Raw::UnixFDList;

use GLib::Roles::Object;

our subset GUnixFDListAncestry is export of Mu
  where GUnixFDList | GObject;

class GIO::Unix::FDList {
  also does GLib::Roles::Object;

  has GUnixFDList $!fd is implementor;

  submethod BUILD (:$fd) {
    self.setGUnixFDList($fd) if $fd;
  }

  method setGUnixFDList(GUnixFDListAncestry $_) {
    my $to-parent;

    $!fd = do {
      when GUnixFDList {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GUnixFDList, $_);
      }
    }
    self!setObject($to-parent);
  }

  multi method new (GUnixFDListAncestry $fd, :$ref = True) {
    return Nil unless $fd;

    my $o = self.bless( :$fd );
    $o.ref if $ref;
    $o;
  }
  multi method new {
    my $fd = g_unix_fd_list_new();

    $fd ?? self.bless( :$fd ) !! Nil;
  }
  multi method new (@fds) {
    self.new_from_array(@fds);
  }
  multi method new (
    @fds,

    :from_array(
      :from-array( :$array )
    ) is required
  ) {
    self.new_from_array(@fds);
  }

  multi method new (
    CArray[gint] $fds,
    Int()        $n_fds,

    :from_array(
      :from-array( :$array )
    ) is required
  ) {
    self.new_from_array($fds, $n_fds);
  }

  proto method new_from_array (|)
      is also<new-from-array>
  { * }

  multi method new_from_array(@fds) {
    my $fda = CArray[gint].new;
    my $cnt = 0;

    samewith(
      ArrayToCArray(gint, @fds),
      @fds.elems
    );
  }
  multi method new_from_array (CArray[gint] $fds, Int() $n_fds) {
    g_unix_fd_list_new_from_array($fds, $n_fds);
  }

  method append (
    Int()                   $fd,
    CArray[Pointer[GError]] $error = gerror
  ) {
    my gint $ffd = $fd;

    clear_error;
    my $ai = g_unix_fd_list_append($!fd, $ffd, $error);
    set_error($error);
    $ai;
  }

  method get (
    Int()                   $index,
    CArray[Pointer[GError]] $error  = gerror
  ) {
    my gint $i = $index;

    clear_error;
    my $fd = g_unix_fd_list_get($!fd, $i, $error);
    set_error($error);
    $fd;
  }

  method get_length is also<get-length> {
    g_unix_fd_list_get_length($!fd);
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_unix_fd_list_get_type, $n, $t );
  }

  proto method peek_fds (|)
      is also<peek-fds>
  { * }

  multi method peek_fds (:$raw = False) {
    samewith($, :$raw);
  }
  multi method peek_fds ($length is rw, :$raw = False) {
    my gint $l = $length;

    my $fds = g_unix_fd_list_peek_fds($!fd, $l);
    $length = $l;
    return $fds if $raw;

    CArrayToArray($fds, $length);
  }

  proto method steal_fds (|)
      is also<steal-fds>
  { * }

  multi method steal_fds (:$raw = False) {
    samewith($, :$raw);
  }
  multi method steal_fds ($length is rw, :$raw = False) {
    my gint $l = 0;

    my $fds = g_unix_fd_list_steal_fds($!fd, $l);
    $length = $l;
    return $fds if $raw;

    CArrayToArray($fds, $length);
  }

}
