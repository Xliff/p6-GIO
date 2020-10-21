use v6.c;

use NativeCall;

use GLib::Raw::Types;
use GIO::Raw::Definitions;

unit package GIO::Raw::Subs;

sub prep-supply ($supply is rw, $callback is rw, $name) is export {
  die "Cannot use \$supply and \$callback in the same call to $name!"
    if $supply && $callback;

  if $supply {
    $supply = Supplier::Preserving.new;
    $callback = -> *@a {
      CATCH { default { .message.say; .backtrace.summary.say } }
      $supply.emit(
        GIO::AsyncResult.new( @a[1], :!ref )
      )
    }
  }
}

sub g_io_error_quark ()
  returns GQuark
  is export
  is native(gio)
{ * }
