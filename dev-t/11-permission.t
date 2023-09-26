use v6.c;

use Test;

use GIO::Raw::Types;

use GLib::MainLoop;
use GIO::SimplePermission;

sub test-simple {
  my $p = GIO::SimplePermission.new(True);

  ok  $p.allowed,                                     'Simple permission object returns true for .allowed';
  nok $p.can-acquire,                                 'Simple permission object cannot acquire permissions';
  nok $p.can-release,                                 'Simple permission object cannot release permissions';

  nok $p.acquire,                                     'Attempt to acquire permission fails';
  #is $ERROR.domain,   $G_IO_ERROR,                    'Global error is set to the right domain';
  is $ERROR.code,     G_IO_ERROR_NOT_SUPPORTED.Int,   'Error code indicates an unsupported operation';

  nok $p.release,                                     'Attempt to release permission fails';
  #is $ERROR.domain,   $G_IO_ERROR,                    'Global error is set to the right domain';
  is $ERROR.code,     G_IO_ERROR_NOT_SUPPORTED.Int,   'Error code indicates an unsupported operation';

  my $loop = GLib::MainLoop.new;
  $p.acquire-async(-> *@a {
    CATCH { default { .message.say; .backtrace.summary.say } }
    
    nok $p.acquire-finish(@a[1]),                     'Attempt to acquire asyncronously fails';
    #is $ERROR.domain,   $G_IO_ERROR,                 'Global error is set to the right domain';
    is $ERROR.code,     G_IO_ERROR_NOT_SUPPORTED.Int, 'Error code indicates an unsupported operation';
    $loop.quit;
  });
  $loop.run;

  $p.release-async(-> *@a {
    CATCH { default { .message.say; .backtrace.summary.say } }

    nok $p.release-finish(@a[1]),                     'Attempt to release asyncronously fails';
    #is $ERROR.domain,   $G_IO_ERROR,                  'Global error is set to the right domain';
    is $ERROR.code,     G_IO_ERROR_NOT_SUPPORTED,     'Error code indicates an unsupported operation';
    $loop.quit;
  });

  .unref for $loop, $p;
}

test-simple;
