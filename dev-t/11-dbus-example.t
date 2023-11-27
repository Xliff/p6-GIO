use v6.c;

use GIO::Raw::Types;
use GIO::DBus::Proxy;

my $KbdBacklightInterface = q:to/INTERFACE/;
  <node>
  <interface name="org.freedesktop.UPower.KbdBacklight">
      <method name="SetBrightness">
          <arg name="value" type="i" direction="in"/>
      </method>
      <method name="GetBrightness">
          <arg name="value" type="i" direction="out"/>
      </method>
      <method name="GetMaxBrightness">
          <arg name="value" type="i" direction="out"/>
      </method>
      <signal name="BrightnessChanged">
          <arg type="i"/>
      </signal>
  </interface>
  </node>
  INTERFACE

sub make-proxy-wrapper ($xml) {

  if GDBusNodeInfo.new_for_xml($xml) -> $info {
    my $iname = $info.interfaces[0];
    $iname.gist.say;

    # Returns the following Callable;
    my &wrapper-func = sub (
      $bus,
      $name,
      $object,
      &callback     = Callable,
      $cancellable  = GCancellable,
      $flags        = G_DBUS_PROXY_FLAGS_NONE
    ) {
      my $o = GIO::DBus::Proxy.new_sync(
        $bus,
        $flags,
        $info,
        $name,
        $object,
        $iname
      );

      if &callback {
        $object.init_async(-> $i, $r {
          CATCH {
            default { .message.say; .backtrace.concise.say }
          }
          $i.init_finish($r);
          &callback($i);
        });
      } else {
        $o.init($cancellable);
      }
      $o;
    }

    &wrapper-func;
  }

}

my &KbdBacklightProxy = make-proxy-wrapper($KbdBacklightInterface);
my $kbdProxy = &KbdBacklightProxy(
  GIO::DBus::Connection.get-sync-system,
  'org.freedeskltop.UPower',
  '/org/freedesktop/UPower/KbdBacklight'
);

say "The max brightness of your keyboard is " ~
    $kbdProxy.call-sync('GetMaxBrightness');

$kbdProxy.call(
  :async,
  -> $, $result, $ {
    my $r = $kbdProxy.call-finish($result);

    die "Error occurred during callback: { $ERROR.message }" if $ERROR;
    say "The current brightness of your keyboard is: { $r }";
  }
);

$kbdProxy.connect('BrightnessChanged', -> *@a {
  say "The keyboard brightness has been changed, the new brightness is " ~
      $kbdProxy.call-sync('GetBrightness');
});

my $loop = GLib::MainLoop.new;
$loop.run;
