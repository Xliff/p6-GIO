use v6.c;

use NativeCall;

use GLib::Raw::Definitions;
use GLib::Raw::Enums;
use GLib::Raw::Object;
use GLib::Raw::Structs;
use GLib::Raw::Subs;
use GLib::Raw::Struct_Subs;
use GIO::Raw::Definitions;

unit package GIO::Raw::Subs;

sub prep-supply ($supply, $callback, $name) is export {
  die "Cannot use \$supply and \$callback in the same call to $name!"
    if $supply && $callback;

  my ($new-callback, $new-supply);
  if $supply {
    my $supplier = Supplier::Preserving.new;
    my $new-callback = -> *@a {
      CATCH { default { .message.say; .backtrace.summary.say } }
      $supplier.emit(
        GIO::AsyncResult.new( @a[1], :!ref )
      )
    }
  }

  ($new-callback // $callback, $new-supply);
}

sub g_io_error_quark ()
  returns GQuark
  is export
  is native(gio)
{ * }
