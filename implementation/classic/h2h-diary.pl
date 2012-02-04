#!/usr/bin/perl
use strict;
use warnings;
use Path::Class;
use lib file (__FILE__)->dir->stringify;
use Getopt::Long;
use Encode;

#$H2H::themepath	= '/home/local/h2h/H2H/';
require H2H;
#require $H2H::themepath.'default/theme.ph';

my $DiaryFileDirectoryName;
my $DiaryTitle = 'My Diary';
my $DiaryTheme = 'Fuyubi';
GetOptions (
  'diary-file-directory-name=s' => \$DiaryFileDirectoryName,
  'diary-title=s' => \$DiaryTitle,
  'diary-theme=s' => \$DiaryTheme,
) or die "Options broken";
$DiaryTitle = encode 'euc-jp', decode 'utf-8', $DiaryTitle;

my %O;
($O{y}, $O{m}, $O{path}) = @ARGV;

my $rev;
unless ($O{y}) {
  (undef, undef, undef, undef, $O{m}, $O{y}) = localtime;  $O{m}++;
  $rev = 1;
}
$O{y} += 1900 if $O{y} < 1000;
$O{m} = substr('0'.$O{m}, -2);

my $DiaryFileD = dir ($DiaryFileDirectoryName)->absolute;
my $DiaryFileYearD = $DiaryFileD->subdir ($O{y});
$DiaryFileYearD->mkpath;

chdir $DiaryFileD->stringify;

my $basepath = $DiaryFileYearD->stringify . q</>;
my $hnffiles = qr/^d\Q$O{y}$O{m}\E(?:[0-9][0-9])\.hnf$/;
my $output_filename = $DiaryFileD->file ('d'.$O{y}.$O{m}.'.ja.html');
my $output_filename2 = $DiaryFileD->file ('current.ja.html');

opendir DIR, $basepath;
  my @FILELIST = (grep(/$hnffiles/, readdir(DIR)));
close DIR;

if ($rev)	{@FILELIST = sort {$b cmp $a} @FILELIST}
else	{@FILELIST = sort {$a cmp $b} @FILELIST}

my $output;

  my $h2h_d = file (__FILE__)->dir;

  my %boptions = (
    directory => $h2h_d->subdir ('H2H', 'V100', 'Theme')->stringify . q</>,
    theme => $DiaryTheme,
    theme09_directory => $h2h_d->subdir ('H2H', 'V090')->stringify . q</>,
    theme09 => 'default',
    title => $DiaryTitle,
    year => $O{y}, month => $O{m}+0,
  );
for my $fn (@FILELIST) {
  my %options = (%boptions);
  $fn =~ tr/\x0D\x0A//d;
  if ($fn =~ /(\d{4})(\d\d)(\d\d)/) {
          ($options{year},$options{month},$options{day}) = ($1,$2+0,$3+0)}
  elsif ($fn =~ /^(.+)\.hnf$/) {$options{prefix} = $1}
  if (-e $basepath.'.title'){open T,$basepath.'.title';$options{title}='';
                              while(<T>) {$options{title} .= $_} close T}
  $options{noheader} = 1; $options{nofooter} = 1;
  open HNF, '<', $basepath.$fn;
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
  my $data = Jcode->new ($output, 'euc')->jis;
  open HTML, '>', $output_filename;  binmode HTML;
    print HTML $data;
  close HTML;
  open HTML, '>', $output_filename2;  binmode HTML;
    print HTML $data;
  close HTML;

  system 'git', 'add',
      file ($output_filename)->relative ($DiaryFileD)->stringify,
      file ($output_filename2)->relative ($DiaryFileD)->stringify;
}

1;
