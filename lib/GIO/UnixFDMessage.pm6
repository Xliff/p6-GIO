use v6.c;

use Method::Also;

use NativeCall;

use GIO::Raw::Types;
use GIO::Raw::UnixFDMessage;

use GIO::SocketControlMessage;
use GIO::UnixFDList;

our subset GUnixFDMessageAncestry is export of Mu
  where GUnixFDMessage | GSocketControlMessageAncestry;

class GIO::UnixFDMessage is GIO::SocketControlMessage {
  has GUnixFDMessage $!fdm is implementor;

  submethod BUILD (:$fd-message) {
    self.setFDMessage($fd-message) if $fd-message;
  }

  method setFDMessage (GUnixFDMessageAncestry $_) {
    my $to-parent;

    $!fdm = do {
      when GUnixFDMessage {
        $to-parent = cast(GSocketControlMessage, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GUnixFDMessage, $_);
      }
    }
    self.setGSocketControlMessage($to-parent);
  }

  method GIO::Raw::Definitions::GUnixFDMessage
    is also<GUnixFDMessage>
  { $!fdm }

  multi method new (GUnixFDMessageAncestry $fd-message, :$ref = True) {
    return Nil unless $fd-message;

    my $o = self.bless( :$fd-message );
    $o.ref if $ref;
    $o;
  }
  multi method new {
    my $fd-message = g_unix_fd_message_new();

    $fd-message ?? self.bless( :$fd-message ) !! Nil;
  }
  multi method new (
    GUnixFDList() $list,

    :with_fd_list(
      :with-fd-list(
        :fd_list(
          :fd-list( :$fdlist )
        )
      )
    ) is required
  ) {
    self.new_with_fd_list($list);
  }
  
  method new_with_fd_list (GUnixFDList() $list) is also<new-with-fd-list> {
    my $fd-message = g_unix_fd_message_new_with_fd_list($list);

    $fd-message ?? self.bless( :$fd-message ) !! Nil;
  }

  method append_fd (
    Int()                   $fd,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<append-fd>
  {
    my gint $ffd = $fd;

    clear_error;
    my $rv = so g_unix_fd_message_append_fd($!fdm, $fd, $error);
    set_error($error);
    $rv;
  }

  method get_fd_list (:$raw = False) is also<get-fd-list> {
    my $fds = g_unix_fd_message_get_fd_list($!fdm);

    $fds ??
      ( $raw ?? $fds !! GIO::UnixFDList.new($fds, :!ref) )
      !!
      Nil;
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_unix_fd_message_get_type, $n, $t );
  }

  proto method steal_fds (|)
    is also<steal-fds>
  { * }

  multi method steal_fds ( :$raw = False ) {
    samewith($, :$raw);
  }
  multi method steal_fds ($length is rw, :$raw = False)  {
    my gint ($l, $idx) = (0, 0);

    my $fds = g_unix_fd_message_steal_fds($!fdm, $l);
    $length = $l;

    return Nil  unless $fds;
    return $fds if     $raw;

    CArrayToArray($fds, $length);
  }

}
