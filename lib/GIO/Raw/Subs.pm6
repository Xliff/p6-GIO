use v6.c;

use NativeCall;

use GLib::Raw::Definitions;
use GLib::Raw::Enums;
use GLib::Raw::Object;
use GLib::Raw::Structs;
use GLib::Raw::Subs;
use GLib::Raw::Struct_Subs;
use GIO::Raw::Definitions;
use GIO::Raw::Enums;

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

sub resolveSettingBindFlags (
  :$default     = False,
  :$get         = False,
  :$set         = False,
  :$sensitivity = True,
  :$changes     = True,
  :$invert      = False
)
  is export
{
  my $f = 0;

  return if $default;

  $f +|= G_SETTINGS_BIND_GET            if     $get;
  $f +|= G_SETTINGS_BIND_SET            if     $set;
  $f +|= G_SETTINGS_BIND_NO_SENSITIVITY unless $sensitivity;
  $f +|= G_SETTINGS_BIND_GET_NO_CHANGES unless $changes;
  $f +|= G_SETTINGS_BIND_INVERT_BOOLEAN if     $invert;
  $f;
}

# cw: The name "promisify" is LTA. (This ain't that much better)
sub makePromise ( $o, $m, :$in = 0, :$args = @() ) is export {
  my $p = Promise.new;

  for $args {
    .wrap({
      nextsame;
      $p.keep;
    }) if Callable;
  }

  $o."$m"( |$args );

  $p;
}

sub g_io_error_quark ()
  returns GQuark
  is export
  is native(gio)
{ * }
