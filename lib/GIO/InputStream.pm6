use v6.c;

use Method::Also;

use NativeCall;

use GIO::Raw::Types;
use GIO::Raw::InputStream;

use GLib::Roles::Object;

our subset GInputStreamAncestry is export of Mu
  where GInputStream | GObject;

class GIO::InputStream {
  also does GLib::Roles::Object;

  has GInputStream $!is is implementor;

  submethod BUILD (:$stream) {
    self.setInputStream($stream) if $stream;
  }

  method setInputStream (GInputStreamAncestry $_) is also<setGInputStream> {
    $!is = do {
      when GInputStream  { $_                     }
      when GObject       { cast(GInputStream, $_) }
    }

    self.roleInit-Object;
  }

  method GIO::Raw::Structs::GInputStream
    is also<GInputStream>
  { $!is }

  method new (GInputStreamAncestry $stream, :$ref = True) {
    return Nil unless $stream;

    my $o = self.bless( :$stream );
    $o.ref if $ref;
    $o;
  }

  method clear_pending is also<clear-pending> {
    g_input_stream_clear_pending($!is);
  }

  multi method close (
    GCancellable()          :$cancellable = GCancellable,
    CArray[Pointer[GError]] :$error       = gerror
  ) {
    samewith($cancellable, $error);
  }
  multi method close (
    GCancellable()          $cancellable,
    CArray[Pointer[GError]] $error       = gerror
  ) {
    g_input_stream_close($!is, $cancellable, $error);
  }

  proto method close_async (|)
    is also<close-async>
  { * }

  multi method close_async (
    &callback,
    GCancellable() $cancellable = GCancellable,
    gpointer       $user_data   = Pointer
  ) {
    samewith(0, $cancellable, &callback, $user_data);
  }
  multi method close_async (
    Int()          $io_priority,
                   &callback,
    GCancellable() $cancellable = GCancellable,
    gpointer       $user_data   = Pointer
  ) {
    samewith($io_priority, $cancellable, &callback, $user_data);
  }
  multi method close_async (
    Int()          $io_priority,
    GCancellable() $cancellable,
                   &callback,
    gpointer       $user_data = Pointer
  ) {
    my int32 $io = $io_priority;

    g_input_stream_close_async(
      $!is,
      $io_priority,
      $cancellable,
      &callback,
      $user_data
    );
  }

  method close_finish (
    GAsyncResult()          $result,
    CArray[Pointer[GError]] $error = gerror()
  )
    is also<close-finish>
  {
    clear_error;
    my $rv = so g_input_stream_close_finish($!is, $result, $error);
    set_error($error);
    $rv;
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_input_stream_get_type, $n, $t );
  }

  method has_pending is also<has-pending> {
    so g_input_stream_has_pending($!is);
  }

  method is_closed is also<is-closed> {
    so g_input_stream_is_closed($!is);
  }

  method read (
    Blob()                  $buffer,
    Int()                   $count,
    GCancellable()          $cancellable = GCancellable,
    CArray[Pointer[GError]] $error       = gerror
  ) {
    my uint64 $c = $count;

    clear_error;
    my $s = g_input_stream_read($!is, $buffer, $c, $cancellable, $error);
    set_error($error);
    $s;
  }

  method read_all (
    Blob()                  $buffer,
    Int()                   $count,
    Int()                   $bytes_read,
    GCancellable()          $cancellable = GCancellable,
    CArray[Pointer[GError]] $error       = gerror
  )
    is also<read-all>
  {
    my gsize ($c, $b) = ($count, $bytes_read);

    clear_error;
    my $rv = so g_input_stream_read_all(
      $!is,
      $buffer,
      $c,
      $b,
      $cancellable,
      $error
    );
    set_error($error);
    $rv;
  }

  proto method read_all_async (|)
    is also<read-all-async>
  { * }

  multi method read_all_async (
    Blob()         $buffer,
    Int()          $count,
    Int()          $io_priority,
                   &callback,
    gpointer       $user_data   = Pointer,
    GCancellable() $cancellable = GCancellable,
  ) {
    samewith(
      $buffer,
      $count,
      $io_priority,
      $cancellable,
      &callback,
      $user_data
    );
  }
  multi method read_all_async (
    Pointer        $buffer,
    Int()          $count,
    Int()          $io_priority,
    GCancellable() $cancellable,
                   &callback,
    gpointer       $user_data = Pointer
  ) {
    my int32 $io = $io_priority;
    my gsize $c  = $count;

    g_input_stream_read_all_async(
      $!is,
      $buffer,
      $c,
      $io,
      $cancellable,
      &callback,
      $user_data
    );
  }

  method read_all_finish (
    GAsyncResult()          $result,
    Int()                   $bytes_read,
    CArray[Pointer[GError]] $error = gerror()
  )
    is also<read-all-finish>
  {
    my gsize $b = $bytes_read;

    clear_error;
    my $rv = so g_input_stream_read_all_finish($!is, $result, $b, $error);
    set_error($error);
    $rv;
  }

  proto method read_async (|)
    is also<read-async>
  { * }

  # cw: Not complete. Missing multis for Str, CArray[uint8], Pointer
  multi method read_async (
    CArray[uint8]  $buffer,
    Int()          $count,
    Int()          $io_priority,
                   &callback,
    gpointer       $user_data    = Pointer,
    GCancellable() $cancellable  = GCancellable
  ) {
    my $b = Buf.allocate($count, 0);
    $b[$_] = $buffer[$_] for ^$count;

    samewith(
      $b,
      $count,
      $io_priority,
      $cancellable,
      &callback,
      $user_data
    );
  }
  multi method read_async (
    Blob()         $buffer,
    Int()          $count,
    Int()          $io_priority,
                   &callback,
    gpointer       $user_data    = Pointer,
    GCancellable() $cancellable  = GCancellable
  ) {
    samewith(
      $buffer,
      $count,
      $io_priority,
      $cancellable,
      &callback,
      $user_data
    );
  }
  multi method read_async (
    Blob()         $buffer,
    Int()          $count,
    Int()          $io_priority,
    GCancellable() $cancellable,
                   &callback,
    gpointer       $user_data
  ) {
    my gsize $c = $count;
    my guint $io = $io_priority;

    g_input_stream_read_async(
      $!is,
      $buffer,
      $c,
      $io,
      $cancellable,
      &callback,
      $user_data
    );
  }

  method read_bytes (
    Int()                   $count,
    GCancellable()          $cancellable = GCancellable,
    CArray[Pointer[GError]] $error       = gerror()
  )
    is also<read-bytes>
  {
    my gsize $c = $count;

    clear_error;
    my $rv = so g_input_stream_read_bytes($!is, $c, $cancellable, $error);
    set_error($error);
    $rv;
  }

  proto method read_bytes_async (|)
    is also<read-bytes-async>
  { * }

  multi method read_bytes_async (
    Int()          $count,
    Int()          $io_priority,
                   &callback,
    gpointer       $user_data    = Pointer,
                   :$cancellable = GCancellable
  ) {
    samewith($count, $io_priority, $cancellable, &callback, $user_data);
  }
  multi method read_bytes_async (
    Int()        $count,
    Int()        $io_priority,
    GCancellable $cancellable,
                 &callback,
    gpointer     $user_data
  ) {
    my uint32 $io = $io_priority;
    my gsize  $c  = $count;

    g_input_stream_read_bytes_async(
      $!is,
      $c,
      $io,
      $cancellable,
      &callback,
      $user_data
    );
  }

  method read_bytes_finish (
    GAsyncResult()          $result,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<read-bytes-finish>
  {
    clear_error;
    my $s = so g_input_stream_read_bytes_finish($!is, $result, $error);
    set_error($error);
    $s;
  }

  method read_finish (
    GAsyncResult()          $result,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<read-finish>
  {
    clear_error;
    my $s = g_input_stream_read_finish($!is, $result, $error);
    set_error($error);
    $s;
  }

  method set_pending (CArray[Pointer[GError]] $error = gerror)
    is also<set-pending>
  {
    clear_error;
    my $rv = so g_input_stream_set_pending($!is, $error);
    set_error($error);
    $rv;
  }

  method skip (
    Int()                   $count,
    GCancellable()          $cancellable = GCancellable,
    CArray[Pointer[GError]] $error       = gerror
  ) {
    my gsize $c = $count;
    clear_error;
    my $s = g_input_stream_skip($!is, $c, $cancellable, $error);
    set_error($error);
    $s;
  }

  proto method skip_async (|)
    is also<skip-async>
  { * }

  multi method skip_async (
    Int()          $count,
                   &callback,
    gpointer       $user_data                  = Pointer,
    Int()          :io_priority(:$io-priority) = G_PRIORITY_DEFAULT,
    GCancellable() :$cancellable               = GCancellable
  ) {
    samewith($count, $io-priority, $cancellable, &callback, $user_data);
  }
  multi method skip_async (
    Int()          $count,
    Int()          $io_priority,
    GCancellable() $cancellable,
                   &callback,
    gpointer       $user_data = Pointer
  ) {
    my uint32 $io = $io_priority;

    my gsize $c   = $count;
    g_input_stream_skip_async(
      $!is,
      $c,
      $io,
      $cancellable,
      &callback,
      $user_data
    );
  }

  method skip_finish (
    GAsyncResult()          $result,
    CArray[Pointer[GError]] $error   = gerror()
  )
    is also<skip-finish>
  {
    clear_error;
    my $s = g_input_stream_skip_finish($!is, $result, $error);
    set_error($error);
    $s;
  }

}
