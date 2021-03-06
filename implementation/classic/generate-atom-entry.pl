#!/usr/bin/perl
use strict;
use warnings;
use Path::Class;
use lib file (__FILE__)->dir->parent->parent->subdir ('modules', 'manakai', 'lib')->stringify;
use lib file (__FILE__)->dir->parent->parent->subdir ('modules', 'charclass', 'lib')->stringify;
use Message::DOM::DOMImplementation;
use Whatpm::H2H;
use Encode;
use Encode::EUCJP1997;
use Getopt::Long;

our $REPOSITORY_PATH = q<path/to/files/>;
our $FEED_TAG = q<data:,tag-url-prefix:>;
our $BASE_URI = q</url/path/of/diary/>;
our $BASE_LANG = 'und';
our $AUTHOR_NAME = q<Author San>;
our $AUTHOR_URI = q<http://example/url/of/author>;
our $AUTHOR_MAIL = q<author-san@example.com>;

GetOptions (
  'diary-file-directory-name=s' => \$REPOSITORY_PATH,
  'feed-tag-url-prefix=s' => \$FEED_TAG,
  'base-url=s' => \$BASE_URI,
  'base-lang=s' => \$BASE_LANG,
  'author-name=s' => \$AUTHOR_NAME,
  'author-url=s' => \$AUTHOR_URI,
  'author-mail-addr=s' => \$AUTHOR_MAIL,
) or die "Broken input";
$AUTHOR_NAME = decode 'utf-8', $AUTHOR_NAME if defined $AUTHOR_NAME;

my ($year, $month, $day) = @ARGV;
$year += 0;
$month += 0;
$day += 0;

my $atom = q<http://www.w3.org/2005/Atom>;
my $fe = q<http://suika.fam.cx/www/2006/feature/>;
my $cfg = q<http://suika.fam.cx/www/2006/dom-config/>;
my $html = q<http://www.w3.org/1999/xhtml>;
my $xml = q<http://www.w3.org/XML/1998/namespace>;
my $xhtml2 = q<http://www.w3.org/2002/06/xhtml2/>;
my $h2h = q<http://suika.fam.cx/~wakaba/archive/2005/manakai/Markup/H2H/>;
my $xmlns = q<http://www.w3.org/2000/xmlns/>;

my $impl = Message::DOM::DOMImplementation->new;

my $base_d = dir ($REPOSITORY_PATH)->subdir ($year)->absolute;
my $base_file_name = $base_d->file
    (sprintf 'd%04d%02d%02d', $year, $month, $day)->stringify;

chdir $base_d->stringify;

my $h2h_data = '';
if (-f $base_file_name.'.hnf') {
  local $/ = undef;
  open my $h2h_file, '<', $base_file_name.'.hnf'
      or die "$0: $base_file_name.hnf: $!";
  $h2h_data = Encode::decode ('euc-jp-1997', <$h2h_file>);
  close $h2h_file;
}

my $h2h_doc = Whatpm::H2H->parse_string ($h2h_data => $impl->create_document);

my $i = 0;

for my $section (@{$h2h_doc->get_elements_by_tag_name_ns ($html, 'body')
                           ->[0]->child_nodes}) {
  next if $section->node_type != $section->ELEMENT_NODE;
  next if $section->local_name ne 'section';
  next if $section->namespace_uri ne $html;

  $i++;

  my $atom_doc = $impl->create_atom_entry_document
                           ($FEED_TAG.$year.':'.$month.':'.$day.':'.$i);
  $atom_doc->dom_config->set_parameter ($cfg.'create-child-element' => 1);

  my $atom_entry = $atom_doc->document_element;
  $atom_entry->set_attribute_ns ($xml, 'xml:base', $BASE_URI);
  $atom_entry->set_attribute_ns ($xml, 'xml:lang', $BASE_LANG);
  $atom_entry->set_attribute_ns ($xmlns, xmlns => $html);

  my $atom_content = $atom_entry->content_element;
  $atom_content->type ('xhtml');

  my $atom_container = $atom_content->container;

  my $hour = 0;
  my $minute = 0;
  my $tz = '-00:00';
  my @section_children = @{$section->child_nodes};
  for my $el (@section_children) {
    next if $el->node_type != $el->ELEMENT_NODE;

    my $xuri = $el->manakai_expanded_uri;

    if ($xuri eq $xhtml2.'h') {
      my $atom_title = $atom_entry->title_element;
      $atom_title->type ('xhtml');
      my $atom_title_container = $atom_title->container;
      my @el_children = @{$el->child_nodes};
      for (@el_children) {
        $atom_title_container->append_child ($atom_doc->adopt_node ($_));
      }

      if ($atom_title_container->text_content
              =~ /\(\@(\d\d):(\d\d) ([+-]\d\d:\d\d)\)\s*$/) {
        $hour = $1 + 0;
        $minute = $2 + 0;
        $tz = $3;
      }
    } elsif ($xuri eq $h2h.'cat') {
      ## TODO:
    } else {
      $atom_container->append_child ($atom_doc->adopt_node ($el));
    }
  }

  $atom_entry->published_element->text_content
      (sprintf '%04d-%02d-%02dT%02d:%02d:00%s',
       $year, $month, $day, $hour, $minute, $tz);

  for my $author_el ($atom_entry->append_child
                         ($atom_doc->create_element_ns ($atom, 'author'))) {
    $author_el->name ($AUTHOR_NAME);
    $author_el->uri ($AUTHOR_URI) if defined $AUTHOR_URI;
    $author_el->email ($AUTHOR_MAIL) if defined $AUTHOR_MAIL;
  }

  for my $link_el ($atom_entry->append_child
                       ($atom_doc->create_element_ns ($atom, 'link'))) {
    $link_el->rel ('alternate');
    $link_el->href (sprintf 'd%04d%02d.%s.html#d%d-%d',
                            $year, $month, $BASE_LANG, $day, $i);
    $link_el->type ('text/html');
    $link_el->hreflang ($BASE_LANG);
  }

  for my $link_el ($atom_entry->append_child
                       ($atom_doc->create_element_ns ($atom, 'link'))) {
    $link_el->rel ('self');
    $link_el->href (sprintf '%04d/d%04d%02d%02d-%d.%s.atom',
                    $year, $year, $month, $day, $i, $BASE_LANG);
    $link_el->type ('application/atom+xml');
    $link_el->hreflang ($BASE_LANG);
  }

  my $entry_file_name = $base_file_name . '-' . $i . '.'.$BASE_LANG.'.atom';

  open my $entry_file, '>', $entry_file_name
      or die "$0: $entry_file_name: $!";
  
  warn qq<Write to "$entry_file_name"\n>;
  print $entry_file Encode::encode ('utf-8', $atom_doc->inner_html);
  close $entry_file;

  system 'git', 'add', file ($entry_file_name)->relative ($base_d)->stringify;
  system 'chmod', 'go+r', file ($entry_file_name)->relative ($base_d)->stringify;
}
