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

  method cancellable_connect (
             &callback,
    gpointer $data              = gpointer,
             &data_destroy_func = Callable
  )
    is also<cancellable-connect>
  {
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

  method signal-data {
    state ( %signal-data, %signal-object );
    my $self = self;
    unless %signal-data{ self.WHERE } {
      %signal-data{ self.WHERE } = (
        cancelled => sub {
          say 'Setting "cancelled" handler...';
          $self.connect($!c, 'cancelled')
        }
      ).Hash;
    }

    # This might be too expensive. Consider returning a Map-like
    # where AT-KEY does the bubbling up if the given key is not found
    # the local %signal-data;
    unless %signal-object{ self.WHERE } {
      state @keys;

      unless @keys {
        @keys = self.GLib::Roles::Object::signal-data.keys;
        @keys.append: %signal-data{ self.WHERE }.keys;
      }

      %signal-object{ self.WHERE } = (class :: does Associative {

        method !getData (\k) {
          say "Searching for '{ k }'...";
          say "Signal data (self): {
              (%signal-data{ $self.WHERE }{k} // '»NOT DEFINED«').gist }";
          say "Signal data (parent): {
              ($self.GLib::Roles::Object::signal-data{k} //
              '»NOT DEFINED«').gist }";

          %signal-data{ $self.WHERE }{k}
            ?? %signal-data{ $self.WHERE }{k}
            !! $self.GLib::Roles::Object::signal-data{k};
        }

        method AT-KEY (\k) {
          self!getData(k);
        }

        method EXISTS-KEY (\k) {
          self!getData(k).defined;
        }

        method keys {
          @keys;
        }

      }).new;
    }

    %signal-object{ self.WHERE };
  }

  method signal-names {
    state @signal-names = self.signal-data.keys;

    @signal-names;
  }
}
