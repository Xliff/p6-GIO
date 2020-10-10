use v6.c;

use Test;

use GIO::Roles::GFile;

sub basic-file-tests (GIO::Roles::File $f, $s) {
  is  $f.get_basename,     'testfile',     'GFile object has basename of `testfile`';
  ok  $f.get_uri.starts-with('file://'),   'GFile object has URI starting with `file://`';
  ok  $f.get_uri.ends-with($s),            "GFile object has URI ending with `{ $s }`";
  ok  $f.has-uri-scheme('file'),           'GFile object has the `file` URI scheme';
  is  $f.get_scheme,       'file',         'GFile returns the scheme value of `file`';
}

sub test-basic {
  subtest 'Basic', {
    my $f = GIO::Roles::GFile.new_for_path('./some/directory/testfile');
    diag $f.get_basename;
    basic-file-tests($f, '/some/directory/testfile');
  };
}

test-basic;
