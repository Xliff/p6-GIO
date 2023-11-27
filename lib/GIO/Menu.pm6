use v6.c;

use Method::Also;
use NativeCall;

use GIO::Raw::Types;
use GIO::Raw::Menu;

use GIO::MenuModel;

my subset GMenuAncestry is export of Mu
  where GMenu | GMenuModel;

class GIO::Menu is GIO::MenuModel {
  has GMenu $!menu is implementor;

  method GIO::Raw::Definitions::GMenu
    is also<GMenu>
  { $!menu }

  submethod BUILD(:$menu) {
    self.setGMenu($menu) if $menu;
  }

  method setGMenu (GMenuAncestry $_) {
    my $to-parent;

    $!menu = do {
      when GMenu {
        $to-parent = cast(GMenuModel, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GMenu, $_);
      }
    }
    self.setMenuModel($to-parent);
  }

  multi method new (GMenuAncestry $menu, :$ref = True) {
    return Nil unless $menu;
    my $o = self.bless( :$menu );
    $o.ref if $ref;
    $o;
  }
  multi method new (@a) {
    samewith( |@a );
  }
  multi method new ( *@a ) {
    my $menu = g_menu_new();

    my $o = $menu ?? self.bless( :$menu ) !! Nil;
    $o.append($_) for @a;
    $o;
  }


  # ↓↓↓↓ SIGNALS ↓↓↓↓
  # ↑↑↑↑ SIGNALS ↑↑↑↑

  # ↓↓↓↓ ATTRIBUTES ↓↓↓↓
  # ↑↑↑↑ ATTRIBUTES ↑↑↑↑

  # ↓↓↓↓ PROPERTIES ↓↓↓↓
  # ↑↑↑↑ PROPERTIES ↑↑↑↑

  # ↓↓↓↓ METHODS ↓↓↓↓
  multi method append (Str() $label) {
    samewith($label, Str);
  }
  multi method append (Str() $detailed_action, :$action is required) {
    samewith(Str, $detailed_action);
  }
  multi method append (Str() $label, Str() $detailed_action) {
    g_menu_append($!menu, $label, $detailed_action);
  }

  method append_item (GMenuItem() $item) is also<append-item> {
    g_menu_append_item($!menu, $item);
  }

  method append_section (Str() $label, GMenuModel() $section)
    is also<append-section>
  {
    g_menu_append_section($!menu, $label, $section);
  }

  method append_submenu (Str() $label, GMenuModel() $submenu)
    is also<append-submenu>
  {
    g_menu_append_submenu($!menu, $label, $submenu);
  }

  method freeze {
    g_menu_freeze($!menu);
  }

  method insert (Int() $position, Str() $label, Str() $detailed_action) {
    my gint $p = $position;

    g_menu_insert($!menu, $p, $label, $detailed_action);
  }

  method insert_item (Int() $position, GMenuItem() $item)
    is also<insert-item>
  {
    my gint $p = $position;

    g_menu_insert_item($!menu, $p, $item);
  }

  method insert_section (
    Int()        $position,
    Str()        $label,
    GMenuModel() $section
  )
    is also<insert-section>
  {
    my gint $p = $position;

    g_menu_insert_section($!menu, $p, $label, $section);
  }

  method insert_submenu (
    Int()        $position,
    Str()        $label,
    GMenuModel() $submenu
  )
    is also<insert-submenu>
  {
    my gint $p = $position;

    g_menu_insert_submenu($!menu, $p, $label, $submenu);
  }

  method prepend (Str() $label, Str() $detailed_action) {
    g_menu_prepend($!menu, $label, $detailed_action);
  }

  method prepend_item (GMenuItem() $item) is also<prepend-item> {
    g_menu_prepend_item($!menu, $item);
  }

  method prepend_section (Str() $label, GMenuModel() $section)
    is also<prepend-section>
  {
    g_menu_prepend_section($!menu, $label, $section);
  }

  method prepend_submenu (Str() $label, GMenuModel() $submenu)
    is also<prepend-submenu>
  {
    g_menu_prepend_submenu($!menu, $label, $submenu);
  }

  method remove (Int() $position) {
    my gint $p = $position;

    g_menu_remove($!menu, $p);
  }

  method remove_all is also<remove-all> {
    g_menu_remove_all($!menu);
  }

  # ↑↑↑↑ METHODS ↑↑↑↑

}
