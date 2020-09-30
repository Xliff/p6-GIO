use v6.c;

use Method::Also;

use GIO::Raw::Types;
use GIO::Raw::FileInfo;

# BOXED!
class GIO::FileAttributeMatcher {
  has GFileAttributeMatcher $!fam is implementor;

  method BUILD (:$matcher) {
    $!fam = $matcher;
  }

  method GIO::Raw::Definitions::GFileAttributeMatcher
    is also<GFileAttributeMatcher>
  { $!fam }

  multi method new (GFileAttributeMatcher $matcher, :$ref = True) {
    return Nil unless $matcher;
    
    my $o = self.bless( :$matcher );
    $o.ref if $ref;
    $o;
  }
  multi method new (Str() $attributes) {
    my $matcher = g_file_attribute_matcher_new($attributes);

    $matcher ?? self.bless( :$matcher ) !! Nil;
  }

  method enumerate_namespace (Str() $ns) is also<enumerate-namespace> {
    so g_file_attribute_matcher_enumerate_namespace($!fam, $ns);
  }

  method enumerate_next is also<enumerate-next> {
    g_file_attribute_matcher_enumerate_next($!fam);
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &g_file_attribute_matcher_get_type, $n, $t );
  }

  method matches (Str() $attribute) {
    so g_file_attribute_matcher_matches($!fam, $attribute);
  }

  method matches_only (Str() $attribute) is also<matches-only> {
    so g_file_attribute_matcher_matches_only($!fam, $attribute);
  }

  method ref is also<upref> {
    g_file_attribute_matcher_ref($!fam);
    self;
  }

  method subtract (GFileAttributeMatcher() $subtract, :$raw = False) {
    my $fam = g_file_attribute_matcher_subtract($!fam, $subtract);

    $fam ??
      ( $raw ?? $fam !! GIO::FileAttributeMatcher.new($fam, :!ref) )
      !!
      Nil;
  }

  method to_string
    is also<
      to-string
      Str
    >
  {
    g_file_attribute_matcher_to_string($!fam);
  }

  method unref is also<downref> {
    g_file_attribute_matcher_unref($!fam);
  }

}
