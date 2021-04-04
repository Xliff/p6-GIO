use v6.c;

use NativeCall;
use NativeHelpers::Blob;
use GIO::Raw::Types;
use GIO::Raw::GFile;
use GIO::Raw::Stream;
use GIO::Raw::OutputStream;

use GLib::Roles::TypedBuffer;

my $buffer = CArray[uint8].new(1, 2, 3, 4, 5,
                               1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12,
                               1, 2, 3);

my @vectors = (
  GOutputVector.new( pointer-to( $buffer ),                   5),
  GOutputVector.new( pointer-to( $buffer.&subarray(4) ),     12),
  GOutputVector.new( pointer-to( $buffer.&subarray(5 + 12) ), 3)
);

.buffer.Numeric.say for @vectors;

my        $e     = gerror;
my        $i     = CArray[GFileIOStream].new;
          $i[0]  = GFileIOStream;
my        $file  = g_file_new_tmp('g_file_writev_XXXXXX', $i, $e);
          $i     = ppr($i[0]);
my        $o     = g_io_stream_get_output_stream($i);
my gint64 $ubw   = 0;

$e = gerror;
g_output_stream_writev_all(
  $o,
  GLib::Roles::TypedBuffer[GOutputVector].new(@vectors).p,
  @vectors.elems,
  $ubw,
  GCancellable,
  $e
);
if $e && $e[0] {
  $e = $e[0].deref;
  say $e.gist;
  say $e.message;
}
$ubw.say;
