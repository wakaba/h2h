#!/usr/bin/perl
use strict;
use warnings;
use Path::Class;
use lib file (__FILE__)->dir->absolute->stringify;
use lib file (__FILE__)->dir->parent->parent->subdir ('modules', 'manakai', 'lib')->absolute->stringify;
use Carp;
use Encode;
use Message::MIME::Charset::Jcode 'Jcode';
use Message::Entity;

sub u8 ($) { encode 'utf-8', $_[0] }

my $conf_file_name = shift or die "Usage: $0 config-file\n";

our $RootD;
our $DiaryID;
our $DiaryTitle;
our $DiaryTheme;
our $DiaryTagURLPrefix;
our $DiaryBaseURL;
our $DiaryBaseLang;
our $DiaryAuthorName;
our $DiaryAuthorURL;
our $DiaryAuthorMailAddr;
do $conf_file_name or die $@;

$RootD = $RootD->absolute;
my $MailLogD = $RootD->subdir ('data', $DiaryID, 'maillog');
my $DiaryDataD = $RootD->subdir ('data', $DiaryID, 'files');
my $H2HImplD = file (__FILE__)->dir->absolute;

$MailLogD->mkpath;

unless (-d $DiaryDataD->stringify) {
  $DiaryDataD->mkpath;
  chdir $DiaryDataD->stringify;
  system 'git', 'init';
}

my $now = time;
my @now = (localtime);
my $i = 0;
my $log_file_name = $MailLogD->file ($now . '.822');
while (-e $log_file_name) {
  $log_file_name = $MailLogD->file ($now . '-' . ++$i . '.822');
}

my $lmsg = '';
{
  open my $msg_log_file, '>', $log_file_name or die "$1: $log_file_name: $!";
  binmode STDIN;
  binmode $msg_log_file;
  while (defined ($_ = <STDIN>)) {
    $lmsg .= $_;
    print $msg_log_file $_;
  }
  close $msg_log_file;
}

my $msg = parse Message::Entity $lmsg,
                  -parse_all => 0,
                  -linebreak_strict => 0,
                  -add_ua => 0,
                  -fill_msgid => 0,
                  -fill_date => 0,
                  -fill_ct => 0;

my $subj = $msg->header->field ('subject');
$subj = defined $subj ? decode 'iso-2022-jp', ''.$subj : '';
$subj =~ s/^\s+//;
$subj =~ s/\s+\z//;
$subj =~ s/\s+/ /g;

my $body = $msg->body;
$body = defined $body ? decode 'iso-2022-jp', ''.$body : '';
$body =~ tr/\x0D//d;
$body =~ s/^\x0A+//;
$body =~ s/\x0A+\z//;
$body =~ s/\x0A\x0A+/\x0AP\x0A/g;
$body = qq<P\x0A> . $body unless $body =~ /^[A-Z-]+\b/;

my $diary_year_d = $DiaryDataD->subdir (sprintf '%04d/', $now[5] + 1900);
$diary_year_d->mkpath;
my $diary_f = $diary_year_d->file
    (sprintf 'd%04d%02d%02d.hnf', $now[5] + 1900, $now[4] + 1, $now[3]);

my $diary_file;

if (-e $diary_f) {
  open $diary_file, '>>', $diary_f->stringify or die "$1: $diary_f: $!";
} else {
  open $diary_file, '>', $diary_f->stringify or die "$1: $diary_f: $!";
  print $diary_file qq<H2H/1.0\x0AOK\x0A\x0A>;
}

print $diary_file encode 'euc-jp',
    sprintf qq<NEW %s (\@%02d:%02d +09:00)\x0A>, $subj, $now[2], $now[1];
print $diary_file encode 'euc-jp', $body;
print $diary_file "\x0A";

close $diary_file;

chdir $diary_year_d->stringify;
system 'git', 'add', $diary_f->relative ($diary_year_d)->stringify;
system 'chmod', 'go+r', $diary_f->relative ($diary_year_d)->stringify;

system 'perl', $H2HImplD->file ('h2h-diary.pl')->stringify,
    $now[5] + 1900, $now[4] + 1, $now[3],
    '--diary-file-directory-name' => $DiaryDataD->absolute->stringify,
    '--diary-title' => u8 $DiaryTitle,
    '--diary-theme' => $DiaryTheme;

system 'perl', $H2HImplD->file ('generate-atom-entry.pl')->stringify,
    $now[5] + 1900, $now[4] + 1, $now[3],
    '--diary-file-directory-name' => $DiaryDataD->absolute->stringify,
    '--feed-tag-url-prefix' => $DiaryTagURLPrefix,
    '--base-url' => $DiaryBaseURL,
    '--base-lang' => $DiaryBaseLang,
    '--author-name' => u8 $DiaryAuthorName,
    '--author-url' => $DiaryAuthorURL,
    '--author-mail-addr' => $DiaryAuthorMailAddr;

system 'perl', $H2HImplD->file ('generate-atom-feed.pl')->stringify,
    $now[5] + 1900, $now[4] + 1,
    '--diary-file-directory-name' => $DiaryDataD->absolute->stringify,
    '--diary-title' => u8 $DiaryTitle,
    '--feed-tag-url-prefix' => $DiaryTagURLPrefix,
    '--base-url' => $DiaryBaseURL,
    '--base-lang' => $DiaryBaseLang,
    '--author-name' => u8 $DiaryAuthorName,
    '--author-url' => $DiaryAuthorURL,
    '--author-mail-addr' => $DiaryAuthorMailAddr;

system 'git', 'commit', -m => 'auto';
system 'git', 'push', 'origin', 'master';
