use v6.c;

use Method::Also;
use NativeCall;

use GIO::Raw::Types;
use GIO::Raw::Task;

use GLib::MainContext;
use GIO::Cancellable;

use GLib::Roles::Object;
use GIO::Roles::AsyncResult;

our subset GTaskAncestry is export of Mu
  where GTask | GAsyncResult | GObject;

class GIO::Task {
  also does GLib::Roles::Object;
  also does GIO::Roles::AsyncResult;

  has GTask $!t is implementor;

  submethod BUILD (:$task) {
    self.setGTask($task) if $task;
  }

  method setGTask (GTaskAncestry $_) {
    my $to-parent;

    $!t = do {
      when GTask {
        $to-parent = cast(GObject, $_);
        $_;
      }

      when GAsyncResult {
        $to-parent = cast(GObject, $_);
        $!ar = $_;
        cast(GTask, $_);
      }

      default {
        $to-parent = $_;
        cast(GTask, $_);
      }
    }
    self!setObject($to-parent);
    self.roleInit-AsyncResult;
  }

  method GIO::Raw::Definitions::GTask
    is also<GTask>
  { $!t }

  multi method new (GTaskAncestry $task, :$ref = True) {
    return Nil unless $task;

    my $o = self.bless( :$task );
    $o.ref if $ref;
    $o;
  }
  multi method new (
    GObject() $source,
              &callback,
    gpointer  $callback_data = gpointer
  ) {
    samewith($source, GCancellable, &callback, $callback_data);
  }
  multi method new (
    GObject()      $source,
    GCancellable() $cancellable,
                   &callback,
    gpointer       $callback_data = gpointer
  ) {
    my $task = g_task_new($source, $cancellable, &callback, $callback_data);

    $task ?? self.bless( :$task ) !! Nil;
  }

  method check_cancellable is rw is also<check-cancellable> {
    Proxy.new(
      FETCH => sub ($) {
        so g_task_get_check_cancellable($!t);
      },
      STORE => sub ($, Int() $check_cancellable is copy) {
        my gboolean $c = $check_cancellable.so.Int;

        g_task_set_check_cancellable($!t, $c);
      }
    );
  }

  method name is rw {
    Proxy.new(
      FETCH => sub ($) {
        g_task_get_name($!t);
      },
      STORE => sub ($, Str() $name is copy) {
        g_task_set_name($!t, $name);
      }
    );
  }

  method priority is rw {
    Proxy.new(
      FETCH => sub ($) {
        g_task_get_priority($!t);
      },
      STORE => sub ($, Int() $priority is copy) {
        my gint $p = $priority;

        g_task_set_priority($!t, $p);
      }
    );
  }

  method return_on_cancel is rw is also<return-on-cancel> {
    Proxy.new(
      FETCH => sub ($) {
        so g_task_get_return_on_cancel($!t);
      },
      STORE => sub ($, Int() $return_on_cancel is copy) {
        my gboolean $r = $return_on_cancel.so.Int;

        g_task_set_return_on_cancel($!t, $r);
      }
    );
  }

  method source_tag is rw is also<source-tag> {
    Proxy.new(
      FETCH => sub ($) {
        g_task_get_source_tag($!t);
      },
      STORE => sub ($, gpointer $source_tag is copy) {
        g_task_set_source_tag($!t, $source_tag);
      }
    );
  }

  method task_data is rw is also<task-data> {
    Proxy.new:
      FETCH => -> $ { self.get-task-data },

      STORE => -> $, $val {
        self.set-task-data(
          do given $val {
            when Pointer               { $_                 }
            when GLib::Roles::Pointers { .p                 }
            when GLib::Roles::Object   { $val.GObject.p     }

                                       # May not accept change of REPR
            when .REPR eq 'CStruct'    { cast(Pointer, $_); }

            default {
              die "Cannot store object of type { .^name } as task data!"
            }
          }
        )
      };
  }

  method attach_source (GSource() $source, &callback) is also<attach-source> {
    g_task_attach_source($!t, $source, &callback);
  }

  method get_cancellable (:$raw = False)
    is also<
      get-cancellable
      cancellable
    >
  {
    my $c = g_task_get_cancellable($!t);

    $c ??
      ( $raw ?? $c !! GIO::Cancellable.new($c, :!ref) )
      !!
      Nil;
  }

  method get_completed
    is also<
      get-completed
      completed
    >
  {
    so g_task_get_completed($!t);
  }

  method get_context (:$raw = False)
    is also<
      get-context
      context
    >
  {
    my $c = g_task_get_context($!t);

    $c ??
      ( $raw ?? $c !! GLib::MainContext.new($c, :!ref) )
      !!
      Nil;
  }

  method get_source_object (:$raw = False)
    is also<
      get-source-object
      source_object
      source-object
    >
  {
    my $o = g_task_get_source_object($!t);

    $o ??
      ( $raw ?? $o !! GLib::Roles::Object.new-object-obj($o, :!ref) )
      !!
      Nil;
  }

  # No arg alias here as we have the attribute .task_data
  method get_task_data is also<get-task-data> {
    g_task_get_task_data($!t);
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_task_get_type, $n, $t );
  }

  method had_error is also<had-error> {
    so g_task_had_error($!t);
  }

  method is_valid (
    GIO::Task:U:
    GAsyncResult() $result,
    GObject()      $source_object
  )
    is also<is-valid>
  {
    so g_task_is_valid($result, $source_object);
  }

  method propagate_boolean (CArray[Pointer[GError]] $error = gerror)
    is also<propagate-boolean>
  {
    clear_error;
    my $b = so g_task_propagate_boolean($!t, $error);
    set_error($error);
    $b;
  }

  method propagate_int (CArray[Pointer[GError]] $error = gerror)
    is also<propagate-int>
  {
    clear_error;
    my $i = g_task_propagate_int($!t, $error);
    set_error($error);
    $i;
  }

  method propagate_pointer (CArray[Pointer[GError]] $error = gerror)
    is also<propagate-pointer>
  {
    clear_error;
    my $p = g_task_propagate_pointer($!t, $error);
    set_error($error);
    $p;
  }

  method report_error (
    GIO::Task:U:
    GObject()               $source_object,
                            &callback,
    gpointer                $callback_data,
    gpointer                $source_tag,
    CArray[Pointer[GError]] $error          = gerror
  )
    is also<report-error>
  {
    clear_error;
    g_task_report_error(
      $source_object,
      &callback,
      $callback_data,
      $source_tag,
      $error
    );
    set_error($error);
  }

  method report_new_error (
    GIO::Task:U:
    GObject()           $source_object,
                        &callback,
    gpointer            $callback_data,
    gpointer            $source_tag,
    GQuark              $domain,
    Int()               $code,
    Str()               $format
  )
    is also<report-new-error>
  {
    my gint $c = $code;

    g_task_report_new_error(
      $source_object,
      &callback,
      $callback_data,
      $source_tag,
      $domain,
      $c,
      $format,
      Str
    );
  }

  method return_boolean (Int() $result) is also<return-boolean> {
    my gboolean $r = $result.so.Int;

    so g_task_return_boolean($!t, $r);
  }

  method return_error (GError() $error) is also<return-error> {
    g_task_return_error($!t, $error);
  }

  method return_error_if_cancelled is also<return-error-if-cancelled> {
    so g_task_return_error_if_cancelled($!t);
  }

  method return_new_error (
    GQuark() $domain,
    Int()    $code,
    Str()    $format
  )
    is also<return-new-error>
  {
    my gint $c = $code;

    g_task_return_new_error($!t, $domain, $c, $format, Str);
  }

  method return_int (Int() $result) is also<return-int> {
    my gssize $r = $result;

    g_task_return_int($!t, $r);
  }

  method return_pointer (
    gpointer $result,
             &result_destroy = Callable
  )
    is also<return-pointer>
  {
    g_task_return_pointer($!t, $result, &result_destroy);
  }

  method run_in_thread (&task_func) is also<run-in-thread> {
    g_task_run_in_thread($!t, &task_func);
  }

  method run_in_thread_sync (&task_func)
    is also<run-in-thread-sync>
  {
    g_task_run_in_thread_sync($!t, &task_func);
  }

  method set_task_data (
    gpointer $task_data,
             &task_data_destroy = Callable
  )
    is also<set-task-data>
  {
    g_task_set_task_data($!t, $task_data, &task_data_destroy);
  }

}
