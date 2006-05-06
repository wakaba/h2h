#!/usr/bin/perl
use strict;
use utf8;

use lib q</home/wakaba/work/manakai/lib>;

our $REPOSITORY_PATH = q</home/wakaba/public_html/d/>;
our $FEED_NAME = q<冬様もすなる☆日記というもの>;
our $FEED_TAG = q<urn:x-suika-fam-cx:fuyubi:>;
our $BASE_URI = q<http://suika.fam.cx/~wakaba/d/>;
our $BASE_LANG = 'ja';
our $FEED_CURRENT_PATH = $REPOSITORY_PATH.'current.'.$BASE_LANG.'.atom';
our $AUTHOR_NAME = q<わかば>;
our $AUTHOR_URI = q<http://suika.fam.cx/~wakaba/who?>;
our $AUTHOR_MAIL = q<w@suika.fam.cx>;

use Message::Markup::Atom;
use Message::DOM::DOMFeature;
use Message::DOM::GenericLS;
use Message::DOM::XMLParser;
use Message::DOM::SimpleLS;
use Encode::EUCJP1997;

my ($year, $month) = @ARGV;
$year += 0;
$month += 0;

my $atom = q<http://www.w3.org/2005/Atom>;
my $fe = q<http://suika.fam.cx/www/2006/feature/>;
my $cfg = q<http://suika.fam.cx/www/2006/dom-config/>;
my $html = q<http://www.w3.org/1999/xhtml>;
my $xml = q<http://www.w3.org/XML/1998/namespace>;
my $xhtml2 = q<http://www.w3.org/2002/06/xhtml2/>;
my $h2h = q<http://suika.fam.cx/~wakaba/archive/2005/manakai/Markup/H2H/>;

my $gls = $Message::DOM::ImplementationRegistry->get_implementation
            ({
              $fe.'GenericLS' => '3.0',
            });
my $aimpl = $gls->get_feature ($fe.'Atom' => '1.0');

my $xp = $gls->create_gls_parser ({
           LS => '3.0',
         });

my $feed_doc = $aimpl->create_atom_feed_document
                         ($FEED_TAG.$year.':'.$month.':');
$feed_doc->dom_config->set_parameter ($cfg.'create-child-element' => 1);

my $atom_feed = $feed_doc->document_element;
$atom_feed->set_attribute_ns ($xml, 'xml:base', $BASE_URI);
$atom_feed->set_attribute_ns ($xml, 'xml:lang', $BASE_LANG);
$atom_feed->title_element->text_content ($FEED_NAME);

my $dir_name = $REPOSITORY_PATH.sprintf ('%04d', $year);
my $dym = sprintf 'd%04d%02d', $year, $month;
opendir my $dir, $dir_name or die "$0: $dir_name: $!";
for my $file_name (sort {$a cmp $b}
                   grep {substr ($_, 0, 7) eq $dym and
                         substr ($_, -(6 + length ($BASE_LANG)))
                             eq '.'.$BASE_LANG.'.atom'}
                   readdir $dir) {
  open my $entry_file, '<', $dir_name.'/'.$file_name
      or die "$0: $dir_name/$file_name: $!";
  my $entry_doc = $xp->parse ({byte_stream => $entry_file,
                               encoding => 'utf-8'});
  $atom_feed->append_child
      ($feed_doc->adopt_node ($entry_doc->document_element));
}
close $dir;

for my $author_el ($atom_feed->append_child
                       ($feed_doc->create_element_ns ($atom, 'author'))) {
  $author_el->name ($AUTHOR_NAME);
  $author_el->uri ($AUTHOR_URI) if defined $AUTHOR_URI;
  $author_el->email ($AUTHOR_MAIL) if defined $AUTHOR_MAIL;
}

for my $link_el ($atom_feed->append_child
                     ($feed_doc->create_element_ns ($atom, 'link'))) {
  $link_el->rel ('alternate');
  $link_el->href (sprintf 'd%04d%02d.%s.html', $year, $month, $BASE_LANG);
  $link_el->type ('text/html');
  $link_el->hreflang ($BASE_LANG);
}

for my $link_el ($atom_feed->append_child
                     ($feed_doc->create_element_ns ($atom, 'link'))) {
  $link_el->rel ('self');
  $link_el->href (sprintf 'd%04d%02d.%s.atom', $year, $month, $BASE_LANG);
  $link_el->type ('application/atom+xml');
  $link_el->hreflang ($BASE_LANG);
}

my $feed_file_name = $REPOSITORY_PATH.sprintf ('d%04d%02d', $year, $month)
                   . '.'.$BASE_LANG.'.atom';

my $ls = $gls->create_gls_serializer ({
           $fe.'SerializeDocumentInstance' => '1.0',
         });

open my $feed_file, '>', $feed_file_name
    or die "$0: $feed_file_name: $!";
  
my $data = Encode::encode ('utf-8', $ls->write_to_string ($feed_doc));
warn qq<Write to "$feed_file_name"\n>;
print $feed_file $data;
close $feed_file;
system 'chmod', 'go+r', $feed_file_name;
$? == -1 and die "$0: chmod $feed_file_name: $!";

open my $feed_file, '>', $FEED_CURRENT_PATH
    or die "$0: $FEED_CURRENT_PATH: $!";
warn qq<Write to "$FEED_CURRENT_PATH"\n>;
print $feed_file $data;
close $feed_file;



