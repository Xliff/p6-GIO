use v6.c;

use Method::Also;

use GIO::Raw::Types;
use GIO::Raw::UnixOutputStream;

use GIO::OutputStream;

use GIO::Roles::FileDescriptorBased;
use GIO::Roles::PollableOutputStream;

our subset GUnixOutputStreamAncestry is export of Mu
  where GUnixOutputStream | GFileDescriptorBased | GPollableOutputStream |
        GOutputStream;

class GIO::Unix::OutputStream is GIO::OutputStream {
  also does GIO::Roles::FileDescriptorBased;
  also does GIO::Roles::PollableOutputStream;

  has GUnixOutputStream $!uos is implementor;

  submethod BUILD (:$unix-stream) {
    self.setGUnixOutputStream($unix-stream) if $unix-stream;
  }

  method setGUnixOutputStream (GUnixOutputStreamAncestry $_) {
    my $to-parent;

    $!uos = do {
      when GUnixOutputStream {
        $to-parent = cast(GOutputStream, $_);
        $_;
      }

      when GFileDescriptorBased {
        $to-parent = cast(GOutputStream, $_);
        $!fdb = $_;
        cast(GUnixOutputStream, $_);
      }

      when GPollableOutputStream {
        $to-parent = cast(GOutputStream, $_);
        $!pos = $_;
        cast(GUnixOutputStream, $_);
      }

      default {
        $to-parent = $_;
        cast(GUnixOutputStream, $_);
      }
    }
    self.setOutputStream($to-parent);
    self.roleInit-FileDescriptorBased;
    self.roleInit-GPollableOutputStream;
  }

  multi method new (GUnixOutputStreamAncestry $unix-stream, :$ref = True) {
    return Nil unless $unix-stream;

    my $o = self.bless( :$unix-stream );
    $o.ref if $ref;
    $o;
  }
  multi method new (Int() $fd, Int() $close_fd) {
    my gint     $f           = $fd;
    my gboolean $cfd         = $close_fd.so.Int;
    my          $unix-stream = g_unix_output_stream_new($f, $cfd);

    $unix-stream ?? self.bless( :$unix-stream ) !! Nil;
  }

  method GIO::Raw::Definitions::GUnixOutputStream
    is also<GUnixOutputStream>
  { $!uos }

  method close_fd is rw is also<close-fd> {
    Proxy.new(
      FETCH => -> $             { self.get_close_fd      },
      STORE => -> $, Int() \cfd { self.set_close_fd(cfd) };
    );
  }

  method get_close_fd {
    so g_unix_output_stream_get_close_fd($!uos);
  }

  method get_fd
    is also<
      get-fd
      fd
    >
  {
    g_unix_output_stream_get_fd($!uos);
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_unix_output_stream_get_type, $n, $t );
  }

  method set_close_fd (Int() $close_fd) {
    my gboolean $c = $close_fd.so.Int;

    g_unix_output_stream_set_close_fd($!uos, $c);
  }

}
