
require H2H;


my $basepath = shift(@main::ARGV);
my $hnffiles = qr/^[\x00-\xFF]+?\.(?:hnf|h2h)$/;
my $output_filename = shift(@main::ARGV);
$basepath =~ tr#\\#/#;
$basepath.= '/' unless substr($basepath,-1) eq '/';
$H2H::Page::basepath = shift(@main::ARGV);
unless ($output_filename) {
  my $path = substr($basepath, 0, length($basepath) - 1);
  $output_filename = $path.'.ja.html';
}

#open A, '| dir /B '.$basepath.$hnffiles.' > .filelist.txt';  close A;
#open D, '.filelist.txt';  @FILELIST = <D>; close D;
opendir DIR, $basepath;
  my @FILELIST = (grep(/$hnffiles/, readdir(DIR)));
close DIR;

if ($rev)	{@FILELIST = sort {$b cmp $a} @FILELIST}
else	{@FILELIST = sort {$a cmp $b} @FILELIST}

my $output;

  my %boptions = (
    directory => 'H2H/V100/Theme/', theme => 'Glossary',
    theme09_directory => '/home/local/h2h/H2H/V090/',
    theme09 => 'glossary',
    title => '用語集',
    keyword => '用語, 辞書, 辞典, 字典, 事典',
    description => '用語集(謎)であります。',
  );
  if(-e $basepath.'.title') {open T,$basepath.'.title';$options{title}='';
                              while(<T>) {$options{title} .= $_} close T}
  if(-e $basepath.'.header'){$options{headerfile} = $basepath.'.header'}
  if(-e $basepath.'.footer'){$options{footerfile} = $basepath.'.footer'}
  if (-e $basepath.'.rc')   {require $basepath.'.rc';
                             &H2H::RC::init(\%boptions)}
for $fn (@FILELIST) {
  my %options = (%boptions);
  $fn =~ tr/\x0D\x0A//d;
  if ($fn =~ /^(.+)\.(?:hnf|h2h)$/) {$options{prefix} = $1}
  $options{noheader} = 1; $options{nofooter} = 1;
  open HNF, $basepath.$fn;
    $output .= H2H->toHTML(\%options, <HNF>);
  close HNF;
}

if ($output) {
  require '/home/suika/lib/jcode.pl';
  $boptions{version} = 'H2H/1.0';
  $output = H2H->header(\%boptions).$output.
            H2H->footer(\%boptions);
  jcode::convert(\$output, 'jis', 'euc');
  open HTML, '> '.$output_filename;  binmode HTML;
    print HTML $output;
  close HTML;
}

1;
