use v6.c;

use Method::Also;
use NativeCall;

use GIO::Raw::GFile;
use GIO::Raw::Types;

use GIO::FileIOStream;
use GIO::FileMonitor;
use GIO::FileOutputStream;
use GIO::FileIOStream;

use GLib::Roles::Object;
use GIO::Roles::AppInfo;
use GIO::Roles::Mount;

role GIO::Roles::File {
  has GFile $!file;

  submethod BUILD (:$file) {
    self!GFileRoleInit($file) if $file;
  }

  method !GFileRoleInit (GFile $file) {
    $!file = $file;
  }

  method roleInit-GFile {
    my \i = findProperImplementor(self.^attributes);

    $!file = cast( GFile, i.get_value(self) );
  }

  method GIO::Raw::Definitions::GFile
    is also<GFile>
  { $!file }

  method new-file-obj (GFile $file)
    is also<
      new_file_obj
      new_gfile_obj
      new-gfile-obj
    >
  {
    $file ?? self.bless(:$file) !! Nil;
  }

  # XXX - To be replaced with multiple dispatchers!
  multi method new (
    :$path,
    :$uri,
    :$cwd,
    :$arg,
    :$iostream,
    :$tmpl,
    :$error
  ) {
    # Can insert more rpbust parameter checking, here... however
    # the priorities established below should be fine.
    my $file = do {
      with $arg {
        with $cwd {
          self.new_for_commandline_arg_and_cwd($arg, $cwd);
        } else {
          self.new_for_commandline_arg($arg);
        }
      } orwith $path {
        self.new_for_path($path);
      } orwith $uri {
        self.new_for_uri($uri);
      } orwith $iostream {
        my $e = $error // gerror;
        with $tmpl {
          self.new_tmp($tmpl, $iostream, $e);
        } else {
          self.new_tmp($iostream, $e);
        }
      } else {
        self.new_tmpl;
      }
    }
    $file ?? self.bless(:$file) !! Nil;
  }

  multi method new (Str() $a, :$arg is required) {
    self.new_for_commandline_arg($a);
  }
  method new_for_commandline_arg (Str() $cmd)
    is also<new-for-commandline-arg>
  {
    my $file = g_file_new_for_commandline_arg($cmd);

    $file ?? self.bless(:$file) !! Nil;
  }

  multi method new (Str() $arg, Str() $cwd, :arg_cwd(:$arg-cwd) is required) {
    self.new_for_commandline_arg_and_cwd($arg, $cwd);
  }
  method new_for_commandline_arg_and_cwd (Str() $arg, Str() $cwd)
    is also<new-for-commandline-arg-and-cwd>
  {
    my $file = g_file_new_for_commandline_arg_and_cwd($arg, $cwd);

    $file ?? self.bless(:$file) !! Nil;
  }

  multi method new (Str() $p, :$path is required) {
    self.new_for_path($p);
  }
  method new_for_path (Str() $path) is also<new-for-path> {
    my $file = g_file_new_for_path($path);

    $file ?? self.bless(:$file) !! Nil;
  }

  multi method new (Str $u, :$uri is required) {
    self.new_for_uri($uri);
  }
  method new_for_uri (Str() $uri) is also<new-for-uri> {
    my $file = g_file_new_for_uri($uri);

    $file ?? self.bless(:$file) !! Nil;
  }

  proto method new_tmp (|)
    is also<new-tmp>
  { * }


  multi method new (
    :temp(:$tmp) is required,
    :$raw = False
  ) {
    self.new_tmp(Str, :$raw);
  }
  multi method new_tmp (
    CArray[Pointer[GError]] $error = gerror,
    :$raw = False
  ) {
    samewith(Str, $, $error, :$raw);
  }

  multi method new (
    Str() $tmpl,
    :temp(:$tmp) is required,
    :$raw = False
  ) {
    self.new_tmp($tmpl, :$raw);
  }
  multi method new_tmp (
    Str() $tmpl,
    CArray[Pointer[GError]] $error = gerror,
    :$raw = False
  ) {
    samewith($tmpl, $, $error, :$raw);
  }

  multi method new (
    Str() $tmpl,
    $iostream is rw,
    :temp(:$tmp) is required,
    :$raw = False,
  ) {
    samewith($tmpl, $iostream);
  }
  multi method new_tmp (
    Str() $tmpl,
    $iostream is rw,
    CArray[Pointer[GError]] $error = gerror,
    :$raw = False
  ) {
    my $i = CArray[Pointer[GFileIOStream]].new;
    $i[0] = Pointer[GFileIOStream];
    my $rv = samewith($tmpl, $i, $error);

    $iostream = ppr($i);
    if $iostream {
      $iostream = GIO::FileIOStream.new($iostream) unless $raw;
    }
    $rv;
  }

  multi method new (
    Str() $tmpl,
    CArray[Pointer[GFileIOStream]] $iostream,
    CArray[Pointer[GError]] $error = gerror,
    :temp(:$tmp) is required
  ) {
    self.new_tmp($tmpl, $iostream, $error);
  }
  multi method new_tmp (
    Str() $tmpl,
    CArray[Pointer[GFileIOStream]] $iostream,
    CArray[Pointer[GError]] $error = gerror
  ) {
    clear_error;
    my $file = g_file_new_tmp($tmpl, $iostream, $error);
    set_error($error);
    $file ?? self.bless(:$file) !! Nil;
  }

  method append_to (
    Int() $flags,                       # GFileCreateFlags $flags,
    GCancellable() $cancellable    = GCancellable,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<append-to>
  {
    clear_error;
    my guint $f = $flags;
    my $file = g_file_append_to($!file, $f, $cancellable, $error);
    set_error($error);
    $file ?? self.bless(:$file) !! Nil;
  }

  proto method append_to_async (|)
    is also<append-to-async>
  { * }

  multi method append_to_async (
    Int() $flags,                       # GFileCreateFlags $flags,
    Int() $io_priority,
    &callback,
    gpointer $user_data         = Pointer,
    GCancellable() $cancellable = GCancellable,
    :$raw = False
  ) {
    samewith($flags, $io_priority, $cancellable, &callback, $user_data, :$raw);
  }
  multi method append_to_async (
    Int() $flags,                       # GFileCreateFlags $flags,
    Int() $io_priority,
    GCancellable() $cancellable,
    &callback,
    gpointer $user_data = Pointer,
    :$raw = False
  ) {
    my guint $f = $flags;
    my gint $io = $io_priority;
    my $fos = g_file_append_to_async(
      $!file, $f, $io, $cancellable, &callback, $user_data
    );

    $fos ??
      ( $raw ?? $fos !! GIO::FileOutputStream.new($fos) )
      !!
      Nil;
  }

  method append_to_finish (
    GAsyncResult() $res,
    CArray[Pointer[GError]] $error  = gerror,
    :$raw = False
  )
    is also<append-to-finish>
  {
    clear_error;
    my $fos = g_file_append_to_finish($!file, $res, $error);
    set_error($error);

    $fos ??
      ( $raw ?? $fos !! GIO::FileOutputStream.new($fos) )
      !!
      Nil;
  }

  multi method copy (
    GFile() $destination,
    Int() $flags,                       # GFileCreateFlags $flags,
    &progress_callback               = Callable,
    gpointer $progress_callback_data = Pointer,
    GCancellable() $cancellable      = GCancellable,
    CArray[Pointer[GError]] $error   = gerror
  ) {
    samewith(
      $destination,
      $flags,
      $cancellable,
      &progress_callback,
      $progress_callback_data,
      $error
    );
  }
  multi method copy (
    GFile() $destination,
    Int() $flags,                       # GFileCreateFlags $flags,
    GCancellable() $cancellable,
    &progress_callback,
    gpointer $progress_callback_data = Pointer,
    CArray[Pointer[GError]] $error   = gerror
  ) {
    my guint $f = $flags;

    clear_error;
    my $rv = so g_file_copy(
      $!file,
      $destination,
      $f,
      $cancellable,
      &progress_callback,
      $progress_callback_data,
      $error
    );
    set_error($error);
    $rv;
  }

  proto method copy_async (|)
    is also<copy-async>
  { * }

  multi method copy_async (
    GFile() $destination,
    Int() $flags,                       # GFileCreateFlags $flags,
    Int() $io_priority,
    &callback,
    &progress_callback               = Callable,
    gpointer $progress_callback_data = Pointer,
    gpointer $user_data              = Pointer,
    GCancellable() $cancellable      = GCancellable
  ) {
    samewith(
      $destination,
      $flags,
      $io_priority,
      $cancellable,
      &progress_callback,
      $progress_callback_data,
      &callback,
      $user_data
    );
  }
  multi method copy_async (
    GFile() $destination,
    Int() $flags,                       # GFileCreateFlags $flags,
    Int() $io_priority,
    GCancellable() $cancellable,
    &progress_callback,
    gpointer $progress_callback_data,
    &callback,
    gpointer $user_data = Pointer
  )  {
    my guint $f = $flags;
    my gint $io = $io_priority;

    g_file_copy_async(
      $!file,
      $destination,
      $f,
      $io,
      $cancellable,
      &progress_callback,
      $progress_callback_data,
      &callback,
      $user_data
    );
  }

  method copy_attributes (
    GFile() $destination,
    Int() $flags,                       # GFileCreateFlags $flags,
    GCancellable() $cancellable    = GCancellable,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<copy-attributes>
  {
    my guint $f = $flags;

    so g_file_copy_attributes(
      $!file, $destination, $f, $cancellable, $error
    );
  }

  method copy_finish (
    GAsyncResult() $res,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<copy-finish>
  {
    clear_error;
    my $rv = so g_file_copy_finish($!file, $res, $error);
    set_error($error);
    $rv;
  }

  method create (
    Int() $flags,                       # GFileCreateFlags $flags,
    GCancellable() $cancellable    = GCancellable,
    CArray[Pointer[GError]] $error = gerror,
    :$raw = False
  ) {
    my guint $f = $flags;

    clear_error;
    my $fos = g_file_create($!file, $f, $cancellable, $error);
    set_error($error);

    $fos ??
      ( $raw ?? $fos !! GIO::FileOutputStream.new($fos) )
      !!
      Nil;
  }

  proto method create_async (|)
    is also<create-async>
  { * }

  multi method create_async (
    Int() $flags,
    Int() $io_priority,
    &callback,
    gpointer $user_data         = Pointer,
    GCancellable() $cancellable = GCancellable
  ) {
    samewith($flags, $io_priority, $cancellable, &callback, $user_data);
  }
  multi method create_async (
    Int() $flags,
    Int() $io_priority,
    GCancellable() $cancellable,
    &callback,
    gpointer $user_data = Pointer
  ) {
    my GFileCreateFlags $f = $flags;
    my gint $io = $io_priority;

    g_file_create_async(
      $!file, $f, $io, $cancellable, &callback, $user_data
    );
  }

  method create_finish (
    GAsyncResult() $res,
    CArray[Pointer[GError]] $error = gerror,
    :$raw = False
  )
    is also<create-finish>
  {
    clear_error;
    my $fos = g_file_create_finish($!file, $res, $error);
    set_error($error);

    $fos ??
      ( $raw ?? $fos !! GIO::FileOutputStream.new($fos) )
      !!
      Nil;
  }

  method create_readwrite (
    Int() $flags,
    GCancellable() $cancellable    = GCancellable,
    CArray[Pointer[GError]] $error = gerror,
    :$raw = False
  )
    is also<create-readwrite>
  {
    my guint $f = $flags;

    clear_error;
    my $fios = g_file_create_readwrite($!file, $f, $cancellable, $error);
    set_error($error);

    $fios ??
      ( $raw ?? $fios !! GIO::FileIOStream.new($fios) )
      !!
      Nil;
  }

  proto method create_readwrite_async (|)
    is also<create-readwrite-async>
  { * }

  multi method create_readwrite_async (
    Int() $flags,
    Int() $io_priority,
    &callback,
    gpointer $user_data         = Pointer,
    GCancellable() $cancellable = GCancellable
  ) {
    samewith($flags, $io_priority, $cancellable, &callback, $user_data);
  }
  multi method create_readwrite_async (
    Int() $flags,
    Int() $io_priority,
    GCancellable() $cancellable,
    &callback,
    gpointer $user_data = Pointer
  ) {
    my GFileCreateFlags $f = $flags;
    my gint $io = $io_priority;

    g_file_create_readwrite_async(
      $!file, $f, $io, $cancellable, &callback, $user_data
    );
  }

  method create_readwrite_finish (
    GAsyncResult() $res,
    CArray[Pointer[GError]] $error = gerror,
    :$raw = False
  )
    is also<create-readwrite-finish>
  {
    clear_error;
    my $fios = g_file_create_readwrite_finish($!file, $res, $error);
    set_error($error);

    $fios ??
      ( $raw ?? $fios !! GIO::FileIOStream.new($fios) )
      !!
      Nil;
  }

  method delete (
    GCancellable() $cancellable    = GCancellable,
    CArray[Pointer[GError]] $error = gerror
  ) {
    clear_error;
    my $rv = so g_file_delete($!file, $cancellable, $error);
    set_error($error);
    $rv;
  }

  proto method delete_async (|)
    is also<delete-async>
  { * }

  multi method delete_async (
    Int() $io_priority,
    &callback,
    gpointer $user_data         = Pointer,
    GCancellable() $cancellable = GCancellable
  ) {
    samewith($io_priority, $cancellable, &callback, $user_data);
  }
  multi method delete_async (
    Int() $io_priority,
    GCancellable() $cancellable,
    &callback,
    gpointer $user_data = Pointer
  ) {
    g_file_delete_async(
      $!file, $io_priority, $cancellable, &callback, $user_data
    );
  }

  method delete_finish (
    GAsyncResult() $result,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<delete-finish>
  {
    clear_error;
    my $rv = so g_file_delete_finish($!file, $result, $error);
    set_error($error);
    $rv;
  }

  method dup (:$raw = False) {
    my $f = g_file_dup($!file);

    $f ??
      ( $raw ?? $f !! GIO::Roles::File.new-file-obj($f) )
      !!
      Nil;
  }

  # proto method eject_mountable (|)
  #   is also<eject-mountable>
  # { * }
  #
  # multi method eject_mountable (
  #   GMountUnmountFlags $flags,
  #   &callback,
  #   gpointer $user_data       = Pointer,
  #   GCancellable $cancellable = Pointer
  # ) {
  #   samewith($flags, $cancellable, &callback, $user_data);
  # }
  # multi method eject_mountable (
  #   GMountUnmountFlags $flags,
  #   GCancellable $cancellable,
  #   &callback,
  #   gpointer $user_data = Pointer
  # ) {
  #   my guint $f = $flags;
  #   g_file_eject_mountable(
  #     $!file, $f, $cancellable, &callback, $user_data
  #   );
  # }
  #
  # method eject_mountable_finish (
  #   GAsyncResult() $result,
  #   CArray[Pointer[GError]] $error = gerror
  # )
  #   is also<eject-mountable-finish>
  # {
  #   clear_error;
  #   my $rc = g_file_eject_mountable_finish($!file, $result, $error);
  #   set_error($error);
  #   $rc;
  # }

  proto method eject_mountable_with_operation (|)
    is also<eject-mountable-with-operation>
  { * }

  multi method eject_mountable_with_operation (
    Int() $flags,
    GMountOperation() $mount_operation,
    &callback,
    gpointer $user_data         = Pointer,
    GCancellable() $cancellable = GCancellable
  ) {
    samewith(
      $flags,
      $mount_operation,
      $cancellable,
      &callback,
      $user_data
    );
  }
  multi method eject_mountable_with_operation (
    Int() $flags,
    GMountOperation() $mount_operation,
    GCancellable() $cancellable,
    &callback,
    gpointer $user_data = Pointer
  ) {
    my GMountUnmountFlags $f = $flags;

    g_file_eject_mountable_with_operation(
      $!file,
      $f,
      $mount_operation,
      $cancellable,
      &callback,
      $user_data
    );
  }

  method eject_mountable_with_operation_finish (
    GAsyncResult() $result,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<eject-mountable-with-operation-finish>
  {
    clear_error;
    my $rv = so g_file_eject_mountable_with_operation_finish(
      $!file,
      $result,
      $error
    );
    set_error($error);
    $rv;
  }

  method enumerate_children (
    Str() $attributes,
    Int() $flags                   = G_FILE_QUERY_INFO_NONE,
    GCancellable() $cancellable    = GCancellable,
    CArray[Pointer[GError]] $error = gerror,
    :$raw = False
  )
    is also<enumerate-children>
  {
    my GFileQueryInfoFlags $f = $flags;

    clear_error;
    my $fe = g_file_enumerate_children(
      $!file,
      $attributes,
      $f,
      $cancellable,
      $error
    );
    set_error($error);

    $fe ??
      ( $raw ?? $fe !! GLib::FileEnumerator.new($fe) )
      !!
      Nil;
  }


  proto method enumerate_children_async (|)
    is also<enumerate-children-async>
  { * }

  multi method enumerate_children_async (
    Str() $attributes,
    Int() $flags,
    Int() $io_priority,
    &callback,
    gpointer $user_data         = Pointer,
    GCancellable() $cancellable = GCancellable
  ) {
    samewith(
      $attributes,
      $flags,
      $io_priority,
      $cancellable,
      &callback,
      $user_data
    )
  }
  multi method enumerate_children_async (
    Str() $attributes,
    Int() $flags,
    Int() $io_priority,
    GCancellable() $cancellable,
    &callback,
    gpointer $user_data = Pointer
  ) {
    my GFileQueryInfoFlags $f = $flags;
    my gint $io = $io_priority;

    g_file_enumerate_children_async(
      $!file,
      $attributes,
      $f,
      $io,
      $cancellable,
      &callback,
      $user_data
    );
  }

  method enumerate_children_finish (
    GAsyncResult() $res,
    CArray[Pointer[GError]] $error = gerror,
    :$raw = False
  )
    is also<enumerate-children-finish>
  {
    clear_error;
    my $fe = g_file_enumerate_children_finish($!file, $res, $error);
    set_error($error);

    $fe ??
      ( $raw ?? $fe !! GLib::FileEnumerator.new($fe) )
      !!
      Nil;
  }

  method equal (GFile() $file2) {
    g_file_equal($!file, $file2);
  }

  method find_enclosing_mount (
    GCancellable() $cancellable    = GCancellable,
    CArray[Pointer[GError]] $error = gerror,
    :$raw = False
  )
    is also<find-enclosing-mount>
  {
    clear_error;
    my $m = g_file_find_enclosing_mount($!file, $cancellable, $error);
    set_error($error);

    $m ??
      ( $raw ?? $m !! GIO::Roles::Mount.new-mount-obj($m) )
      !!
      Nil;
  }

  proto method find_enclosing_mount_async (|)
    is also<find-enclosing-mount-async>
  { * }

  multi method find_enclosing_mount_async (
    Int() $io_priority,
    &callback,
    gpointer $user_data         = Pointer,
    GCancellable() $cancellable = GCancellable
  ) {
    samewith($io_priority, $cancellable, &callback, $user_data);
  }
  multi method find_enclosing_mount_async (
    Int() $io_priority,
    GCancellable() $cancellable,
    &callback,
    gpointer $user_data = Pointer
  ) {
    my gint $i = $io_priority;

    g_file_find_enclosing_mount_async(
      $!file,
      $i,
      $cancellable,
      &callback,
      $user_data
    );
  }

  method find_enclosing_mount_finish (
    GAsyncResult() $res,
    CArray[Pointer[GError]] $error = gerror,
    :$raw = False
  )
    is also<find-enclosing-mount-finish>
  {
    clear_error;
    my $m = g_file_find_enclosing_mount_finish($!file, $res, $error);
    set_error($error);

    $m ??
      ( $raw ?? $m !! GIO::Roles::Mount.new-mount-obj($m) )
      !!
      Nil;
  }

  method get_basename
    is also<
      get-basename
      basename
    >
  {
    g_file_get_basename($!file);
  }

  method get_child (Str() $name, :$raw = False) is also<get-child> {
    my $f = g_file_get_child($!file, $name);

    $f ??
      ( $raw ?? $f !! GIO::Roles::File.new-file-obj($f) )
      !!
      Nil;
  }

  method get_child_for_display_name (
    Str() $display_name,
    CArray[Pointer[GError]] $error = gerror,
    :$raw = False
  )
    is also<get-child-for-display-name>
  {
    clear_error;
    my $f = g_file_get_child_for_display_name(
      $!file,
      $display_name,
      $error
    );
    set_error($error);

    $f ??
      ( $raw ?? $f !! GIO::Roles::File.new-file-obj($f) )
      !!
      Nil;
  }

  method get_parent (:$raw = False)
    is also<
      get-parent
      parent
    >
  {
    my $f = g_file_get_parent($!file);

    $f ??
      ( $raw ?? $f !! GIO::Roles::File.new-file-obj($f) )
      !!
      Nil;
  }

  # Cannot use shorter variant due to conflict with the method parse_name()
  method get_parse_name
    is also<
      get-parse-name
    >
  {
    g_file_get_parse_name($!file);
  }

  method get_path
    is also<
      get-path
      path
    >
  {
    g_file_get_path($!file);
  }

  method get_relative_path (GFile() $descendant) is also<get-relative-path> {
    g_file_get_relative_path($!file, $descendant);
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_file_get_type, $n, $t );
  }

  method get_uri
    is also<
      get-uri
      uri
    >
  {
    g_file_get_uri($!file);
  }

  method get_uri_scheme
    is also<
      get-uri-scheme
      uri_scheme
      uri-scheme
    >
  {
    g_file_get_uri_scheme($!file);
  }

  method has_parent (GFile() $parent) is also<has-parent> {
    so g_file_has_parent($!file, $parent);
  }

  method has_prefix (GFile() $prefix) is also<has-prefix> {
    so g_file_has_prefix($!file, $prefix);
  }

  method has_uri_scheme (Str() $uri_scheme) is also<has-uri-scheme> {
    so g_file_has_uri_scheme($!file, $uri_scheme);
  }

  method hash {
    g_file_hash($!file);
  }

  method is_native is also<is-native> {
    so g_file_is_native($!file);
  }

  method load_bytes (
    GCancellable() $cancellable,
    Str() $etag_out,
    CArray[Pointer[GError]] $error = gerror,
    :$raw = False
  )
    is also<load-bytes>
  {
    clear_error;
    my $b = g_file_load_bytes($!file, $cancellable, $etag_out, $error);
    set_error($error);

    $b ??
      ( $raw ?? $b !! GLib::Bytes($b) )
      !!
      Nil;
  }

  method load_bytes_async (
    GCancellable() $cancellable,
    &callback,
    gpointer $user_data = Pointer
  )
    is also<load-bytes-async>
  {
    g_file_load_bytes_async($!file, $cancellable, &callback, $user_data);
  }

  method load_bytes_finish (
    GAsyncResult() $result,
    Str() $etag_out,
    CArray[Pointer[GError]] $error = gerror,
    :$raw = False
  )
    is also<load-bytes-finish>
  {
    clear_error;
    my $b = g_file_load_bytes_finish($!file, $result, $etag_out, $error);
    set_error($error);

    $b ??
      ( $raw ?? $b !! GLib::Bytes($b) )
      !!
      Nil;
  }

  proto method load_contents (|)
    is also<load-contents>
  { * }

  multi method load_contents (
    CArray[Pointer[GError]] $error = gerror,
    :$buf = True
  ) {
    samewith($, $, $, $error, :all, :$buf);
  }
  multi method load_contents (
    $contents is rw,
    $length is rw,
    $etag_out is rw,
    CArray[Pointer[GError]] $error = gerror,
    :$buf = True
  ) {
    my @r = callwith(
      GCancellable,
      $contents,
      $length,
      $etag_out,
      $error,
      :all,
      :$buf
    );
    @r[0] ?? @r[1..*] !! Nil;
  }
  multi method load_contents (
    GCancellable() $cancellable,
    $contents is rw,
    $length is rw,
    $etag_out is rw,
    CArray[Pointer[GError]] $error = gerror,
    :$all = False,
    :$buf = True
  ) {
    my gsize $l = 0;
    my $c = CArray[uint8].new;
    my $eo = CArray[Str].new;
    ($c[0], $eo[0]) = (0, Str);

    clear_error;
    my $rv = so g_file_load_contents(
      $!file,
      $cancellable,
      $c,
      $l,
      $eo,
      $error
    );
    set_error($error);

    my @a = CArrayToArray($c);
    $all.not ??
      $rv
      !!
      (
        $rv,
        $buf ?? Buf.new(@a) !! @a,
        $l,
        $eo[0] ?? $eo[0] !! Nil
      )
  }

  method load_contents_async (
    GCancellable() $cancellable,
    &callback,
    gpointer $user_data = Pointer
  )
    is also<load-contents-async>
  {
    g_file_load_contents_async($!file, $cancellable, &callback, $user_data);
  }

  proto method load_contents_finish (|)
    is also<load-contents-finish>
  { * }

  multi method load_contents_finish (
    GAsyncResult() $res,
    CArray[Pointer[GError]] $error = gerror
  ) {
    my $rv = samewith($res, $, $, $, $error, :all);
    $rv[0] ?? $rv.skip(1) !! Nil;
  }
  multi method load_contents_finish (
    GAsyncResult() $res,
    $contents is rw,
    $length is rw,
    $etag_out is rw,
    CArray[Pointer[GError]] $error = gerror,
    :$all = False
  ) {
    my gsize $l = 0;
    my ($c, $e) = CArray[Str].new;
    ( $c[0], $e[0] ) = Str xx 2;

    clear_error;
    my $rv = so g_file_load_contents_finish($!file, $res, $c, $l, $e, $error);
    set_error($error);
    ($contents, $length, $etag_out) = ($c[0], $l, $e[0]);
    $all.not ?? $rv !! ($rv, $contents, $length, $etag_out);
  }

  proto method load_partial_contents_async (|)
    is also<load-partial-contents-async>
  { * }

  multi method load_partial_contents_async (
    &read_more_callback,
    &callback,
    gpointer $user_data = Pointer,
    GCancellable() $cancellable = GCancellable
  ) {
    samewith($cancellable, &read_more_callback, &callback, $user_data);
  }
  multi method load_partial_contents_async (
    GCancellable() $cancellable,
    &read_more_callback,
    &callback,
    gpointer $user_data = Pointer
  ) {
    g_file_load_partial_contents_async(
      $!file,
      $cancellable,
      &read_more_callback,
      &callback,
      $user_data
    );
  }

  proto method load_partial_contents_finish (|)
    is also<load-partial-contents-finish>
  { * }

  multi method load_partial_contents_finish (
    GAsyncResult() $res,
    CArray[Pointer[GError]] $error = gerror
  ) {
    my $rv = samewith($res, $, $, $, $error, :all);
    $rv[0] ?? $rv.skip(1) !! Nil;
  }
  multi method load_partial_contents_finish (
    GAsyncResult() $res,
    $contents is rw,
    $length   is rw,
    $etag_out is rw,
    CArray[Pointer[GError]] $error = gerror,
    :$all = False
  )
    is also<load-partial-contents-finish>
  {
    my gsize $l = 0;
    my ($c, $e) = CArray[Str].new;
    ( $c[0], $e[0] ) = Str xx 2;

    clear_error;
    my $rv = g_file_load_partial_contents_finish(
      $!file,
      $res,
      $c,
      $l,
      $e,
      $error
    );
    set_error($error);
    ($contents, $length, $etag_out) = ($c[0], $l, $e[0]);
    $all.not ?? $rv !! ($rv, $contents, $length, $etag_out);
  }

  method make_directory (
    GCancellable() $cancellable,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<make-directory>
  {
    clear_error;
    my $rv = so g_file_make_directory($!file, $cancellable, $error);
    set_error($error);
    $rv
  }

  proto method make_directory_async (|)
    is also<make-directory-async>
  { * }

  multi method make_directory_async (
    Int() $io_priority,
    &callback,
    gpointer $user_data         = Pointer,
    GCancellable() $cancellable = GCancellable
  ) {
    samewith($io_priority, $cancellable, &callback, $user_data);
  }
  multi method make_directory_async (
    Int() $io_priority,
    GCancellable() $cancellable,
    &callback,
    gpointer $user_data = Pointer
  ) {
    my gint $io = $io_priority;

    g_file_make_directory_async(
      $!file,
      $io,
      $cancellable,
      &callback,
      $user_data
    );
  }

  method make_directory_finish (
    GAsyncResult() $result,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<make-directory-finish>
  {
    clear_error;
    my $rv = so g_file_make_directory_finish($!file, $result, $error);
    set_error($error);
    $rv;
  }

  method make_directory_with_parents (
    GCancellable() $cancellable,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<make-directory-with-parents>
  {
    clear_error;
    my $rv = so g_file_make_directory_with_parents(
      $!file,
      $cancellable,
      $error
    );
    set_error($error);
    $rv;
  }

  method make_symbolic_link (
    Str() $symlink_value,
    GCancellable() $cancellable    = GCancellable,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<make-symbolic-link>
  {
    clear_error;
    my $rc = g_file_make_symbolic_link(
      $!file,
      $symlink_value,
      $cancellable,
      $error
    );
    set_error($error);
    $rc;
  }

  proto method measure_disk_usage (|)
    is also<measure-disk-usage>
  { * }

  multi method measure_disk_usage (
    Int() $flags,
    &progress_callback,
    gpointer $progress_data        = gpointer,
    GCancellable() $cancellable    = GCancellable,
    CArray[Pointer[GError]] $error = gerror,
  ) {
    my $rv = samewith(
      $flags,
      $cancellable,
      &progress_callback,
      $progress_data,
      $,
      $,
      $,
      $error,
      :all
    );
    $rv[0] ?? $rv.skip(1) !! Nil;
  }
  multi method measure_disk_usage (
    Int() $flags,
    GCancellable() $cancellable,
    &progress_callback,
    gpointer $progress_data,
    $disk_usage is rw,
    $num_dirs   is rw,
    $num_files  is rw,
    CArray[Pointer[GError]] $error = gerror,
    :$all = False
  )

  {
    my GFileMeasureFlags $f = $flags;
    my guint64 ($du, $nd, $nf) = 0 xx 3;
    clear_error;
    my $rv = so g_file_measure_disk_usage(
      $!file,
      $f,
      $cancellable,
      &progress_callback,
      $progress_data,
      $du,
      $nd,
      $nf,
      $error
    );
    set_error($error);
    ($disk_usage, $num_dirs, $num_files) = ($du, $nd, $nf);
    $all.not ?? $rv !! ($rv, $disk_usage, $num_dirs, $num_files);
  }

  method measure_disk_usage_async (
    Int() $flags,
    Int() $io_priority,
    GCancellable() $cancellable = GCancellable,
    &progress_callback          = Callable,
    gpointer $progress_data     = Pointer,
    &callback                   = Callable,
    gpointer $user_data         = Pointer
  )
    is also<measure-disk-usage-async>
  {
    my GFileMeasureFlags $f = $flags;
    my gint $io = $io_priority;
    g_file_measure_disk_usage_async(
      $!file,
      $f,
      $io,
      $cancellable,
      &progress_callback,
      $progress_data,
      &callback,
      $user_data
    );
  }

  proto method measure_disk_usage_finish (|)
    is also<measure-disk-usage-finish>
  { * }

  multi method measure_disk_usage_finish (
    GAsyncResult() $result,
    CArray[Pointer[GError]] $error = gerror,
    :$all = False
  ) {
    samewith($result, $, $, $, $error, :all);
  }
  multi method measure_disk_usage_finish (
    GAsyncResult() $result,
    $disk_usage is rw,
    $num_dirs   is rw,
    $num_files  is rw,
    CArray[Pointer[GError]] $error = gerror,
    :$all = False
  ) {
    my guint64 ($du, $nd, $nf) = 0 xx 3;

    clear_error;
    my $rv = so g_file_measure_disk_usage_finish(
      $!file,
      $result,
      $du,
      $nd,
      $nf,
      $error
    );
    set_error($error);
    ($disk_usage, $num_dirs, $num_files) = ($du, $nd, $nf);
    $all.not ?? $rv !! ($rv, $disk_usage, $num_dirs, $num_files);
  }

  method monitor (
    Int() $flags,
    GCancellable() $cancellable    = GCancellable,
    CArray[Pointer[GError]] $error = gerror,
    :$raw = False
  ) {
    my GFileMonitorFlags $f = $flags;

    clear_error;
    my $mon = g_file_monitor($!file, $f, $cancellable, $error);
    set_error($error);

    $mon ??
      ( $raw ?? $mon !! GIO::FileMonitor.new($mon) )
      !!
      Nil;
  }

  method monitor_directory (
    Int() $flags,
    GCancellable() $cancellable    = GCancellable,
    CArray[Pointer[GError]] $error = gerror,
    :$raw = False
  )
    is also<monitor-directory>
  {
    my GFileMonitorFlags $f = $flags;

    clear_error;
    my $mon = g_file_monitor_directory($!file, $f, $cancellable, $error);
    set_error($error);

    $mon ??
      ( $raw ?? $mon !! GIO::FileMonitor.new($mon) )
      !!
      Nil;
  }

  method monitor_file (
    Int() $flags,
    GCancellable() $cancellable    = GCancellable,
    CArray[Pointer[GError]] $error = gerror,
    :$raw = False
  )
    is also<monitor-file>
  {
    my GFileMonitorFlags $f = $flags;

    clear_error;
    my $mon = g_file_monitor_file($!file, $f, $cancellable, $error);
    set_error($error);

    $mon ??
      ( $raw ?? $mon !! GIO::FileMonitor.new($mon) )
      !!
      Nil;
  }

  proto method mount_enclosing_volume (|)
    is also<mount-enclosing-volume>
  { * }

  multi method mount_enclosing_volume (
    Int() $flags,
    GMountOperation() $mount_operation,
    &callback,
    gpointer $user_data         = Pointer,
    GCancellable() $cancellable = GCancellable
  ) {
    samewith($flags, $mount_operation, $cancellable, &callback, $user_data);
  }
  multi method mount_enclosing_volume (
    Int() $flags,
    GMountOperation() $mount_operation,
    GCancellable() $cancellable,
    &callback,
    gpointer $user_data = Pointer
  ) {
    my GMountMountFlags $f = $flags;

    g_file_mount_enclosing_volume(
      $!file,
      $f,
      $mount_operation,
      $cancellable,
      &callback,
      $user_data
    );
  }

  method mount_enclosing_volume_finish (
    GAsyncResult() $result,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<mount-enclosing-volume-finish>
  {
    clear_error;
    my $rv = so g_file_mount_enclosing_volume_finish($!file, $result, $error);
    set_error($error);
    $rv;
  }

  method mount_mountable (
    Int() $flags,
    GMountOperation() $mount_operation,
    GCancellable() $cancellable,
    &callback,
    gpointer $user_data = Pointer
  )
    is also<mount-mountable>
  {
    my GMountMountFlags $f = $flags;

    g_file_mount_mountable(
      $!file,
      $f,
      $mount_operation,
      $cancellable,
      &callback,
      $user_data
    );
  }

  method mount_mountable_finish (
    GAsyncResult() $result,
    CArray[Pointer[GError]] $error = gerror,
    :$raw = False
  )
    is also<mount-mountable-finish>
  {
    clear_error;
    my $f = g_file_mount_mountable_finish($!file, $result, $error);
    set_error($error);

    $f ??
      ( $raw ?? $f !! GIO::Roles::File.new-file-obj($f) )
      !!
      Nil;
  }

  multi method move (
    GFile() $destination,
    Int() $flags,
    &progress_callback,
    gpointer $progress_callback_data = Pointer,
    GCancellable() $cancellable      = GCancellable,
    CArray[Pointer[GError]] $error   = gerror
  ) {
    samewith(
      $destination,
      $flags,
      $cancellable,
      &progress_callback,
      $progress_callback_data,
      $error
    );
  }
  multi method move (
    GFile() $destination,
    Int() $flags                     = G_FILE_COPY_NONE,
    GCancellable() $cancellable      = GCancellable,
    &progress_callback               = Callable,
    gpointer $progress_callback_data = Pointer,
    CArray[Pointer[GError]] $error   = gerror
  ) {
    my GFileCopyFlags $f = $flags;

    clear_error;
    my $rv = so g_file_move(
      $!file,
      $destination,
      $f,
      $cancellable,
      &progress_callback,
      $progress_callback_data,
      $error
    );
    set_error($error);
    $rv;
  }

  method open_readwrite (
    GCancellable() $cancellable    = GCancellable,
    CArray[Pointer[GError]] $error = gerror,
    :$raw = False
  )
    is also<open-readwrite>
  {
    clear_error;
    my $fios = g_file_open_readwrite($!file, $cancellable, $error);
    set_error($error);

    $fios ??
      ( $raw ?? $fios !! GIO::FileIOStream.new($fios) )
      !!
      Nil;
  }

  proto method open_readwrite_async (|)
    is also<open-readwrite-async>
  { * }

  multi method open_readwrite_async (
    Int() $io_priority,
    &callback,
    gpointer $user_data         = Pointer,
    GCancellable() $cancellable = GCancellable,
  ) {
    samewith($io_priority, $cancellable, &callback, $user_data);
  }
  multi method open_readwrite_async (
    Int() $io_priority,
    GCancellable() $cancellable,
    &callback,
    gpointer $user_data  = Pointer
  ) {
    my gint $io = $io_priority;

    g_file_open_readwrite_async(
      $!file,
      $io,
      $cancellable,
      &callback,
      $user_data
    );
  }

  method open_readwrite_finish (
    GAsyncResult() $res,
    CArray[Pointer[GError]] $error = gerror,
    :$raw = False
  )
    is also<open-readwrite-finish>
  {
    clear_error;
    my $fios = g_file_open_readwrite_finish($!file, $res, $error);
    set_error($error);

    $fios ??
      ( $raw ?? $fios !! GIO::FileIOStream.new($fios) )
      !!
      Nil;
  }

  method parse_name (
    GIO::Roles::File:U:
    Str() $name
  )
    is also<parse-name>
  {
    g_file_parse_name($name);
  }

  method peek_path is also<peek-path> {
    g_file_peek_path($!file);
  }

  method poll_mountable (
    GCancellable() $cancellable,
    &callback,
    gpointer $user_data = Pointer
  )
    is also<poll-mountable>
  {
    g_file_poll_mountable($!file, $cancellable, &callback, $user_data);
  }

  method poll_mountable_finish (
    GAsyncResult() $result,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<poll-mountable-finish>
  {
    clear_error;
    my $rc = g_file_poll_mountable_finish($!file, $result, $error);
    set_error($error);
    $rc;
  }

  method query_default_handler (
    GCancellable() $cancellable,
    CArray[Pointer[GError]] $error = gerror,
    :$raw = False
  )
    is also<query-default-handler>
  {
    clear_error;
    my $ai = g_file_query_default_handler($!file, $cancellable, $error);
    set_error($error);

    $ai ??
      ( $raw ?? $ai !! GIO::Roles::AppInfo.new-appinfo-obj($ai) )
      !!
      Nil;
  }

  method query_exists (GCancellable() $cancellable) is also<query-exists> {
    g_file_query_exists($!file, $cancellable);
  }

  method query_file_type (
    GFileQueryInfoFlags $flags,
    GCancellable() $cancellable
  )
    is also<query-file-type>
  {
    my guint $f = $flags;
    g_file_query_file_type($!file, $f, $cancellable);
  }

  method query_filesystem_info (
    Str() $attributes,
    GCancellable() $cancellable,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<query-filesystem-info>
  {
    g_file_query_filesystem_info($!file, $attributes, $cancellable, $error);
  }

  method query_filesystem_info_async (
    Str() $attributes,
    Int() $io_priority,
    GCancellable() $cancellable,
    &callback,
    gpointer $user_data = Pointer
  )
    is also<query-filesystem-info-async>
  {
    my gint $io = $io_priority;
    g_file_query_filesystem_info_async(
      $!file,
      $attributes,
      $io,
      $cancellable,
      &callback,
      $user_data
    );
  }

  method query_filesystem_info_finish (
    GAsyncResult() $res,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<query-filesystem-info-finish>
  {
    clear_error;
    my $rc = g_file_query_filesystem_info_finish($!file, $res, $error);
    set_error($error);
    $rc;
  }

  method query_info (
    Str() $attributes,
    GFileQueryInfoFlags $flags,
    GCancellable() $cancellable,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<query-info>
  {
    my guint $f = $flags;
    clear_error;
    my $rc = g_file_query_info($!file, $attributes, $f, $cancellable, $error);
    set_error($error);
    $rc;
  }

  method query_info_async (
    Str() $attributes,
    GFileQueryInfoFlags $flags,
    Int() $io_priority,
    GCancellable() $cancellable,
    &callback,
    gpointer $user_data = Pointer
  )
    is also<query-info-async>
  {
    my guint $f = $flags;
    my gint $io = $io_priority;
    g_file_query_info_async(
      $!file,
      $attributes,
      $f,
      $io,
      $cancellable,
      &callback,
      $user_data
    );
  }

  method query_info_finish (
    GAsyncResult() $res,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<query-info-finish>
  {
    clear_error;
    my $rc = g_file_query_info_finish($!file, $res, $error);
    set_error($error);
    $rc;
  }

  method query_settable_attributes (
    GCancellable() $cancellable,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<query-settable-attributes>
  {
    clear_error;
    my $rc = g_file_query_settable_attributes($!file, $cancellable, $error);
    set_error($error);
    $rc;
  }

  method query_writable_namespaces (
    GCancellable() $cancellable,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<query-writable-namespaces>
  {
    clear_error;
    my $rc = g_file_query_writable_namespaces($!file, $cancellable, $error);
    set_error($error);
    $rc;
  }

  method read (
    GCancellable() $cancellable    = GCancellable,
    CArray[Pointer[GError]] $error = gerror
  ) {
    clear_error;
    my $rc = g_file_read($!file, $cancellable, $error);
    set_error($error);
    $rc;
  }

  method read_async (
    Int() $io_priority,
    GCancellable() $cancellable,
    &callback,
    gpointer $user_data
  )
    is also<read-async>
  {
    g_file_read_async(
      $!file, $io_priority, $cancellable, &callback, $user_data
    );
  }

  method read_finish (
    GAsyncResult() $res,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<read-finish>
  {
    clear_error;
    my $rc = g_file_read_finish($!file, $res, $error);
    set_error($error);
    $rc;
  }

  method replace (
    Str() $etag                    = Str,
    Int() $make_backup             = False,
    Int() $flags                   = G_FILE_CREATE_NONE,
    GCancellable() $cancellable    = GCancellable,
    CArray[Pointer[GError]] $error = gerror,
    :$raw = True
  ) {
    my gboolean $m = $make_backup.so.Int;
    my GFileCreateFlags $f = $flags;

    clear_error;
    my $fos = g_file_replace($!file, $etag, $m, $f, $cancellable, $error);
    set_error($error);

    $fos ??
      ( $raw ?? $fos !! GIO::FileOutputStream.new($fos) )
      !!
      Nil;

  }

  method replace_async (
    Str() $etag,
    Int() $make_backup,
    Int() $flags,
    Int() $io_priority,
    GCancellable() $cancellable,
    &callback,
    gpointer $user_data = Pointer,
    :$raw = False
  )
    is also<replace-async>
  {
    my gboolean $m = $make_backup.so.Int;
    my GFileCreateFlags $f = $flags;
    my gint $io = $io_priority;
    my $fos = g_file_replace_async(
      $!file,
      $etag,
      $m,
      $f,
      $io,
      $cancellable,
      &callback,
      $user_data
    );

    $fos ??
      ( $raw ?? $fos !! GIO::FileOutputStream.new($fos) )
      !!
      Nil;
  }

  method replace_contents (
    Str() $contents,
    Int() $length,
    Str() $etag,
    Int() $make_backup,
    Int() $flags,
    Str() $new_etag,
    GCancellable() $cancellable,
    CArray[Pointer[GError]] $error = gerror,
    :$raw = False
  )
    is also<replace-contents>
  {
    my gboolean $m = $make_backup.so.Int;
    my GFileCreateFlags $f = $flags;
    my gsize $l = $length;

    clear_error;
    my $fos = g_file_replace_contents(
      $!file,
      $contents,
      $l,
      $etag,
      $m,
      $f,
      $new_etag,
      $cancellable,
      $error
    );
    set_error($error);

    $fos ??
      ( $raw ?? $fos !! GIO::FileOutputStream.new($fos) )
      !!
      Nil;
  }

  method replace_contents_async (
    Str() $contents,
    Int() $length,
    Str() $etag,
    Int() $make_backup,
    Int() $flags,
    GCancellable() $cancellable,
    &callback,
    gpointer $user_data = Pointer
  )
    is also<replace-contents-async>
  {
    my gboolean $m = $make_backup.so.Int;
    my GFileCreateFlags $f = $flags;
    my gsize $l = $length;

    g_file_replace_contents_async(
      $!file,
      $contents,
      $l,
      $etag,
      $m,
      $f,
      $cancellable,
      &callback,
      $user_data
    );
  }

  method replace_contents_bytes_async (
    GBytes() $contents,
    Str() $etag,
    Int() $make_backup,
    Int() $flags,
    GCancellable() $cancellable,
    &callback,
    gpointer $user_data = Pointer
  )
    is also<replace-contents-bytes-async>
  {
    my gboolean $m = $make_backup.so.Int;
    my GFileCreateFlags $f = $flags;

    g_file_replace_contents_bytes_async(
      $!file,
      $contents,
      $etag,
      $make_backup,
      $f,
      $cancellable,
      &callback,
      $user_data
    );
  }

  method replace_contents_finish (
    GAsyncResult() $res,
    Str() $new_etag,
    CArray[Pointer[GError]] $error = gerror,
    :$raw = False
  )
    is also<replace-contents-finish>
  {
    clear_error;
    my $fos = g_file_replace_contents_finish($!file, $res, $new_etag, $error);
    set_error($error);

    $fos ??
      ( $raw ?? $fos !! GIO::FileOutputStream.new($fos) )
      !!
      Nil;
  }

  method replace_finish (
    GAsyncResult() $res,
    CArray[Pointer[GError]] $error = gerror,
    :$raw = False
  )
    is also<replace-finish>
  {
    clear_error;
    my $fos = g_file_replace_finish($!file, $res, $error);
    set_error($error);

    $fos ??
      ( $raw ?? $fos !! GIO::FileOutputStream.new($fos) )
      !!
      Nil;
  }

  method replace_readwrite (
    Str() $etag,
    Int() $make_backup,
    Int() $flags,
    GCancellable() $cancellable,
    CArray[Pointer[GError]] $error = gerror,
    :$raw = False
  )
    is also<replace-readwrite>
  {
    my gboolean $m = $make_backup.so.Int;
    my GFileCreateFlags $f = $flags;

    clear_error;
    my $fis = g_file_replace_readwrite(
      $!file,
      $etag,
      $make_backup,
      $f,
      $cancellable,
      $error
    );
    set_error($error);

    $fis ??
      ( $raw ?? $fis !! GIO::FileIOStream.new($fis) )
      !!
      Nil;
  }

  method replace_readwrite_async (
    Str() $etag,
    Int() $make_backup,
    Int() $flags,
    Int() $io_priority,
    GCancellable() $cancellable,
    &callback,
    gpointer $user_data = Pointer
  )
    is also<replace-readwrite-async>
  {
    my GFileCreateFlags $f = $flags;
    my gint $io = $io_priority;
    my gboolean $m = $make_backup.so.Int;

    g_file_replace_readwrite_async(
      $!file,
      $etag,
      $m,
      $f,
      $io,
      $cancellable,
      &callback,
      $user_data
    );
  }

  method replace_readwrite_finish (
    GAsyncResult() $res,
    CArray[Pointer[GError]] $error = gerror,
    :$raw = False
  )
    is also<replace-readwrite-finish>
  {
    clear_error;
    my $fios = g_file_replace_readwrite_finish($!file, $res, $error);
    set_error($error);

    $fios ??
      ( $raw ?? $fios !! GIO::FileIOStream.new($fios) )
      !!
      Nil;
  }

  method resolve_relative_path (Str() $relative_path)
    is also<resolve-relative-path>
  {
    g_file_resolve_relative_path($!file, $relative_path);
  }

  method set_attribute (
    Str() $attribute,
    Int() $type,
    gpointer $value_p,
    Int() $flags,
    GCancellable() $cancellable    = GCancellable,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<set-attribute>
  {
    my GFileAttributeType $t = $type,
    my GFileQueryInfoFlags $f = $flags;

    clear_error;
    my $rv = so g_file_set_attribute(
      $!file,
      $attribute,
      $t,
      $value_p,
      $f,
      $cancellable,
      $error
    );
    set_error($error);
    $rv;
  }

  method set_attribute_byte_string (
    Str() $attribute,
    Str() $value,
    Int() $flags,
    GCancellable() $cancellable    = GCancellable,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<set-attribute-byte-string>
  {
    my GFileQueryInfoFlags $f = $flags;

    clear_error;
    my $rv = so g_file_set_attribute_byte_string(
      $!file,
      $attribute,
      $value,
      $f,
      $cancellable,
      $error
    );
    set_error($error);
    $rv;
  }

  method set_attribute_int32 (
    Str() $attribute,
    Int() $value,
    Int() $flags,
    GCancellable() $cancellable    = GCancellable,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<set-attribute-int32>
  {
    my guint $f = $flags;
    my gint32 $v = $value;

    clear_error;
    my $rv = so g_file_set_attribute_int32(
      $!file,
      $attribute,
      $v,
      $f,
      $cancellable,
      $error
    );
    set_error($error);
    $rv;
  }

  method set_attribute_int64 (
    Str() $attribute,
    Int() $value,
    Int() $flags,
    GCancellable() $cancellable    = GCancellable,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<set-attribute-int64>
  {
    my GFileQueryInfoFlags $f = $flags;
    my gint64 $v = $value;

    my $rv = so g_file_set_attribute_int64(
      $!file,
      $attribute,
      $v,
      $f,
      $cancellable,
      $error
    );
    set_error($error);
    $rv;
  }

  method set_attribute_string (
    Str() $attribute,
    Str() $value,
    Int() $flags,
    GCancellable() $cancellable,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<set-attribute-string>
  {
    my GFileQueryInfoFlags $f = $flags;

    clear_error;
    my $rv = so g_file_set_attribute_string(
      $!file,
      $attribute,
      $value,
      $f,
      $cancellable,
      $error
    );
    set_error($error);
    $rv;
  }

  method set_attribute_uint32 (
    Str() $attribute,
    Int() $value,
    Int() $flags,
    GCancellable() $cancellable    = GCancellable,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<set-attribute-uint32>
  {
    my guint $f = $flags;
    my guint32 $v = $value;

    clear_error;
    my $rv = g_file_set_attribute_uint32(
      $!file,
      $attribute,
      $v,
      $f,
      $cancellable,
      $error
    );
    set_error($error);
    $rv;
  }

  method set_attribute_uint64 (
    Str() $attribute,
    Int() $value,
    Int() $flags,
    GCancellable() $cancellable    = GCancellable,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<set-attribute-uint64>
  {
    my GFileQueryInfoFlags $f = $flags;
    my guint64 $v = $value;
    clear_error;

    my $rv = so g_file_set_attribute_uint64(
      $!file,
      $attribute,
      $v,
      $f,
      $cancellable,
      $error
    );
    set_error($error);
    $rv;
  }

  proto method set_attributes_async (|)
    is also<set-attributes-async>
  { * }

  multi method set_attributes_async (
    GFileInfo() $info,
    Int() $flags,
    Int() $io_priority,
    &callback,
    gpointer $user_data         = Pointer,
    GCancellable() $cancellable = GCancellable
  ) {
    samewith($info, $flags, $io_priority, $cancellable, &callback, $user_data);
  }
  multi method set_attributes_async (
    GFileInfo() $info,
    Int() $flags,
    Int() $io_priority,
    GCancellable() $cancellable,
    &callback,
    gpointer $user_data = Pointer
  ) {
    my GFileQueryInfoFlags $f = $flags;
    my gint $io = $io_priority;

    g_file_set_attributes_async(
      $!file,
      $info,
      $f,
      $io,
      $cancellable,
      &callback,
      $user_data
    );
  }

  proto method set_attributes_finish (|)
    is also<set-attributes-finish>
  { * }

  multi method set_attributes_finish (
    GAsyncResult() $result,
    CArray[Pointer[GError]] $error = gerror,
  ) {
    my $rv = samewith($result, $, $error, :all);
    $rv[0] ?? $rv.skip(1) !! Nil;
  }
  multi method set_attributes_finish (
    GAsyncResult() $result,
    $info is rw,
    CArray[Pointer[GError]] $error = gerror,
    :$all = False
  ) {
    my $i = CArray[Pointer[GFileInfo]].new;
    $i[0] = Pointer[GFileInfo].new;

    clear_error;
    my $rv = so g_file_set_attributes_finish($!file, $result, $info, $error);
    set_error($error);
    $info = ppr($i);
    $all.not ?? $rv !! ($rv, $info)
  }

  method set_attributes_from_info (
    GFileInfo() $info,
    Int() $flags,
    GCancellable() $cancellable    = GCancellable,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<set-attributes-from-info>
  {
    my GFileQueryInfoFlags $f = $flags;

    clear_error;
    my $rv = so g_file_set_attributes_from_info(
      $!file,
      $info,
      $flags,
      $cancellable,
      $error
    );
    set_error($error);
    $rv;
  }

  method set_display_name (
    Str() $display_name,
    GCancellable() $cancellable    = GCancellable,
    CArray[Pointer[GError]] $error = gerror,
    :$raw = False
  )
    is also<set-display-name>
  {
    clear_error;
    my $f = g_file_set_display_name(
      $!file,
      $display_name,
      $cancellable,
      $error
    );
    set_error($error);

    $f ??
      ( $raw ?? $f !! GIO::Roles::File.new-file-obj($f) )
      !!
      Nil;
  }

  proto method set_display_name_async (|)
    is also<set-display-name-async>
  { * }

  multi method set_display_name_async (
    Str() $display_name,
    Int() $io_priority,
    &callback,
    gpointer $user_data = Pointer,
    GCancellable() $cancellable = GCancellable
  ) {
    samewith($display_name, $io_priority, $cancellable, &callback, $user_data);
  }
  multi method set_display_name_async (
    Str() $display_name,
    Int() $io_priority,
    GCancellable() $cancellable,
    &callback,
    gpointer $user_data = Pointer
  ) {
    my gint $io = $io_priority;

    g_file_set_display_name_async(
      $!file,
      $display_name,
      $io,
      $cancellable,
      &callback,
      $user_data
    );
  }

  method set_display_name_finish (
    GAsyncResult() $res,
    CArray[Pointer[GError]] $error = gerror,
    :$raw = False
  )
    is also<set-display-name-finish>
  {
    clear_error;
    my $f = g_file_set_display_name_finish($!file, $res, $error);
    set_error($error);

    $f ??
      ( $raw ?? $f !! GIO::Roles::File.new-file-obj($f) )
      !!
      Nil;
  }

  proto method start_mountable (|)
    is also<start-mountable>
  { * }

  multi method start_mountable (
    Int() $flags,
    GMountOperation() $start_operation,
    &callback,
    gpointer $user_data         = Pointer,
    GCancellable() $cancellable = GCancellable
  ) {
    samewith($flags, $start_operation, $cancellable, &callback, $user_data);
  }
  multi method start_mountable (
    Int() $flags,
    GMountOperation() $start_operation,
    GCancellable() $cancellable,
    &callback,
    gpointer $user_data = Pointer
  ) {
    my GDriveStartFlags $f = $flags;

    so g_file_start_mountable(
      $!file,
      $f,
      $start_operation,
      $cancellable,
      &callback,
      $user_data
    );
  }

  method start_mountable_finish (
    GAsyncResult() $result,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<start-mountable-finish>
  {
    clear_error;
    my $rv = so g_file_start_mountable_finish($!file, $result, $error);
    set_error($error);
    $rv;
  }

  proto method stop_mountable (|)
    is also<stop-mountable>
  { * }

  multi method stop_mountable (
    Int() $flags,
    GMountOperation() $mount_operation,
    &callback,
    gpointer $user_data         = Pointer,
    GCancellable() $cancellable = GCancellable
  ) {
    samewith($flags, $mount_operation, $cancellable, &callback, $user_data);
  }
  multi method stop_mountable (
    Int() $flags,
    GMountOperation() $mount_operation,
    GCancellable() $cancellable,
    &callback,
    gpointer $user_data = Pointer
  ) {
    my GMountUnmountFlags $f = $flags;

    g_file_stop_mountable(
      $!file,
      $f,
      $mount_operation,
      $cancellable,
      &callback,
      $user_data
    );
  }

  multi method stop_mountable_finish (
    GAsyncResult() $result,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<stop-mountable-finish>
  {
    clear_error;
    my $rv = so g_file_stop_mountable_finish($!file, $result, $error);
    set_error($error);
    $rv;
  }

  method supports_thread_contexts is also<supports-thread-contexts> {
    so g_file_supports_thread_contexts($!file);
  }

  method trash (
    GCancellable() $cancellable,
    CArray[Pointer[GError]] $error = gerror
  ) {
    clear_error;
    my $rc = g_file_trash($!file, $cancellable, $error);
    set_error($error);
    $rc;
  }


  proto method trash_async (|)
    is also<trash-async>
  { * }

  multi method trash_async (
    Int() $io_priority,
    &callback,
    gpointer $user_data         = Pointer,
    GCancellable() $cancellable = GCancellable
  ) {
    samewith($io_priority, $cancellable, &callback, $user_data);
  }
  multi method trash_async (
    Int() $io_priority,
    GCancellable() $cancellable,
    &callback,
    gpointer $user_data = Pointer
  ) {
    my gint $io = $io_priority;

    g_file_trash_async(
      $!file,
      $io,
      $cancellable,
      &callback,
      $user_data
    );
  }

  method trash_finish (
    GAsyncResult() $result,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<trash-finish>
  {
    clear_error;
    my $rv = so g_file_trash_finish($!file, $result, $error);
    set_error($error);
    $rv;
  }

  # method unmount_mountable (
  #   GMountUnmountFlags $flags,
  #   GCancellable $cancellable,
  #   &callback,
  #   gpointer $user_data = Pointer
  # )
  #   is also<unmount-mountable>
  # {
  #   my gint $f = $flags;
  #   g_file_unmount_mountable($!file, $f, $cancellable, &callback, $user_data);
  # }
  #
  # method unmount_mountable_finish (
  #   GAsyncResult() $result,
  #   CArray[Pointer[GError]] $error = gerror
  # )
  #   is also<unmount-mountable-finish>
  # {
  #   clear_error;
  #   my $rc = g_file_unmount_mountable_finish($!file, $result, $error);
  #   set_error($error);
  #   $rc;
  # }


  proto method unmount_mountable_with_operation (|)
    is also<unmount-mountable-with-operation>
  { * }

  multi method unmount_mountable_with_operation (
    Int() $flags,
    GMountOperation() $mount_operation,
    GAsyncReadyCallback &callback,
    gpointer $user_data         = Pointer,
    GCancellable() $cancellable = GCancellable
  ) {
    samewith($flags, $mount_operation, $cancellable, &callback, $user_data);
  }
  multi method unmount_mountable_with_operation (
    Int() $flags,
    GMountOperation() $mount_operation,
    GCancellable() $cancellable,
    GAsyncReadyCallback &callback,
    gpointer $user_data = Pointer
  ) {
    my GMountUnmountFlags $f = $flags;

    g_file_unmount_mountable_with_operation(
      $!file,
      $f,
      $mount_operation,
      $cancellable,
      &callback,
      $user_data
    );
  }

  method unmount_mountable_with_operation_finish (
    GAsyncResult() $result,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<unmount-mountable-with-operation-finish>
  {
    clear_error;
    my $rv = so g_file_unmount_mountable_with_operation_finish(
      $!file,
      $result,
      $error
    );
    set_error($error);
    $rv;
  }

}

# Compatibility with old name.
package GIO::Roles {
  our constant GFile := GIO::Roles::File;
}
