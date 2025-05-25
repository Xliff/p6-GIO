use v6.c;

use Method::Also;

use NativeCall;

use GIO::Raw::Types;
use GIO::Raw::FileMonitor::Local;

use GIO::FileMonitor;

use GLib::Roles::Implementor;

our subset GLocalFileMonitorAncestry is export of Mu
  where GLocalFileMonitor | GFileMonitorAncestry;

class GIO::FileMonitor::Local is GIO::FileMonitor {
  has GLocalFileMonitor $!glfm is implementor;

  submethod BUILD ( :$g-local-fm ) {
    self.setGLocalFileMonitor($g-local-fm)
      if $g-local-fm
  }

  method setGLocalFileMonitor (GLocalFileMonitorAncestry $_) {
    my $to-parent;

    $!glfm = do {
      when GLocalFileMonitor {
        $to-parent = cast(GFileMonitor, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GLocalFileMonitor, $_);
      }
    }
    self.setGFileMonitor($to-parent);
  }

  method GIO::Raw::Definitions::GLocalFileMonitor
    is also<GLocalFileMonitor>
  { $!glfm }

  multi method new (
    $g-local-fm where * ~~ GLocalFileMonitorAncestry,

    :$ref = True
  ) {
    return unless $g-local-fm;

    my $o = self.bless( :$g-local-fm );
    $o.ref if $ref;
    $o;
  }

  method new_for_path (
    Str()                   $pathname,
    Int()                   $is_directory,
    Int()                   $flags,
    CArray[Pointer[GError]] $error         = gerror
  )
    is also<new-for-path>
  {
    my gboolean                $i = $is_directory;
    my GFileMonitorFlags       $f = $flags;

    clear_error;
    my $g-local-fm = g_local_file_monitor_new_for_path(
      $pathname,
      $i,
      $f,
      $error
    );
    set_error($error);

    $g-local-fm ?? self.bless( :$g-local-fm ) !! Nil;
  }

  method new_in_worker (
    Str()                   $pathname,
    Int()                   $is_directory,
    Int()                   $flags,
                            &callback,
    gpointer                $user_data,
                            &dstry_data    = %DEFAULT-CALLBACKS<GDestroyNotify>,
    CArray[Pointer[GError]] $error         = gerror
  )
    is also<new-in-worker>
  {
    my gboolean                $i = $is_directory;
    my GFileMonitorFlags       $f = $flags;

    clear_error;
    my $g-local-fm = g_local_file_monitor_new_in_worker(
      $pathname,
      $i,
      $f,
      &callback,
      $user_data,
      &dstry_data,
      $error
    );
    set_error($error);

    $g-local-fm ?? self.bless( :$g-local-fm ) !! Nil;
  }

  method g_file_monitor_source_handle_event (
    GFileMonitorSource() $source,
    Int()                $event_type,
    Str()                $child,
    Str()                $rename_to,
    GFile()              $other,
    Int()                $event_time
  )
    is also<g-file-monitor-source-handle-event>
  {
    my gint64            $e  = $event_time;
    my GFileMonitorEvent $ev = $event_type;

    g_file_monitor_source_handle_event(
      $source,
      $ev,
      $child,
      $rename_to,
      $other,
      $e
    );
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_local_file_monitor_get_type, $n, $t );
  }

}
