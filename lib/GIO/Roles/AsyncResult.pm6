use v6.c;

use Method::Also;
use NativeCall;

use GIO::Raw::Types;
use GIO::Raw::AsyncResult;

our subset GAsyncResultAncestry is export of Mu
  where GAsyncResult | GObject;

role GIO::Roles::AsyncResult {
  has GAsyncResult $!ar;

  submethod BUILD (:$result) {
    self.setAsyncResult($result) if $result;
  }

  method setGAsyncResult (GAsyncResultAncestry $_) {
    my $to-parent;

    $!ar = do {
      when GAsyncResult {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GAsyncResult, $_);
      }
    }
    self!setObject($to-parent);
  }

  method roleInit-AsyncResult is also<roleInit_AsyncResult> {
    return if $!ar;

    my \i = findProperImplementor(self.^attributes);
    $!ar = cast( GAsyncResult, i.get_value(self) );
  }

  method GIO::Raw::Definitions::GAsyncResult
    is also<GAsyncResult>
  { $!ar }

  method new-asyncresult-obj (GAsyncResultAncestry $result, :$ref = True) {
    return Nil unless $result;

    my $o = self.bless( :$result );
    $o.ref if $ref;
    $o;
  }

  method get_source_object (:$raw = False) is also<get-source-object> {
    my $o = g_async_result_get_source_object($!ar);

    $o ??
      ( $raw ?? $o !! GLib::Roles::Object.new-object-obj($o, :!ref) )
      !!
      Nil;
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_async_result_get_type, $n, $t );
  }

  method get_user_data is also<get-user-data> {
    g_async_result_get_user_data($!ar);
  }

  method is_tagged (gpointer $source_tag) is also<is-tagged> {
    so g_async_result_is_tagged($!ar, $source_tag);
  }

  proto method legacy_propagate_error (|)
    is also<legacy-propagate-error>
  { * }

  multi method legacy_propagate_error ($error is rw) {
    my $e = CArray[Pointer[GError]].new;
    $e[0] = Pointer[GError];

    $error = return-with-all( samewith($e, :all) );
  }
  multi method legacy_propagate_error (
    CArray[Pointer[GError]] $error,
                            :$all   = False
  ) {
    # cw: XXX - There is doubt here that the global $ERROR should be used.
    #clear_error;
    my $e = so g_async_result_legacy_propagate_error($!ar, $error);
    #set_error($error);
    ppr($e);
  }

}
