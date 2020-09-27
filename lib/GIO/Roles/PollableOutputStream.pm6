use v6.c;

use Method::Also;
use NativeCall;

use GIO::Raw::Types;
use GIO::Raw::PollableOutputStream;

use GLib::Source;

role GIO::Roles::PollableOutputStream {
  has GPollableOutputStream $!pos;

  submethod BUILD (:$pollable) {
    $!pos = $pollable if $pollable;
  }

  method roleInit-PollableOutputStream is also<roleInit_PollableOutputStream> {
    return if $!pos;

    my \i = findProperImplementor(self.^attributes);
    $!pos = cast( GPollableOutputStream, i.get_value(self) );
  }

  method GIO::Raw::Definitions::GPollableOutputStream
    is also<GPollableOutputStream>
  { $!pos }

  method new-pollableoutputstream-obj (GPollableOutputStream $pollable)
    is also<new_pollableoutputstream_obj>
  {
    $pollable ?? self.bless( :$pollable ) !! Nil;
  }

  method can_poll is also<can-poll> {
    so g_pollable_output_stream_can_poll($!pos);
  }

  method create_source (
    GCancellable() $cancellable = GCancellable,
                   :$raw        = False
  )
    is also<create-source>
  {
    my $s = g_pollable_output_stream_create_source($!pos, $cancellable);

    $s ??
      ( $raw ?? $s !! GLib::Source.new($s) )
      !!
      Nil;
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_pollable_output_stream_get_type, $n, $t );
  }

  method is_writable is also<is-writable> {
    so g_pollable_output_stream_is_writable($!pos);
  }

  method write_nonblocking (
    Pointer                 $buffer,
    Int()                   $count,
    GCancellable()          $cancellable = GCancellable,
    CArray[Pointer[GError]] $error       = gerror
  )
    is also<write-nonblocking>
  {
    my gsize $c = $count;

    clear_error;
    my $rv = g_pollable_output_stream_write_nonblocking(
      $!pos,
      $buffer,
      $c,
      $cancellable,
      $error
    );
    set_error($error);
    $rv;
  }

  proto method writev_nonblocking (|)
      is also<writev-nonblocking>
  { * }

  multi method writev_nonblocking (
                            @vectors,
    GCancellable()          $cancellable = GCancellable,
    CArray[Pointer[GError]] $error       = gerror,
  ) {
    my $rv = samewith(
      GLib::Roles::TypedBuffer[GOutputVector].new(@vectors).p,
      @vectors.elems,
      $,
      $cancellable,
      $error,
      :all
    );

    $rv[0] ?? $rv[1] !! Nil;
  }
  multi method writev_nonblocking (
    Pointer                 $vectors,
    Int()                   $n_vectors,
                            $bytes_written is rw,
    GCancellable()          $cancellable   = GCancellable,
    CArray[Pointer[GError]] $error         = gerror,
                            :$all          = False
  ) {
    my gsize ($n, $bw) = ($n_vectors, $bw);

    clear_error;
    my $rv = g_pollable_output_stream_writev_nonblocking(
      $!pos,
      $vectors,
      $n,
      $bw,
      $cancellable,
      $error
    );
    set_error($error);
    $bytes_written = $bw;
    $all ?? $rv !! ($rv, $bytes_written);
  }

}
