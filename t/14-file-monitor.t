use v6.c;

use Test;

use GIO::Raw::Types;
use GIO::Raw::FileAttributeTypes;

use GLib::FileUtils;
use GLib::MainLoop;
use GLib::Test;
use GLib::Timeout;
use GLib::Utils;

use GIO::Roles::GFile;

my ($tmp-dir, $HAVE-LINKS);

sub setup {
  my $path = GLib::FileUtils.dir-make-tmp('gio-test-testfilemonitor_XXXXXX');
  nok $ERROR, 'No error detected when creating temp directory';
  $tmp-dir = GIO::File.new_for_path($path);
  GLib::Test.message("Using temporary directory: { $path }");
}

sub teardown {
  $tmp-dir.delete;
  nok $ERROR, 'No error detected when deleting temp file';
  .unref with $tmp-dir
}

enum Environment (
  NONE    => 0,
  INOTIFY => 1,
  KQUEUE  => 4
);

sub output-event ($r) {
  if $r<step> > 0 {
    GLib::Test.message(">>>> step { $$r<step> }");
  } else {
    GLib::Test.message("{ $r<event-type> } file={ $r<file> }other_file={$r<other-file> }");
  }
}

sub get-environment ($m) {
  do given $m.objectType.name {
    when    'GInotifyFileMonitor' { INOTIFY }
    when    'GKqueueFileMonitor'  { KQUEUE  }
    default                       { NONE    }
  }
}

sub check-expected-events (@e, @r, $env) {
  my $num-results = @r.elems;
  my ($i, $li) = 0 xx 2;

  for @e -> $e1 {
    my ($e2, $mismatch) = (@r.shift, True);
    repeat {
      my $ignore-other-file = False;

      last if $e1<step> != $e2<step>;
      if $e1<event-type> != $e2<event-type> && $env +& KQUEUE {
        if $e1<event-type> == G_FILE_MONITOR_EVENT_RENAMED {
          last unless @r.elems;
          my $e2-next = @r.shift;

          last if $e2<event-type>      != G_FILE_MONITOR_EVENT_DELETED;
          last if $e2-next<event-type> != G_FILE_MONITOR_EVENT_CREATED;
          last unless $e2<step> == $e2-next<step>;
          last if ( $e1<file>.defined && $e1<file>.chars ) &&
                  ( $e1<file> ne $e2<file> || $e2-next<other-file>.defined );
          last if ( $e1<other-file>.defined && $e1<other-file>.chars ) &&
                  ( $e1<other-file> ne $e2-next<file> ||
                    $e2-next<other-file>.defined );
          @r.unshift($e2-next);
          $mismatch = False;
          next;
        }
      } elsif $e1<event-type> == G_FILE_MONITOR_EVENT_MOVED_IN {
        last unless $e2<event-type> == G_FILE_MONITOR_EVENT_CREATED;
        $ignore-other-file = True;
      } elsif $e1<event-type> == G_FILE_MONITOR_EVENT_MOVED_OUT {
        last unless $e2<event-type> == G_FILE_MONITOR_EVENT_DELETED;
        $ignore-other-file = True;
      } else {
        last;
      }
      last if $e1<file>.defined                   &&
              $e1<file>.chars                     &&
              $e1<file> ne $e2<file>;
      last if $e1<other-file>.defined             &&
              $e1<other-file>.chars               &&
              $ignore-other-file.not              &&
              $e1<other-file> ne $e2<other-file>;

      $mismatch = False;
    } while 0;

    if $mismatch {
      if $e1<event-type> != G_FILE_MONITOR_EVENT_CHANGES_DONE_HINT &&
         $e2<event-type> == G_FILE_MONITOR_EVENT_CHANGES_DONE_HINT
      {
        GLib::Test.message("Event CHANGES_DONE_HINT ignored at {
                            '' }expected index { $i }, recorded index { $li }");
        $li++;
        @r.shift;
        redo;
      } elsif ($env // 0) +& ($e1<optional> // 0) {
        GLib::Test.message("Event { $e1<event-type> } at expected index {
                            $i } skipped because it is marked as optional");
        $i++;
        redo;
      }
    } else {
      GLib::Test.message('Recorded events:');
      output-event($_) for @r;

      GLib::Test.message('Expected events:');
      output-event($_) for @e;

      is $e1<step>,       $e2<step>,       'Step count matches';
      is $e1<event-type>, $e2<event-type>, 'Event types match';
      is $e1<file>,       $e2<file>,       'Filenames match'
        if $e1<file>.defined       && $e1<file>.chars;
      is $e1<other-file>, $e2<other-file>, 'Other file name matches'
        if $e1<other-file>.defined && $e1<other-file>.chars;

      exit 1;
    }

    $i++; $li++
  }

  is      $i,              @e.elems,        'Iteration count matches expected value';
  is      $li,             $num-results,    'Recorded events matches expected value';
}

sub create-event ($et, $f, $of, $s, $env = $) {
  (
    event-type => GFileMonitorEventEnum($et) // -1,
    file       => $f,
    other-file => $of,
    step       => $s,
    env        => $env
  ).Hash;
}

multi sub record-event (%d, $et = -1, $f = $, $of = $, $s = -1) {
  %d<events>.push: create-event($et, $f, $of, $s);
}

sub monitor-changed ( *@a ($monitor, $f, $of, $et, $d) ) {
  my ($fo, $ofo) = ( GIO::File.new($f), GIO::File.new($of) );
  my $other-base = $of ?? $ofo.get_basename !! $;

  record-event($d, $et, $fo.get_basename, $other-base);
}

sub atomic-replace-step (%d) {
  record-event(%d);
  given %d<step> {
    when 0 {
      %d<file>.replace_contents('step 0');
      nok $ERROR, 'No error occurred when replacing contents at step 0';
    }

    when 1 {
      %d<file>.replace_contents('step 1');
      nok $ERROR, 'No error occurred when replacing contents at step 1';
    }

    when 2 {
      %d<file>.delete;
    }

    when 3 {
      %d<loop>.quit;
    }
  }
  %d<step>++;

  G_SOURCE_CONTINUE.Int;
}

my @atomic-replace-output = (
  [ -1,                                     $,                     $,                      0, NONE   ],
  [ G_FILE_MONITOR_EVENT_CREATED,           'atomic_replace_file', $,                     -1, NONE   ],
  [ G_FILE_MONITOR_EVENT_CHANGED,           'atomic_replace_file', $,                     -1, KQUEUE ],
  [ G_FILE_MONITOR_EVENT_CHANGES_DONE_HINT, 'atomic_replace_file', $,                     -1, KQUEUE ],
  [ -1,                                     $,                     $,                      1, NONE   ],
  [ G_FILE_MONITOR_EVENT_RENAMED,           '',                    'atomic_replace_file', -1, NONE   ],
  [ -1,                                     $,                     $,                      2, NONE   ],
  [ G_FILE_MONITOR_EVENT_DELETED,           'atomic_replace_file', $,                     -1, NONE   ],
  [ -1,                                     $,                     $,                      3, NONE   ],
).map({ create-event( |$_) });

sub change-step (%d) {
   record-event(%d);
   given %*data<step> {
     when 9 {
       %d<file>.replace_contents('step 0');
       nok $ERROR, 'No error detected when replacing contents at step 0';
     }

     when 1 {
       my $stream = %d<file>.append_to(G_FILE_CREATE_NONE);
       nok $ERROR, 'No errors detected obtaining append stream at step 1';
       # cw: YYY - Does this handle the NUL terminator??
       $stream.write-all(' step 1');
       nok $ERROR, 'No errors detected writing to the stream at step 1';
       $stream.close;
       nok $ERROR, 'No errors detected closing the stream at step 1';
       $stream.unref;
     }

     when 2 {
       %d<file>.set_attribute(G_FILE_ATTRIBUTE_UNIX_MODE.&fAttrVal, 0o660);
       nok $ERROR, 'No errors detected setting attribute at step 2';
     }

     when 3 {
       %d<file>.delete;
     }

     when 4 {
       %d<loop>.quit;
       return G_SOURCE_REMOVE.Int;
     }
   }
   %d<step>++;

   G_SOURCE_CONTINUE.Int;
}

my @change-output = (
  [ -1,                                     $,             $,  0, NONE   ],
  [ G_FILE_MONITOR_EVENT_CREATED,           'change_file', $, -1, NONE   ],
  [ G_FILE_MONITOR_EVENT_CHANGED,           'change_file', $, -1, KQUEUE ],
  [ G_FILE_MONITOR_EVENT_CHANGES_DONE_HINT, 'change_file', $, -1, KQUEUE ],
  [ -1,                                     $,             $,  1, NONE   ],
  [ G_FILE_MONITOR_EVENT_CHANGED,           'change_file', $, -1, NONE   ],
  [ G_FILE_MONITOR_EVENT_CHANGES_DONE_HINT, 'change_file', $, -1, NONE   ],
  [ -1,                                     $,             $,  2, NONE   ],
  [ G_FILE_MONITOR_EVENT_ATTRIBUTE_CHANGED, 'change_file', $, -1, NONE   ],
  [ -1,                                     $,             $,  3, NONE   ],
  [ G_FILE_MONITOR_EVENT_DELETED,           'change_file', $, -1, NONE   ],
  [ -1,                                     $,             $,  4, NONE   ]
);

sub dir-step(%d) {
  record-event(%d);
  given %d<step> {
    when 1 {
      my $parent = %d<file>.parent;
      my $file   = $parent.get-child('dir_test_file');
      $file.replace_contents('step 1', flags => G_FILE_CREATE_NONE);
      nok $ERROR, 'No error detected when replacing contents at step 1';
      .unref for $file, $parent;
    }

    when 2 {
      my $parent = %d<file>.parent;
      my $file   = $parent.get_child('dir_test_file');
      my $file2  = %d<file>.get_child('dir_test_file');
      $file.move($file2);
      nok $ERROR, 'No error detected when moving file at step 2';
      .unref for $file, $file2, $parent;
    }

    when 3 {
      my $file  = %d<file>.get_child('dir_test_file');
      my $file2 = %d<file>.get_child('dir_test_file2');
      $file.move($file2);
      nok $ERROR, 'No error detected when moving file at step 3';
      .unref for $file, $file2;
    }

    when 4 {
      my $parent = %d<file>.parent;
      my $file  = %d<file>.get_child('dir_test_file2');
      my $file2 = $parent.get_child('dir_test_file2');
      $file.move($file2);
      nok $ERROR, 'No error detected when deleting file at step 4';
      $file2.delete;
      .unref for $file, $file2, $parent;
    }

    when 5 {
      %d<file>.delete;
    }

    when 6 {
      %d<loop>.quit;
      return G_SOURCE_REMOVE.Int;
    }
  }
  %d<step>++;

  G_SOURCE_CONTINUE.Int;
}

my @dir-output = (
  [ -1,                             $,                 $,                 1, NONE ],
  [ -1,                             $,                 $,                 2, NONE ],
  [ G_FILE_MONITOR_EVENT_MOVED_IN,  'dir_test_file',   $,                -1, NONE ],
  [ G_FILE_MONITOR_EVENT_RENAMED,   'dir_test_file',   'dir_test_file2', -1, NONE ],
  [ -1,                             $,                 $,                 3, NONE ],
  [ -1,                             $,                 $,                 4, NONE ],
  [ G_FILE_MONITOR_EVENT_MOVED_OUT, 'dir_test_file2',  $,                -1, NONE ],
  [ -1,                             $,                 $,                 5, NONE ],
  [ G_FILE_MONITOR_EVENT_DELETED,  'dir_monitor_test', $,                -1, NONE ],
  [ -1,                             $,                 $,                 6, NONE ]
).map({ create-event( |$_ ) });

sub nodir-step (%d) {
  record-event(%d);
  given %d<step> {
    when 0 {
      my $parent = %d<file>.parent;
      $parent.make_directory;
      nok $ERROR, 'No error detected when creating directory at step 0';
      $parent.unref;
    }

    when 1 {
      %d<file>.replace_contents('step 1');
      nok $ERROR, 'No error detected when replacing contents at step 1';
    }

    when 2 {
      %d<file>.delete;
      nok $ERROR, 'No error detected when deleting file at step 2';
    }

    when 3 {
      my $parent = %d<file>.parent;
      $parent.delete;
      nok $ERROR, 'No errors detected when deleting parent at step 3';
      $parent.unref;
    }

    when 4 {
      %d<loop>.quit;
      return G_SOURCE_REMOVE.Int;
    }
  }
  %d<step>++;

  G_SOURCE_CONTINUE.Int;
}

my @nodir-output = (
  [ -1,                                         $,            $,  0, NONE   ],
  [ G_FILE_MONITOR_EVENT_CREATED,               'nosuchfile', $, -1, KQUEUE ],
  [ G_FILE_MONITOR_EVENT_CHANGES_DONE_HINT,     'nosuchfile', $, -1, KQUEUE ],
  [ -1,                                         $,            $,  1, NONE   ],
  [ G_FILE_MONITOR_EVENT_CREATED,               'nosuchfile', $, -1, NONE   ],
  [ G_FILE_MONITOR_EVENT_CHANGED,               'nosuchfile', $, -1, KQUEUE ],
  [ G_FILE_MONITOR_EVENT_CHANGES_DONE_HINT,     'nosuchfile', $, -1, KQUEUE ],
  [ -1,                                         $,            $,  2, NONE   ],
  [ G_FILE_MONITOR_EVENT_DELETED,               'nosuchfile', $, -1, NONE   ],
  [ -1,                                         $,            $,  3, NONE   ],
  [ -1,                                         $,            $,  4, NONE   ]
).map({ create-event( |$_ ) });

sub set-up-data (%d, &p, $m = 'Using GFileMonitor') {
  %d<step events> = (0, $);

  &p(%d);

  ok  %d<monitor>, 'File monitor object created';
  nok $ERROR,      'No error detected when starting monitor';
  GLib::Test.message("{ $m } { %d<monitor>.objectType.name }");
  %d<monitor>.rate-limit = 200;
  %d<monitor>.changed.tap(-> *@a {
    CATCH { default { .message.say; .message.concise } }
    my @a-args = @a.head(* - 1);
    @a-args.push: %d;

    #diag "A-ARGS: { @a-args.gist } / { @a-args.elems }";

    monitor-changed ( |@a-args )
  });
}

sub actual-run-tests (&s, $d) {
  my $loop := $d ~~ Positional ?? $d[0]<loop> !! $d<loop>;

  $loop = GLib::MainLoop.new(True);
  GLib::Timeout.add(500, -> *@a --> gboolean {
    CATCH { default { .message.say; .message.concise } }
    &s($d)
  });
  $loop.run;
}

sub run-tests ($n, @r, &s, &p) {
  subtest $n, {
    my %data;

    set-up-data(%data, &p);
    actual-run-tests(&s, %data);
    check-expected-events( @r, %data<events>, get-environment(%data<monitor>) );

    .unref for %data<loop monitor file>;
    .unref with %data<output-stream>;
  }
}

sub atomic-replace-pre (%d) {
  %d<file> = $tmp-dir.get_child('atomic_replace_file');
  %d<file>.delete;
  %d<monitor> = %d<file>.monitor_file;
}

sub change-pre (%d) {
  %d<file> = $tmp-dir.get_child('change_file');
  %d<file>.delete;
  %d<monitor> = %d<file>.monitor_file;
}

sub dir-pre (%d) {
  %d<file> = $tmp-dir.get-child('dir_monitor_test');
  %d<file>.delete;
  %d<file>.make_directory;
  %d<monitor> = %d<file>.monitor_directory;
}

sub nodir-pre (%d) {
  %d<file>    = $tmp-dir.get_child('nosuchdir/nosuchfile');
  %d<monitor> = %d<file>.monitor_file;
}

sub hard-link-pre (%d) {
  diag "#755721";
  %d<file>          = $tmp-dir.get_child('testfilemonitor.db');
  %d<output-stream> = %d<file>.replace;
  nok $ERROR, 'No error detected obtaining output stream from file object';
  %d<monitor> = %d<file>.monitor_file(G_FILE_MONITOR_WATCH_MOUNTS     +|
                                      G_FILE_MONITOR_WATCH_MOVES      +|
                                      G_FILE_MONITOR_WATCH_HARD_LINKS   );
}

sub cross-dir-step (@d) {
  record-event($_) for @d;
  given @d[0]<step> {
    when 0 {
      my $file = @d[1]<file>.get_child('a');
      $file.replace_contents('step 0');
      nok $ERROR, 'No error detected when replacing contents at step 0';
      $file.unref;
    }

    when 1 {
      my $file  = @d[1]<file>.get_child('a');
      my $file2 = @d[0]<file>.get_child('a');
      $file.move($file2);
      nok $ERROR, 'No error detected when moving file at step 0';
      .unref for $file, $file2;
    }

    when 2 {
      my $file2 = @d[0]<file>.get_child('a');
      $file2.delete;
      .<file>.delete for @d;
      $file2.unref;
    }

    when 3 {
      @d[0]<loop>.quit;
      return G_SOURCE_REMOVE.Int;
    }
  }
  @d[0]<step>++;

  G_SOURCE_CONTINUE.Int;
}

my @cross-dir-a-output = (
  [ -1,                                     $,             $,  0, NONE   ],
  [ -1,                                     $,             $,  1, NONE   ],
  [ G_FILE_MONITOR_EVENT_CREATED,           'a',           $, -1, NONE   ],
  [ G_FILE_MONITOR_EVENT_CHANGES_DONE_HINT, 'a',           $, -1, KQUEUE ],
  [ -1,                                     $,             $,  2, NONE   ],
  [ G_FILE_MONITOR_EVENT_DELETED,           'a',           $, -1, NONE   ],
  [ G_FILE_MONITOR_EVENT_DELETED,           'cross_dir_a', $, -1, NONE   ],
  [ -1,                                     $,             $,  3, NONE   ]
).map({ create-event( |$_ ) });

my @cross-dir-b-output = (
  [ -1,                                     $,             $,    0, NONE   ],
  [ G_FILE_MONITOR_EVENT_CREATED,           'a',           $,   -1, NONE   ],
  [ G_FILE_MONITOR_EVENT_CHANGED,           'a',           $,   -1, KQUEUE ],
  [ G_FILE_MONITOR_EVENT_CHANGES_DONE_HINT, 'a',           $,   -1, KQUEUE ],
  [ -1,                                     $,             $,    1, NONE   ],
  [ G_FILE_MONITOR_EVENT_MOVED_OUT,         'a',           'a', -1, NONE   ],
  [ -1,                                     $,             $,    2, NONE   ],
  [ G_FILE_MONITOR_EVENT_DELETED,           'cross_dir_b', $,   -1, NONE   ],
  [ -1,                                     $,             $,    3, NONE   ]
).map({ create-event( |$_ ) });

sub test-cross-dir-moves {
  my @data;

  sub pre-op (%d, $ab) {
    %d<file> = $tmp-dir.get-child("cross_dir_{ $ab }");
    %d<file>.delete;
    %d<file>.make_directory;
    %d<monitor>.monitor_directory;
  }

  set-up-data(
    @data[$_],
    sub { pre-op(@data[$_], $_) },
    "Using GFileMonitor { $_ eq 'a' ?? '0' !! '1' }"
  ) for <a b>;

  actual-run-tests(&cross-dir-step, @data);

  check-expected-events(
    @cross-dir-a-output,
    @data[0]<events>,
    get-environment( @data[0]<monitor> )
  );

  check-expected-events(
    @cross-dir-b-output,
    @data[1]<events>,
    get-environment( @data[1]<monitor> )
  );

  for @data {
    .unref for $_<loop monitor file>;
  }
}

sub file-hard-links-step (%d) {
  my $filename       = %d<file>.filename;
  my $hard-link-name = "{ $filename }2";
  my $hard-link-file = GIO::File.new_for_path($hard-link-name);

  LAST { $hard-link-file.unref }

  record-event(%d);
  given %d<step> {
    when 0 {
      %d<output-stream>.write-all('hello, step 0');
      nok $ERROR, 'No error detected when writing to output stream at step 0';
      %d<output-stream>.close;
      nok $ERROR, 'No error detected when closing output stream at step 0';
    }

    when 1 {
      %d<file>.replace_contents('step 1');
      nok $ERROR, 'No error detected when replacing contents at step 1';
    }

    when 2 {
      if $HAVE-LINKS {
        if link($filename, $hard-link-name) < 0 {
          die "link({ $filename }, { $hard-link-name}) failed: {
               GLib::Utils.error_name($ERRNO) }";
        }
      }
    }

    when 3 {
      if $HAVE-LINKS {
        my $hard-link-stream = $hard-link-file.append-to;
        nok $ERROR, 'No error detected when obtaining output stream from link at step 3';
        $hard-link-stream.write-all('step 3');
        nok $ERROR, 'No error detected when writing to stream at step 3';
        $hard-link-stream.close;
        nok $ERROR, 'No error detected when closing stream at step 3';
        $hard-link-stream.unref;
      }
    }

    when 4 {
      %d<file>.delete;
      nok   $ERROR, ' No error detected when deleting file at step 4';
    }

    when 5 {
      if $HAVE-LINKS {
        $hard-link-file.delete;
        nok $ERROR, 'No error detected when deleting link at step 5';
      }
    }

    when 6 {
      %d<loop>.quit;
      return G_SOURCE_REMOVE.Int;
    }
  }
  %d<step>++;

  G_SOURCE_CONTINUE.Int
}

my @file-hard-links-output = (
  [ -1,                                     $,                    $,                     0, NONE    ],
  [ G_FILE_MONITOR_EVENT_CHANGED,           'testfilemonitor.db', $,                    -1, NONE    ],
  [ G_FILE_MONITOR_EVENT_CHANGES_DONE_HINT, 'testfilemonitor.db', $,                    -1, NONE    ],
  [ -1,                                     $,                    $,                     1, NONE    ],
  [ G_FILE_MONITOR_EVENT_RENAMED,           '',                   'testfilemonitor.db', -1, NONE    ],
  [ -1,                                     $,                    $,                     2, NONE    ],
  [ -1,                                     $,                    $,                     3, NONE    ],
  [ G_FILE_MONITOR_EVENT_CHANGED,           'testfilemonitor.db', $,                    -1, INOTIFY ],
  [ -1,                                     $,                    $,                     4, NONE    ],
  [ G_FILE_MONITOR_EVENT_DELETED,           'testfilemonitor.db', $,                    -1, NONE    ],
  [ -1,                                     $,                    $,                     5, NONE    ],
  [ G_FILE_MONITOR_EVENT_DELETED,           'testfilemonitor.db', $,                    -1, INOTIFY ],
  [ -1,                                     $,                    $,                     6, NONE    ]
).map({ create-event( |$_ ) });

my @tests = (
  [ 'Atomic Replace File', @atomic-replace-output,  &atomic-replace-step , &atomic-replace-pre ],
  [ 'Change File',         @change-output,          &change-step         , &change-pre         ],
  [ 'Dir Monitor',         @dir-output,             &dir-step            , &dir-pre            ],
  [ 'No Dir/No File',      @nodir-output,           &nodir-step          , &nodir-pre          ],
  &test-cross-dir-moves,
  [ 'Hard Link',           @file-hard-links-output, &file-hard-links-step, &hard-link-pre      ]
);

sub MAIN ( :$links is copy ) {
  $HAVE-LINKS = $links // $*DISTRO.is-win.not;

  for @tests {
    setup;
    $_ ~~ Callable ?? $_() !! run-tests( |$_ );
    teardown;
  }
}
