
(undef, undef, undef, $d, $m, $y) = localtime;  $m++;


$y += 1900 if $y < 1000;
$m = substr('0'.$m, -2);
$d = substr('0'.$d, -2);

unless (-e 'd:\\home\\local\\d\\'.$y.'\\d'.$y.$m.$d.'.hnf') {
  open D, '> d:\\home\\local\\d\\'.$y.'\\d'.$y.$m.$d.'.hnf';
    binmode D; print D "H2H/1.0\x0d\x0aTENKI À²\x0d\x0aOK\x0d\x0a\x0d\x0aNEW ";
  close D;
}

system 'c:\\programs\\hidemaru\\hidemaru d:\\home\\local\\d\\'.$y.'\\d'.$y.$m.$d.'.hnf';

require 'h2h-diary.pl';
print STDERR "Opening folder window...";
#system 'start D:\home\suika\public_html\d';
system qq(scp /cygdrive/d/home/suika/public_html/d/d$y$m.ja.html wakaba\@suika.fam.cx:/home/wakaba/public_html/d/);
