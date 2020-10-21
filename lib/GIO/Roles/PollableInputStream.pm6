use v6.c;

use Method::Also;
use NativeCall;

use GIO::Raw::Types;
use GIO::Raw::PollableInputStream;

use GLib::Roles::Object;

role GIO::Roles::PollableInputStream does GLib::Roles::Object {
  has GPollableInputStream $!pis;

  method roleInit-PollableInputStream is also<roleInit_PollableInputStream> {
    return if $!pis;

    my \i = findProperImplementor(self.^attributes);
    $!pis = cast(GPollableInputStream, i.get_value(self) );
  }

  method GIO::Raw::Definitions::GPollableInputStream
    is also<GPollableInputStream>
  { * }

  method can_poll is also<can-poll> {
    so g_pollable_input_stream_can_poll($!pis);
  }

  method create_source (GCancellable() $cancellable = GCancellable)
    is also<create-source>
  {
    g_pollable_input_stream_create_source($!pis, $cancellable);
  }

  method get_type is also<pollableinputstream-get-type> {
    state ($n, $t);

    unstable_get_type(
      self.^name,
      &g_pollable_input_stream_get_type(),
      $n,
      $t
    );
  }

  method is_readable is also<is-readable> {
    so g_pollable_input_stream_is_readable($!pis);
  }

  method read_nonblocking (
    Pointer                 $buffer,
    Int()                   $count,
    GCancellable()          $cancellable = GCancellable,
    CArray[Pointer[GError]] $error       = gerror
  )
    is also<read-nonblocking>
  {
    my gsize $c = $count;

    clear_error;
    my $rv = g_pollable_input_stream_read_nonblocking(
      $!pis,
      $buffer,
      $c,
      $cancellable,
      $error
    );
    clear_error($error);
    $rv;
  }

}

our subset GPollableInputStreamAncestry is export of Mu
  where GPollableInputStream | GObject;

class GIO::PollableInputStream does GIO::Roles::PollableInputStream {
  submethod BUILD (:$pollable-input) {
    self.setGPollableInputStream($pollable-input) if $pollable-input;
  }

  method setGPollableInputStream (GPollableInputStreamAncestry $_) {
    my $to-parent;

    $!pis = do {
      when GPollableInputStream {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GPollableInputStream, $_);
      }
    }
    self!setObject($to-parent);
  }

  method new (GPollableInputStreamAncestry $pollable-input, :$ref = True) {
    return Nil unless $pollable-input;

    my $o = self.bless( :$pollable-input );
    $o.ref if $ref;
    $o;
  }

}
