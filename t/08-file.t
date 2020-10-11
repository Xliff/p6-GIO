use v6.c;

use Test;

use GIO::Raw::Types;
use GIO::Raw::Quarks;

use GLib::Test;

use GIO::Roles::GFile;

sub basic-file-tests (GIO::Roles::File $f, $s) {
  is  $f.get_basename,     'testfile',     'GFile object has basename of `testfile`';
  ok  $f.get_uri.starts-with('file://'),   'GFile object has URI starting with `file://`';
  ok  $f.get_uri.ends-with($s),            "GFile object has URI ending with `{ $s }`";
  ok  $f.has_uri_scheme('file'),           'GFile object has the `file` URI scheme';
  is  $f.get_uri_scheme,   'file',         'GFile returns the scheme value of `file`';
}

sub test-basic {
  subtest 'Basic', {
    my $f = GIO::File.new_for_path('./some/directory/testfile');
    basic-file-tests($f, '/some/directory/testfile');
  }
}

# cw: Not testing GFile's name building functionality, as it has not yet been,
#     andlikely will NOT be, implemented.

sub test-parent {
  subtest 'Parent', {
    my $file1  = GIO::File.new_for_path('./some/directory/testfile');
    my $file2  = GIO::File.new_for_path('./some/directory');
    my $root   = GIO::File.new_for_path('/');
    my $parent = $file1.parent;

    ok  $file1.has_parent($file2),  '$file1\'s has the parent $file2';
    ok  $parent.equal($file2),      '$file1\'s parent equals $file2';
    nok $root.parent,               '$root does not have a parent.'
  }
}

sub test-type {
  subtest 'Type', {
    my $datapath-f = GIO::File.new_for_path(
      my $path = GLib::Test.get_dir(G_TEST_DIST)
    );

    my $file1 = $datapath-f.get_child('g-icon.c');
    my $type1 = $file1.query_file_type;
    is  $type1, G_FILE_TYPE_REGULAR,                'First type test call is to a regular file';

    my $file2 = $datapath-f.get_child('cert-tests');
    my $type2 = $file2.query_file_type;
    is  $type2, G_FILE_TYPE_DIRECTORY,              'Second type test call is to a directory';

    $file2.read;
    diag 'When trying to read the directory as a file...';

    # cw: Getting 225 instead of 51. Why?
    #is  $ERROR.domain, $G_IO_ERROR,                 'Error domain is of the proper type';
    is  $ERROR.code,   G_IO_ERROR_IS_DIRECTORY.Int, 'Error code is the proper value (G_FILE_TYPE_DIRECTORY)';
  }
}

sub test-parse-name {
  subtest 'Parse Name', {
    my $f = GIO::File.new_for_uri('file://somewhere');
    my $n = $f.get_parse_name;
    is $n, 'file://somewhere', 'Round-trip value for \'file://somewhere\' works properly';

    $f = GIO::File.new_for_uri('~foo');
    $n = $f.get_parse_name;
    ok $n,                     'Round-trip value for \'~foo\' is non-NULL';
  }
}

class CreateDeleteData {
  has $.context         is rw;
  has $.file            is rw;
  has $.monitor         is rw;
  has $.ostream         is rw;
  has $.istream         is rw;
  has $.buffersize      is rw;
  has $.monitor-created is rw;
  has $.monitor-deleted is rw;
  has $.monitor-changed is rw;
  has $.monitor-path    is rw;
  has $.pos             is rw;
  has $.data            is rw;
  has $.buffer          is rw;
  has $.timeout         is rw;
  has $.file-deleted    is rw;
  has $.timed-out       is rw;
};

sub monitor-changed ($m, $f, $of, $et, $d) {
  my ($fo, $ofo) = ( GIO::File.new($f), GIO::File.new($of) );
  my ($p,  $pp)  = ($f.get_path, $f.get_peek_path);

  is  $d.monitor-path, $p,  'Monitored path has the correct value';
  is  $p,              $pp, 'Path and peeked path are equivalent';

  $d.monitor-created++ if $et = G_FILE_MONITOR_EVENT_CREATED.Int;
  $d.monitor-deleted++ if $et = G_FILE_MONITOR_EVENT_DELETED.Int;
  $d.monitor-changed++ if $et = G_FILE_MONITOR_EVENT_CHANGED.Int;
  $d.context.wakeup;
}

sub iclosed-cb ($d, $res) {
  my $r = $d.istream.close-finish($res);
  nok $ERROR,               'No error detected when asynchronously closing input stream';
  ok  $r,                   'Return valued from operation is True';
  ok  $d.istream.is-closed, 'Input stream is closed';

  ok  $d.file.delete,       'File deleted operation has been performed';
  nok $ERROR,               'No errors were encountered during delete operation';
  $d.file-deleted = True;
  $d.context.wakeup;
}

sub read-cb ($d, $res) {
  my $size = $d.istream.read-finish($res);

  nok $ERROR, 'No errors detected when asynchronously reading input stream ';

  $d.pos += $size;
  if $d.pos < $d.data.chars {
    my $buf = $d.buffer.substr-rw($d.pos);

    # cw: One day, even the naked 0 will be gone.
    $d.istream.read-async(
      $buf,
      $buf.chars,
      0,
      -> *@a { read-cb($d, @a[1]) }
    );
  } else {
    is  $d.buffer,            $d.data, 'Buffer matches expected data';
    nok $d.istream.is-closed,          'Input stream is NOT closed';

    $d.istream.close-async( -> *@a { iclosed-cb($d, @a[1]) } );
  }
}

sub ipending-cb ($d, $res) {
  $d.istream.read-finish($res);

  # cw: Expect to comment
  ok  $ERROR.domain, $G_IO_ERROR,      'Global ERROR has the proper domain';
  ok  $ERROR.code, G_IO_ERROR_PENDING, 'Global ERROR code is G_IO_ERROR_PENDING';
}

sub skipped-cb ($d, $res) {
  my $s = $d.istream.skip-finish($res);

  nok $ERROR,     'No error detected during .skip-finish';
  is  $s, $d.pos, 'Size of skip and value of position are the same';

  my $buf = $d.buffer.substring-rw($d.pos);
  $d.istream.read-async(
    $buf,
    $buf.chars,
    0,
    -> *@a { read-cb($d, @a[1]) }
  );
  # Should result in a pending error.
  $d.istream.read-async(
    $buf,
    $buf.chars,
    0,
    -> *@a { ipending-cb($d, @a[1]) }
  );
}

sub opened-cb ($d, $res) {
  my $b = $d.file.read-finish($res);

  nok $ERROR, 'No error detected during .read-finish';
  $d.istream = $d.buffersize == 0
    ?? $b.ref
    !! GIO::BufferedInputStream.new(:sized, $b, $d.buffersize);
  $b.unref;
  $d.buffer = Buf.allocate($d.data + 1);
  $d.buffer.pack('A10', $d.data);
  $d.pos = 10;
  $d.istream.skip-async(10, -> *@a { skipped-cb ($d, @a[1]) });
}

sub oclosed-cb ($d, $res) {
  my $ret = $d.ostream.close-finished($res);

  nok $ERROR,               'No error detected during .close-finished';
  ok  $ret,                 'Return value from .closed-finished was True';
  ok  $d.ostream.is-closed, 'Output stream is closed';

  $d.file.read-async(-> *@a { opened-cb($d, @a[1]) });
}

sub written-cb ($d, $res) {
  my $size = $d.ostream.write-finish($res);

  nok $ERROR,                 'No error detected during .write-finished';
  $d.pos += $size;
  if $d.pos < $d.data.chars {
    my $buf = $d.data.substr-rw($d.pos);
    $d.ostream.write-async($buf, $buf.chars, -> *@a { written-cb($d, @a[1]) });
  } else {
    nok $d.ostream.is-closed, 'Output stream is NOT closed';
    $d.ostream.close-async(-> *@a { oclosed-cb($d, @a[1]) });
  }
}

sub opending-cb ($d, $res) {
  $d.ostream.wrote-finish($res);

  is $ERROR.domain, $G_IO_ERROR,        'Error belongs to the G_IO_ERROR domain';
  is $ERROR.code,   G_IO_ERROR_PENDING, 'Error code is G_IO_ERROR_PENDING';
}

sub created-cb ($s, $res, $d) {
  my $base = $s.create-finish($res);

  nok $ERROR,               'No error detected during .create-finish';
  ok  $d.file.query-exists, 'Call to $d.file.query-exists returns a True value';

  $d.ostream = $d.buffersize == 0
    ?? $base.ref
    !! GIO::BufferedOutputStream.new(:sized, $base, $d.buffersize);
  $base.unref;

  $d.ostream.write-async(
    $d.data,
    $d.data.chars,
    -> *@a { written-cb($d, @a[1]) }
  );
  # Should generate a pending error
  $d.ostream.write-async(
    $d.data,
    $d.data.chars,
    -> *@a { opending-cb($d, @a[1]) }
  );
}

sub stop-timeout ($d --> gboolean) {
  $d.timed-out = True;
  $d.context.wakeup;
  G_SOURCE_REMOVE
}

sub test-create-delete ($buffersize) {
  my ($data, $iostream) = ( CreateDeleteData.new );
  $data.buffersize = $buffersize;
  $data.data       = 'abcdefghijklmnopqrstuvxyzABCDEFGHIJKLMNOPQRSTUVXYZ0123456789';
  $data.pos        = 0;
  $data.file       = GIO::File.new_tmp('g_file_create_delete_XXXXXX', $iostream);

  ok $data.file,               'Temporary file created sucessfully';
  $iostream.unref;

  $data.monitor-path = $data.file.get_path;
  $data.monitor-path.IO.unlink;

  nok $data.file.query-exists, 'Monitor file no longer exists';
  $data.monitor = $data.file.monitor_file;

  nok $ERROR,                  'No error detected when creating file monitor';

  my $mn = $data.monitor.typeName;
  if $mn ne <GPollFileMonitor GKqueueFileMonitor>.all {
    $data.monitor.rate-limit = 100;
    $data.monitor.changed.tap(-> $m, $f, $of, $et, $ud {
      monitor-changed($data.monitor, $f, $of, $et, $data)
    });
    $data.timeout = GLib::Timeout.add-seconds(
      10,
      -> *@a { stop-timeout($data) }
    );
    $data.file.crteate-async(-> *@a { created-cb($data, @a[1]) });

    $data.context.iteration(True) while $data.timed-out.not && (
                                          $data.monitor-created.not ||
                                          $data.monitor-deleted.not ||
                                          $data.monitor-changed.not ||
                                          $data.file-deleted   .not
                                        );
    $data.timeout.remove;

    diag 'After monitor run...';
    nok $data.timed-out,            '...no timeout-encountered';
    ok  $data.file-deleted,         '...file was deleted';
    is  $data.monitor-create,  1,   '...monitor was create only once';
    is  $data.monitor-deleted, 1,   '...monmitor was deleted only once';
    is  $data.monitor-changed, 0,   '...monitor was never changed';
    nok $data.monitor.is-cancelled, '...monitor was never cancelled';

    diag 'Monitor cancel operation sent';
    $data.monitor.cancel;
    ok $data.monitor.is-cancelled,  'Monitor has been cancelled';

    # g_clear_pointer($data.context, &g_main_context_unref) -- Why?
    $data.context.unref;

    .unref for $data.ostream, $data.istream;
  } else {
    diag "Skipping test for this GFileMonitorImplementation: $mn";
  }
  .unref for $data.monitor, $data.file;
}

my $original-data = q:to/OD/;
  /**
   * g_file_replace_contents_async:
  **/
  OD

my $replace-data = q:to/RD/;
   /**
    * g_file_replace_contents_async:
    * @file: input #GFile.
    * @contents: string of contents to replace the file with.
    * @length: the length of @contents in bytes.
    * @etag: (nullable): a new <link linkend=\"gfile-etag\">entity tag</link> for the @file, or %NULL
    * @make_backup: %TRUE if a backup should be created.
    * @flags: a set of #GFileCreateFlags.
    * @cancellable: optional #GCancellable object, %NULL to ignore.
    * @callback: a #GAsyncReadyCallback to call when the request is satisfied
    * @user_data: the data to pass to callback function
    *
    * Starts an asynchronous replacement of @file with the given
    * @contents of @length bytes. @etag will replace the document's
    * current entity tag.
    *
    * When this operation has completed, @callback will be called with
    * @user_user data, and the operation can be finalized with
    * g_file_replace_contents_finish().
    *
    * If @cancellable is not %NULL, then the operation can be cancelled by
    * triggering the cancellable object from another thread. If the operation
    * was cancelled, the error %G_IO_ERROR_CANCELLED will be returned.
    *
    * If @make_backup is %TRUE, this function will attempt to
    * make a backup of @file.
   RD

class ReplaceLoadData {
  has $.file  is rw;
  has $.data  is rw;
  has $.loop  is rw;
  has $.again is rw;
}

sub replaced-cb ($d, $res) { ... }
sub loaded-cb   ($d, $res) {
  my ($contents, $length) = $d.file.load-contents-finish($res);

  ok  $contents && $length,   '.load-contents-finish completed with return values';
  nok $ERROR,                 'No errors detected during call to .load-contents-finish';
  is  $length, $d.chars,      'Returned content length matches expected value';
  is  $contents, $d.data,     'Returnede content matches expected value';

  if $d.again {
    $d.again = False;
    $d.data = 'pi pa po';
    $d.file.replace-contents-async(
      $d.data,
      $d.data.chars,
      -> *@a { replaced-cb($d, @a[1]) }
    );
  } else {
    my $r = $d.file.delete;

    nok $ERROR,               'No error during call to .delete';
    ok  $r,                   '.delete returned True';
    nok $d.file.query-exists, 'File no longer exists';
    $d.loop.quit;
  }
}

sub replaced-cb ($d, $res) {
  $d.file.replace-contents-finish($res);

  nok $ERROR, 'No error during call to .replace-contents-finish';
  $d.file.load-contents-async(-> *@a { loaded-cb($d, $res) });
}

sub test-replace-load {
  subtest 'Replace Load', {
    my ($data, $iostream) = ( ReplaceLoadData.new );
    $data.again           = True;
    $data.data            = $replace-data;
    $data.file            = GIO::File.new-tmp(
      'g_file_replace_load_XXXXXX',
      $iostream
    );

    ok $data.file,               '$data.file has a non-Nil value';
    $iostream.unref;

    my $path = $data.file.peek-path;
    $path.IO.unlink;

    nok $data.file.query-exists, '$data.file does not exist after removal';
    $data.loop = GLib::MainLoop.new;
    $data.file.replace-contents-async(
      $data.data,
      -> *@a { replaced-cb($data, @a[1]) }
    );
    $data.loop.run;
    .unref for $data.loop, $data.file;
  }
}

sub test-writev-helper (@vectors, $use-bytes-written, $ec, $el) {
  my $iostream;
  my $file = GIO::File.new-tmp('g_file_writev_XXXXXX', $iostream);

  ok  $file,               '$file is non-Nil';
  ok  $iostream,           '$iostream is non-Nil';

  my ($res, $ubw) = $iostream.output-stream.writev-all(@vectors);
  nok $ERROR,              'No errors detected during .writev-all';
  ok  $res,                '.writev-all returned True';
  is $ubw,      $el,       'Bytes actually written matches expected length'
     if $use-bytes-written;

  $res = $iostream.close;
  nok $ERROR,              'No errors detected when closing the iostream';
  ok  $res,                '.close returned True';
  $iostream.unref;


  my ($contents, $length);
  $res = $file.load-contents($contents, $length, $);
  nok $ERROR,              'No errors detected when loading contents';
  ok  $res,                '.load-contents returned defined values';
  is  $length,   $el,      'Returned length matches expected value';
  is  $contents, $ec,      'Contents match expected value';

  .delete && .unref with $file;
}

sub test-writev {
  my $buffer = "\x1\x2\x3\x4\x5\x1\x2\x3\x4\x5\x6\x7\x8\x9\xa\xb\xc\x1\x2\x3";

  # cw: All of these really need to be a part of the same memory space!
  my @vectors = (
    GOutputVector.new($buffer,               5),
    GOutputVector.new($buffer.substr-rw(5), 12),
    GOutputVector.new($buffer.substr-rw(12), 3)
  );

  test-writev-helper(@vectors, True, $buffer, $buffer.chars);
}

# Ended at line 1295 of original

GLib::Test.init;

test-basic;
test-parent;
test-type;
test-parse-name;
# cw: Currently has an endless-loop somewhere in it's myriad of callbacks.
# test-create-delete($_) for 0, 1, 10, 25, 4096;
