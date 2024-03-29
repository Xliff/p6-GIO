use v6.c;

use Method::Also;

use NativeCall;

use GIO::Raw::Types;
use GIO::Raw::ListStore;

use GLib::Value;

use GLib::Roles::Object;
use GIO::Roles::ListModel;

our subset GListStoreAncestry is export of Mu
  where GListStore | GListModel | GObject;

class GIO::ListStore {
  also does GLib::Roles::Object;
  also does GIO::Roles::ListModel;

  has GListStore $!ls is implementor;

  submethod BUILD (:$store) {
    self.setGListStore($store) if $store;
  }

  method setGListStore (GListStoreAncestry $_) {
    my $to-parent;

    $!ls = do {
      when GListStore {
        $to-parent = cast(GObject, $_);
        $_;
      }

      when GListModel {
        $to-parent = cast(GObject, $_);
        $!lm       = $_;
        cast(GListStore, $_);
      }

      default {
        $to-parent = $_;
        cast(GListStore, $_);
      }
    }
    self!setObject($to-parent);
    self.roleInit-GListModel;
  }

  method GIO::Raw::Definitions::GListStore
    is also<GListStore>
  { $!ls }

  multi method new (GListStoreAncestry $store, :$ref = True) {
    return Nil unless $store;

    my $o = self.bless( :$store );
    $o.ref if $ref;
    $o;
  }
  multi method new (Int() $type) {
    my GType $t = $type;

    my $store = g_list_store_new($t);

    $store ?? self.bless( :$store ) !! Nil;
  }

  my %attributes = (
    item-type => GLib::Value.gtypeFromType(GType);
  );

  # Type: GType
  method item-type is rw  is also<item_type> {
    my GLib::Value $gv .= new( G_TYPE_UINT64 );
    Proxy.new(
      FETCH => -> $ {
        $gv = GLib::Value.new(
          self.prop_get('item-type', $gv)
        );

        # YYY -
        # cw: This is the proper way to handle GType in the future!
        # 11/11/2019
        $gv.uint64 ∈ GTypeEnum.pairs.map( *.value ) ??
          GTypeEnum( $gv.uint64 ) !! $gv.uint64;
      },
      STORE => -> $, $val is copy {
        warn 'item-type is a construct-only property and cannot be modified';
      }
    );
  }

  # cw: This will need to be repeated for all basic item types.
  multi method append (Str $item) {
    die "Cannot append Str when ListStore is of type {
         GTypeEnum( self.item-type ) }"
    unless self.item_type == G_TYPE_STRING;

    nextwith( cast(Pointer, $item) );
  }
  multi method Append (Int $item, :$double = False, :$signed = False) {
    die "Cannot append Str when ListStore is of type {
         GTypeEnum( self.item-type ) }"
    unless self.item_type == do {
      when $signed     & $double     { G_TYPE_INT64 }
      when $signed.not & $double     { G_TYPE_UINT64 }
      when $signed.not & $double.not { G_TYPE_INT    }
      when $signed     & $double.not { G_TYPE_INT    }
    }

    # cw: Should also perform basic checks on value limits for $item.
    #     Any fault here is NON fatal and clamped.

    nextwith( toPointer($item, :$double, :$signed) )
  }
  multi method append (Num $item, :$double = True) {
    die "Cannot append Str when ListStore is of type {
         GTypeEnum( self.item-type ) }"
    unless self.item_type == do {
      when  $double     { G_TYPE_DOUBLE }
      when  $double.not { G_TYPE_FLOAT  }
    }

    # cw: Should also perform basic checks on value limits for $item.
    #     Any fault here is NON fatal and clamped.

    nextwith( toPointer($item, :$double) )
  }
  multi method append (GLib::Roles::Object $item) {
    samewith( $item.p );
  }
  multi method append (gpointer $item) {
    g_list_store_append($!ls, $item);
  }



  method insert (Int() $position, gpointer $item) {
    my guint $p = $position;

    g_list_store_insert($!ls, $p, $item);
  }

  multi method insert_sorted (
    gpointer $item,
             &compare_func,
    gpointer $user_data = gpointer;
  )
    is also<insert-sorted>
  {
    g_list_store_insert_sorted($!ls, $item, &compare_func, $user_data);
  }

  method remove (Int() $position) {
    my guint $p = $position;

    g_list_store_remove($!ls, $p);
  }

  method remove_all is also<remove-all> {
    g_list_store_remove_all($!ls);
  }

  method sort (
             &compare_func,
    gpointer $user_data = gpointer
  ) {
    g_list_store_sort($!ls, &compare_func, $user_data);
  }

  multi method splice (
    Int() $position,
    Int() $n_removals,
          @additions
  ) {
    die '@additions must only contain gpointers!'
      unless @additions.all ~~ gpointer;

    my $aa = CArray[gpointer].new;
    $aa[$_] = @additions[$_] for ^@additions.elems;

    samewith($position, $n_removals, $aa, @additions.elems);
  }
  multi method splice (
    Int()            $position,
    Int()            $n_removals,
    CArray[gpointer] $additions,
    Int()            $n_additions
  ) {
    my guint ($p, $np, $na) = ($position, $n_removals, $n_additions);

    g_list_store_splice($!ls, $position, $n_removals, $additions, $n_additions);
  }

}
