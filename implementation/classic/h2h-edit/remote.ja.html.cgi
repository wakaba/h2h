#!/usr/bin/perl

use Suika::CGI;

Suika::CGI::Error::die('open', file => $Suika::CGI::param{file})
   unless -e $Suika::CGI::param{file};
Suika::CGI::Error::die('open', file => $Suika::CGI::param{file})
   unless $Suika::CGI::param{file} =~ 
     m#\.(?:h2h|hnf|html|txt)(?:\.(?:jis|euc|sjis|sj3|ej3))?$#;
if ($Suika::CGI::param{file} =~ m#^/usr/local/apache/htdocs/okuchuu/blue-oceans/([\x00-\xFF]+)$#) {
  Suika::CGI::Error::die('open', file => $Suika::CGI::param{file})
    unless $main::ENV{REMOTE_USER} =~ m#^(?:fujii|wakaba)$#;
  $Suika::CGI::param{uri} ||= 'http://suika.fam.cx/okuchuu/blue-oceans/'.$1;
} elsif ($Suika::CGI::param{file} =~ m#^/usr/local/apache/htdocs/([\x00-\xFF]+)$#) {
  Suika::CGI::Error::die('open', file => $Suika::CGI::param{file})
    unless $main::ENV{REMOTE_USER} eq 'wakaba';
  $Suika::CGI::param{uri} ||= 'http://suika.fam.cx/'.$1;
} elsif ($Suika::CGI::param{file} =~ m#^/home/wakaba/public_html/([\x00-\xFF]+)$#) {
  Suika::CGI::Error::die('open', file => $Suika::CGI::param{file})
    unless $main::ENV{REMOTE_USER} eq 'wakaba';
  $Suika::CGI::param{uri} ||= 'http://suika.fam.cx/~wakaba/'.$1;
} else {
  ## Permissionally deny.
  Suika::CGI::Error::die('open', file => $Suika::CGI::param{file});
}

if ($Suika::CGI::param{mode} eq 'post') {
  print edit_post(%Suika::CGI::param);
} else {
  print edit_input(%Suika::CGI::param);
}

sub edit_input {
  my %o = @_;
  
  open H2H, $o{file}
    or  Suika::CGI::Error::die('open', file => $o{file});
    my $h2h = _html(join('', <H2H>));
  close H2H;
  
  jcode::jis(<<EOH);
Content-Type: text/html; charset=jis_encoding
Content-Style-Type: text/css

<html lang="ja">
<head>
<title>$o{file}</title>
<link rel="stylesheet" href="/s/simpledoc" />
<meta name="ROBOTS" content="NOINDEX" />
</head>
<body>
<h1>ï“èW</h1>

<form action="?" method="post" accept-charset="iso-2022-jp">

<p>ñ{ï∂:<br />
<input type="hidden" name="file" value="$o{file}" />
<input type="hidden" name="mode" value="post" />
<textarea name="body" style="width: 90%; height: 20em; font-size: 100%">
$h2h
</textarea>
</p>

<p>
<input type="submit" value="OK" />
</p>
</form>

<address>
[<a href="/">/</a>]
[<a href="$o{uri}">$o{uri}</a>]
</address>
</body>
</html>
EOH
}

sub edit_post {
  my %o = @_;
  
  Suika::CGI::Error::die('empty') unless $o{body};
  open H2H, '> '.$o{file}
    or  Suika::CGI::Error::die('write', file => $o{file});
    print H2H $o{body};
  close H2H;
  
  edit_input(%o);
}

sub _html {
  my $s = shift;
  $s =~ s/&/&amp;/g;
  $s =~ s/</&lt;/g;
  $s =~ s/>/&gt;/g;
  $s =~ s/"/&quot;/g;
  $s;
}

1;
