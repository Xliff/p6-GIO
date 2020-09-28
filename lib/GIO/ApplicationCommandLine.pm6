use v6.c;

use Method::Also;

use GIO::Raw::Types;
use GIO::Raw::ApplicationCommandLine;

use GLib::VariantDict;
use GIO::InputStream;

use GLib::Roles::Object;
use GIO::Roles::GFile;

our subset GApplicationCommandLineAncestry is export of Mu
  where GApplicationCommandLine | GObject;

class GIO::ApplicationCommandLine {
  also does GLib::Roles::Object;

  has GApplicationCommandLine $!cl is implementor;

  submethod BUILD (:$command-line) {
    self.setGApplicationCommandLine($command-line) if $command-line;
  }

  method setGApplicationCommandLine (GApplicationCommandLine $_) {
    my $to-parent;

    $!cl = {
      when GApplicationCommandLine {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GApplicationCommandLine, $_);
      }
    }
    self!setObject($to-parent);
  }

  method GIO::Raw::Definitions::GApplicationCommandLine
    is also<GApplicationCommandLine>
  { * }

  method new (GApplicationCommandLineAncestry $command-line, :$ref = True) {
    return Nil unless $command-line;

    my $o = self.bless( :$command-line );
    $o.ref if $ref;
    $o;
  }

  method create_file_for_arg (Str() $arg, :$raw = False)
    is also<create-file-for-arg>
  {
    my $f = g_application_command_line_create_file_for_arg($!cl, $arg);

    $f ??
      ( $raw ?? $f !! GIO::Roles::GFile.new-file-obj($f, :!ref) )
      !!
      Nil;
  }

  method get_arguments ($argc is rw) is also<get-arguments> {
    my gint $a = 0;
    my $al = g_application_command_line_get_arguments($!cl, $a);

    $al ?? CStringArrayToArray($al) !! Nil;
  }

  method get_cwd is also<get-cwd> {
    g_application_command_line_get_cwd($!cl);
  }

  method get_environ is also<get-environ> {
    my $el = g_application_command_line_get_environ($!cl);

    $el ?? CStringArrayToArray($el) !! Nil;
  }

  method get_exit_status is also<get-exit-status> {
    g_application_command_line_get_exit_status($!cl);
  }

  method get_is_remote is also<get-is-remote> {
    so g_application_command_line_get_is_remote($!cl);
  }

  method get_options_dict (:$raw = False) is also<get-options-dict> {
    my $v = g_application_command_line_get_options_dict($!cl);

    $v ??
      ( $raw ?? $v !! GLib::VariantDict.new($v, :ref) )
      !!
      Nil;
  }

  method get_platform_data (:$raw = False) is also<get-platform-data> {
    my $v = g_application_command_line_get_platform_data($!cl);

    $v ??
      ( $raw ?? $v !! GLib::Variant.new($v, :ref) )
      !!
      Nil;
  }

  method get_stdin (:$raw = False) is also<get-stdin> {
    my $is = g_application_command_line_get_stdin($!cl);

    $is ??
      ( $raw ?? $is !! GIO::InputStream.new($is, :!ref) )
      !!
      Nil;
  }

  method getenv (Str() $name) {
    g_application_command_line_getenv($!cl, $name);
  }

  method set_exit_status (Int() $exit_status) is also<set-exit-status> {
    my gint $e = $exit_status;

    g_application_command_line_set_exit_status($!cl, $e);
  }

}
