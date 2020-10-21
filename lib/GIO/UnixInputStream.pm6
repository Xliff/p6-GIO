use v6.c;

use Method::Also;

use GIO::Raw::Types;
use GIO::Raw::UnixInputStream;

use GIO::InputStream;

use GIO::Roles::FileDescriptorBased;
use GIO::Roles::PollableInputStream;

our subset GUnixInputStreamAncestry is export of Mu
  where GUnixInputStream | GFileDescriptorBased | GPollableInputStream |
        GInputStream;

class GIO::UnixInputStream is GIO::InputStream {
  also does GIO::Roles::FileDescriptorBased;
  also does GIO::Roles::PollableInputStream;

  has GUnixInputStream $!uis is implementor;

  submethod BUILD (:$unix-stream) {
    self.setGUnixInputStream($unix-stream) if $unix-stream;
  }

  method setGUnixInputStream (GUnixInputStreamAncestry $_) {
    my $to-parent;

    $!uis = do {
      when GUnixInputStream {
        $to-parent = cast(GInputStream, $_);
        $_;
      }

      when GFileDescriptorBased {
        $to-parent = cast(GInputStream, $_);
        $!fdb = $_;
        cast(GUnixInputStream, $_);
      }

      when GPollableInputStream {
        $to-parent = cast(GInputStream, $_);
        $!pis = $_;
        cast(GUnixInputStream, $_);
      }

      default {
        $to-parent = $_;
        cast(GUnixInputStream, $_);
      }
    }
    self.setInputStream($to-parent);
    self.roleInit-FileDescriptorBased;
    self.roleInit-GPollableInputStream;
  }

  multi method new (GUnixInputStreamAncestry $unix-stream, :$ref = True) {
    return Nil unless $unix-stream;

    my $o = self.bless( :$unix-stream );
    $o.ref if $ref;
    $o;
  }
  multi method new (Int() $fd, Int() $close_fd) {
    my gint     $f           = $fd;
    my gboolean $cfd         = $close_fd.so.Int;
    my          $unix-stream = g_unix_input_stream_new($f, $cfd);

    $unix-stream ?? self.bless( :$unix-stream ) !! Nil;
  }

  method GIO::Raw::Definitions::GUnixInputStream
    is also<GUnixInputStream>
  { $!uis }

  method close_fd is also<close-fd> is rw {
    Proxy.new:
      FETCH => -> $           { self.get_close_fd      },
      STORE => -> $, Int \cfd { self.set_close_fd(cfd) };
  }

  method get_close_fd is also<get-close-fd> {
    so g_unix_input_stream_get_close_fd($!uis);
  }

  method get_fd
    is also<
      get-fd
      fd
    >
  {
    g_unix_input_stream_get_fd($!uis);
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_unix_input_stream_get_type, $n, $t );
  }

  method set_close_fd (Int() $cfd) is also<set-close-fd> {
    my gboolean $c = $cfd.so.Int;

    g_unix_input_stream_set_close_fd($!uis, $c);
  }

}
