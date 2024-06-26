use v6.c;

use NativeCall;

use GLib::Raw::Debug;
use GLib::Raw::Definitions;
use GLib::Raw::Enums;
use GLib::Raw::Object;
use GLib::Raw::Structs;
use GLib::Raw::Subs;
use GLib::Raw::Struct_Subs;
use GIO::Raw::Definitions;

use GLib::Roles::Pointers;

unit package GIO::Raw::Structs;

multi sub resolve-carray ($_, $cn = '', :$type = uint8) is raw {
  say "resolve-carray given: { .^name }" if $DEBUG;

  my \CA := CArray.^parameterize[$type];

  return CA if $_ =:= Any || .^shortname eq 'Any';

  when $_ =:= Pointer  { CA                                       }
  when Array           { CA.new( $_ )                             }
  when Blob | CArray   { CA = CArray.^parameterize[.of]; proceed  }
  when Blob            { CA.new( .Array )                         }
  when CArray          { CA.new( $_ )                             }
  when Pointer         { cast(CA, $_)                             }
  when Str             { CA.new( .comb )                          }

  default      { die "Unknown type '{ .^name }' used for { $cn }.buffer!" }
}

sub resolve-pointer ($_, $cn = '') is raw {
  say "resolve-buffer given: { .^name }" if $DEBUG;

  return Pointer if $_ =:= Any || .^shortname eq 'Any';

  when $_ =:= Pointer   { Pointer                                          }
  when Array            { cast( Pointer, CArray[uint8].new( |$_,     0 ) ) }
  when Blob             { cast( Pointer, CArray[uint8].new( |.Array, 0 ) ) }
  when CArray           { cast( Pointer, $_ )                              }
  when Pointer          { Pointer.new(+$_)                                 }
  when Str              { cast( Pointer, explicitly-manage($_) )           }

  default      { die "Unknown type '{ .^name }' used for { $cn }.buffer!" }
}

class GInputVector  is repr('CStruct') does GLib::Roles::Pointers is export {
  has Pointer       $.buffer;
  has gssize        $.size;

  submethod BUILD (:$buffer, :$!size) {
    $!buffer := resolve-pointer($buffer, ::?CLASS.^shortname);
  }

  multi method new ($buffer, $size) { self.bless(:$buffer, :$size) }
  multi method new                  { self.bless( size => 0 )      }
}

class GOutputVector is repr('CStruct') does GLib::Roles::Pointers is export {
  has Pointer       $.buffer;
  has gssize        $.size;

  submethod BUILD (:$buffer, Int() :$!size) {
    $!buffer := resolve-pointer($buffer, ::?CLASS.^shortname);
  }

  multi method new ($buffer, $size) { self.bless(:$buffer, :$size) }
  multi method new                  { self.bless(size => 0)        }
}

class GSocketControlMessage is repr('CStruct') does GLib::Roles::Pointers is export {
  HAS GObject       $.parent;
  has Pointer       $!priv;                   #= GSocketControlMessagePrivate (not included)
}

class GInputMessage is repr('CStruct') does GLib::Roles::Pointers is export {
  has Pointer       $.address;                #= GSocketAddress **
  has GInputVector  $.vectors;                #= GInputVector *
  has guint         $.num_vectors;
  has gsize         $.bytes_received;
  has gint          $.flags;
  has Pointer       $.control_messages;       #= GSocketControlMessage ***
  has CArray[guint] $.num_control_messages;   #= Pointer with 1 element == *guint
}

class GOutputMessage is repr('CStruct') does GLib::Roles::Pointers is export {
  has Pointer       $.address;
  has GOutputVector $.vectors;
  has guint         $.num_vectors;
  has guint         $.bytes_sent;
  has Pointer       $.control_messages;
  has guint         $.num_control_messages;
};

class GPermission is repr('CStruct') does GLib::Roles::Pointers is export {
  has uint64        $.dummy1;
  has uint64        $.dummy2;
  has uint64        $.dummy3;
  has uint64        $.dummy4;
}

class GFileAttributeInfoList is repr('CStruct') does GLib::Roles::Pointers is export {
  has GFileAttributeInfo $.infos;
  has gint               $.n_infos;
}

class GActionEntry is repr('CStruct') does GLib::Roles::Pointers is export {
  has Str     $!name;
  has Pointer $!activate;
  has Str     $!parameter_type;
  has Str     $!state;
  has Pointer $!change_state;

  # Padding  - Not accessible
  has uint64  $!pad1;
  has uint64  $!pad2;
  has uint64  $!pad3;

  submethod BUILD (
    :$name,
    :&activate,
    :$parameter_type,
    :$state,
    :&change_state
  ) {
    self.name           = $name;
    self.activate       = &activate        if &activate.defined;
    self.parameter_type = $parameter_type  if $parameter_type;
    self.state          = $state           if $state;
    self.change_state   = &change_state    if &change_state.defined
  }

  method name is rw {
    Proxy.new:
      FETCH => -> $                { $!name },
      STORE => -> $, Str() $val    { self.^attributes(:local)[0]
                                         .set_value(self, $val)    };
  }

  method activate is rw {
    Proxy.new:
      FETCH => -> $ { $!activate },
      STORE => -> $, \func {
        $!activate := set_func_pointer( &(func), &sprintf-SaVP);
      };
  }

  method parameter_type is rw {
    Proxy.new:
      FETCH => -> $                { $!parameter_type },
      STORE => -> $, Str() $val    { self.^attributes(:local)[2]
                                         .set_value(self, $val)    };
  }

  method state is rw {
    Proxy.new:
      FETCH => -> $                { $!state },
      STORE => -> $, Str() $val    { self.^attributes(:local)[3]
                                         .set_value(self, $val)    };
  }

  method change_state is rw {
    Proxy.new:
      FETCH => -> $        { $!activate },
      STORE => -> $, \func {
        $!change_state := set_func_pointer( &(func), &sprintf-SaVP )
      };
  }

  method parameter-type is rw { self.parameter_type }
  method change-state   is rw { self.change_state   }

  multi method new (
    $name,
    &activate       = Callable,
    $state          = Str,
    $parameter_type = Str,
    &change_state   = Callable
  ) {
    self.bless(:$name, :&activate, :$parameter_type, :$state, :&change_state);
  }

  method gist {
    "GActionEntry.new(\n{
      self.^attributes.sort( *.name )
                      .map({ "  { .name.substr(2) } => { .get_value(self) // '' }" })
                      .join(",\n")
     }\n)";
  }

}

class GInputStream is repr<CStruct> does GLib::Roles::Pointers is export {
  HAS GObject  $!parent;
  has gpointer $!private;
}

class GOutputStream is repr<CStruct> does GLib::Roles::Pointers is export {
  HAS GObject  $!parent;
  has gpointer $!private;
}

sub sprintf-SaVP (
  Blob,
  Str,
  & (GSimpleAction, GVariant, gpointer),
)
  returns int64
  is native
  is symbol('sprintf')
{ * }
