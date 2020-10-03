use v6.c;

use Method::Also;
use NativeCall;

use GIO::Raw::Types;

use GLib::Roles::Object;
use GIO::Roles::GFile;
use GIO::Roles::Icon;
use GIO::Roles::LoadableIcon;

our subset GFileIconAncestry is export of Mu
  where GFileIcon | GLoadableIcon | GIcon | GObject;

class GIO::FileIcon {
  also does GLib::Roles::Object;
  also does GIO::Roles::Icon;
  also does GIO::Roles::LoadableIcon;

  has GFileIcon $!fi is implementor;

  submethod BUILD (:$fileicon) {
    self.setGFileIcon($fileicon) if $fileicon;
  }

  method setGFileIcon (GFileIconAncestry $_) {
    my $to-parent;

    $!fi = do {
      when GFileIcon {
        $to-parent = cast(GObject, $_);
        $_;
      }

      when GIcon {
        $to-parent = cast(GObject, $_);
        $!icon = $_;
        cast(GFileIcon, $_);
      }

      when GLoadableIcon {
        $to-parent = cast(GObject, $_);
        $!li = $_;
        cast(GFileIcon, $_);
      }

      default {
        $to-parent = $_;
        cast(GFileIcon, $_);
      }
    }

    self.roleInit-Icon;
    self.roleInit-LoadableIcon;
  }

  method GIO::Raw::Definitions::GFileIcon
    is also<GFileIcon>
  { $!fi }

  multi method new (GFileIconAncestry $fileicon, :$ref = True) {
    return Nil unless $fileicon;

    my $o = self.bless( :$fileicon );
    $o.ref if $ref;
    $o;
  }
  multi method new (GFile() $icon) {
    my $fileicon = g_file_icon_new($icon);

    $fileicon ?? self.bless( :$fileicon ) !! Nil;
  }

  method get_file (:$raw = False)
    is also<
      get-file
      file
    >
  {
    my $f = g_file_icon_get_file($!fi);

    $f ??
      ( $raw ?? $f !! GIO::Roles::GFile.new-file-obj($f, :!ref) )
      !!
      Nil;
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_file_icon_get_type, $n, $t );
  }

}

sub g_file_icon_get_file (GFileIcon $icon)
  returns GFile
  is native(gio)
  is export
{ * }

sub g_file_icon_get_type ()
  returns GType
  is native(gio)
  is export
{ * }

sub g_file_icon_new (GFile $file)
  returns GFileIcon
  is native(gio)
  is export
{ * }

# our %GIO::FileIcon::RAW-DEFS;
# for MY::.pairs {
#   %GIO::FileIcon::RAW-DEFS{.key} := .value if .key.starts-with('&g_file_icon_');
# }
