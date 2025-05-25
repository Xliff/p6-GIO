use v6.c;

use Method::Also;

use NativeCall;

use GIO::Raw::Types;
use GIO::Raw::UnixConnection;

use GIO::Credentials;
use GIO::SocketConnection;

our subset GUnixConnectionAncestry is export of Mu
  where GUnixConnection | GSocketConnectionAncestry;

class GIO::Unix::Connection is GIO::SocketConnection {
  has GUnixConnection $!uc is implementor;

  submethod BUILD (:$unix-connection) {
    self.setUnixConnection($unix-connection) if $unix-connection;
  }

  method setUnixConnection (GUnixConnectionAncestry $_) {
    my $to-parent;

    $!uc = do {
      when GUnixConnection {
        $to-parent = cast(GSocketConnection, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GUnixConnection, $_);
      }
    };
    self.setSocketConnection($to-parent);
  }

  method GIO::Raw::Definitions::GUnixConnection
    is also<GUnixConnection>
  { $!uc }

  method new (GUnixConnectionAncestry $unix-connection, :$ref = True) {
    return Nil unless $unix-connection;

    my $o = self.bless( :$unix-connection );
    $o.ref if $ref;
    $o;
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_unix_connection_get_type, $n, $t );
  }

  method receive_credentials (
    GCancellable()          $cancellable = GCancellable,
    CArray[Pointer[GError]] $error       = gerror,
                            :$raw        = False
  )
    is also<receive-credentials>
  {
    clear_error;
    my $c = g_unix_connection_receive_credentials($!uc, $cancellable, $error);
    set_error($error);

    $c ??
      ( $raw ?? $c !! GIO::Credentials.new($c, :!ref) )
      !!
      Nil;
  }

  proto method receive_credentials_async (|)
    is also<receive-credentials-async>
  { * }

  multi method receive_credentials_async (
                   &callback,
    gpointer       $user_data = gpointer
  ) {
    samewith(GCancellable, &callback, $user_data);
  }
  multi method receive_credentials_async (
    GCancellable() $cancellable,
                   &callback,
    gpointer       $user_data    = gpointer
  )
  {
    g_unix_connection_receive_credentials_async(
      $!uc,
      $cancellable,
      &callback,
      $user_data
    );
  }

  method receive_credentials_finish (
    GAsyncResult()          $result,
    CArray[Pointer[GError]] $error   = gerror,
                            :$raw    = False
  )
    is also<receive-credentials-finish>
  {
    clear_error;
    my $c = g_unix_connection_receive_credentials_finish($!uc, $result, $error);
    set_error($error);

    $c ??
      ( $raw ?? $c !! GIO::Credentials.new($c, :!ref) )
      !!
      Nil;
  }

  method receive_fd (
    GCancellable()          $cancellable = GCancellable,
    CArray[Pointer[GError]] $error       = gerror
  )
    is also<receive-fd>
  {
    clear_error;
    my $f = g_unix_connection_receive_fd($!uc, $cancellable, $error);
    set_error($error);
    $f;
  }

  method send_credentials (
    GCancellable()          $cancellable = GCancellable,
    CArray[Pointer[GError]] $error       = gerror
  )
    is also<send-credentials>
  {
    clear_error;
    my $rv = so g_unix_connection_send_credentials($!uc, $cancellable, $error);
    set_error($error);
    $rv;
  }

  proto method send_credentials_async (|)
    is also<send-credentials-async>
  { * }

  multi method send_credentials_async (
                   &callback,
    gpointer       $user_data = gpointer
  ) {
    samewith(GCancellable, &callback, $user_data);
  }
  multi method send_credentials_async (
    GCancellable() $cancellable,
                   &callback,
    gpointer       $user_data    = gpointer
  ) {
    g_unix_connection_send_credentials_async(
      $!uc,
      $cancellable,
      &callback,
      $user_data
    );
  }

  method send_credentials_finish (
    GAsyncResult()          $result,
    CArray[Pointer[GError]] $error   = gerror
  )
    is also<send-credentials-finish>
  {
    clear_error;
    my $rv = so g_unix_connection_send_credentials_finish(
      $!uc,
      $result,
      $error
    );
    set_error($error);
    $rv;
  }

  method send_fd (
    Int()                   $fd,
    GCancellable()          $cancellable = GCancellable,
    CArray[Pointer[GError]] $error       = gerror
  )
    is also<send-fd>
  {
    my gint $f = $fd;

    clear_error;
    my $rv = so g_unix_connection_send_fd($!uc, $f, $cancellable, $error);
    set_error($error);
    $rv;
  }

}
