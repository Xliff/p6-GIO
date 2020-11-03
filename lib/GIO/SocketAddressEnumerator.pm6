use v6.c;

use Method::Also;
use NativeCall;

use GIO::Raw::Types;

use GLib::Roles::Object;

our subset GSocketAddressEnumeratorAncestry is export of Mu
  where GSocketAddressEnumerator | GObject;

class GIO::SocketAddressEnumerator {
  also does GLib::Roles::Object;

  has GSocketAddressEnumerator $!se is implementor;

  submethod BUILD (:$enumerator) {
    self.setGSocketAddressEnumerator($enumerator) if $enumerator;
  }

  method setGSocketAddressEnumerator (GSocketAddressEnumeratorAncestry $_) {
    my $to-parent;

    $!se = do {
      when GSocketAddressEnumerator {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GSocketAddressEnumerator, $_);
      }
    }
    self!setObject($to-parent);
  }

  method GIO::Raw::Definitions::GSocketAddressEnumerator
    is also<GSocketAddressEnumerator>
  { $!se }

  method new (GSocketAddressEnumerator $enumerator, :$ref = True) {
    return Nil unless $enumerator;

    my $o = self.bless( :$enumerator );
    $o.ref if $ref;
    $o;
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type(
      self.^name,
      &g_socket_address_enumerator_get_type,
      $n,
      $t
    );
  }

  method next (
    GCancellable()          $cancellable,
    CArray[Pointer[GError]] $error        = gerror,
                            :$raw         = False;
  ) {
    clear_error;
    my $sa = g_socket_address_enumerator_next($!se, $cancellable, $error);
    set_error($error);

    $sa ??
      ( $raw ?? $sa !! ::('GIO::SocketAddress').new($sa, :!ref) )
      !!
      Nil;
  }

  proto method next_async (|)
  { * }

  multi method next_async (
                   &callback,
    gpointer       $user_data    = gpointer
  ) {
    samewith(GCancellable, &callback, $user_data);
  }
  multi method next_async (
    GCancellable() $cancellable,
                   &callback,
    gpointer       $user_data    = gpointer
  )
    is also<next-async>
  {
    g_socket_address_enumerator_next_async(
      $!se,
      $cancellable,
      &callback,
      $user_data
    );

  }

  method next_finish (
    GAsyncResult()          $result,
    CArray[Pointer[GError]] $error   = gerror,
                            :$raw    = False
  )
    is also<next-finish>
  {
    clear_error;
    my $sa = g_socket_address_enumerator_next_finish($!se, $result, $error);
    set_error($error);

    $sa ??
      ( $raw ?? $sa !! ::('GIO::SocketAddress').new($sa, :!ref) )
      !!
      Nil
  }

}

sub g_socket_address_enumerator_get_type ()
  returns GType
  is native(gio)
  is export
{ * }

sub g_socket_address_enumerator_next (
  GSocketAddressEnumerator $enumerator,
  GCancellable             $cancellable,
  CArray[Pointer[GError]]  $error
)
  returns GSocketAddress
  is native(gio)
  is export
{ * }

sub g_socket_address_enumerator_next_async (
  GSocketAddressEnumerator $enumerator,
  GCancellable             $cancellable,
                           &callback (
                             GSocketAddressEnumerator,
                             GAsyncResult,
                             gpointer
                           ),
  gpointer                 $user_data
)
  is native(gio)
  is export
{ * }

sub g_socket_address_enumerator_next_finish (
  GSocketAddressEnumerator $enumerator,
  GAsyncResult             $result,
  CArray[Pointer[GError]]  $error
)
  returns GSocketAddress
  is native(gio)
  is export
{ * }

# our %GIO::SocketAddressEnumerator::RAW-DEFS;
# for MY::.pairs {
#   %GIO::SocketAddressEnumerator::RAW-DEFS{.key} := .value
#     if .key.starts-with('&g_socket_address_enumerator_');
# }
