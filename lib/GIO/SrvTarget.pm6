use v6.c;

use Method::Also;

use GIO::Raw::Types;
use GIO::Raw::SrvTarget;

use GLib::GList;

use GLib::Roles::Implementor;
use GLib::Roles::ListData;

# BOXED
class GIO::SrvTarget {
  also does GLib::Roles::Implementor;
  
  has GSrvTarget $!st is implementor;

  submethod BUILD (:$srv) {
    $!st = $srv;
  }

  method GIO::Raw::Definitions::GSrvTarget
    is also<GSrvTarget>
  { $!st }

  multi method new (GSrvTarget $srv) {
    $srv ?? self.bless( :$srv ) !! Nil;
  }
  multi method new (Str() $host, Int() $port, Int() $priority, Int() $weight) {
    my guint16 ($pt, $pr, $w) = ($port, $priority, $weight);
    my         $srv           = g_srv_target_new($host, $pt, $pr, $w);

    $srv ?? self.bless( :$srv ) !! Nil;
  }

  method copy (:$raw = False) {
    my $c = g_srv_target_copy($!st);

    $c ??
      ( $raw ?? $c !! GIO::SrvTarget.new($c, :!ref) )
      !!
      Nil;
  }

  method free {
    g_srv_target_free($!st);
  }

  method get_hostname
    is also<
      get-hostname
      hostname
    >
  {
    g_srv_target_get_hostname($!st);
  }

  method get_port
    is also<
      get-port
      port
    >
  {
    g_srv_target_get_port($!st);
  }

  method get_priority
    is also<
      get-priority
      priority
    >
  {
    g_srv_target_get_priority($!st);
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_srv_target_get_type, $n, $t );
  }

  method get_weight
    is also<
      get-weight
      weight
    >
  {
    g_srv_target_get_weight($!st);
  }

  method list_sort (
    GIO::SrvTarget:U:
    GList()           $targets,
                      :$glist   = False,
                      :$raw     = False
  )
    is also<list-sort>
  {
    my $tl = g_srv_target_list_sort($targets);

    return Nil unless $tl;
    return $tl if $glist && $raw;

    $tl = GLib::GList.new($tl) but GLib::Roles::ListData[GSrvTarget];
    return $tl if $glist;

    $raw ?? $tl.Array
         !! $tl.Array.map({ GIO::SrvTarget.new($_, :!ref) });
  }

}
