
#$H2H::themepath	= '/home/local/h2h/H2H/';
require H2H;
#require $H2H::themepath.'default/theme.ph';

my %O;
($O{y}, $O{m}, $O{path}) = @ARGV;

unless ($O{y}) {
  (undef, undef, undef, undef, $O{m}, $O{y}) = localtime;  $O{m}++;
  $rev = 1;
}
$O{y} += 1900 if $O{y} < 1000;
$O{m} = substr('0'.$O{m}, -2);
$O{path} = $O{path} || '/home/wakaba/public_html/d/'.$O{y}.'/';
    ## H2H Source directory

my $basepath = $O{path};
#$hnffiles = 'd'.$O{y}.$O{m}.'??.hnf';
my $hnffiles = qr/^d$O{y}$O{m}(?:[0-9][0-9])\.hnf$/;
my $output_filename = '/home/wakaba/public_html/d/d'.$O{y}.$O{m}.'.ja.html';

#open A, '| dir /B '.$basepath.$hnffiles.' > .filelist.txt';  close A;
#open D, '.filelist.txt';  @FILELIST = <D>; close D;
opendir DIR, $basepath;
  my @FILELIST = (grep(/$hnffiles/, readdir(DIR)));
close DIR;

if ($rev)	{@FILELIST = sort {$b cmp $a} @FILELIST}
else	{@FILELIST = sort {$a cmp $b} @FILELIST}

my $output;

  my %boptions = (
    directory => 'H2H/V100/Theme/', theme => 'Fuyubi',
    theme09_directory => 'H2H/V090/',
    theme09 => 'default',
    title => '冬様もすなる☆日記というもの',
    year => $O{y}, month => $O{m}+0,
  );
for $fn (@FILELIST) {
  my %options = (%boptions);
  $fn =~ tr/\x0D\x0A//d;
  if ($fn =~ /(\d{4})(\d\d)(\d\d)/) {
          ($options{year},$options{month},$options{day}) = ($1,$2+0,$3+0)}
  elsif ($fn =~ /^(.+)\.hnf$/) {$options{prefix} = $1}
  if (-e $basepath.'.title'){open T,$basepath.'.title';$options{title}='';
                              while(<T>) {$options{title} .= $_} close T}
  $options{noheader} = 1; $options{nofooter} = 1;
  open HNF, $basepath.$fn;
    $output .= H2H->toHTML(\%options, <HNF>);
  close HNF;
}

if ($output) {
    use Jcode;
  #require 'jcode.pl';
  $boptions{version} = 'H2H/1.0';
  $output = H2H->header(\%boptions).$output.
            H2H->footer(\%boptions);
  #my $s = &H2H::Page::start($title).$output.&H2H::Page::end($title);
  #jcode::convert(\$output, 'jis', 'euc');
  open HTML, '> '.$output_filename;  binmode HTML;
    print HTML Jcode->new ($output, 'euc')->jis;
  close HTML;
}

1;
