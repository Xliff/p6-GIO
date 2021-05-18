use v6;c

use GLib::Raw::Definitions;
use GLib::Raw::Object;
use GIO::Raw::Definitions;

unit package GIO::Raw::SimpleAsyncResult;

### /usr/include/glib-2.0/gio/gsimpleasyncresult.h

sub g_simple_async_result_complete (GSimpleAsyncResult $simple)
  is native(gio)
  is export
{ * }

sub g_simple_async_result_complete_in_idle (GSimpleAsyncResult $simple)
  is native(gio)
  is export
{ * }

sub g_simple_async_result_get_op_res_gboolean (GSimpleAsyncResult $simple)
  returns uint32
  is native(gio)
  is export
{ * }

sub g_simple_async_result_get_op_res_gpointer (GSimpleAsyncResult $simple)
  returns Pointer
  is native(gio)
  is export
{ * }

sub g_simple_async_result_get_op_res_gssize (GSimpleAsyncResult $simple)
  returns gssize
  is native(gio)
  is export
{ * }

sub g_simple_async_result_get_source_tag (GSimpleAsyncResult $simple)
  returns Pointer
  is native(gio)
  is export
{ * }

sub g_simple_async_result_get_type ()
  returns GType
  is native(gio)
  is export
{ * }

sub g_simple_async_result_is_valid (
  GAsyncResult $result,
  GObject      $source,
  gpointer     $source_tag
)
  returns uint32
  is native(gio)
  is export
{ * }

sub g_simple_async_result_new (
  GObject  $source_object,
           &callback (GSimpleAsyncResult, GAsyncResult, gpointer),
  gpointer $user_data,
  gpointer $source_tag
)
  returns GSimpleAsyncResult
  is native(gio)
  is export
{ * }

sub g_simple_async_result_new_error (
  GObject  $source_object,
           &callback (GSimpleAsyncResult, GAsyncResult, gpointer),
  gpointer $user_data,
  GQuark   $domain,
  gint     $code,
  Str      $format
)
  returns GSimpleAsyncResult
  is native(gio)
  is export
{ * }

sub g_simple_async_result_new_from_error (
  GObject                 $source_object,
                          &callback (
                            GSimpleAsyncResult,
                            GAsyncResult,
                            gpointer
                          ),
  gpointer                $user_data,
  CArray[Pointer[GError]] $error
)
  returns GSimpleAsyncResult
  is native(gio)
  is export
{ * }

sub g_simple_async_result_new_take_error (
  GObject                 $source_object,
                          &callback (
                            GSimpleAsyncResult,
                            GAsyncResult,
                            gpointer
                          ),
  gpointer                $user_data,
  CArray[Pointer[GError]] $error
)
  returns GSimpleAsyncResult
  is native(gio)
  is export
{ * }

sub g_simple_async_result_propagate_error (
  GSimpleAsyncResult      $simple,
  CArray[Pointer[GError]] $dest
)
  returns uint32
  is native(gio)
  is export
{ * }

sub g_simple_async_result_run_in_thread (
  GSimpleAsyncResult $simple,
  GSimpleAsyncThreadFunc $func,
  gint $io_priority,
  GCancellable $cancellable
)
  is native(gio)
  is export
{ * }

sub g_simple_async_result_set_check_cancellable (
  GSimpleAsyncResult $simple,
  GCancellable       $check_cancellable
)
  is native(gio)
  is export
{ * }

sub g_simple_async_result_set_error (
  GSimpleAsyncResult $simple,
  GQuark             $domain,
  gint               $code,
  Str                $format
)
  is native(gio)
  is export
{ * }

sub g_simple_async_result_set_from_error (
  GSimpleAsyncResult      $simple,
  CArray[Pointer[GError]] $error
)
  is native(gio)
  is export
{ * }

sub g_simple_async_result_set_handle_cancellation (
  GSimpleAsyncResult $simple,
  gboolean           $handle_cancellation
)
  is native(gio)
  is export
{ * }

sub g_simple_async_result_set_op_res_gboolean (
  GSimpleAsyncResult $simple,
  gboolean           $op_res
)
  is native(gio)
  is export
{ * }

sub g_simple_async_result_set_op_res_gpointer (
  GSimpleAsyncResult $simple,
  gpointer           $op_res,
  GDestroyNotify     $destroy_op_res
)
  is native(gio)
  is export
{ * }

sub g_simple_async_result_set_op_res_gssize (
  GSimpleAsyncResult $simple,
  gssize             $op_res
)
  is native(gio)
  is export
{ * }

sub g_simple_async_result_take_error (
  GSimpleAsyncResult      $simple,
  CArray[Pointer[GError]] $error
)
  is native(gio)
  is export
{ * }

sub g_simple_async_report_error_in_idle (
  GObject  $object,
           &callback (GSimpleAsyncResult, GAsyncResult, gpointer),
  gpointer $user_data,
  GQuark   $domain,
  gint     $code,
  Str      $format
)
  is native(gio)
  is export
{ * }

sub g_simple_async_report_gerror_in_idle (
  GObject                 $object,
                          &callback (
                            GSimpleAsyncResult,
                            GAsyncResult,
                            gpointer
                          ),
  gpointer                $user_data,
  CArray[Pointer[GError]] $error
)
  is native(gio)
  is export
{ * }

sub g_simple_async_report_take_gerror_in_idle (
  GObject                 $object,
                          &callback (
                            GSimpleAsyncResult,
                            GAsyncResult,
                            gpointer
                          ), 
  gpointer                $user_data,
  CArray[Pointer[GError]] $error
)
  is native(gio)
  is export
{ * }
