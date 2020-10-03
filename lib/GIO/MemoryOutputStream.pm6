use v6.c;

use Method::Also;

use NativeCall;

use GIO::Raw::Types;
use GIO::Raw::MemoryOutputStream;

use GIO::OutputStream;

use GIO::Roles::Seekable;
use GIO::Roles::PollableOutputStream;

our subset GMemoryOutputStreamAncestry of Mu is export
  where GMemoryOutputStream | GSeekable | GPollableOutputStream | GOutputStream;

class GIO::MemoryOutputStream is GIO::OutputStream {
  also does GIO::Roles::Seekable;
  also does GIO::Roles::PollableOutputStream;

  has GMemoryOutputStream $!mos is implementor;

  submethod BUILD (:$memory-output) {
    self.setMemoryOutputStream($memory-output) if $memory-output;
  }

  method setMemoryOutputStream (GMemoryOutputStreamAncestry $_) {
    my $to-parent;

    $!mos = do {
      when GMemoryOutputStream {
        $to-parent = cast(GOutputStream, $_);
        $_;
      }

      when GSeekable {
        $!s = $_;
        $to-parent = cast(GOutputStream, $_);
        cast(GMemoryOutputStream, $_);
      }

      when GPollableOutputStream {
        $!pos = $_;
        $to-parent = cast(GOutputStream, $_);
        cast(GMemoryOutputStream, $_);
      }

      default {
        $to-parent = $_;
        cast(GMemoryOutputStream, $_);
      }
    }

    self.setOuptutStream($to-parent);
    self.roleInit-Seekable             unless $!s;
    self.RoleInit-PollableOutputStream unless $!pos;
  }

  method GIO::Raw::Definitions::GMemoryOutputStream
    is also<GMemoryOutputStream>
  { $!mos }

  multi method new (GMemoryOutputStreamAncestry $memory-output, :$ref = True) {
    return Nil unless $memory-output;

    my $o = self.bless( :$memory-output );
    $o.ref if $ref;
    $o;
  }
  multi method new (
    Buf() $data,
          &realloc_function,
          &destroy_function = Callable
  ) {
    samewith(
      cast(Pointer, $data),
      $data.elems,
      &realloc_function,
      &destroy_function
    )
  }
  multi method new (
    gpointer $data,
    Int()    $size,
             &realloc_function,
             &destroy_function = Callable
  ) {
    my gsize $s = $size;
    my $memory-output = g_memory_output_stream_new(
      $data,
      $size,
      &realloc_function,
      &destroy_function
    );

    $memory-output ?? self.bless( :$memory-output ) !! Nil;
  }

  method new_resizable is also<new-resizable> {
    my $memory-output = g_memory_output_stream_new_resizable();

    $memory-output ?? self.bless( :$memory-output ) !! Nil;
  }

  method get_data (:$raw = False) is also<get-data> {
    my $d = g_memory_output_stream_get_data($!mos);

    $d ??
      ( $raw ?? $d !! cast(CArray[uint8], $d) )
      !!
      Nil;
  }

  method get_data_size is also<get-data-size> {
    g_memory_output_stream_get_data_size($!mos);
  }

  method get_size is also<get-size> {
    g_memory_output_stream_get_size($!mos);
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_memory_output_stream_get_type, $n, $t );
  }

  method steal_as_bytes (:$raw = False) is also<steal-as-bytes> {
    my $b = g_memory_output_stream_steal_as_bytes($!mos);

    $b ??
      ( $raw ?? $b !! GLib::Bytes.new($b) )
      !!
      Nil;
  }

  method steal_data (:$raw = False) is also<steal-data> {
    my $d = g_memory_output_stream_steal_data($!mos);

    $d ??
      ( $raw ?? $d !! cast(CArray[uint8], $d) )
      !!
      Nil;
  }

}
