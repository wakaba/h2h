#!/usr/bin/perl

(undef, undef, undef, $d, $m, $y) = localtime;  $m++;


$y += 1900 if $y < 1000;
$m = substr('0'.$m, -2);
$d = substr('0'.$d, -2);

my $h2h_path = qq(/home/wakaba/public_html/d/$y/d$y$m${d}.hnf);
unless (-e $h2h_path) {
  open D, '> '.$h2h_path;
    binmode D; print D "H2H/1.0\x0d\x0aTENKI À²\x0d\x0aOK\x0d\x0a\x0d\x0aNEW ";
  close D;
}

system 'emacs -nw '.$h2h_path;

require 'h2h-diary.pl';
#print STDERR "Opening folder window...";
#system 'start D:\home\suika\public_html\d';
#system qq(scp /cygdrive/d/home/suika/public_html/d/d$y$m.ja.html wakaba\@suika.fam.cx:/home/wakaba/public_html/d/);
