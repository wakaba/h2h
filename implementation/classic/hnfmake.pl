
$H2H::themepath	= '/home/local/h2h/H2H/';
require H2H;
require $H2H::themepath.'general/theme.ph';

my ($basepath,$output_filename) = @main::ARGV;
exit unless $basepath;
$basepath =~ tr#/#\\#;
$basepath.= '\\' unless substr($basepath,-1) eq '\\';
$H2H::Page::basepath = $main::ARGV[2];

$hnffiles = '*.hnf';
unless ($output_filename) {
  my $path = substr($basepath, 0, length($basepath) - 1);
  $output_filename = $path.'.ja.html';
}

open A, '| dir /B '.$basepath.$hnffiles.' > \\home\\local\\h2h\\.filelist.txt';  close A;
open D, '\\home\\local\\h2h\\.filelist.txt';  @FILELIST = <D>; close D;

my $output;@FILELIST = sort {$a cmp $b} @FILELIST;

for (@FILELIST) {  chop;
  my @prefix;  if (/^(?:s\d+-)?(.+)\.hnf$/) {$prefix[3] = $1}
  open HNF, $basepath.$_;
    my @HNF = <HNF>;
    $output .= &H2H::h2h(undef, \@prefix, @HNF);
  close HNF;
}

if ($output) {
  my $title;
  if (-e $basepath.'.header') {$H2H::Template::header = $basepath.'.header'}
  if (-e $basepath.'.footer') {$H2H::Template::footer = $basepath.'.footer'}
  if(-e $basepath.'.title'){open T,$basepath.'.title';while(<T>){$title.=$_}close T}
  require '/home/suika/lib/jcode.pl';
  my $s = &H2H::Page::start($title).$output.&H2H::Page::end($title);
  jcode::convert(\$s, 'jis', 'euc');
  open HTML, '> '.$output_filename;  binmode HTML;
    print HTML $s;
  close HTML;
}
1;
