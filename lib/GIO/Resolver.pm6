use v6.c;

use Method::Also;
use NativeCall;

use GIO::Raw::Types;
use GIO::Raw::Resolver;

use GLib::GList;
use GIO::InetAddress;

use GLib::Roles::ListData;
use GLib::Roles::Object;
use GLib::Roles::Signals::Generic;

our subset GResolverAncestry is export of Mu
  where GResolver | GObject;

class GIO::Resolver {
  also does GLib::Roles::Object;
  also does GLib::Roles::Signals::Generic;

  has GResolver $!r is implementor;

  submethod BUILD (:$resolver) {
    self.setGResolver($resolver) if $resolver;
  }

  method setGResolver (GResolverAncestry $_) {
    my $to-parent;

    $!r = do {
      when GResolver {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GResolver, $_);
      }
    }

    self!setObject($to-parent);
  }

  method GIO::Raw::Definitions::GResolver
    is also<GResolver>
  { $!r }

  method new (GResolverAncestry $resolver, :$ref = True) {
    return Nil unless $resolver;

    my $o = self.bless( :$resolver );
    $o.ref if $ref;
    $o;
  }

  # Is originally:
  # GResolver, gpointer --> void
  method reload {
    self.connect($!r, 'reload');
  }

  method get_default (GIO::Resolver:U: :$raw = False) is also<get-default> {
    my $r = g_resolver_get_default();

    $r ??
      ( $raw ?? $r !! GIO::Resolver.new($r, :!ref) )
      !!
      Nil;
  }

  method error_quark ( GIO::Resolver:U: ) is also<error-quark> {
    g_resolver_error_quark();
  }

  method free_addresses ( GIO::Resolver:U: GList() $addresses)
    is also<free-addresses>
  {
    g_resolver_free_addresses($addresses);
  }

  method free_targets ( GIO::Resolver:U: GList() $targets)
    is also<free-targets>
  {
    g_resolver_free_targets($targets);
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_resolver_get_type, $n, $t );
  }

  method lookup_by_address (
    GInetAddress()          $address,
    GCancellable()          $cancellable = GCancellable,
    CArray[Pointer[GError]] $error       = gerror
  )
    is also<lookup-by-address>
  {
    clear_error;
    my $a = g_resolver_lookup_by_address($!r, $address, $cancellable, $error);
    set_error($error);
    $a;
  }

  method lookup_by_address_async (
    GInetAddress()      $address,
    GCancellable()      $cancellable,
                        &callback,
    gpointer            $user_data    = gpointer
  )
    is also<lookup-by-address-async>
  {
    g_resolver_lookup_by_address_async(
      $!r,
      $address,
      $cancellable,
      &callback,
      $user_data
    );
  }

  method lookup_by_address_finish (
    GAsyncResult() $result,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<lookup-by-address-finish>
  {
    clear_error;
    my $a = g_resolver_lookup_by_address_finish($!r, $result, $error);
    set_error($error);
    $a;
  }

  method lookup_by_name (
    Str()                   $hostname,
    GCancellable()          $cancellable = GCancellable,
    CArray[Pointer[GError]] $error       = gerror,
                            :$glist      = False,
                            :$raw        = False
  )
    is also<lookup-by-name>
  {
    clear_error;
    my $l = g_resolver_lookup_by_name($!r, $hostname, $cancellable, $error);
    set_error($error);

    return Nil unless $l;
    return $l if $glist && $raw;

    $l = GLib::GList.new($l) but GLib::Roles::ListData[GInetAddress];
    return $l if $raw;

    $raw ?? $l.Array !! $l.Array.map({ GIO::InetAddress.new($_, :!ref) });
  }

  method lookup_by_name_async (
    Str()               $hostname,
    GCancellable()      $cancellable,
                        &callback,
    gpointer            $user_data   = gpointer
  )
    is also<lookup-by-name-async>
  {
    g_resolver_lookup_by_name_async(
      $!r,
      $hostname,
      $cancellable,
      &callback,
      $user_data
    );
  }

  method lookup_by_name_finish (
    GAsyncResult()          $result,
    CArray[Pointer[GError]] $error  = gerror,
                            :$glist = False,
                            :$raw   = False
  )
    is also<lookup-by-name-finish>
  {
    clear_error;
    my $l = g_resolver_lookup_by_name_finish($!r, $result, $error);
    set_error($error);

    return Nil unless $l;
    return $l if $glist && $raw;

    $l = GLib::GList.new($l) but GLib::Roles::ListData[GInetAddress];
    return $l if $raw;

    $raw ?? $l.Array !! $l.Array.map({ GIO::InetAddress.new($_, :!ref) });
  }

  method lookup_by_name_with_flags (
    Str()                   $hostname,
    Int()                   $flags,
    GCancellable()          $cancellable = GCancellable,
    CArray[Pointer[GError]] $error       = gerror,
                            :$glist      = False,
                            :$raw        = False
  )
    is also<lookup-by-name-with-flags>
  {
    my GResolverNameLookupFlags $f = $flags;

    clear_error;
    my $l = g_resolver_lookup_by_name_with_flags(
      $!r,
      $hostname,
      $f,
      $cancellable,
      $error
    );
    set_error($error);

    return Nil unless $l;
    return $l if $glist && $raw;

    $l = GLib::GList.new($l) but GLib::Roles::ListData[GInetAddress];
    return $l if $raw;

    $raw ?? $l.Array !! $l.Array.map({ GIO::InetAddress.new($_, :!ref) });
  }

  method lookup_by_name_with_flags_async (
    Str()               $hostname,
    Int()               $flags,
    GCancellable()      $cancellable,
                        &callback,
    gpointer            $user_data   = gpointer
  )
    is also<lookup-by-name-with-flags-async>
  {
    my GResolverNameLookupFlags $f = $flags;

    g_resolver_lookup_by_name_with_flags_async(
      $!r,
      $hostname,
      $f,
      $cancellable,
      &callback,
      $user_data
    );
  }

  method lookup_by_name_with_flags_finish (
    GAsyncResult()          $result,
    CArray[Pointer[GError]] $error   = gerror,
                            :$glist  = False,
                            :$raw    = False
  )
    is also<lookup-by-name-with-flags-finish>
  {
    clear_error;
    my $l = g_resolver_lookup_by_name_with_flags_finish($!r, $result, $error);
    set_error($error);

    return Nil unless $l;
    return $l if $glist && $raw;

    $l = GLib::GList.new($l) but GLib::Roles::ListData[GInetAddress];
    return $l if $raw;

    $raw ?? $l.Array !! $l.Array.map({ GIO::InetAddress.new($_, :!ref) });
  }

  method lookup_records (
    Str()                   $rrname,
    Int()                   $record_type,
    GCancellable()          $cancellable  = GCancellable,
    CArray[Pointer[GError]] $error        = gerror,
                            :$glist       = False,
                            :$raw         = False
  )
    is also<lookup-records>
  {
    my GResolverRecordType $rt = $record_type;

    clear_error;
    my $l = g_resolver_lookup_records($!r, $rrname, $rt, $cancellable, $error);
    set_error($error);

    return Nil unless $l;
    return $l if $glist && $raw;

    $l = GLib::GList.new($l) but GLib::Roles::ListData[GVariant];
    return $l if $raw;

    $raw ?? $l.Array !! $l.Array.map({ GLib::Variant.new($_, :!ref) });
  }

  method lookup_records_async (
    Str            $rrname,
    Int()          $record_type,
    GCancellable() $cancellable,
                   &callback,
    gpointer       $user_data    = gpointer
  )
    is also<lookup-records-async>
  {
    my GResolverRecordType $rt = $record_type;

    g_resolver_lookup_records_async(
      $!r,
      $rrname,
      $rt,
      $cancellable,
      &callback,
      $user_data
    );
  }

  method lookup_records_finish (
    GAsyncResult()          $result,
    CArray[Pointer[GError]] $error   = gerror,
                            :$glist  = False,
                            :$raw    = False
  )
    is also<lookup-records-finish>
  {
    clear_error;
    my $l = g_resolver_lookup_records_finish($!r, $result, $error);
    set_error($error);

    return Nil unless $l;
    return $l if $glist && $raw;

    $l = GLib::GList.new($l) but GLib::Roles::ListData[GSrvTarget];
    return $l if $raw;

    $raw ?? $l.Array !! $l.Array.map({ GIO::SrvTarget.new($_, :!ref) });
  }

  method lookup_service (
    Str()                   $service,
    Str()                   $protocol,
    Str()                   $domain,
    GCancellable()          $cancellable,
    CArray[Pointer[GError]] $error        = gerror,
                            :$glist       = False,
                            :$raw         = False
  )
    is also<lookup-service>
  {
    clear_error;
    my $l = g_resolver_lookup_service(
      $!r,
      $service,
      $protocol,
      $domain,
      $cancellable,
      $error
    );
    set_error($error);

    return Nil unless $l;
    return $l if $glist && $raw;

    $l = GLib::GList.new($l) but GLib::Roles::ListData[GSrvTarget];
    return $l if $raw;

    $raw ?? $l.Array !! $l.Array.map({ GIO::SrvTarget.new($_, :!ref) });
  }

  method lookup_service_async (
    Str()               $service,
    Str()               $protocol,
    Str()               $domain,
    GCancellable()      $cancellable,
                        &callback,
    gpointer            $user_data = gpointer
  )
    is also<lookup-service-async>
  {
    g_resolver_lookup_service_async(
      $!r,
      $service,
      $protocol,
      $domain,
      $cancellable,
      &callback,
      $user_data
    );
  }

  method lookup_service_finish (
    GAsyncResult()          $result,
    CArray[Pointer[GError]] $error  = gerror,
                            :$glist = False,
                            :$raw   = False
  )
    is also<lookup-service-finish>
  {
    clear_error;
    my $l = g_resolver_lookup_service_finish($!r, $result, $error);
    set_error($error);

    return Nil unless $l;
    return $l if $glist && $raw;

    $l = GLib::GList.new($l) but GLib::Roles::ListData[GSrvTarget];
    return $l if $raw;

    $raw ?? $l.Array !! $l.Array.map({ GIO::SrvTarget.new($_, :!ref) });
  }

  method set_default is also<set-default> {
    g_resolver_set_default($!r);
  }

}
