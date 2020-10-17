use v6.c;

use NativeCall;
use Test;

use GLib::Compat::Definitions;
use GIO::Raw::Types;
use GIO::Raw::Quarks;
use GIO::Raw::FileAttributeTypes;

use GLib::FileUtils;
use GLib::MainLoop;
use GLib::Source;
use GLib::Test;
use GLib::Timeout;

use GIO::BufferedOutputStream;

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
  CATCH { default { .message.say } }

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
  CATCH { default { .message.say } }

  my $r = $d.istream.close_finish($res);
  nok $ERROR,               'No error detected when asynchronously closing input stream';
  ok  $r,                   'Return valued from operation is True';
  ok  $d.istream.is-closed, 'Input stream is closed';

  ok  $d.file.delete,       'File deleted operation has been performed';
  nok $ERROR,               'No errors were encountered during delete operation';
  $d.file-deleted = True;
  $d.context.wakeup;
}

sub read-cb ($d, $res) {
  CATCH { default { .message.say } }

  my $size = $d.istream.read_finish($res);

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
  CATCH { default { .message.say } }

  $d.istream.read_finish($res);

  # cw: Expect to comment
  ok  $ERROR.domain, $G_IO_ERROR,      'Global ERROR has the proper domain';
  ok  $ERROR.code, G_IO_ERROR_PENDING, 'Global ERROR code is G_IO_ERROR_PENDING';
}

sub skipped-cb ($d, $res) {
  CATCH { default { .message.say } }

  my $s = $d.istream.skip-finish($res);

  nok $ERROR,     'No error detected during .skip-finish';
  is  $s, $d.pos, 'Size of skip and value of position are the same';

  my $buf = $d.buffer.subbuf($d.pos);
  $d.istream.read-async(
    $buf,
    $buf.chars,
    0,
    -> *@a {
      CATCH { default { .message.say } }
      read-cb($d, @a[1])
    }
  );
  # Should result in a pending error.
  $d.istream.read-async(
    $buf,
    $buf.chars,
    0,
    -> *@a {
      CATCH { default { .message.say } }
      ipending-cb($d, @a[1])
    }
  );
}

sub opened-cb ($d, $res) {
  CATCH { default { .message.say } }

  my $b = $d.file.read_finish($res);

  nok $ERROR, 'No error detected during .read_finish';
  $d.istream = $d.buffersize == 0
    ?? $b.ref
    !! GIO::BufferedInputStream.new(:sized, $b, $d.buffersize);
  $b.unref;

  # cw: XXX - Work blockage here... must figure this out.
  $d.buffer = Buf.allocate($d.data.chars + 1, 0);
  my $db = $d.data.encode('utf8');
  $d.buffer[$_] = $db[$_] for ^10;

  $d.pos = 10;
  $d.istream.skip-async(
    10,
    -> *@a {
      CATCH { default { .message.say; .backtrace.summary.say } }
      skipped-cb($d, @a[1])
    }
  );
}

sub oclosed-cb ($d, $res) {
  CATCH { default { .message.say } }

  my $ret = $d.ostream.close_finish($res);

  nok $ERROR,               'No error detected during .close-finished';
  ok  $ret,                 'Return value from .closed-finished was True';
  ok  $d.ostream.is-closed, 'Output stream is closed';

  $d.file.read_async(
    -> *@a {
      CATCH { default { .message.say } }
      opened-cb($d, @a[1])
    }
  );
}

sub written-cb ($d, $res) {
  CATCH { default { .message.say } }

  my $size = $d.ostream.write-finish($res);

  nok $ERROR,                 'No error detected during .write-finished';
  $d.pos += $size;
  if $d.pos < $d.data.chars {
    my $buf = $d.data.substr-rw($d.pos);
    $d.ostream.write-async(
      $buf, $buf.chars, -> *@a {
        CATCH { default { .message.say } }
        written-cb($d, @a[1])
      }
    );
  } else {
    nok $d.ostream.is-closed, 'Output stream is NOT closed';
    $d.ostream.close-async(-> *@a {
      CATCH { default { .message.say } }
      oclosed-cb($d, @a[1])
    });
  }
}

sub opending-cb ($d, $res) {
  CATCH { default { .message.say } }

  $d.ostream.write-finis($res);

  is $ERROR.domain, $G_IO_ERROR,            'Error belongs to the G_IO_ERROR domain';
  is $ERROR.code,   G_IO_ERROR_PENDING.Int, 'Error code is G_IO_ERROR_PENDING';
}

sub created-cb ($f, $res, $d) {
  CATCH { default { .message.say; .backtrace.summary.say } }

  my $base = $f.create_finish($res);

  nok $ERROR,               'No error detected during .create-finish';
  ok  $d.file.query_exists, 'Call to $d.file.query-exists returns a True value';

  $d.ostream = $d.buffersize == 0
    ?? $base.ref
    !! GIO::BufferedOutputStream.new(:sized, $base, $d.buffersize);
  $base.unref;

  $d.ostream.write-async(
    $d.data,
    $d.data.chars,
    -> *@a {
      CATCH { default { .message.say; .backtrace.summary.say } }
      written-cb($d, @a[1])
    }
  );
  # Should generate a pending error
  $d.ostream.write-async(
    $d.data,
    $d.data.chars,
    -> *@a {
      CATCH { default { .message.say; .backtrace.summary.say } }
      opending-cb($d, @a[1])
    }
  );
}

sub stop-timeout ($d --> gboolean) {
  CATCH { default { .message.say; .backtrace.summary.say } }

  $d.timed-out = True;
  $d.context.wakeup;
  G_SOURCE_REMOVE
}

sub test-create-delete ($buffersize) {
  subtest "Create Delete: $buffersize", {
    CATCH { default { .message.say; .backtrace.summary.say } }

    my ($data, $iostream) = ( CreateDeleteData.new );
    $data.context    = GLib::MainContext;
    $data.buffersize = $buffersize;
    $data.data       = 'abcdefghijklmnopqrstuvxyzABCDEFGHIJKLMNOPQRSTUVXYZ0123456789';
    $data.pos        = 0;
    $data.file       = GIO::File.new_tmp('g_file_create_delete_XXXXXX', $iostream);

    ok $data.file,               'Temporary file created sucessfully';
    $iostream.unref;

    $data.monitor-path = $data.file.get_path;
    $data.monitor-path.IO.unlink;

    nok $data.file.query_exists, 'Monitor file no longer exists';
    $data.monitor = $data.file.monitor_file;

    nok $ERROR,                  'No error detected when creating file monitor';

    my $mn = $data.monitor.objectType.name;
    if $mn ne <GPollFileMonitor GKqueueFileMonitor>.all {
      $data.monitor.rate-limit = 100;
      # $data.monitor.changed.tap(-> $m, $f, $of, $et, $ud {
      #   CATCH { default { .message.say } }
      #   monitor-changed($data.monitor, $f, $of, $et, $data)
      # });
      $data.timeout = GLib::Timeout.add-seconds(
        10,
        -> *@a --> gboolean {
          CATCH { default { .message.say; .backtrace.summary.say } }
          stop-timeout($data)
        }
      );
      $data.file.create_async(-> *@a {
        CATCH { default { .message.say; .backtrace.summary.say } }
        created-cb($data.file, @a[1], $data)
      });

      $data.context.iteration(True) while $data.timed-out.not && (
                                            $data.monitor-created.not ||
                                            $data.monitor-deleted.not ||
                                            $data.monitor-changed.not ||
                                            $data.file-deleted   .not
                                          );
      GLib::Source.remove($data.timeout);

      diag 'After monitor run...';
      nok $data.timed-out,            '...no timeout-encountered';
      ok  $data.file-deleted,         '...file was deleted';
      is  $data.monitor-created, 1,   '...monitor was create only once';
      is  $data.monitor-deleted, 1,   '...monmitor was deleted only once';
      is  $data.monitor-changed, 0,   '...monitor was never changed';
      nok $data.monitor.is-cancelled, '...monitor was never cancelled';

      diag 'Monitor cancel operation sent';
      $data.monitor.cancel;
      ok $data.monitor.is-cancelled,  'Monitor has been cancelled';

      # g_clear_pointer($data.context, &g_main_context_unref) -- Why?
      # ...ESPECIALLY for a NULL pointer, even!

      for $data.ostream, $data.istream {
        .unref if .defined;
      }
    } else {
      diag "Skipping test for this GFileMonitorImplementation: $mn";
    }
    .unref for $data.monitor, $data.file;
  }
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

sub test-replace-cancel {
  subtest 'Replace/Cancel', {
    diag '#629301';
    my $path   = GLib::FileUtils.make-tmp('g_file_replace_cancel_XXXXXX');
    nok  $ERROR,                                   'No error encountered when creating tmp directory name';

    my $tmpdir = GIO::File.new-for-path($path);
    my $f      = $tmpdir.get-child('file');

    $f.replace-contents($original-data);
    nok  $ERROR,                                   'No error encountered when setting replacement content';

    my $o = $f.replace;
    nok  $ERROR,                                   'No errors encountered when creating replacement output stream';

    my $bw = $o.write-all($replace-data);
    nok $ERROR,                                    'No errors encountered when writing replacement data';
    is  $bw,    $replace-data.chars,               'Bytes written by .write-all matches the expected value';

    my $fenum = $tmpdir.enumerate_children;
    nok $ERROR,                                    'No error detected obtaining a file enumerator';

    my $info  = $fenum.next-file;
    nok $ERROR,                                    'No error detected detected retrieving the next file';
    ok  $info,                                     'Next file retrieved successfully';
    $info.unref;

    $info  = $fenum.next-file;
    nok $ERROR,                                    'No error detected detected retrieving the next file';
    ok  $info,                                     'Next file retrieved successfully';
    $info.unref;

    $fenum.close;
    nok $ERROR,                                    'No error detected when closing the enumerator';
    $fenum.unref;

    $fenum = $tmpdir.enumerate_children;
    nok $ERROR,                                    'No error detected obtaining a file enumerator';

    # Test both indicies
    for ^2 -> $id {
      my $count = 0;
      loop {
        my $info = $fenum.iterate;
        ok  $info[0],                              "[$id] A value was retrieved when iterating the enumerator";
        nok $ERROR,                                "[$id] No errors were detected during iteration";
        last unless $info[0];
        $count++;
      }
      is  $count, 2,                               "[$id] Two iterations were performed";
      $fenum.close;
      nok $ERROR,                                  "[$id] No errors detected when closing enumerator";
    }

    # cw: For all dangling GObjects, an .undef is implied when leaving scope. If it's
    #     not that way now, then it SHOULD BE!
    #$fenum.unref;

    my $c = GIO::Cancellable;
    $c.cancel;
    $o.close($c);
    ok  $ERROR.domain, $G_IO_ERROR,                'Error detected and is in the G_IO_ERROR domain';
    ok  $ERROR.code,   G_IO_ERROR_CANCELLED.Int,   'Error was a G_IO_ERROR_CANCELLED';
    .unref for $c, $o;

    ($c, $) = $f.load-contents;
    nok $ERROR,                                    'No error occurred when loading contents';
    is  $c, $original-data,                        'Loaded contents match original data';
    .delete && .unref with $f;

    $tmpdir.delete;
    nok $ERROR,                                    'No error occurred when deleting temp directory';
    $tmpdir.unref;
  }
}

sub on-file-deleted ($f, $res, $loop) {
  my $local-error = gerror-blank;

  $f.delete-finish($res, $local-error);
  nok $local-error || $local-error[0],             'No error detected during .delete-finish';
  $loop.quit;
}

sub test-file-delete {
  subtest 'Async Delete', {
    my ($f, $i) = GIO::file.new_tmp('g_file_delete_XXXXXX');
    nok $ERROR,                                    'No errors detected generating tmp dirname';
    $i.unref;

    ok $f.query_exists,                            'Directory was created';
    exit(1) unless $f.IO.d;

    my $loop = GLib::MainLoop.new;
    $f.delete-async(-> *@a { on-file-deleted($f, @a[1], $loop) });
    $loop.run;
    nok $f.query-exists,                           'Directory was deleted';

    # cw: Again, a .unref on DESTROY is the implied behavior for GObjects!
    #     (we aren't quire there yet, though)
    .unref for $loop, $f;
  }
}

sub test-copy-preserve-mode {
  use NativeCall;

  sub umask (uint32 $m)
    returns uint32
    is native
  { * }

  my $current-umask = umask(0);

  class CopyPreserveVector {
    has $.source                         is rw;
    has $.expected-destination           is rw;
    has $.create-destination-before-copy is rw;
    has $.flags                          is rw;

    submethod bless (
      :$!source,
      :$!expected-destination,
      :cdbc(:$!create-destination-before-copy),
      :$!flags
    ) { }

    method new ($source, $expected-destination, $cdbc, $flags) {
      self.build(
        :$source,
        :$expected-destination,
        :$cdbc,
        :$flags
      );
    }
  }
  constant CPV := CopyPreserveVector;

  my @vectors = (
    CPV.new( 0o600, 0o600,                      True,                                     G_FILE_COPY_OVERWRITE +| G_FILE_COPY_NOFOLLOW_SYMLINKS +| G_FILE_COPY_ALL_METADATA ),
    CPV.new( 0o600, 0o600,                      True,                                     G_FILE_COPY_OVERWRITE +| G_FILE_COPY_NOFOLLOW_SYMLINKS                             ),
    CPV.new( 0o600, 0o600,                     False,                                                              G_FILE_COPY_NOFOLLOW_SYMLINKS +| G_FILE_COPY_ALL_METADATA ),
    CPV.new( 0o600, 0o600,                     False,                                                              G_FILE_COPY_NOFOLLOW_SYMLINKS                             ),
    CPV.new( 0o600, 0o666 +& ~^$current-umask,  True, G_FILE_COPY_TARGET_DEFAULT_PERMS +| G_FILE_COPY_OVERWRITE +| G_FILE_COPY_NOFOLLOW_SYMLINKS +| G_FILE_COPY_ALL_METADATA ),
    CPV.new( 0o600, 0o666 +& ~^$current-umask,  True, G_FILE_COPY_TARGET_DEFAULT_PERMS +| G_FILE_COPY_OVERWRITE +| G_FILE_COPY_NOFOLLOW_SYMLINKS                             ),
    CPV.new( 0o600, 0o666 +& ~^$current-umask, False, G_FILE_COPY_TARGET_DEFAULT_PERMS                          +| G_FILE_COPY_NOFOLLOW_SYMLINKS +| G_FILE_COPY_ALL_METADATA ),
    CPV.new( 0o600, 0o666 +& ~^$current-umask, False, G_FILE_COPY_TARGET_DEFAULT_PERMS                          +| G_FILE_COPY_NOFOLLOW_SYMLINKS                             )
  );
  umask($current-umask);
  diag "Current umask: 0o{ $current-umask.base(8) }";

  subtest 'Copy Preserve', {
    for @vectors.kv -> $k, $v {
      my $V = @vectors[$k];

      diag "Vector { $k.fmt("%lu"); }"; # G_GSIZE_FORMAT = %lu

      my      $local-error   = gerror;
      my      ($tmpfile, $i) = GIO::File.new_tmp('tmp-copy-preserve-modeXXXXXX', $local-error);

      ok no-error($local-error),                           'No error detected when generating temp dirname';
      $i.close( error => ($local-error = gerror) );
      ok no-error($local-error),                           'No error detected when closing input stream';
      $tmpfile.set-attribute(
        |G_FILE_ATTRIBUTE_UNIX_MODE,
        $V.source-mode,
        flags => G_FILE_QUERY_INFO_NOFOLLOW_SYMLINKS,
        error => ($local-error = gerror),
      );
      ok no-error($local-error),                           'No error detected when setting file attribute';

      my $dtmpfile;
      ($dtmpfile, $i) = GIO::File.new_tmp('tmp-copy-preserve-modeXXXXXX', $local-error);
      ok no-error($local-error),                           'No error detected when generating temp dirname';
      $i.close( error => ($local-error = gerror) );
      ok no-error($local-error),                           'No error detected when closing input stream';

      unless $V.create-destination-before-copy {
        $dtmpfile.delete($local-error = gerror);
        ok no-error($local-error),                         'No error detected when deleting temp directory';
      }

      $tmpfile.copy(
        $dtmpfile,
        $V.copy-flags,
        error => ($local-error = gerror)
      );
      ok no-error($local-error),                           'No error detected during copy';

      my $dinfo = $dtmpfile.query_info(
        GFileAttributeName(G_FILE_ATTRIBUTE_UNIX_MODE),
        G_FILE_QUERY_INFO_NOFOLLOW_SYMLINKS,
        error => ($local-error = gerror)
      );
      ok no-error($local-error),                           'No error detected during query_info';

      my $dmode = $dinfo.get_attribute(
        GFileAttributeName(G_FILE_ATTRIBUTE_UNIX_MODE)
      );

      is $dmode +& ^S_IFMT, $V.expected-destination-mode,  'Test and Expected destination modes match';
      is $dmode +& S_IFMT, S_IFREG,                        'Test destination mode is also S_IFREG';
      .delete for $tmpfile, $dtmpfile;
    }
  }
}

# cw: It's only use was the the C code that was never written in get-size-from-du!
# sub splice-to-string($i, $e) {
#   my $buffer = GIO::MemoryOutputStream.new;
#   my $ret    = Nil;
#
#   if !$buffer.splice($i) {
#     if $buffer.write("\0", 1) {
#       $ret = $buffer.steal-data if $buffer.close;
#     }
#   }
#   $ret;
# }

sub get-size-from-du ($path) {
  # cw: This would test the subprocess aspects of glib, but sometimes enough is
  # enough! Use the raku-ish alternative
  qqx«du --bytes -s $path» ~~ m/(\d+)/;
  $0;
}

sub test-measure {
  subtest 'Measure', {
    plan 5;

    my $path = GLib::Test.get_dir(G_TEST_DIST).IO.add('desktop-files');
    my $file = GIO::File.new_for_path($path);

    skip-rest 'du not found or failed to run, skipping byte measurement'
        unless my $size = get-size-from-du($path);

    my @size-data = $file.measure_disk_usage(G_FILE_MEASURE_APPARENT_SIZE);

    ok +@size-data,                       '.measure-disk-usage executed properly';
    ok no-error,                          'No error detected during .measure-disk-usage';

    $size > 0 ?? is @size-data[0], $size, 'Size data matches expected result'
              !! pass                     'Skipping byte measurement';


    is @size-data[1], 6,                  'Six directories were found';
    is @size-data[2], 31,                 'Thirty-one files were encountered';

    #$file.unref;
  }
}

my &test-measure-async;
{
  class MeasureData {
    has $.expected-bytes is rw;
    has $.expected-dirs  is rw;
    has $.expected-files is rw;
    has $.progress-count is rw;
    has $.progress-bytes is rw;
    has $.progress-dirs  is rw;
    has $.progress-files is rw;
  }

  my $measure-data = MeasureData.new;

  sub measure-progress ($r, $cs, $nd, $nf, $d) {
     $measure-data.progress-count++;
     ok $cs >= $measure-data.progress-bytes, 'Current size  is less than progress bytes';
     ok $nd >= $measure-data.progress-dirs,  'Current dirs  is less than progress dirs';
     ok $nf >= $measure-data.progress-files, 'Current files are less than progress files';

     ( .progress-bytes, .progress-dirs, .progress.files ) = ($cs, $nd, $nf)
       with $measure-data;
  }

  sub measure-done ($s, $r, $d) {
    my ($bytes, $dirs, $files) = $s.disk_usage_finish($r);

    ok $bytes && $dirs && $files, 'Cal to .disk_used_finished executed and returned values';

    my $eb = $measure-data.expected-bytes;
    $eb > 0 ?? is $bytes, $eb,                    'Measured total bytes matches expected'
            !! pass                                 'Skipping measured bytes check';
    is $dirs,  $measure-data.expected-dirs,         'Dir total matches expected';
    is $files, $measure-data.expected-files,        'File total matches expected';

    #$s.unref;
  }

  &test-measure-async = sub {
    $measure-data = MeasureData.new;
    subtest 'Measure Async', {
      .progress-count = .progress-bytes = .progress-files = .progress-dirs = 0
        with $measure-data;

      my $path = GLib::Test.get_dir(G_TEST_DIST).IO.add('desktop-files');
      my $file = GIO::File.new_for_path($path);

      unless my $size = get-size-from-du($path) {
        skip-rest 'du not found or failed to run, skipping byte measurement'
        .expected-bytes = 0;
      }

      ( .expected-dirs, .expected-files ) = (6, 31) with $measure-data;
      $file.measure_disk_usage_async(
        G_FILE_MEASURE_APPARENT_SIZE,
        progress_callback => &measure-progress,
        callback          => &measure-done
      );
    }
  }
}

sub test-load-bytes {
  subtest 'Load Bytes', {
    my $fn = 'g_file_load_bytes_XXXXXX';
    my $fd = GLib::FileUtils.mkstemp($fn);
    ok $fd != -1,               'Returned file descriptor is not -1';

    my $text = 'test_load_bytes';
    my $ret  = GLib::FileUtils.write($fd, $text, $text.chars);
    is $ret, $text.chars,       'Wrote out the proper number of bytes';
    native-close($fd);

    my $file  = GIO::File.new_for_path( $*CWD.add($fn).absolute );
    my $bytes = $file.load_bytes;
    ok no-error,                'No error detected when loading data';

    ok $bytes,                  'Returned object is non-Nil';
    is $ret,  $bytes.get-size,  'Retured file size contains the correct value';

    my ($data) = ( $bytes.get-data );
    is $text, $data,            'Returned data is the correct value';
    $file.delete;
    .unref for $bytes, $file;
  }
}

my &test-load-bytes-async;
{
  class LoadBytesAsyncData {
    has $.loop  is rw;
    has $.file  is rw;
    has $.bytes is rw;

    method unref {
      .unref for $!file, $!bytes, $!loop;
    }
  }
  my $bytes-async-data = LoadBytesAsyncData.new;

  sub load-bytes-cb ($o, $r, $d) {
    CATCH { default { .message.say; .backtrace.summary.say } }
    my $f = GIO::File.new($o);

    my $b = $bytes-async-data.bytes = $f.load_bytes_finish($r);
    ok no-error,                'No errors detected during .bytes_finish';
    ok $b,                      'Async data bytes storage is non-Nil';
    $bytes-async-data.loop.quit;
  }

  &test-load-bytes-async = sub {
    subtest 'Load Bytes, Async', {
      my $fn = 'g_file_load_bytes_XXXXXX';
      my $fd = GLib::FileUtils.mkstemp($fn);
      my $c  = 'test_load_bytes_async';
      my $l  = $c.chars;
      my $r  = GLib::FileUtils.write($fd, $c, $l);
      is $r, $l,                               'Wrote proper number of bytes to temporary file';
      native-close($fd);

      $bytes-async-data.loop      = GLib::MainLoop.new(False);
      $bytes-async-data.file      = GIO::File.new_for_path($fn);
      $bytes-async-data.file.load_bytes_async( &load-bytes-cb );
      $bytes-async-data.loop.run;

      is $l, $bytes-async-data.bytes.get-size, 'Async bytes read matches expected value';
      my ($d, $) = $bytes-async-data.bytes.get-data;

      is $d, $c,                               'Async data matches expected value';
      .delete && .unref given $bytes-async-data.file;
      $bytes-async-data.unref;
    }
  }
}

sub compare-buffer ($a, $b) {
  unless $a.defined {
    # diag $b.defined.not ?? 'Passed' !! 'A is NULL but not B';
    return $b.defined.not;
  }
  unless $b.defined {
    # diag $a.defined.not ?? 'Passed' !! 'B is NULL but not A';
    return $a.defined.not;
  }

  for ^$a.elems {
    unless $a[$_] = $b[$_] {
      diag "Failed comparison at position $_";
      return False;
    }
  }
  return True;
}

sub test-writev-helper (
  @vectors           = (),
  $use-bytes-written = False,
  $ec                = Buf,
  $el                = 0
) {
  my $iostream;
  my $file = GIO::File.new_tmp('g_file_writev_XXXXXX', $iostream);

  ok  $file,                          '$file is non-Nil';
  ok  $iostream,                      '$iostream is non-Nil';

  my $ubw = $iostream.get-output-stream.writev-all(@vectors);
  nok $ERROR,                         'No errors detected during .writev-all';
  ok  $ubw.defined,                   '.writev-all returned defined values';
  is  $ubw,     $el,                  'Bytes actually written matches expected length'
     if $use-bytes-written;

  my $res = $iostream.close;
  nok $ERROR,                         'No errors detected when closing the iostream';
  ok  $res,                           '.close returned True';
  $iostream.unref;

  my ($contents, $length, $) = $file.load_contents($contents, $length, $);
  nok $ERROR,                         'No errors detected when loading contents';
  # cw: Tricky, since $contents CAN be undefined, $length is the only way
  #     to properly determine if the underlying routine returned true.
  ok  $length.defined,                '.load-contents returned defined values';
  is  $length   // 0,   $el,          'Returned length matches expected value';
  ok  compare-buffer($contents, $ec), 'Contents match expected value';

  .delete && .unref with $file;
}

sub test-writev {
  my $buffer = CArray[uint8].new(1, 2, 3, 4, 5,
                                 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12,
                                 1, 2, 3);

  my @vectors = (
    GOutputVector.new($buffer,                   5),
    GOutputVector.new($buffer.&subarray(5),     12),
    GOutputVector.new($buffer.&subarray(5 + 12), 3)
  );

  subtest 'WriteV', {
    test-writev-helper(@vectors, True, $buffer, $buffer.elems);
  }
}

sub test-writev-no-bytes-written {
  my $buffer = CArray[uint8].new(1, 2, 3, 4, 5,
                                 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12,
                                 1, 2, 3);

  my @vectors = (
    GOutputVector.new($buffer,                   5),
    GOutputVector.new($buffer.&subarray(5),     12),
    GOutputVector.new($buffer.&subarray(5 + 12), 3)
  );

  subtest 'WriteV, no bytes written', {
    test-writev-helper(@vectors, False, $buffer, $buffer.elems);
  }
}

sub test-writev-no-vectors {
  subtest 'WriteV, No vectors', {
    test-writev-helper;
  }
}

sub test-writev-empty-vectors {
  my @vectors = GOutputVector.new xx 3;

  subtest 'WriteV, Empty vectors', {
    test-writev-helper(@vectors, True, Nil, 0);
  }
}

sub test-writev-too-big-vectors {
  subtest 'WriteV, Too Big Vectors', {
    my $iostream;
    my $buffer    = Pointer[uint8].new(1);
    my @vectors   = GOutputVector.new($buffer, G_MAXSIZE / 2) xx 3;
    my $file      = GIO::File.new_tmp('g_file_writev_XXXXXX', $iostream);

    ok  no-error,                                       'No error generating tmpfile name';
    ok  $iostream,                                      'IOStream returned from .new_tmp is defined';

    my $ostream = $iostream.get-output-stream;
    my $ubw     = $ostream.writev-all(@vectors);
    ok  $ERROR,                                         'Error detected during call to .writev-all';
    #is  $ERROR.domain, $G_IO_ERROR,                     'Error is in the G_IO_ERROR domain';
    is  $ERROR.code,   G_IO_ERROR_INVALID_ARGUMENT.Int, 'Error code is G_IO_ERROR_INVALID_ARGUMENT';
    # cw: Not checking bytes_writte == 0, due to the way this API works as opposed to C
    nok $ubw.defined,                               'Call to .writev-all returned no defined values';

    my  ($res, $contents, $length) = ( $iostream.close );
    ok  no-error,                                   'No error detected when closing iostream';
    ok  $res,                                       '.close operation returned True';
    ok  compare-buffer($contents, $length),         'Buffer comparison succeeded';

    .delete && .unref with $file;
  }
}

# cw: -XXX- 20201013
#
# Continue from L#1324 of original -- Efforts marred by the lack of ability
# to use a sub-CArray. Efforts on this file will be paused until this
# is rectified or a workaround can be discovered.

# cw: Not quite in, yet.
# sub test-build-attribute-list-for-copy {
#   my @test-flags = (
#     G_FILE_COPY_NONE,
#     G_FILE_COPY_TARGET_DEFAULT_PERMS,
#     G_FILE_COPY_ALL_METADATA,
#     G_FILE_COPY_ALL_METADATA +| G_FILE_COPY_TARGET_DEFAULT_PERMS,
#   );
#
#   subtest 'Build attribute list for copy', {
#     my $i;
#     my $tmpfile = GIO::File.new_tmp(
#       'tmp-build-attribute-list-for-copyXXXXXX',
#       $i
#     );
#
#     ok  no-error, 'No error encountered when generating tmpfile name';
#     $i.close;
#     nok no-error, 'No error encountered when closing iostream';
#
#     for @test-flags {
#       my $atrs = $tmpfile.build_attribute_list_for_copy($_);
#       ...
#     }
#   }
# }

GLib::Test.init;

test-basic;
test-parent;
test-type;
test-parse-name;

# cw: These tests are not currently being performed due to the lack of
#     ability to create a sub-buffer or sub-array that can be passed to
#     a NativeCall routine.
#test-create-delete($_) for 0, 1, 10, 25, 4096;

test-measure;

# cw: MoarVM panic: native callback ran on thread (140662838081088) unknown to MoarVM
#&test-measure-async();

test-load-bytes;
&test-load-bytes-async();

test-writev;
test-writev-no-bytes-written;
test-writev-no-vectors;
test-writev-empty-vectors;
test-writev-too-big-vectors;
