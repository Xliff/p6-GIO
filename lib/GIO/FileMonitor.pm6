use v6.c;

use Method::Also;

use GIO::Raw::Types;
use GIO::Raw::FileMonitor;

use GLib::Value;

use GLib::Roles::Object;
use GIO::Roles::Signals::FileMonitor;

our subset GFileMonitorAncestry is export of Mu
  where GFileMonitor | GObject;

class GIO::FileMonitor {
  also does GLib::Roles::Object;
  also does GIO::Roles::Signals::FileMonitor;

  has GFileMonitor $!m is implementor;

  submethod BUILD (:$monitor) {
    self.setGFileMonitor($monitor) if $monitor;
  }

  method setGFileMonitor (GFileMonitorAncestry $_) {
    my $to-parent;

    $!m = do {
      when GFileMonitor {
        $to-parent = cast(GObject, $_);
        $_
      }

      default {
        $to-parent = $_;
        cast(GFileMonitor, $_);
      }
    }
    self!setObject($to-parent);
  }

  method GIO::Raw::Definitions::GFileMonitor
    is also<GFileMonitor>
  { $!m }

  multi method new (GFileMonitor $monitor, :$ref = False) {
    return Nil unless $monitor;

    my $o = self.bless( :$monitor );
    $o.ref if $ref;
    $o;
  }
  multi method new {
    self.bless( monitor => GFileMonitor );
  }

  # Type: gint
  method rate-limit is rw  is also<rate_limit> {
    my GLib::Value $gv .= new( G_TYPE_INT );
    Proxy.new(
      FETCH => -> $ {
        $gv = GLib::Value.new(
          self.prop_get('rate-limit', $gv)
        );
        $gv.int;
      },
      STORE => -> $, Int() $val is copy {
        $gv.int = $val;
        self.prop_set('rate-limit', $gv);
      }
    );
  }

  # Is originally:
  # GFileMonitor, GFile, GFile, GFileMonitorEvent, gpointer --> void
  method changed {
    self.connect-changed($!m);
  }

  method cancel {
    g_file_monitor_cancel($!m);
  }

  method emit_event (
    GFile() $child,
    GFile() $other_file,
    Int()   $event_type
  )
    is also<emit-event>
  {
    my GFileMonitorEvent $e = $event_type;

    g_file_monitor_emit_event($!m, $child, $other_file, $e);
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_file_monitor_get_type, $n, $t );
  }

  method is_cancelled is also<is-cancelled> {
    so g_file_monitor_is_cancelled($!m);
  }

  method set_rate_limit (Int() $limit_msecs) is also<set-rate-limit> {
    my gint $l = $limit_msecs;

    g_file_monitor_set_rate_limit($!m, $l);
  }

  method signal-data {
    state ( %signal-data, %signal-object );
    my $self = self;
    unless %signal-data{ self.WHERE } {
      %signal-data{ self.WHERE } = (
        changed => sub { $self.connect-changed($!m) }
      ).Hash;
    }

    unless %signal-object{ self.WHERE } {
      state @keys;

      unless @keys {
        @keys = self.GLib::Roles::Object::signal-data.keys;
        @keys.append: %signal-data{ self.WHERE }.keys;
      }

      %signal-object{ self.WHERE } = (class :: does Associative {

        method !getData (\k) {
          %signal-data{ $self.WHERE }{k}
            ?? %signal-data{ $self.WHERE }{k}
            !! $self.GLib::Roles::Object::signal-data{k};
        }

        method AT-KEY (\k) {
          self!getData(k);
        }

        method EXISTS-KEY (\k) {
          self!getData(k).defined;
        }

        method keys {
          @keys;
        }

      }).new;
    }

    %signal-object{ self.WHERE };
  }

  method signal-names {
    state @signal-names = self.signal-data.keys;

    @signal-names;
  }
}
