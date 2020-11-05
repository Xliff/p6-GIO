use v6.c;

use Test;

use GIO::Raw::Types;

use GIO::DataOutputStream;
use GIO::MemoryOutputStream;

constant MAX_LINES        = 0xfff;
constant MAX_LINES_BUFF   = 0xffffff;
constant MAX_BYTES_BINARY = 0x100;

sub test-basic {
  my $data        = Buf.allocate(MAX_LINES_BUFF, 0);
  my $base-stream = GIO::MemoryOutputStream.new($data, MAX_LINES_BUFF);
  my $stream      = GIO::DataOutputStream.new($base-stream);

  is $stream.byte-order, G_DATA_STREAM_BYTE_ORDER_BIG_ENDIAN,    'Stream has Big Endian byte order';

  $stream.byte-order = G_DATA_STREAM_BYTE_ORDER_LITTLE_ENDIAN;
  is $stream.byte-order, G_DATA_STREAM_BYTE_ORDER_LITTLE_ENDIAN, 'Stream now reports Little Endian byte order after set operation';

  .unref for $stream, $base-stream;
}

sub test-read-lines ($nlt) {
  constant TEST_PREFIX = 'some_text';

  my $max-lines = 2;

  my @endl             = ("\n", "\r", "\r\n", "\n");
  my $test-string      = TEST_PREFIX ~ @endl[$nlt.value];
  my $test-str-len     = $test-string.chars;
  my $data             = Buf.allocate(MAX_LINES_BUFF, 0);
  my $base-stream      = GIO::MemoryOutputStream.new($data, MAX_LINES_BUFF);
  my $stream           = GIO::DataOutputStream.new($base-stream);
  my $lines            = $test-string x $max-lines;

  # cw: .decode may turn a Buf into a Str, but it still embeds all of the NUL chars.
  #     This converts that value back into a proper C-expectant Str
  sub c-decode ($b) {
    my $i = 0;
    $i++ while $b[$i];
    $b.subbuf(0, $i).decode;
  }

  subtest "Read line test for { $nlt.key }", {
    for ^$max-lines {
      my $res = $stream.put-string($test-string);
      #nok $ERROR,                                                  "No error detected when writing line { $_ }";
      #ok  $res,                                                    '.put-string operation completed properly';
    }

    $stream.byte-order = G_DATA_STREAM_BYTE_ORDER_BIG_ENDIAN;
    is $stream.byte-order, G_DATA_STREAM_BYTE_ORDER_BIG_ENDIAN,    'Stream reports Big Endian byte order after set operation';

    $stream.byte-order = G_DATA_STREAM_BYTE_ORDER_LITTLE_ENDIAN;
    is $stream.byte-order, G_DATA_STREAM_BYTE_ORDER_LITTLE_ENDIAN, 'Stream reports Little Endian byte order after set operation';

    # cw: Why doesn't .decode stop at first null char? Named option, maybe?
    my $data-result = $data.&c-decode;
    ok $data-result.chars < MAX_LINES_BUFF,                        'Data output stream is not larger than original buffer';
    is $data-result,       $lines,                                 'Data output stream matches expected result';
  }

  .unref for $base-stream, $stream;
}

enum TestDataType <
  TEST_DATA_BYTE
  TEST_DATA_INT16   TEST_DATA_UINT16
  TEST_DATA_INT32   TEST_DATA_UINT32
  TEST_DATA_INT64   TEST_DATA_UINT64
>;

sub test-data-array ($buf, $len, $type, $bo) {
  my $stream-data = Buf.allocate($len, 0);
  my $base-stream = GIO::MemoryOutputStream.new($stream-data, $len);
  my $stream      = GIO::DataOutputStream.new($base-stream);

  $stream.byte-order = $bo == BigEndian ?? G_DATA_STREAM_BYTE_ORDER_BIG_ENDIAN
                                        !! G_DATA_STREAM_BYTE_ORDER_LITTLE_ENDIAN;
  my $swap = $bo != NativeEndian && $bo != $*KERNEL.endian;

  my $suf;
  my $ws = do given $type {
    when TEST_DATA_BYTE                     { 1; $suf = 'byte' }
    when TEST_DATA_INT16 | TEST_DATA_UINT16 { 2; $suf = 'int16'; $suf = "u{$suf}" if $_ == TEST_DATA_UINT16 }
    when TEST_DATA_INT32 | TEST_DATA_UINT32 { 4; $suf = 'int32'; $suf = "u{$suf}" if $_ == TEST_DATA_UINT32 }
    when TEST_DATA_INT64 | TEST_DATA_UINT64 { 8; $suf = 'int64'; $suf = "u{$suf}" if $_ == TEST_DATA_UINT64 }
  }
  nok $len % $ws, "Length is divisible by word size ($ws)";
  $len /= $ws if $ws == 8;

  # Write
  my $res;
  $res = $stream."put_{ $suf }"( $buf[$_] ) for ^$len;
  nok $ERROR,     'No errors detected during writes';
  ok  $res,       'All writes completed successfully';

  # Adjust suffix for Raku, not C.
  my $read-suf = $suf eq 'byte' ?? 'uint8' !! $suf;
  # Compare
  for ^$len {
    my $read-byte-order = $swap
      ?? ( $bo == NativeEndian ?? NativeEndian
                               !! ( $bo == LittleEndian ?? BigEndian
                                                        !! LittleEndian ) )
      !! $bo;

    my $val = $buf."read-{ $read-suf }"($_, $read-byte-order);
    is $val, $stream-data[$_], "Value matches data at position { $_ }";
  }

  .unref for $base-stream, $stream;
}

test-basic;
test-read-lines($_) for GDataStreamNewlineTypeEnum.enums.sort( *.values ).head(* - 1);
