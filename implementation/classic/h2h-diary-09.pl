
$H2H::themepath	= '/home/local/h2h/H2H/';
require H2H;
require $H2H::themepath.'default/theme.ph';

($O{y}, $O{m}, $O{path}) = @ARGV;

unless ($O{y}) {
  (undef, undef, undef, undef, $O{m}, $O{y}) = localtime;  $O{m}++;
  $rev = 1;
}
$O{y} += 1900 if $O{y} < 1000;
$O{m} = substr('0'.$O{m}, -2);
$O{path} = $O{path} || '\\home\\local\\d\\'.$O{y}.'\\';

$basepath = $O{path};
$hnffiles = 'd'.$O{y}.$O{m}.'??.hnf';
$output_filename = '\\home\\suika\\public_html\\d\\d'.$O{y}.$O{m}.'.ja.html';

open A, '| dir /B '.$basepath.$hnffiles.' > .filelist.txt';  close A;
open D, '.filelist.txt';  @FILELIST = <D>; close D;

if ($rev)	{@FILELIST = sort {$b cmp $a} @FILELIST}
else	{@FILELIST = sort {$a cmp $b} @FILELIST}

my $output;

for (@FILELIST) {  chop;
  my @prefix;  if (/(\d{4})(\d\d)(\d\d)/) {@prefix = ($1,$2,$3)}
  elsif (/^(.+)\.hnf$/) {$prefix[3] = $1}
  open HNF, $basepath.$_;
    my @HNF = <HNF>;
    $output .= &H2H::h2h(undef, \@prefix, @HNF);
  close HNF;
}

if ($output) {
  my $title;
  if(-e $basepath.'.title'){open T,$basepath.'.title';while(<T>){$title.=$_}close T}
  require '/home/rocket/pl/jcode.pl';
  my $s = &H2H::Page::start($title).$output.&H2H::Page::end($title);
  jcode::convert(\$s, 'jis', 'euc');
  open HTML, '> '.$output_filename;  binmode HTML;
    print HTML $s;
  close HTML;
}

1;
