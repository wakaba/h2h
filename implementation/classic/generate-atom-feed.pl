#!/usr/bin/perl
use strict;
use warnings;
use Path::Class;
use lib file (__FILE__)->dir->parent->parent->subdir ('modules', 'manakai', 'lib')->stringify;
use lib file (__FILE__)->dir->parent->parent->subdir ('modules', 'charclass', 'lib')->stringify;
use Message::DOM::DOMImplementation;
use Encode;
use Getopt::Long;

our $REPOSITORY_PATH = q<path/to/files/>;
our $FEED_NAME = q<Test Diary>;
our $FEED_TAG = q<data:,tag-url-prefix:>;
our $BASE_URI = q</url/path/of/diary/>;
our $BASE_LANG = 'und';
our $AUTHOR_NAME = q<Author San>;
our $AUTHOR_URI = q<http://example/url/of/author>;
our $AUTHOR_MAIL = q<author-san@example.com>;

GetOptions (
  'diary-file-directory-name=s' => \$REPOSITORY_PATH,
  'diary-title=s' => \$FEED_NAME,
  'feed-tag-url-prefix=s' => \$FEED_TAG,
  'base-url=s' => \$BASE_URI,
  'base-lang=s' => \$BASE_LANG,
  'author-name=s' => \$AUTHOR_NAME,
  'author-url=s' => \$AUTHOR_URI,
  'author-mail-addr=s' => \$AUTHOR_MAIL,
) or die "Broken input";
$FEED_NAME = decode 'utf-8', $FEED_NAME if defined $FEED_NAME;
$AUTHOR_NAME = decode 'utf-8', $AUTHOR_NAME if defined $AUTHOR_NAME;

my $DiaryFileD = dir ($REPOSITORY_PATH);

our $FEED_CURRENT_PATH = $DiaryFileD->file ('current.'.$BASE_LANG.'.atom')->stringify;

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

my $impl = Message::DOM::DOMImplementation->new;

my $feed_doc = $impl->create_atom_feed_document
                         ($FEED_TAG.$year.':'.$month.':');
$feed_doc->dom_config->set_parameter ($cfg.'create-child-element' => 1);

my $atom_feed = $feed_doc->document_element;
$atom_feed->set_attribute_ns ($xml, 'xml:base', $BASE_URI);
$atom_feed->set_attribute_ns ($xml, 'xml:lang', $BASE_LANG);
$atom_feed->title_element->text_content ($FEED_NAME);


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

my $dir_name = $DiaryFileD->subdir ($year);
my $dym = sprintf 'd%04d%02d', $year, $month;
opendir my $dir, $dir_name or die "$0: $dir_name: $!";
for my $file_name (sort {$a cmp $b}
                   grep {substr ($_, 0, 7) eq $dym and
                         substr ($_, -(6 + length ($BASE_LANG)))
                             eq '.'.$BASE_LANG.'.atom'}
                   readdir $dir) {
  open my $entry_file, '<:utf8', $dir_name.'/'.$file_name
      or die "$0: $dir_name/$file_name: $!";
  local $/ = undef;
  my $entry_text = <$entry_file>;
  my $entry_doc = $impl->create_document;
  $entry_doc->inner_html ($entry_text);
  $atom_feed->append_child
      ($feed_doc->adopt_node ($entry_doc->document_element));
}
close $dir;

my $feed_file_name = $DiaryFileD->file (sprintf ('d%04d%02d', $year, $month)
                   . '.'.$BASE_LANG.'.atom');

open my $feed_file, '>', $feed_file_name
    or die "$0: $feed_file_name: $!";
warn qq<Write to "$feed_file_name"\n>;
my $data = Encode::encode ('utf-8', $feed_doc->inner_html);
print $feed_file $data;
close $feed_file;

open my $feed_file, '>', $FEED_CURRENT_PATH
    or die "$0: $FEED_CURRENT_PATH: $!";
warn qq<Write to "$FEED_CURRENT_PATH"\n>;
print $feed_file $data;
close $feed_file;

chdir $DiaryFileD->stringify;
system 'git', 'add', 
    file ($feed_file_name)->relative ($DiaryFileD),
    file ($FEED_CURRENT_PATH)->relative ($DiaryFileD);
system 'chmod', 'go+r', 
    file ($feed_file_name)->relative ($DiaryFileD),
    file ($FEED_CURRENT_PATH)->relative ($DiaryFileD);
