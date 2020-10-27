use v6.c;

use GIO::Raw::Types;
use GIO::Raw::FileAttributeTypes;

use GLib::URI;
use GLib::FileUtils;
use GLib::String;
use GLib::MainLoop;
use GIO::OutputStream;
use GIO::ThreadedSocketService;

use GIO::Roles::GFile;

my $root;

sub send-error ($o, $ec, $r) {
  $o.write-all( qq:to/RES/ )
    HTTP/1.0 $ec $r\r\n\r\n
    <html>
      <head>
        <title>$ec $r</title>
      <head>
      <body>$r</body>
    </html>
  RES
}

sub handler ($s, $c, $l, $ud) {
  my $co         = GIO::Stream.new($c);
  my ($in, $out) = ($co.get-input-stream, $co.get-output.stream);
  my $data       = GIO::DataInputStream.new($in);

  LEAVE { $data.unref }

  $data.newline-type = G_DATA_STREAM_NEWLINE_TYPE_ANY;
  my $line = $data.read-line;
  unless $line {
    send-error($out, 400, 'Invalid request');
    return;
  }

  unless $line.starts-with('GET ') {
    send-error($out, 501, 'Only GET implemented');
    return;
  }

  my ($version, $uri) = $line.substr(4).split(' ');
  unless $version {
    send-error($out, 400, 'Bad Request');
    return;
  }
  unless $version.starts-with('HTTP/1.') {
    send-error($out, 505, 'HTTP Version Not Supported');
    return;
  }

  my ($pre-query, $query) = $uri.split('?');
  my $unescaped = GLib::URI.unescape-string($uri);
  my $path      = GLib::FileUtils.build-filename($root, $unescaped);
  my $f         = GIO::File.new-for-path($path);
  my $file-in   = $f.read;
  unless $file-in {
    send-error($out, 404, $ERROR.message);
    return;
  }

  my $out-s = GLib::String.new("HTTP/1.0 200 OK\r\n");
  my $info  = $file-in.query-info(
    GFileAttributeName(G_FILE_ATTRIBUTE_STANDARD_SIZE) ~ ',' ~
    GFileAttributeName(G_FILE_ATTRIBUTE_STANDARD_CONTENT_TYPE)
  );

  if $info {
    $out-s.append("Content-Length: { $info.size }")
      if $info.has-attribute(
        GFileAttributeName(G_FILE_ATTRIBUTE_STANDARD_SIZE)
      );
    if $info.content-type -> $content-type {
      if GIO::ContentType.get-mime-type($content-type) -> $mime-type {
        $out-s.append("Content-Type: { $mime-type }");
      }
    }
  }
  $out-s.append("\r\n");

  $out.stream-splice($file-in) if $out.write-all($out-s.str);
  .close && .unref given $file-in;

  True
}

sub MAIN (
  Str $root-directory,       #= Root directory for server
  Int :p(:$port) = 8080      #= Local port to bind to
) {
  my $service = GIO::ThreadedSocketService.new(10);
  if $service.add-inet-port($port).not {
    $*ERR.say: "{ $*PROGRAM.basename }: { $ERROR.message }";
    exit 1;
  }
  $root = $root-directory;

  $service.run.tap(&handler);
  GLib::MainLoop.new.run;
}
