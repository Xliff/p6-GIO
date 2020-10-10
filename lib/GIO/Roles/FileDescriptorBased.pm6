use v6.c;

use Method::Also;
use NativeCall;

use GIO::Raw::Types;

use GLib::Roles::Object;

role GIO::Roles::FileDescriptorBased does GLib::Roles::Object {
  has GFileDescriptorBased $!fdb;

  method GIO::Raw::Definitions::GFileDescriptorBased
    is also<GFileDescriptorBased>
  { $!fdb }

  method roleInit-FileDescriptorBased is also<roleInit_FileDescriptorBased> {
    return if $!fdb;

    my \i = findProperImplementor(self.^attributes);
    $!fdb = cast( GFileDescriptorBased, i.get_value(self) );
  }

  method role_get_fd is also<role-get-fd> {
    g_file_descriptor_based_get_fd($!fdb);
  }

  method filedescriptorbased_get_type is also<filedescriptorbased-get-type> {
    g_file_descriptor_based_get_type();
  }

}

our subset GFileDescriptorBasedAncestry is export
  where GFileDescriptorBased | GObject;

class GIO::FileDescriptorBased does GIO::Roles::FileDescriptorBased {

  submethod BUILD (:$descriptor-based) {
    self.setGFileDescriptorBased($descriptor-based) if $descriptor-based;
  }
  
  method setGFileDescriptorBased (GFileDescriptorBasedAncestry $_) {
    my $to-parent;

    $!fdb = do {
      when GFileDescriptorBased {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GFileDescriptorBased, $_);
      }
    }
    self!setObject($to-parent);
  }

  method new (
    GFileDescriptorBasedAncestry $descriptor-based,
                                 :$ref              = True
  ) {
    return Nil unless $descriptor-based;

    # Cannot compose BUILD, so it is done, here.
    my $o = self.bless;
    $o.setGFileDescriptorBased($descriptor-based);
    $o.ref if $ref;
    $o;
  }

}


sub g_file_descriptor_based_get_fd (GFileDescriptorBased $fd_based)
  returns gint
  is native(gio)
  is export
{ * }

sub g_file_descriptor_based_get_type ()
  returns GType
  is native(gio)
  is export
{ * }

# our %GIO::Roles::FileDescriptorBased::RAW-DEFS;
# for MY::.pairs {
#   %GIO::Roles::FileDescriptorBased::RAW-DEFS{.key} := .value
#     if .key.starts-with('&g_file_descriptor_based_');
# }
