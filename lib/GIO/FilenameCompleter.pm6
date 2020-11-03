use v6.c;

use Method::Also;

use NativeCall;

use GIO::Raw::Types;
use GIO::Raw::FilenameCompleter;

use GLib::Roles::Object;

our subset GFilenameCompleterAncestry is export of Mu
  where GFilenameCompleter | GObject;

class GIO::FilenameCompleter {
  also does GLib::Roles::Object;

  has GFilenameCompleter $!fc is implementor;

  submethod BUILD (:$completer) {
    self.setGFilenameCompleter($completer) if $completer;
  }

  method setGFilenameCompleter (GFilenameCompleterAncestry $_) {
    my $to-parent;

    $!fc = do {
      when GFilenameCompleter {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GFilenameCompleter, $_);
      }
    }
    self!setObject($to-parent);
  }

  method GIO::Raw::Definitions::GFilenameCompleter
    is also<GFilenameCompleter>
  { $!fc }

  multi method new (GFilenameCompleterAncestry $completer, :$ref = True) {
    return Nil unless $completer;

    my $o = self.bless( :$completer );
    $o.ref if $ref;
    $o;
  }
  multi method new {
    my $completer = g_filename_completer_new();

    $completer ?? self.bless( :$completer ) !! Nil;
  }

  method get_completion_suffix (Str() $initial_text)
    is also<get-completion-suffix>
  {
    g_filename_completer_get_completion_suffix($!fc, $initial_text);
  }

  method get_completions (Str() $initial_text) is also<get-completions> {
    CStringArrayToArray(
      g_filename_completer_get_completions($!fc, $initial_text)
    );
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_filename_completer_get_type, $n, $t );
  }

  method set_dirs_only (Int() $dirs_only) is also<set-dirs-only> {
    my gboolean $d = $dirs_only.so.Int;

    g_filename_completer_set_dirs_only($!fc, $d);
  }

}
