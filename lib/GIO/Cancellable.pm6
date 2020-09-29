use v6.c;

use Method::Also;

use NativeCall;

use GIO::Raw::Types;
use GIO::Raw::Cancellable;

use GLib::Source;

use GLib::Roles::Object;
use GLib::Roles::Signals::Generic;

our subset GCancellableAncestry is export of Mu
  where GCancellable | GObject;

class GIO::Cancellable {
  also does GLib::Roles::Object;
  also does GLib::Roles::Signals::Generic;

  has GCancellable $!c is implementor;

  submethod BUILD (:$cancellable) {
    self.setGCancellable($cancellable) if $cancellable;
  }

  method setGCancellable (GCancellableAncestry $_) {
    my $to-parent;
    $!c = do {
      when GCancellable {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GCancellable, $_);
      }
    }
    self!setObject($to-parent);
  }

  method GIO::Raw::Definitions::GCancellable
    is also<GCancellable>
  { $!c }

  multi method new (GCancellable $cancellable, :$ref = True) {
    return Nil unless $cancellable;

    my $o = self.bless( :$cancellable );
    $o.ref if $ref;
    $o;
  }
  multi method new {
    my $cancellable = g_cancellable_new();

    $cancellable ?? self.bless( :$cancellable ) !! Nil;
  }

  method get_current (GIO::Cancellable:U: :$raw = False)
    is also<
      get-current
      current
    >
  {
    my $cancellable = g_cancellable_get_current();

    $cancellable ?? self.bless( :$cancellable ) !! Nil;
  }

  # Is default signal.
  method cancelled {
    self.connect($!c, 'cancelled');
  }

  multi method cancel (GIO::Cancellable:D:) {
    GIO::Cancellable.cancel($!c);
  }
  multi method cancel (
    GIO::Cancellable:U:
    GCancellable()      $cancel = GCancellable
  ) {
    g_cancellable_cancel($cancel);
  }

  method connect (
             &callback,
    gpointer $data              = gpointer,
             &data_destroy_func = Callable
  ) {
    g_cancellable_connect($!c, &callback, $data, &data_destroy_func);
  }

  method disconnect (Int() $handler_id) {
    my gulong $h = $handler_id;

    g_cancellable_disconnect($!c, $h);
  }

  method get_fd is also<get-fd> {
    g_cancellable_get_fd($!c);
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_cancellable_get_type, $n, $t );
  }

  method is_cancelled is also<is-cancelled> {
    so g_cancellable_is_cancelled($!c);
  }

  method make_pollfd (GPollFD() $pollfd) is also<make-pollfd> {
    so g_cancellable_make_pollfd($!c, $pollfd);
  }

  method pop_current is also<pop-current> {
    g_cancellable_pop_current($!c);
  }

  method push_current is also<push-current> {
    g_cancellable_push_current($!c);
  }

  method release_fd is also<release-fd> {
    g_cancellable_release_fd($!c);
  }

  method reset {
    g_cancellable_reset($!c);
  }

  method set_error_if_cancelled (CArray[Pointer[GError]] $error = gerror)
    is also<set-error-if-cancelled>
  {
    clear_error;
    my $rv = so g_cancellable_set_error_if_cancelled($!c, $error);
    set_error($error);
    $rv;
  }

  method source_new (:$raw = False) is also<source-new> {
    my $s = g_cancellable_source_new($!c);

    $s ??
      ( $raw ?? $s !! GLib::Source.new($s, :!ref) )
      !!
      Nil;
  }

}
