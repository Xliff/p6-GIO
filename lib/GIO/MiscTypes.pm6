class GIO::Inotify::File::Monitor {

  method get_type {
    state ($n, $t);

    unstable_get_type( self.^name, &g_inotify_file_monitor_get_type, $n, $t );
 }

}

### /usr/src/glib/gio/inotify/ginotifyfilemonitor.h

sub g_inotify_file_monitor_get_type
  returns GType
  is      native(gio)
  is      export
{ * }
