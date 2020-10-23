use v6.c;

use Method::Also;
use NativeCall;

use GIO::Raw::Types;

use GLib::Value;

use GLib::Roles::Object;

role GIO::Roles::TlsFileDatabase {
  has GTlsFileDatabase $!tfd;

  method roleInit-TlsFileDatabase is also<roleInit_TlsFileDatabase> {
    die 'Must use GLib::Roles::Properties!'
      unless self ~~ GLib::Roles::Properties;
    return if $!tfd;

    my \i = findProperImplementor(self.^attributes);

    $!tfd = cast( GTlsFileDatabase, i.get_value(self) );
  }

  method GIO::Raw::Definitions::GTlsFileDatabase
    is also<GTlsFileDatabase>
  { $!tfd }

  # Type: Str
  method anchors is rw  {
    my GLib::Value $gv .= new( G_TYPE_STRING );
    Proxy.new(
      FETCH => -> $ {
        $gv = GLib::Value.new(
          self.prop_get('anchors', $gv)
        );
        $gv.string;
      },
      STORE => -> $, Str() $val is copy {
        $gv.string = $val;
        self.prop_set('anchors', $gv);
      }
    );
  }

  method get_tlsfiledatabase_type is also<get-tlsfiledatabase-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_tls_file_database_get_type, $n, $t );
  }

}

our subset GTlsFileDatabaseAncestry is export of Mu
  where GTlsFileDatabase | GObject;

class GIO::TlsFileDatabase does GLib::Roles::Object
                           does GIO::Roles::TlsFileDatabase
{

  submethod BUILD (:$file-database) {
    self.setGTlsFileDatabase($file-database) if $file-database;
  }

  method setGTlsFileDatabase (GTlsFileDatabaseAncestry $_) {
    my $to-parent;

    $!tfd = do {
      when GTlsFileDatabase {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GTlsFileDatabase, $_);
      }
    }
    self!setObject($to-parent);
  }


  proto method new (|)
      is also<new_tlsfiledatabase_obj>
  { * }

  multi method new (
    GTlsFileDatabase $file-database,
                     :$ref = True
  ) {
    return Nil unless $file-database;

    my $o = self.bless( :$file-database );
    $o.ref if $ref;
    $o;
  }
  multi method new (
    Str()                   $anchor-file,
    CArray[Pointer[GError]] $error = gerror
  ) {
    clear_error;
    my $file-database = g_tls_file_database_new($anchor-file, $error);
    set_error($error);
    $file-database ?? self.bless( :$file-database ) !! Nil;
  }

}

sub g_tls_file_database_get_type ()
  returns GType
  is native(gio)
  is export
{ * }

sub g_tls_file_database_new (Str $anchors, CArray[Pointer[GError]] $error)
  returns GTlsDatabase
  is native(gio)
  is export
{ * }

# our %GIO::Roles::TlsFileDatabase::RAW-DEFS;
# for MY::.pairs {
#   %GIO::Roles::TlsFileDatabase::RAW-DEFS{.key} := .value
#     if .key.starts-with('&g_tls_file_database_');
# }
