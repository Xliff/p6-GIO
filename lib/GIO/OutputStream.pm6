use v6.c;

use Method::Also;
use NativeHelpers::Blob;
use NativeCall;

use GIO::Raw::Types;
use GIO::Raw::OutputStream;

use GLib::Roles::Object;

our subset GOutputStreamAncestry is export of Mu
  where GOutputStream | GObject;

class GIO::OutputStream {
  also does GLib::Roles::Object;

  has GOutputStream $!os is implementor;

  submethod BUILD (:$output-stream) {
    self.setGOutputStream($output-stream) if $output-stream;
  }

  method setGOutputStream (GOutputStreamAncestry $_) {
    my $to-parent;

    $!os = do {
      when GOutputStream {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GOutputStream, $_);
      }
    }
    self!setObject($to-parent);
  }

  method GIO::Raw::Definitions::GOutputStream
    is also<GOutputStream>
  { $!os }

  method new (GOutputStreamAncestry $output-stream, :$ref = True) {
    return Nil unless $output-stream;

    my $o = self.bless( :$output-stream );
    $o.ref if $ref;
    $o;
  }

  method clear_pending is also<clear-pending> {
    g_output_stream_clear_pending($!os);
  }

  method close (
    GCancellable()          $cancellable = GCancellable,
    CArray[Pointer[GError]] $error       = gerror
  ) {
    clear_error;
    my $rv = so g_output_stream_close($!os, $cancellable, $error);
    set_error($error);
    $rv;
  }

  proto method close_async (|)
    is also<close-async>
  { * }

  multi method close_async (
                   &callback,
    gpointer       $user_data    = gpointer,
    Int()          :$io_priority = 0,
    GCancellable() :$cancellable = GCancellable,
  ) {
    samewith($io_priority, $cancellable, &callback, $user_data);
  }
  multi method close_async (
    Int()          $io_priority,
    GCancellable() $cancellable,
                   &callback,
    gpointer       $user_data    = gpointer
  ) {
    my gint $io = $io_priority;

    g_output_stream_close_async(
      $!os,
      $io,
      $cancellable,
      &callback,
      $user_data
    );
  }

  method close_finish (
    GAsyncResult()          $result,
    CArray[Pointer[GError]] $error   = gerror
  )
    is also<close-finish>
  {
    clear_error;
    my $rv = so g_output_stream_close_finish($!os, $result, $error);
    set_error($error);
    $rv;
  }

  method flush (
    GCancellable()          $cancellable  = GCancellable,
    CArray[Pointer[GError]] $error        = gerror
  ) {
    clear_error;
    my $rv = so g_output_stream_flush($!os, $cancellable, $error);
    set_error($error);
    $rv;
  }

  proto method flush_async (|)
    is also<flush-async>
  { * }

  multi method flush_async (
                   &callback,
    gpointer       $user_data    = gpointer,
    Int()          :$io_priority = 0,
    GCancellable() :$cancellable = GCancellable,
  ) {
    samewith($io_priority, $cancellable, &callback, $user_data);
  }
  multi method flush_async (
    Int()          $io_priority,
    GCancellable() $cancellable,
                   &callback,
    gpointer       $user_data    = gpointer
  ) {
    my gint $io = $io_priority;

    g_output_stream_flush_async($!os, $io, $cancellable, &callback, $user_data);
  }

  method flush_finish (
    GAsyncResult()          $result,
    CArray[Pointer[GError]] $error   = gerror
  )
    is also<flush-finish>
  {
    clear_error;
    my $rv = so g_output_stream_flush_finish($!os, $result, $error);
    set_error($error);
    $rv;
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_output_stream_get_type, $n, $t );
  }

  method has_pending is also<has-pending> {
    so g_output_stream_has_pending($!os);
  }

  method is_closed is also<is-closed> {
    so g_output_stream_is_closed($!os);
  }

  method is_closing is also<is-closing> {
    so g_output_stream_is_closing($!os);
  }

  method set_pending (
    CArray[Pointer[GError]] $error = gerror
  )
    is also<set-pending>
  {
    clear_error;
    my $rv = so g_output_stream_set_pending($!os, $error);
    set_error($error);
    $rv;
  }

  method splice (
    GInputStream()          $source,
    Int()                   $flags        = 0,
    GCancellable()          $cancellable  = GCancellable,
    CArray[Pointer[GError]] $error        = gerror
  ) {
    my GOutputStreamSpliceFlags $f = $flags;

    g_output_stream_splice($!os, $source, $f, $cancellable, $error);
  }

  proto method splice_async (|)
    is also<splice-async>
  { * }

  multi method splice_async (
    GInputStream()  $source,
                    &callback,
    gpointer        $user_data,
    Int()           :$flags       = 0,
    Int()           :$io_priority = 0,
    GCancellable()  :$cancellable = GCancellable
  ) {
    samewith(
      $source,
      $flags,
      $io_priority,
      $cancellable,
      &callback,
      $user_data
    );
  }
  multi method splice_async (
    GInputStream()  $source,
    Int()           $flags,
    Int()           $io_priority,
    GCancellable()  $cancellable,
                    &callback,
    gpointer        $user_data
  )
  {
    my gint                     $io = $io_priority;
    my GOutputStreamSpliceFlags $f  = $flags;

    g_output_stream_splice_async(
      $!os,
      $source,
      $f,
      $io,
      $cancellable,
      &callback,
      $user_data
    );
  }

  method splice_finish (
    GAsyncResult()          $result,
    CArray[Pointer[GError]] $error   = gerror
  )
    is also<splice-finish>
  {
    clear_error;
    my $n = g_output_stream_splice_finish($!os, $result, $error);
    set_error($error);
    $n;
  }

  multi method write (
    Pointer                 $buffer,
    Int()                   $count,
    GCancellable()          $cancellable,
    CArray[Pointer[GError]] $error        = gerror
  ) {
    my gsize $c = $count;

    clear_error;
    my $n = g_output_stream_write($!os, $buffer, $c, $cancellable, $error);
    set_error($error);
    $n;
  }

  proto method write_all (|)
    is also<write-all>
  { * }

  multi method write_all (
    Str                     $buffer,
    Int()                   $count       = $buffer.chars,
    GCancellable            $cancellable = GCancellable,
    CArray[Pointer[GError]] $error       = gerror
  ) {
    return-with-all(
      samewith(
        cast(Pointer, $buffer),
        $count,
        $,
        $cancellable,
        $error,
        :all
      )
    );
  }
  multi method write_all (
    Pointer                 $buffer,
    Int()                   $count,
    GCancellable            $cancellable = GCancellable,
    CArray[Pointer[GError]] $error       = gerror,
  ) {
    return-with-all(
      samewith($buffer, $count, $, $cancellable, $error, :all)
    );
  }
  multi method write_all (
    Pointer                 $buffer,
    Int()                   $count,
                            $bytes_written is rw,
    GCancellable            $cancellable   =  GCancellable,
    CArray[Pointer[GError]] $error         =  gerror,
    :$all = False
  ) {
    my gsize ($c, $bw) = ($count, 0);

    clear_error;
    my $rv = g_output_stream_write_all(
      $!os,
      $buffer,
      $c,
      $bw,
      $cancellable,
      $error
    );
    set_error($error);
    $bytes_written = $bw;
    $all.not ?? $rv !! ($rv, $bytes_written);
  }

  proto method write_all_async (|)
    is also<write-all-async>
  { * }

  multi method write_all_async (
    Pointer        $buffer,
    Int()          $count,
                   &callback,
    gpointer       $user_data    = gpointer,
    Int()          :$io_priority = 0,
    GCancellable() :$cancellable = GCancellable
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
  multi method write_all_async (
    Pointer        $buffer,
    Int()          $count,
    Int()          $io_priority,
    GCancellable() $cancellable,
                   &callback,
    gpointer       $user_data    = gpointer
  ) {
    my gint  $io = $io_priority;
    my gsize $c  = $count;

    g_output_stream_write_all_async(
      $!os,
      $buffer,
      $c,
      $io,
      $cancellable,
      &callback,
      $user_data
    );
  }

  proto method write_all_finish (|)
    is also<write-all-finish>
  { * }

  multi method write_all_finish (
    GAsyncResult()          $result,
    CArray[Pointer[GError]] $error   = gerror,
  ) {
    return-with-all( samewith($result, $error, :all) );
  }
  multi method write_all_finish (
    GAsyncResult()          $result,
                            $bytes_written is rw,
    CArray[Pointer[GError]] $error         =  gerror,
                            :$all          =  False
  ) {
    my gsize $bw = 0;

    clear_error;
    my $rv = g_output_stream_write_all_finish($!os, $result, $bw, $error);
    set_error($error);
    $bytes_written = $bw;
    $all.not ?? $rv !! ($rv, $bytes_written);
  }

  proto method write_async (|)
    is also<write-async>
  { * }

  multi method write (
    Str()          $buffer,
                   &callback,
    gpointer       $user_data    =  gpointer,
                   :$async       is required,
    Int()          :$count       =  $buffer.chars,
    GCancellable() :$cancellable =  GCancellable,
    Int()          :$io_priority =  0,
                   :$encoding    =  'utf8'
  ) {
    self.write_async(
      $buffer,
      $count,
      $io_priority,
      $cancellable,
      &callback,
      $user_data
    );
  }
  multi method write_async (
    Str()          $buffer,
                   &callback,
    gpointer       $user_data    =  gpointer,
    Int()          :$count       =  $buffer.chars,
    GCancellable() :$cancellable =  GCancellable,
    Int()          :$io_priority =  0,
                   :$encoding    =  'utf8'
  ) {
    self.write_async(
      $buffer,
      $count,
      $io_priority,
      $cancellable,
      &callback,
      $user_data
    );
  }
  multi method write_async (
    Str()          $buffer,
    Int()          $count,
    Int()          $io_priority,
    GCancellable() $cancellable,
                   &callback,
    gpointer       $user_data    = gpointer,
    Str()          :$encoding    = 'utf8'
  ) {
    samewith(
      CArray[uint8].new( $buffer.encode($encoding) ),
      $count,
      $io_priority,
      $cancellable,
      &callback,
      $user_data
    );
  }
  multi method write (
    CArray[uint8]  $buffer,
                   &callback,
    gpointer       $user_data     =  gpointer,
    Int()          :$count        =  $buffer.elems,
                   :$async        is required,
    Int()          :$io_priority  =  0,
    GCancellable() :$cancellable  =  GCancellable,
  ) {
    self.write_async(
      $buffer,
      $count,
      $io_priority,
      $cancellable,
      &callback,
      $user_data
    );
  }
  multi method write_async (
    CArray[uint8]  $buffer,
                   &callback,
    gpointer       $user_data     =  gpointer,
    Int()          :$count        =  $buffer.elems,
    Int()          :$io_priority  =  0,
    GCancellable() :$cancellable  =  GCancellable,
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
  multi method write_async (
    CArray[uint8]  $buffer,
    Int()          $count,
    Int()          $io_priority,
    GCancellable() $cancellable,
                   &callback,
    gpointer       $user_data    = gpointer
  ) {
    samewith(
      pointer-to($buffer),
      $count,
      $io_priority,
      $cancellable,
      &callback,
      $user_data
    );
  }
  multi method write (
    Pointer        $buffer,
    Int()          $count,
                   &callback,
    gpointer       $user_data    =  gpointer,
                   :$async       is required,
    GCancellable() :$cancellable =  GCancellable,
    Int()          :$io_priority =  0,
  ) {
    self.write_async(
      $buffer,
      $count,
      $io_priority,
      $cancellable,
      &callback,
      $user_data
    );
  }
  multi method write_async (
    Pointer        $buffer,
    Int()          $count,
    Int()          $io_priority,
    GCancellable() $cancellable,
                   &callback,
    gpointer       $user_data    = gpointer
  ) {
    my gint  $io = $io_priority;
    my gsize $c  = $count;

    g_output_stream_write_async(
      $!os,
      $buffer,
      $c,
      $io,
      $cancellable,
      &callback,
      $user_data
    );
  }

  method write_bytes (
    GBytes()                $bytes,
    GCancellable()          $cancellable = GCancellable,
    CArray[Pointer[GError]] $error       = gerror
  )
    is also<write-bytes>
  {
    clear_error;
    my $gs = g_output_stream_write_bytes($!os, $bytes, $cancellable, $error);
    set_error($error);
    $gs;
  }

  proto method write_bytes_async (|)
    is also<write-bytes-async>
  { * }

  multi method write_bytes_async (
    GBytes()            $bytes,
                        &callback,
    gpointer            $user_data    = gpointer,
    Int()               :$io_priority = 0,
    GCancellable        :$cancellable = GCancellable
  ) {
    samewith($bytes, $io_priority, GCancellable, &callback, $user_data);
  }
  multi method write_bytes_async (
    GBytes()            $bytes,
    Int()               $io_priority,
    GCancellable()      $cancellable,
                        &callback,
    gpointer            $user_data    = gpointer
  )
  {
    my gint $io = $io_priority;

    g_output_stream_write_bytes_async(
      $!os,
      $bytes,
      $io,
      $cancellable,
      &callback,
      $user_data
    );
  }

  method write_bytes_finish (
    GAsyncResult()          $result,
    CArray[Pointer[GError]] $error   = gerror
  )
    is also<write-bytes-finish>
  {
    clear_error;
    my $rv = g_output_stream_write_bytes_finish($!os, $result, $error);
    set_error($error);
    $rv;
  }

  method write_finish (
    GAsyncResult()          $result,
    CArray[Pointer[GError]] $error   = gerror
  )
    is also<write-finish>
  {
    clear_error;
    my $rv = g_output_stream_write_finish($!os, $result, $error);
    set_error($error);
    $rv;
  }

  multi method writev (
                            @vectors,
    GCancellable            :$cancellable  =  GCancellable,
    CArray[Pointer[GError]] :$error        =  gerror,
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
    )
  }
  multi method writev (
    Pointer                 $vectors,
    Int()                   $n_vectors,
                            $bytes_written is rw,
    GCancellable()          $cancellable,
    CArray[Pointer[GError]] $error         =  gerror,
                            :$all          =  False;
  ) {
    my gsize ($nv, $bw) = ($n_vectors, 0);

    clear_error;
    my $rv = g_output_stream_writev(
      $!os,
      $vectors,
      $nv,
      $bw,
      $cancellable,
      $error
    );
    set_error($error);
    $bytes_written = $bw;
    $all.not ?? $rv !! ($rv, $bytes_written);
  }

  proto method writev_all (|)
    is also<writev-all>
  { * }

  multi method writev_all (
                            @vectors,
    GCancellable()          :$cancellable  = GCancellable,
    CArray[Pointer[GError]] :$error        = gerror
  ) {
    return-with-all(
      samewith(
        +@vectors ?? GLib::Roles::TypedBuffer[GOutputVector].new(@vectors).p
                  !! Pointer,
        @vectors.elems,
        $,
        $cancellable,
        $error,
        :all
      )
    );
  }
  multi method writev_all (
    Pointer                 $vectors,
    Int()                   $n_vectors,
                            $bytes_written is rw,
    GCancellable()          $cancellable   =  GCancellable,
    CArray[Pointer[GError]] $error         =  gerror,
                            :$all          =  False
  ) {
    my gsize ($nv, $bw) = ($n_vectors, 0);

    clear_error;
    my $rv = so g_output_stream_writev_all(
      $!os,
      $vectors,
      $nv,
      $bw,
      $cancellable,
      $error
    );
    set_error($error);
    $bytes_written = $bw;
    $all.not ?? $bytes_written !! ($rv, $bytes_written);
  }

  proto method writev_all_async (|)
    is also<writev-all-async>
  { * }

  multi method writev_all_async (
                        @vectors,
                        &callback,
    gpointer            $user_data    = gpointer,
    Int()               :$io_priority = 0,
    GCancellable()      :$cancellable = GCancellable

  ) {
    samewith(
      GLib::Roles::TypedBuffer[GOutputVector].new(@vectors).p,
      @vectors.elems,
      $io_priority,
      $cancellable,
      &callback,
      $user_data
    );
  }
  multi method writev_all_async (
    Pointer             $vectors,
    Int()               $n_vectors,
    Int()               $io_priority,
    GCancellable()      $cancellable,
                        &callback,
    gpointer            $user_data    = gpointer
  ) {
    my gint  $io = $io_priority;
    my gsize $nv = $n_vectors;

    g_output_stream_writev_all_async(
      $!os,
      $vectors,
      $nv,
      $io,
      $cancellable,
      &callback,
      $user_data
    );
  }

  proto method writev_all_finish (|)
    is also<writev-all-finish>
  { * }

  multi method writev_all_finish (
    GAsyncResult()          $result,
    CArray[Pointer[GError]] $error   = gerror
  ) {
    return-with-all( samewith($result, $, $error, :all) );
  }
  multi method writev_all_finish (
    GAsyncResult()          $result,
                            $bytes_written is rw,
    CArray[Pointer[GError]] $error                = gerror,
                            :$all                 = False
  ) {
    my gsize $bw = 0;

    clear_error;
    my $rv = so g_output_stream_writev_all_finish($!os, $result, $bw, $error);
    set_error($error);
    $bytes_written = $bw;
    $all.not ?? $rv !! ($rv, $bytes_written);
  }

  proto method writev_async (|)
    is also<writev-async>
  { * }

  multi method writev_async (
                    @vectors,
                    &callback,
    gpointer        $user_data    = gpointer,
    Int()           :$io_priority = 0,
    GCancellable()  :$cancellable = GCancellable
  ) {
    samewith(
      GLib::Roles::TypedBuffer[GOutputVector].new(@vectors).p,
      @vectors.elems,
      $io_priority,
      $cancellable,
      &callback,
      $user_data
    );
  }
  multi method writev_async (
    GOutputVector() $vectors,
    Int()           $n_vectors,
    Int()           $io_priority,
    GCancellable()  $cancellable,
                    &callback,
    gpointer        $user_data    = gpointer
  ) {
    my gint  $io = $io_priority;
    my gsize $nv = $n_vectors;

    g_output_stream_writev_async(
      $!os,
      $vectors,
      $nv,
      $io,
      $cancellable,
      &callback,
      $user_data
    );
  }

  proto method writev_finish (|)
    is also<writev-finish>
  { * }

  multi method writev_finish (
    GAsyncResult()          $result,
    CArray[Pointer[GError]] $error   = gerror
  ) {
    return-with-all( samewith($result, $, $error, :all) );
  }
  multi method writev_finish (
    GAsyncResult()          $result,
                            $bytes_written is rw,
    CArray[Pointer[GError]] $error         =  gerror,
                            :$all = False
  ) {
    my gsize $bw = 0;

    clear_error;
    my $rv = so g_output_stream_writev_finish($!os, $result, $bw, $error);
    set_error($error);
    $bytes_written = $bw;

    $all.not ?? $rv !! ($rv, $bytes_written)
  }

}
