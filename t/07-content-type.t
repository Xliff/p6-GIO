use v6.c;

use Test;

use GIO::Raw::Types;

use GIO::ContentType;
use GIO::ThemedIcon;

# cw: Test ported from https://github.com/GNOME/glib/blob/master/gio/tests/contenttype.c

sub test-guess {
  subtest 'Content Type Guessing', {
    my $existing-directory = '/etc/';
    my $data               = q:to/DESK/;
      [Desktop Entry]
      Type=Application
      Name=appinfo-test
      Exec=./appinfo-test --option
      DESK

    my ($ct, $uncert) = GIO::ContentType.guess($existing-directory);
    my $expect        = GIO::ContentType.from-mime-type('inode/directory');
    is $expect, $ct, 'Content Type of /etc matches "inode/directory"';
    ok $uncert,      'Guess was made with uncertainty.';

    ($ct, $uncert) = GIO::ContentType.guess('foo.txt');
    $expect        = GIO::ContentType.from-mime-type('text/plain');
    is $expect, $ct, 'Content Type of `foo.txt` matches "text/plain"';

    ($ct, $uncert) = GIO::ContentType.guess('foo.txt', $data, $data.chars - 1);
    $expect        = GIO::ContentType.from-mime-type('text/plain');
    is $expect, $ct, 'Content Type of `foo.txt` matches "text/plain"';
    nok $uncert,     'Guess was made with certainty';

    ($ct, $uncert) = GIO::ContentType.guess('foo', $data, $data.chars - 1);
    $expect        = GIO::ContentType.from-mime-type('text/plain');
    is $ct, $expect, 'Content Type of `foo` matches "text/plain"';

    ($ct, $uncert) = GIO::ContentType.guess('foo.desktop', $data, $data.chars - 1);
    $expect        = GIO::ContentType.from-mime-type('application/x-desktop');
    is $ct, $expect, 'Content Type of `foo` matches "application/x-desktop"';
    nok $uncert,     'Guess was made with certainty';

    ($ct, $uncert) = GIO::ContentType.guess('test.pot', 'ABC abc', 7);
    $expect        = GIO::ContentType.from-mime-type('text/x-gettext-translation-template');
    is $ct, $expect, 'Content Type of `test.pot` matches "text/x-gettext-translation-template"';
    nok $uncert,     'Guess was made with certainty';

    ($ct, $uncert) = GIO::ContentType.guess('test.pot', 'msgid "', 7);
    $expect        = GIO::ContentType.from-mime-type('text/x-gettext-translation-template');
    is $ct, $expect, 'Content Type of `test.pot` matches "text/x-gettext-translation-template"';
    nok $uncert,     'Guess was made with certainty';

    # cw: Signature from original test was "\xCF\xD0\xE0\x11", which didn't work.
    ($ct, $uncert) = GIO::ContentType.guess('test.pot', "\x50\x4b\x03\x04", 4);
    $expect        = GIO::ContentType.from-mime-type('application/vnd.ms-powerpoint');
    is $ct, $expect, 'Content Type of `test.pot` matches "application/vnd.ms-powerpoint"';

    ($ct, $uncert) = GIO::ContentType.guess('test.otf', 'OTTO', 4);
    $expect        = GIO::ContentType.from-mime-type('application/x-font-otf');
    is $ct, $expect, 'Content Type of `test.otf` matches "application/x-font-otf"';
    nok $uncert,     'Guess was made with certainty';

    ($ct, $uncert) = GIO::ContentType.guess(Str, '%!PS-Adobe-2.0 EPSF-1.2', 23);
    $expect        = GIO::ContentType.from-mime-type('image/x-eps');
    is $ct, $expect, 'Content Type of null file with 23-byte Adobe header matches "image/x-eps"';
    nok $uncert,     'Guess was made with certainty';

    ($ct, $uncert) = GIO::ContentType.guess(Str, '%!PS-Adobe-2.0 EPSF-1.2', 0);
    $expect        = GIO::ContentType.from-mime-type('application/x-zerosize');
    is $ct, $expect, 'Content Type of null file with non-sized Adobe header matches "application/x-zerosize"';
    nok $uncert,     'Guess was made with certainty';
  }
}

sub test-unknown {
  subtest 'Unknown', {
    my $unk    = GIO::ContentType.from-mime-type('application/octet-stream');
    my $unk-ct = GIO::ContentType.is-unknown($unk);
    ok $unk-ct, 'Content type is not known';
    my $ct     = GIO::ContentType.get-mime-type($unk);
    is $ct, 'application/octet-stream', 'Content type of unknown is "application/octet-stream"';
  }
}

sub plain { GIO::ContentType.from-mime-type('text/plain')      }
sub xml   { GIO::ContentType.from-mime-type('application/xml') }

sub test-subtype {
  subtest 'Subtype', {
    my ($plain, $xml) = (plain, xml);
    ok GIO::ContentType.is-a($xml, $plain),               '"application/xml" is_a "text/plain"';
    ok GIO::ContentType.is_mime_type($xml, 'text/plain'), '"application/xml" is_mime_type "text/plain"';
  };
}

sub test-list {
  subtest 'List', {
    my ($plain, $xml) = (plain, xml);
    my $types = GIO::ContentType.get-registered;
    ok $types.grep( * eq $plain ),                     'Can find "text/plain" in list of registered types';
    ok $types.grep( * eq $xml   ),                     'Can find "application/xml" in list of registered types';
  }
}

sub test-executable {
  subtest 'Executable', {
    my $x-exec = GIO::ContentType.from-mime-type('application/x-executable');
    ok  GIO::ContentType.can-be-executable($x-exec),   '"application/x-executable" can be executed';
    ok  GIO::ContentType.can-be-executable(plain),     '"text/plain" can be executed';
    my $png  = GIO::ContentType.from-mime-type('image/png');
    nok GIO::ContentType.can-be-executable($png),      '"text/plain" can NOT be executed';
  }
}

sub test-description {
  subtest 'Description', {
    ok  GIO::ContentType.get-description(plain),       '"text/plain" has a retrievable description';
  }
}

sub test-icon {
  subtest 'Icon', {
    my $icon = GIO::ContentType.get-icon('text/plain');
    ok $icon ~~ GIO::Roles::Icon,                      'Icon retrieved from "text/plain" MIME type is a GIcon';

    my @names = $icon.get_names;
    ok @names.grep( * eq 'text-plain' ).elems,         'Icon list contains `text-plain` icon';
    ok @names.grep( * eq 'text-x-generic').elems,      'Icon list contains the `text-x-generic` icon';

    $icon = GIO::ContentType.get-icon('application/rtf');
    ok $icon ~~ GIO::Roles::Icon,                      'Icon retrieved from "application/rtf" MIME type is a GIcon';

    @names = $icon.get_names;
    ok @names.grep( * eq 'application-rtf' ).elems,    'Icon list contains `application-rtf` icon';
    ok @names.grep( * eq 'x-office-document').elems,   'Icon list contains the `x-office-document` icon';
  }
}

sub test-symbolic-icon {
  subtest 'Symbolic Icon', {
    my $type = plain;
    my $icon = GIO::ContentType.get-symbolic-icon($type);

    ok     $icon ~~ GIO::Roles::Icon,                      'Value retrieved from get-symbolic-icon as "text/plain" has the correct roles';
    my @names = $icon.get-names;

    ok     @names.grep( * eq $_ ).elems,                   "'$_' icon is contained in the icon list'"
      for <text-plain-symbolic text-x-generic-symbolic text-plain text-x-generic>;

    $type  = GIO::ContentType.from-mime-type('application/rtf');
    $icon  = GIO::ContentType.get-symbolic-icon($type);
    @names = $icon.get-names;

    diag @names.gist;
    ok     $icon ~~ GIO::Roles::Icon,                      'Value retrieved from get-symbolic-icon as "application/rtf" has the correct role';
    isa-ok $icon, GIO::ThemedIcon,                         'Value retrieve from get-symbolic-icon as "application/rtf" has the correct type';

    ok     @names.grep( * eq $_ ).elems,                   "'$_' icon is contained in the icon list'"
      for <application-rtf-symbolic application-rtf x-office-document-symbolic x-office-document>;

  }
}

test-guess;
test-unknown;
test-subtype;
test-list;
test-executable;
test-description;
test-icon;
test-symbolic-icon;
