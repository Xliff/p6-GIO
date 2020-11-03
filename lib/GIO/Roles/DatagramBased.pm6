use v6.c;

use Method::Also;

use NativeCall;

use GIO::Raw::Types;
use GIO::Raw::DatagramBased;

use GLib::Source;

use GLib::Roles::Object;

role GIO::Roles::DatagramBased {
  has GDatagramBased $!d;

  submethod roleInit-DatagramBased {
    return if $!d;

    my \i = findProperImplementor(self.^attributes);
    $!d = cast(GDatagramBased, i.get_value(self) );
  }

  method GIO::Raw::Definitions::GDatagramBased
    is also<GDatagramBased>
  { $!d }

  method condition_check (Int() $condition) is also<condition-check> {
    my GIOCondition $c = $condition;

    GIOConditionEnum( g_datagram_based_condition_check($!d, $c) );
  }

  method condition_wait (
    Int()                   $condition,
    Int()                   $timeout,
    GCancellable()          $cancellable,
    CArray[Pointer[GError]] $error        = gerror
  )
    is also<condition-wait>
  {
    my GIOCondition $c = $condition;
    my gint64       $t = $timeout;

    clear_error;
    my $rv =
      so g_datagram_based_condition_wait($!d, $c, $t, $cancellable, $error);
    set_error($error);
    $rv;
  }

  method create_source (
    Int()          $condition,
    GCancellable() $cancellable,
                   :$raw         = False
  )
    is also<create-source>
  {
    my GIOCondition $c = $condition;
    my              $s = g_datagram_based_create_source($!d, $c, $cancellable);

    $s ??
      ( $raw ?? $s !! GLib::Source.new($s, :!ref) )
      !!
      Nil;
  }

  method datagrambased_get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_datagram_based_get_type, $n, $t );
  }

  method receive_messages (
    GInputMessage           $messages,
    Int()                   $num_messages,
    Int()                   $flags,
    Int()                   $timeout,
    GCancellable()          $cancellable,
    CArray[Pointer[GError]] $error         = gerror
  )
    is also<receive-messages>
  {
    my guint  $nm = $num_messages;
    my gint   $f  = $flags;
    my gint64 $t  = $timeout;

    clear_error;
    my $m = g_datagram_based_receive_messages(
      $!d,
      $messages,
      $nm,
      $f,
      $t,
      $cancellable,
      $error
    );
    set_error($error);
    $m;
  }

  method send_messages (
    GOutputMessage          $messages,
    Int()                   $num_messages,
    Int()                   $flags,
    Int()                   $timeout,
    GCancellable()          $cancellable,
    CArray[Pointer[GError]] $error         = gerror
  )
    is also<send-messages>
  {
    my guint  $nm = $num_messages;
    my gint   $f  = $flags;
    my gint64 $t  = $timeout;

    clear_error;
    my $m = g_datagram_based_send_messages(
      $!d,
      $messages,
      $nm,
      $f,
      $t,
      $cancellable,
      $error
    );
    set_error($error);
    $m;
  }

}

our subset GDatagramBasedAncestry is export of Mu
  where GDatagramBased | GObject;

class GIO::DatagramBased does GLib::Roles::Object does GIO::Roles::DatagramBased {

  submethod BUILD (:$datagram-based) {
    self.setGDatagramBased($datagram-based) if $datagram-based;
  }

  method setGDatagramBased (GDatagramBasedAncestry $_) {
    my $to-parent;

    $!d = do {
      when GDatagramBased {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GDatagramBased, $_);
      }
    }
    self!setObject($to-parent);
  }

  method new (GDatagramBasedAncestry $datagram-based, :$ref = True) {
    return Nil unless $datagram-based;

    my $o = self.bless( :$datagram-based ) if $datagram-based;
    $o.ref if $ref;
    $o;
  }

}
