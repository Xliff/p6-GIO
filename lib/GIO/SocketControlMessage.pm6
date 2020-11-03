use v6.c;

use Method::Also;

use GIO::Raw::Types;
use GIO::Raw::SocketControlMessage;

use GLib::Roles::Object;

our subset GSocketControlMessageAncestry is export of Mu
  where GSocketControlMessage | GObject;

class GIO::SocketControlMessage {
  also does GLib::Roles::Object;

  has GSocketControlMessage $!scm is implementor;

  submethod BUILD (:$message) {
    self.setSocketControlMessage($message) if $message;
  }

  method setSocketControlMessage (GSocketControlMessageAncestry $_) {
    my $to-parent;

    $!scm = do {
      when GSocketControlMessage {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GSocketControlMessage, $_);
      }
    }
    self!setObject($to-parent);
  }

  method GIO::Raw::Definitions::GSocketControlMessage
    is also<GSocketControlMessage>
  { * }

  proto method new (|)
  { * }

  multi method new (GSocketControlMessageAncestry $message, :$ref = True) {
    return Nil unless $message;

    my $o = self.bless( :$message );
    $o.ref if $ref;
    $o;
  }
  multi method new (Int() $level, Int() $type, Int() $size, gpointer $data) {
    GIO::SocketControlMessage.deserialize($level, $type, $size, $data);
  }

  method deserialize (
    GIO::SocketControlMessage:U:
    Int()    $level,
    Int()    $type,
    Int()    $size,
    gpointer $data
  ) {
    my gint ($l, $t) = ($level, $type);
    my gsize $s = $size;
    my       $message = g_socket_control_message_deserialize($l, $t, $s, $data);

    $message ?? self.bless( :$message ) !! Nil;
  }

  method get_level
    is also<
      get-level
      level
    >
  {
    g_socket_control_message_get_level($!scm);
  }

  method get_msg_type
    is also<
      get-msg-type
      msg_type
      msg-type
    >
  {
    g_socket_control_message_get_msg_type($!scm);
  }

  method get_size
    is also<
      get-size
      size
    >
  {
    g_socket_control_message_get_size($!scm);
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_socket_control_message_get_type, $n, $t );
  }

  method serialize (gpointer $data) {
    g_socket_control_message_serialize($!scm, $data);
  }

}
