use v6.c;

use Method::Also;

use NativeCall;

use GIO::Raw::Types;
use GIO::Raw::FileEnumerator;

use GIO::FileInfo;

use GLib::Roles::Object;
use GIO::Roles::GFile;

our subset GFileEnumeratorAncestry is export of Mu
  where GFileEnumerator | GObject;

class GIO::FileEnumerator {
  also does GLib::Roles::Object;

  has GFileEnumerator $!fe is implementor;

  submethod BUILD (:$enumerator) {
    self.setGFileEnumerator($enumerator) if $enumerator;
  }

  method setGEnumerator (GFileEnumeratorAncestry $_) {
    my $to-parent;

    $!fe = do {
      when GFileEnumerator {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GObject, $_);
      }
    }

    self!setObject($to-parent);
  }

  method GIO::Raw::Definitions::GFileEnumerator
    is also<GFileEnumerator>
  { $!fe }

  method new (GFileEnumerator $enumerator, :$ref = True) {
    return Nil unless $enumerator;

    my $o = self.bless( :$enumerator );
    $o.ref if $ref;
    $o;
  }

  method close (
    GCancellable() $cancellable    = GCancellable,
    CArray[Pointer[GError]] $error = gerror
  ) {
    clear_error;
    my $rv = g_file_enumerator_close($!fe, $cancellable, $error);
    set_error($error);
    $rv;
  }

  proto method close_sync (|)
    is also<close-async>
  { * }

  multi method close_sync (
    Int()    $io_priority,
             &callback,
    gpointer $user_data    = gpointer
  ) {
    samewith($io_priority, GCancellable, &callback, $user_data);
  }
  method close_async (
    Int()          $io_priority,
    GCancellable() $cancellable,
                   &callback,
    gpointer       $user_data    = gpointer
  )
  {
    my gint $i = $io_priority;

    g_file_enumerator_close_async(
      $!fe,
      $i,
      $cancellable,
      &callback,
      $user_data
    );
  }

  method close_finish (
    GAsyncResult()          $result,
    CArray[Pointer[GError]] $error   = gerror
  )
    is also<close-finish>
  {
    clear_error;
    my $rv = g_file_enumerator_close_finish($!fe, $result, $error);
    set_error($error);
    $rv;
  }

  method get_child (GFileInfo() $info, :$raw = False) is also<get-child> {
    my $c = g_file_enumerator_get_child($!fe, $info);

    $c ??
      ( $raw ?? $c !! GIO::Roles::File.new-file-obj($c, :!ref) )
      !!
      Nil;
  }

  method get_container (:$raw = False) is also<get-container> {
    my $c = g_file_enumerator_get_container($!fe);

    $c ??
      ( $raw ?? $c !! GIO::Roles::File.new-file-obj($c, :!ref) )
      !!
      Nil;
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_file_enumerator_get_type, $n, $t );
  }

  method has_pending is also<has-pending> {
    so g_file_enumerator_has_pending($!fe);
  }

  method is_closed is also<is-closed> {
    so g_file_enumerator_is_closed($!fe);
  }

  proto method iterate (|)
  { * }

  multi method iterate (
    GCancellable()          $cancellable = GCancellable,
    CArray[Pointer[GError]] $error       = gerror,
                            :$raw        = False
  ) {
    my $rv = samewith($, $, $cancellable, $error, :$raw);

    $rv[0] ?? $rv.skip(1) !! Nil;
  }
  multi method iterate (
                            $out_info    is rw,
                            $out_child   is rw,
    GCancellable()          $cancellable =  GCancellable,
    CArray[Pointer[GError]] $error       =  gerror,
                            :$raw        =  False
  ) {
    my $oi = CArray[Pointer[GFileInfo]].new;
    $oi[0] = Pointer[GFileInfo].new;
    my $oc = CArray[Pointer[GFile]].new;
    $oc[0] = Pointer[GFile].new;

    clear_error;
    my $rv = g_file_enumerator_iterate(
      $!fe,
      $oi,
      $oc,
      $cancellable,
      $error
    );
    set_error($error);

    $out_info = $oi[0] ??
      ($raw ?? $oi[0] !! GIO::FileInfo.new( $oi[0], :!ref ) )
      !!
      Nil;

    $out_child = $oc[0] ??
      ($raw ?? $oc[0] !! GIO::Roles::File.new-file-obj( $oc[0], :!ref ) )
      !!
      Nil;

    ($rv, $out_info, $out_child);
  }

  method next_file (
    GCancellable()          $cancellable = GCancellable,
    CArray[Pointer[GError]] $error       = gerror,
                            :$raw        = False
  )
    is also<next-file>
  {
    clear_error;
    my $rv = g_file_enumerator_next_file($!fe, $cancellable, $error);
    set_error($error);

    $rv ??
      ( $raw ?? $rv !! GIO::FileInfo.new($rv, :!ref) )
      !!
      Nil;
  }

  proto method next_files_async (|)
    is also<next-files-async>
  { * }

  multi method next_files_async (
    Int()    $num_files,
    Int()    $io_priority,
             &callback,
    gpointer $user_data    = gpointer
  ) {
    samewith($num_files, $io_priority, GCancellable, &callback, $user_data);
  }
  multi method next_files_async (
    Int()          $num_files,
    Int()          $io_priority,
    GCancellable() $cancellable,
                   &callback,
    gpointer       $user_data    = gpointer
  ) {
    my gint ($nf, $i) = ($num_files, $io_priority);

    g_file_enumerator_next_files_async(
      $!fe,
      $nf,
      $i,
      $cancellable,
      &callback,
      $user_data
    );
  }

  method next_files_finish (
    GAsyncResult()          $result,
    CArray[Pointer[GError]] $error   = gerror,
                            :$raw    = False
  )
    is also<next-files-finish>
  {
    clear_error;
    my $rv = g_file_enumerator_next_files_finish($!fe, $result, $error);
    set_error($error);

    $rv ??
      ( $raw ?? $rv !! GIO::FileInfo.new($rv, :!ref) )
      !!
      Nil;
  }

  method set_pending (Int() $pending)
    is also<set-pending>
  {
    my gboolean $p = $pending;

    g_file_enumerator_set_pending($!fe, $p);
  }

}
