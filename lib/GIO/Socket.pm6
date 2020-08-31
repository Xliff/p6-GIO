use v6.c;

use Method::Also;

use NativeCall;

use GIO::Raw::Types;
use GIO::Raw::Socket;

use GIO::SocketAddress;

use GLib::Roles::Object;
use GIO::Roles::Initable;
use GIO::Roles::DatagramBased;

our subset GSocketAncestry is export of Mu
  where GSocket | GDatagramBased | GInitable | GObject;

class GIO::Socket {
  also does GLib::Roles::Object;
  also does GIO::Roles::Initable;
  also does GIO::Roles::DatagramBased;

  has GSocket $!s is implementor;

  submethod BUILD (:$socket) {
    self.setGSocket($socket) if $socket;
  }

  method setGSocket (GSocketAncestry $_) {
    my $to-parent;

    $!s = do {
      when GSocket {
        $to-parent = cast(GObject, $_);
        $_;
      }

      when GDatagramBased {
        $to-parent = cast(GObject, $_);
        $!d = $_;
        cast(GSocket, $_);
      }

      when GInitable {
        $to-parent = cast(GObject, $_);
        $!i = $_;
        cast(GSocket, $_);
      }

      default {
        $to-parent = $_;
        cast(GSocket, $_);
      }
    }

    self!setObject($to-parent);
    self.roleInit-Initable unless $!i;
    self.roleInit-DatagramBased unless $!d;
  }

  method GIO::Raw::Definitions::GSocket
    is also<GSocket>
  { $!s }

  multi method new (GSocket $socket) {
    $socket ?? self.bless( :$socket ) !! Nil;
  }
  multi method new (
    Int() $family,
    Int() $type,
    Int() $protocol,
    CArray[Pointer[GError]] $error = gerror
  ) {
    my GSocketFamily $f = $family;
    my GSocketType $t = $type;
    my GSocketProtocol $p = $protocol;

    clear_error;
    my $socket = g_socket_new($f, $t, $p, $error);
    set_error($error);
    $socket ?? self.bless( :$socket ) !! Nil;
  }

  method new_from_fd (
    CArray[Pointer[GError]] $error = gerror
  )
    is also<new-from-fd>
  {
    clear_error;
    my $socket = g_socket_new_from_fd($!s, $error);
    set_error($error);
    $socket ?? self.bless( :$socket ) !! Nil;
  }

  method blocking is rw {
    Proxy.new(
      FETCH => sub ($) {
        so g_socket_get_blocking($!s);
      },
      STORE => sub ($, Int() $blocking is copy) {
        my gboolean $b = $blocking.so.Int;

        g_socket_set_blocking($!s, $b);
      }
    );
  }

  method broadcast is rw {
    Proxy.new(
      FETCH => sub ($) {
        so g_socket_get_broadcast($!s);
      },
      STORE => sub ($, Int() $broadcast is copy) {
        my gboolean $b = $broadcast.so.Int;

        g_socket_set_broadcast($!s, $b);
      }
    );
  }

  method keepalive is rw {
    Proxy.new(
      FETCH => sub ($) {
        so g_socket_get_keepalive($!s);
      },
      STORE => sub ($, Int() $keepalive is copy) {
        my gboolean $k = $keepalive.so.Int;

        g_socket_set_keepalive($!s, $k);
      }
    );
  }

  method listen_backlog is rw is also<listen-backlog> {
    Proxy.new(
      FETCH => sub ($) {
        g_socket_get_listen_backlog($!s);
      },
      STORE => sub ($, Int() $backlog is copy) {
        my gint $b = $backlog;

        g_socket_set_listen_backlog($!s, $b);
      }
    );
  }

  method multicast_loopback is rw is also<multicast-loopback> {
    Proxy.new(
      FETCH => sub ($) {
        so g_socket_get_multicast_loopback($!s);
      },
      STORE => sub ($, Int() $loopback is copy) {
        my gboolean $l = $loopback.so.Int;

        g_socket_set_multicast_loopback($!s, $l);
      }
    );
  }

  method multicast_ttl is rw is also<multicast-ttl> {
    Proxy.new(
      FETCH => sub ($) {
        g_socket_get_multicast_ttl($!s);
      },
      STORE => sub ($, Int() $ttl is copy) {
        my guint $t = $ttl;

        g_socket_set_multicast_ttl($!s, $t);
      }
    );
  }

  method timeout is rw {
    Proxy.new(
      FETCH => sub ($) {
        g_socket_get_timeout($!s);
      },
      STORE => sub ($, Int() $timeout is copy) {
        my guint $t = $timeout;

        g_socket_set_timeout($!s, $t);
      }
    );
  }

  method ttl is rw {
    Proxy.new(
      FETCH => sub ($) {
        g_socket_get_ttl($!s);
      },
      STORE => sub ($, Int() $ttl is copy) {
        my guint $t = $ttl;

        g_socket_set_ttl($!s, $t);
      }
    );
  }

  method accept (
    GCancellable() $cancellable,
    CArray[Pointer[GError]] $error = gerror,
    :$raw = False
  ) {
    clear_error;
    my $s = g_socket_accept($!s, $cancellable, $error);
    set_error($error);

    $s ??
      ( $raw ?? $s !! GIO::Socket.new($s) )
      !!
      Nil
  }

  method bind (
    GSocketAddress() $address,
    Int() $allow_reuse,
    CArray[Pointer[GError]] $error = gerror
  ) {
    my gboolean $ar = $allow_reuse;
    clear_error;
    my $rv = so g_socket_bind($!s, $address, $ar, $error);
    set_error($error);
    $rv;
  }

  method check_connect_result (
    CArray[Pointer[GError]] $error = gerror
  )
    is also<check-connect-result>
  {
    clear_error;
    my $rv = so g_socket_check_connect_result($!s, $error);
    set_error($error);
    $rv;
  }

  method close (CArray[Pointer[GError]] $error = gerror) {
    clear_error;
    my $rv = so g_socket_close($!s, $error);
    set_error($error);
    $rv;
  }

  method condition_check (Int() $condition) is also<condition-check> {
    my GIOCondition $c = $condition;

    GIOConditionEnum( g_socket_condition_check($!s, $c) );
  }

  method condition_timed_wait (
    Int() $condition,
    Int() $timeout_us,
    GCancellable() $cancellable = GCancellable,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<condition-timed-wait>
  {
    my GIOCondition $c = $condition;
    my gint64 $to-μs = $timeout_us;

    clear_error;
    my $rv =
     so g_socket_condition_timed_wait($!s, $c, $to-μs, $cancellable, $error);
    set_error($error);
    $rv;
  }

  method condition_wait (
    Int() $condition,
    GCancellable() $cancellable = GCancellable,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<condition-wait>
  {
    my GIOCondition $c = $condition;

    clear_error;
    my $rv = so g_socket_condition_wait($!s, $c, $cancellable, $error);
    set_error($error);
    $rv;
  }

  method connect (
    GSocketAddress() $address,
    GCancellable() $cancellable = GCancellable,
    CArray[Pointer[GError]] $error = gerror
  ) {
    clear_error;
    my $rv = so g_socket_connect($!s, $address, $cancellable, $error);
    set_error($error);
    $rv;
  }

  method create_source (
    Int() $condition,
    GCancellable() $cancellable = GCancellable
  )
    is also<create-source>
  {
    my GIOCondition $c = $condition;

    g_socket_create_source($!s, $c, $cancellable);
  }

  method get_available_bytes
    is also<
      get-available-bytes
      available_bytes
      available-bytes
    >
  {
    g_socket_get_available_bytes($!s);
  }

  method credentials {
    self.get_credentials;
  }

  method get_credentials (
    CArray[Pointer[GError]] $error = gerror
  )
    is also<get-credentials>
  {
    clear_error;
    g_socket_get_credentials($!s, $error);
    set_error($error);
  }

  method get_family
    is also<
      get-family
      family
    >
  {
    GSocketFamilyEnum( g_socket_get_family($!s) );
  }

  method get_fd
    is also<
      get-fd
      fd
    >
  {
    g_socket_get_fd($!s);
  }

  method get_local_address (
    CArray[Pointer[GError]] $error = gerror,
    :$raw = False;
  )
    is also<get-local-address>
  {
    clear_error;
    my $la = g_socket_get_local_address($!s, $error);
    set_error($error);

    $la ??
      ( $raw ?? $la !! GIO::SocketAddress.new($la) )
      !!
      Nil
  }

  method get_option (
    Int() $level,
    Int() $optname,
    Int() $value,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<get-option>
  {
    my gint ($l, $o, $v) = ($level, $optname, $value);

    clear_error;
    my $rv = so g_socket_get_option($!s, $l, $o, $v, $error);
    set_error($error);
    $rv;
  }

  method get_protocol
    is also<
      get-protocol
      protocol
    >
  {
    GSocketProtocolEnum( g_socket_get_protocol($!s) );
  }

  method remote_address (:$raw = False) is also<remote-address> {
    self.get_remote_address(:$raw);
  }

  method get_remote_address (
    CArray[Pointer[GError]] $error = gerror,
    :$raw = False
  )
    is also<get-remote-address>
  {
    clear_error;
    my $ra = g_socket_get_remote_address($!s, $error);
    set_error($error);

    $ra ??
      ( $raw ?? $ra !! GIO::SocketAddress($ra) )
      !!
      Nil;
  }

  method get_socket_type
    is also<
      get-socket-type
      socket_type
      socket-type
    >
  {
    GSocketTypeEnum( g_socket_get_socket_type($!s) );
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_socket_get_type, $n, $t );
  }

  method is_closed is also<is-closed> {
    so g_socket_is_closed($!s);
  }

  method is_connected is also<is-connected> {
    so g_socket_is_connected($!s);
  }

  method join_multicast_group (
    GInetAddress() $group,
    Int() $source_specific,
    Str() $iface,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<join-multicast-group>
  {
    my gboolean $ss = $source_specific;

    clear_error;
    my $rc = so g_socket_join_multicast_group($!s, $group, $ss, $iface, $error);
    set_error($error);
    $rc;
  }

  method join_multicast_group_ssm (
    GInetAddress() $group,
    GInetAddress() $source_specific,
    Str() $iface,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<join-multicast-group-ssm>
  {
    clear_error;
    my $rv = so g_socket_join_multicast_group_ssm(
      $!s,
      $group,
      $source_specific,
      $iface,
      $error
    );
    set_error($error);
    $rv;
  }

  method leave_multicast_group (
    GInetAddress() $group,
    Int() $source_specific,
    Str() $iface,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<leave-multicast-group>
  {
    my gboolean $ss = $source_specific;

    clear_error;
    my $rv =
      so g_socket_leave_multicast_group($!s, $group, $ss, $iface, $error);
    set_error($error);
    $rv;
  }

  method leave_multicast_group_ssm (
    GInetAddress() $group,
    GInetAddress() $source_specific,
    Str() $iface,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<leave-multicast-group-ssm>
  {
    clear_error;
    my $rv = so g_socket_leave_multicast_group_ssm(
      $!s,
      $group,
      $source_specific,
      $iface,
      $error
    );
    set_error($error);
    $rv;
  }

  method listen (
    CArray[Pointer[GError]] $error = gerror
  ) {
    clear_error;
    my $rv = so g_socket_listen($!s, $error);
    set_error($error);
    $rv;
  }

  multi method receive (
    Int() $size,
    GCancellable() $cancellable = GCancellable,
    CArray[Pointer[GError]] $error = gerror,
    :$raw = False,
    :$encoding = 'utf-8';
  ) {
    my $b = CArray[uint8].allocate($size);
    my $rv = samewith($, $size, $cancellable, $error, :all, :$raw, :$encoding);

    $rv[0] ?? $rv[1] !! Nil
  }
  multi method receive (
    $buffer is rw,
    Int() $size,
    GCancellable() $cancellable = GCancellable,
    CArray[Pointer[GError]] $error = gerror,
    :$all = False,
    :$raw = False,
    :$encoding = 'utf-8'
  ) {
    my gsize $s = $size;
    my $b = CArray[uint8].allocate($size);

    clear_error;
    my $rv = g_socket_receive($!s, $buffer, $s, $cancellable, $error);
    set_error($error);

    $buffer = $raw ?? $b !! Buf.new($b).decode($encoding);

    $all.not ?? $rv !! ($rv, $buffer);
  }

  proto method receive_from (|)
    is also<receive-from>
  { * }

  multi method receive_from (
    Int() $size,
    GCancellable() $cancellable = GCancellable,
    CArray[Pointer[GError]] $error = gerror,
    :$raw = False,
    :$encoding = 'utf-8';
  ) {
    my $rv = samewith(
      $,
      $,
      $size,
      $cancellable,
      $error,
      :all,
      :$raw,
      :$encoding
    );

    return $rv[0] ?? $rv.skip(1) !! Nil;
  }
  multi method receive_from (
    $address is rw,
    $buffer is rw,
    Int() $size,
    GCancellable() $cancellable = GCancellable,
    CArray[Pointer[GError]] $error = gerror,
    :$all = False,
    :$raw = False,
    :$encoding = 'utf-8'
  ) {
    my gsize $s = $size;
    my $a = CArray[GSocketAddress].new;
    my $b = CArray[uint8].allocate($size);
    $a[0] = GSocketAddress;


    clear_error;
    my $rv = g_socket_receive_from(
      $!s,
      $a,
      $b,
      $s,
      $cancellable,
      $error
    );
    set_error($error);

    $buffer = $raw ?? $b !! Buf.new($b).decode($encoding);

    $address = $a ??
      ( $raw ?? $a !! GIO::SocketAddress.new($a) )
      !!
      Nil;

    $all.not ?? $rv !! ($rv, $address, $buffer);
  }

  proto method receive_message (|)
    is also<receive-message>
  { * }

  multi method receive_message (
    @vectors,
    GCancellable() $cancellable = GCancellable,
    CArray[Pointer[GError]] $error = gerror,
    :$raw = False
  ) {
    my $rv = samewith(
      $,
      GLib::Roles::TypedBuffer.new(@vectors).p,
      @vectors,
      $,
      $,
      $,
      $cancellable,
      $error,
      :all,
      :$raw
    );

    $rv[0] ?? $rv.skip(1) !! Nil;
  }
  multi method receive_message (
    Buf() $vectors,
    Int() $num_vectors = $vectors.bytes / nativesizeof(GInputVector),
    GCancellable() $cancellable = GCancellable,
    CArray[Pointer[GError]] $error = gerror,
    :$raw = False
  ) {
    my $rv = samewith(
      $,
      CArray[uint8].new($vectors),
      $num_vectors,
      $,
      $,
      $,
      $cancellable,
      $error,
      :all,
      :$raw
    );

    $rv[0] ?? $rv.skip(1) !! Nil;
  }
  multi method receive_message (
    CArray[uint8] $vectors,
    Int() $num_vectors,
    GCancellable() $cancellable = GCancellable,
    CArray[Pointer[GError]] $error = gerror,
    :$raw,
  ) {
    my $rv = samewith(
      $,
      cast(Pointer, $vectors),
      $num_vectors,
      $,
      $,
      $,
      $cancellable,
      $error,
      :all,
      :$raw
    );

    $rv[0] ?? $rv.skip(1) !! Nil;
  }
  multi method receive_message (
    $address is rw,
    Pointer $vectors,
    Int() $num_vectors,
    $messages is rw,
    $num_messages is rw,
    $flags is rw,
    GCancellable() $cancellable = GCancellable,
    CArray[Pointer[GError]] $error = gerror,
    :$all = False,
    :$raw = False
  ) {
    my $a = CArray[GSocketAddress].new;
    $a[0] = GSocketAddress;
    my gint ($nv, $nm, $f) = ($num_vectors, 0, $flags);
    my $m = CArray[Pointer[Pointer[GSocketControlMessage]]].new;
    $m[0] = Pointer[Pointer[GSocketControlMessage]];

    clear_error;
    my $br = g_socket_receive_message(
      $!s,
      $address,
      $vectors,
      $nv,
      $m,
      $nm,
      $f,
      $cancellable,
      $error
    );
    set_error($error);
    ($address, $num_messages, $flags) = (ppr($a), $nm, $f);

    $address = $address ??
      ( $raw ?? $address !! GIO::SocketAddress.new($address) )
      !!
      Nil;

    $messages = ($m && $m[0]) ?? CArrayToArray($m[0][0], $nm) !! Nil;
    $all.not ?? $br !! ($br, $address, $messages, $num_messages, $flags);
  }

  proto method receive_messages (|)
    is also<receive-messages>
  { * }

  multi method receive_messages (
    @messages,
    Int() $flags,
    GCancellable() $cancellable = GCancellable,
    CArray[Pointer[GError]] $error = gerror
  ) {
    my $rv = samewith(
      GLib::Roles::TypedBuffer[GInputMessage].new(@messages).p,
      @messages.elems,
      $flags,
      $cancellable,
      $error
    );

    $rv[0] ?? $rv[1] !! Nil;
  }
  multi method receive_messages (
    Buf() $messages,        # GInputMessage() $messages,
    Int() $num_messages,
    Int() $flags,
    GCancellable() $cancellable = GCancellable,
    CArray[Pointer[GError]] $error = gerror
  ) {
    my $rv = samewith(
      CArray[uint8].new($messages),
      $num_messages,
      $flags,
      $cancellable,
      $error
    );

    $rv[0] ?? $rv[1] !! Nil;
  }
  multi method receive_messages (
    CArray[uint8] $messages,        # GInputMessage() $messages,
    Int() $num_messages,
    Int() $flags,
    GCancellable() $cancellable = GCancellable,
    CArray[Pointer[GError]] $error = gerror
  ) {
    my $rv = samewith(
      cast(Pointer, $messages),
      $num_messages,
      $flags,
      $cancellable,
      $error
    );

    $rv[0] ?? $rv[1] !! Nil;
  }
  multi method receive_messages (
    Pointer $messages,        # GInputMessage() $messages,
    Int() $num_messages,
    Int() $flags,
    GCancellable() $cancellable = GCancellable,
    CArray[Pointer[GError]] $error = gerror,
    :$all = False
  ) {
    my guint $nm = $num_messages;
    my gint $f = $flags;

    clear_error;
    my $rv = so g_socket_receive_messages(
      $!s,
      $messages,
      $nm,
      $f,
      $cancellable,
      $error
    );
    set_error($error);

    $all.not ?? $rv
             !! (
                  $rv,
                  GLib::Roles::TypedBuffer[GInputMessage].new-typedbuffer-obj(
                    $messages,
                    $nm
                  ).Array
                )
  }

  proto method receive_with_blocking (|)
    is also<receive-with-blocking>
  { * }

  multi method receive_with_blocking (
    Int() $size,
    Int() $blocking,
    GCancellable() $cancellable = GCancellable,
    CArray[Pointer[GError]] $error = gerror,
    :$all = False,
    :$raw = False,
    :$encoding = 'utf-8'
  ) {
    my $rv = samewith(
      CArray[uint8].allocate($size),
      $size,
      $blocking,
      $cancellable,
      $error,
      :all,
      :$raw,
      :$encoding,
    );

    $rv[0] ?? $rv[1] !! Nil;
  }
  multi method receive_with_blocking (
    $buffer is rw,
    Int() $size,
    Int() $blocking,
    GCancellable() $cancellable = GCancellable,
    CArray[Pointer[GError]] $error = gerror,
    :$all = False,
    :$raw = False,
    :$encoding = 'utf-8'
  ) {
    my $rv = samewith(
      CArray[uint8].allocate($size),
      $size,
      $blocking,
      $cancellable,
      $error,
      :all,
      :$raw,
      :$encoding,
    );
    $buffer = Nil;

    $rv[0] ?? ($buffer = $rv[1]) !! Nil;
  }
  multi method receive_with_blocking (
    CArray[uint8] $buffer,
    Int() $size,
    Int() $blocking,
    GCancellable() $cancellable = GCancellable,
    CArray[Pointer[GError]] $error = gerror,
    :$all = False,
    :$raw = False,
    :$encoding = 'utf-8'
  ) {
    my $rv = samewith(
      cast(Pointer, $buffer),
      $size,
      $blocking,
      $cancellable,
      $error,
      :all,
      :$raw,
      :$encoding
    );

    $rv[0] ?? ($buffer = $rv[1]) !! Nil;
  }
  multi method receive_with_blocking (
    Pointer $buffer,
    Int() $size,
    Int() $blocking,
    GCancellable() $cancellable = GCancellable,
    CArray[Pointer[GError]] $error = gerror,
    :$all = False,
    :$raw = False,
    :$encoding = 'utf-8'
  ) {
    my gsize $s = $size;
    my gboolean $b = $blocking;

    clear_error;
    my $rv = so g_socket_receive_with_blocking(
      $!s,
      $buffer,
      $s,
      $b,
      $cancellable,
      $error
    );
    set_error($error);
    $buffer = $raw ?? $b !! Buf.new($b).decode($encoding);
    $all.not ?? $rv !! ($rv, $buffer);
  }

  method send (
    Str() $buffer,
    Int() $size,
    GCancellable() $cancellable = GCancellable,
    CArray[Pointer[GError]] $error = gerror
  ) {
    my gsize $s = $size;

    clear_error;
    my $rv = g_socket_send($!s, $buffer, $s, $cancellable, $error);
    set_error($error);
    $rv;
  }

  proto method send_message (|)
    is also<send-message>
  { * }

  multi method send_message (
    GSocketAddress() $address,
    @vectors,
    @messages,
    Int() $flags,
    GCancellable() $cancellable = GCancellable,
    CArray[Pointer[GError]] $error = gerror
  ) {
    samewith(
      $address,
      GLib::Roles::TypedBuffer[GOutputVector].new(@vectors).p,
      @vectors.elems,
      GLib::Roles::TypedBuffer[GSocketControlMessage].new(@messages).p,
      @messages.elems,
      $flags,
      $cancellable,
      $error,
    );
  }
  multi method send_message (
    GSocketAddress() $address,
    Buf() $vectors, #= Array of GOutputVector
    Int() $num_vectors,
    Buf() $messages,
    Int() $num_messages,
    Int() $flags,
    GCancellable() $cancellable = GCancellable,
    CArray[Pointer[GError]] $error = gerror
  ) {
    samewith(
      $address,
      CArray[uint8].new($vectors),
      $num_vectors,
      CArray[uint8].new($messages),
      $num_messages,
      $flags,
      $cancellable,
      $error
    );
  }
  multi method send_message (
    GSocketAddress() $address,
    CArray[uint8] $vectors, #= Array of GOutputVector
    Int() $num_vectors,
    CArray[uint8] $messages,
    Int() $num_messages,
    Int() $flags,
    GCancellable() $cancellable = GCancellable,
    CArray[Pointer[GError]] $error = gerror
  ) {
    samewith(
      $address,
      cast(Pointer, $vectors),
      $num_vectors,
      cast(Pointer, $messages),
      $num_messages,
      $flags,
      $cancellable,
      $error
    );
  }
  multi method send_message (
    GSocketAddress() $address,
    Pointer $vectors, #= Array of GOutputVector
    Int() $num_vectors,
    Pointer $messages,
    Int() $num_messages,
    Int() $flags,
    GCancellable() $cancellable = GCancellable,
    CArray[Pointer[GError]] $error = gerror
  ) {
    my gint ($nv, $nm, $f) = ($num_vectors, $num_messages, $flags);
    my $m = CArray[Pointer];
    $m[0] = $messages;

    clear_error;
    my $rv = g_socket_send_message(
      $!s,
      $address,
      $vectors,
      $nv,
      $m,
      $nm,
      $f,
      $cancellable,
      $error
    );
    set_error($error);
    $rv;
  }

  proto method send_message_with_timeout (|)
    is also<send-message-with-timeout>
  { * }

  multi method send_message_with_timeout (
    GSocketAddress() $address,
    @vectors,
    @messages,
    Int() $flags,
    Int() $timeout_us,
    GCancellable() $cancellable = GCancellable,
    CArray[Pointer[GError]] $error = gerror
  ) {
    my $rv = samewith(
      $address,
      GLib::Roles::TypedBuffer[GOutputVector].new(@vectors).p,
      @vectors.elems,
      GLib::Roles::TypedBuffer[GSocketControlMessage].new(@messages).p,
      @messages.elems,
      $flags,
      $timeout_us,
      $cancellable,
      $error,
      :all
    );

    $rv[0] ?? $rv[1] !! Nil;
  }
  multi method send_message_with_timeout (
    GSocketAddress() $address,
    Buf() $vectors,
    Int() $num_vectors,
    Buf() $messages,
    Int() $num_messages,
    Int() $flags,
    Int() $timeout_us,
    GCancellable() $cancellable = GCancellable,
    CArray[Pointer[GError]] $error = gerror
  ) {
    my $rv = samewith(
      $address,
      CArray[uint8].new($vectors),
      $num_vectors,
      CArray[uint8].new($messages),
      $num_messages,
      $flags,
      $timeout_us,
      $cancellable,
      $error,
      :all
    );

    $rv[0] ?? $rv[1] !! Nil;
  }
  multi method send_message_with_timeout (
    GSocketAddress() $address,
    CArray[uint8] $vectors,
    Int() $num_vectors,
    CArray[uint8] $messages,
    Int() $num_messages,
    Int() $flags,
    Int() $timeout_us,
    GCancellable() $cancellable = GCancellable,
    CArray[Pointer[GError]] $error = gerror
  ) {
    my $rv = samewith(
      $address,
      cast(Pointer, $vectors),
      $num_vectors,
      cast(Pointer, $messages),
      $num_messages,
      $flags,
      $timeout_us,
      $cancellable,
      $error,
      :all
    );

    $rv[0] ?? $rv[1] !! Nil;
  }
  multi method send_message_with_timeout (
    GSocketAddress() $address,
    Pointer $vectors, #= Array of GOutputVector
    Int() $num_vectors,
    Pointer $messages, #= Pointer to Array of GSocketControlMessage
    Int() $num_messages,
    Int() $flags,
    Int() $timeout_us,
    $bytes_written is rw,
    GCancellable() $cancellable = GCancellable,
    CArray[Pointer[GError]] $error = gerror,
    :$all = False
  ) {
    my gint ($nv, $nm, $f) = ($num_vectors, $num_messages, $flags);
    my gint64 $to-μs = $timeout_us;
    my gsize $bw = 0;

    clear_error;
    my $rv = g_socket_send_message_with_timeout(
      $!s,
      $address,
      $vectors,
      $nv,
      $messages,
      $nm,
      $f,
      $to-μs,
      $bw,
      $cancellable,
      $error
    );
    $bytes_written = $bw;
    set_error($error);

    $all.not ?? $rv !! ($rv, $bytes_written);
  }

  proto method send_messages (|)
    is also<send-messages>
  { * }

  multi method send_messages (
    @messages,
    Int() $flags,
    GCancellable() $cancellable = GCancellable,
    CArray[Pointer[GError]] $error = gerror
  ) {
    samewith(
      GLib::Roles::TypedBuffer[GOutputMessage].new(@messages).p,
      @messages.elems,
      $flags,
      $cancellable,
      $error
    );
  }
  multi method send_messages (
    Buf() $messages, #= Array of GOutputMessage
    Int() $num_messages,
    Int() $flags,
    GCancellable() $cancellable = GCancellable,
    CArray[Pointer[GError]] $error = gerror
  ) {
    samewith(
      CArray[uint8].new($messages),
      $num_messages,
      $flags,
      $cancellable,
      $error
    );
  }
  multi method send_messages (
    CArray[uint8] $messages, #= Array of GOutputMessage
    Int() $num_messages,
    Int() $flags,
    GCancellable() $cancellable = GCancellable,
    CArray[Pointer[GError]] $error = gerror
  ) {
    samewith(
      cast(Pointer, $messages),
      $num_messages,
      $flags,
      $cancellable,
      $error
    );
  }
  multi method send_messages (
    Pointer $messages, #= Array of GOutputMessage
    Int() $num_messages,
    Int() $flags,
    GCancellable() $cancellable = GCancellable,
    CArray[Pointer[GError]] $error = gerror
  ) {
    my guint $nm = $num_messages;
    my gint $f = $flags;

    clear_error;
    my $rv =
      g_socket_send_messages($!s, $messages, $nm, $f, $cancellable, $error);
    set_error($error);
    $rv;
  }

  proto method send_to (|)
    is also<send-to>
  { * }

  multi method send_to (
    GSocketAddress() $address,
    Str() $buffer,
    GCancellable() $cancellable = GCancellable,
    CArray[Pointer[GError]] $error = gerror,
    :$encoding = 'utf-8'
  ) {
    my $b = $buffer.encode($encoding);

    samewith(
      $!s,
      $address,
      $b,
      $b.bytes,
      $cancellable,
      $error
    );
  }
  multi method send_to (
    GSocketAddress() $address,
    Buf() $buffer,
    Int() $size,
    GCancellable() $cancellable = GCancellable,
    CArray[Pointer[GError]] $error = gerror
  ) {
    samewith(
      $!s,
      $address,
      CArray[uint8].new($buffer),
      $size,
      $cancellable,
      $error
    );
  }
  multi method send_to (
    GSocketAddress() $address,
    CArray[uint8] $buffer,
    Int() $size,
    GCancellable() $cancellable = GCancellable,
    CArray[Pointer[GError]] $error = gerror
  ) {
    samewith(
      $!s,
      $address,
      cast(Pointer, $buffer),
      $size,
      $cancellable,
      $error
    );
  }
  multi method send_to (
    GSocketAddress() $address,
    Pointer $buffer,
    Int() $size,
    GCancellable() $cancellable = GCancellable,
    CArray[Pointer[GError]] $error = gerror
  ) {
    my gsize $s = $size;

    clear_error;
    my $rs = g_socket_send_to(
      $!s,
      $address,
      $buffer,
      $s,
      $cancellable,
      $error
    );
    set_error($error);
    $rs;
  }

  proto method send_with_blocking
    is also<send-with-blocking>
  { * }

  multi method send_with_blocking (
    @buffer,
    Int() $blocking,
    GCancellable() $cancellable = GCancellable,
    CArray[Pointer[GError]] $error = gerror
  ) {
    samewith(
      CArray[uint8].new(@buffer),
      @buffer.size,
      $blocking,
      $cancellable,
      $error
    );
  }
  multi method send_with_blocking (
    Str() $buffer,
    Int() $blocking,
    GCancellable() $cancellable = GCancellable,
    CArray[Pointer[GError]] $error = gerror,
    :$encoding = 'utf-8'
  ) {
    my $b = $buffer.encode($encoding);

    samewith($b, $b.bytes, $blocking, $cancellable, $error);
  }
  multi method send_with_blocking (
    Buf() $buffer,
    Int() $size,
    Int() $blocking,
    GCancellable() $cancellable = GCancellable,
    CArray[Pointer[GError]] $error = gerror
  ) {
    samewith(
      CArray[uint8].new($buffer),
      $size,
      $blocking,
      $cancellable,
      $error
    );
  }
  multi method send_with_blocking (
    CArray[uint8] $buffer,
    Int() $size,
    Int() $blocking,
    GCancellable() $cancellable = GCancellable,
    CArray[Pointer[GError]] $error = gerror
  ) {
    samewith(
      cast(Pointer, $buffer),
      $size,
      $blocking,
      $cancellable,
      $error
    );
  }
  multi method send_with_blocking (
    Pointer $buffer,
    Int() $size,
    Int() $blocking,
    GCancellable() $cancellable = GCancellable,
    CArray[Pointer[GError]] $error = gerror
  ) {
    my gsize    $s = $size;
    my gboolean $b = $blocking;

    clear_error;
    my $rv =
      g_socket_send_with_blocking($!s, $buffer, $s, $b, $cancellable, $error);
    set_error($error);
    $rv;
  }

  method set_option (
    Int() $level,
    Int() $optname,
    Int() $value,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<set-option>
  {
    my gint ($l, $o, $v) = ($level, $optname, $value);

    clear_error;
    my $rv = so g_socket_set_option($!s, $l, $o, $v, $error);
    set_error($error);
    $rv;
  }

  method shutdown (
    Int() $shutdown_read,
    Int() $shutdown_write,
    CArray[Pointer[GError]] $error = gerror
  ) {
    my gboolean ($sr, $sw) = ($shutdown_read, $shutdown_write).map( *.so.Int );

    clear_error;
    my $rv = so g_socket_shutdown($!s, $sr, $sw, $error);
    set_error($error);
    $rv;
  }

  method speaks_ipv4 is also<speaks-ipv4> {
    so g_socket_speaks_ipv4($!s);
  }

}
