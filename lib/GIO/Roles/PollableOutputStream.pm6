use v6.c;

use Method::Also;
use NativeCall;

use GIO::Raw::Types;
use GIO::Raw::PollableOutputStream;

use GLib::Source;

use GLib::Roles::Object;

role GIO::Roles::PollableOutputStream {
  has GPollableOutputStream $!pos;

  method roleInit-PollableOutputStream is also<roleInit_PollableOutputStream> {
    return if $!pos;

    my \i = findProperImplementor(self.^attributes);
    $!pos = cast( GPollableOutputStream, i.get_value(self) );
  }

  method GIO::Raw::Definitions::GPollableOutputStream
    is also<GPollableOutputStream>
  { $!pos }

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
      ( $raw ?? $s !! GLib::Source.new($s, :!ref) )
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
    CArray[Pointer[GError]] $error        = gerror,
    GCancellable()          :$cancellable = GCancellable,
  ) {
    return-with-all(
      samewith(
        GLib::Roles::TypedBuffer[GOutputVector].new(@vectors).p,
        @vectors.elems,
        $,
        $cancellable,
        $error,
        :all
      )
    );
  }
  multi method writev_nonblocking (
    Pointer                 $vectors,
    Int()                   $n_vectors,
                            $bytes_written is rw,
    GCancellable()          $cancellable   = GCancellable,
    CArray[Pointer[GError]] $error         = gerror,
                            :$all          = False
  ) {
    my gsize ($n, $bw) = ($n_vectors, 0);

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


our subset GPollableOutputStreamAncestry is export of Mu
  where GPollableOutputStream | GObject;

class GIO::PollableOutputStream does GLib::Roles::Object
                                does GIO::Roles::PollableOutputStream
{

  submethod BUILD (:$pollable) {
    self.setGPollableOutputStream($pollable) if $pollable;
  }

  method setGPollableOutputStream (GPollableOutputStreamAncestry $_) {
    my $to-parent;

    $!pos = do {
      when GPollableOutputStream {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GPollableOutputStream, $_);
      }
    }
    self!setObject($to-parent);
  }

  method new (GPollableOutputStreamAncestry $pollable, :$ref = True) {
    return Nil unless $pollable;

    my $o = self.bless( :$pollable );
    $o.ref if $ref;
    $o
  }

}
