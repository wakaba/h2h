
=head1 NAME

H2H::V090.pm

=head1 DESCRIPTION

H2H/0.9 -> HTML converter core module

=cut

package H2H::V090;
$VERSION = '0.90';

=head1 parse()

Convert to HTML.

=head2 EXAMPLE

my $converted_html = H2H::V090->parse([2000,8,13,'diary'], @H2H_DOCUMENT);

=cut

sub parse {
  my ($self, $prefix, @HNF) = @_;
  &H2H::Template::init($prefix->{year},$prefix->{month},$prefix->{day},
                       $prefix->{prefix});
  my ($header, $cd, %c) = (1, 0);
  my ($retheader, $rethtml) = &H2H::HnfFile::start();
  
    for (@HNF) {
      my $ret = $_;
      $ret =~ tr/\x0d\x0a//d;
      $ret =~ s/[ \t]+$//;
      if ($ret) {
        if ($header) {
          if ($ret eq 'OK') {
            $header = 0;
            $retheader .= &H2H::HnfFile::endheader();
          } else {
            if ($ret =~ /^([0-9A-Z]+) +(.+)$/) {
              $retheader .= &H2H::HnfFile::headervar($1, $2);
            } elsif ($ret =~ /^([0-9A-Z]+)\* +([^ ]+) +(.+)$/) {
              $retheader .= &H2H::HnfFile::headervar($1, $3, $2);
            } else {
              $retheader .= $H2H::error::invalidheader.$ret;
            }
          } undef $ret;
        } elsif ($c{$cd}{fn}) {
          if ($ret eq '/FN') {
            &H2H::Command::endFN();  $c{$cd}{fn} = 0;  undef $ret;
          } elsif ($ret =~ /^LINK +([^ ]+) +(.+)$/) {
            undef $ret;
            &H2H::Command::textFN(&H2H::Command::textLINK($1, $2));
          } elsif ($ret =~ /^RUBY +([^ ]+) +(.+)$/) {
            undef $ret;
            &H2H::Command::textFN(&H2H::Command::textRUBY($1, $2));
          } else {
            &H2H::Command::textFN($ret);  undef $ret;
          }
        } elsif ($c{$cd}{ul} || $c{$cd}{ol}) {
          if ($ret eq '/UL') {
            $ret = &H2H::Command::endUL();  $c{$cd}{ul} = 0;
          } elsif ($ret eq '/OL') {
            $ret = &H2H::Command::endOL();  $c{$cd}{ol} = 0;
          } elsif ($ret =~ /^LI\* +([^ ]+) +(.+)/) {
            $ret = &H2H::Command::textLI(&H2H::Command::textLINK($1,$2));
          } else {
            $ret =~ s/^LI +//;
            $ret = &H2H::Command::textLI($ret);
          }
        } else {
          if ($ret eq 'P') {
            undef $ret;
            $ret = &H2H::Command::endP() if $c{$cd}{p};
            $ret .= &H2H::Command::endPRE()	if $c{$cd}{pre};  $c{$cd}{pre} = 0;
            $ret .= &H2H::Command::startP();  $c{$cd}{p} = 1;
          } elsif ($ret =~ /^NEW +(.+)/) {
            undef $ret;
            $ret = &H2H::Command::endP()	if $c{$cd}{p};  $c{$cd}{p} = 0;
            $ret .= &H2H::Command::endPRE()	if $c{$cd}{pre};  $c{$cd}{pre} = 0;
            $ret .= &H2H::Command::endDIV()	if $c{$cd}{div};  $c{$cd}{div} = 0;
            $ret .= &H2H::Command::endSUB()	if $c{$cd}{sub};  $c{$cd}{sub} = 0;
            $ret .= &H2H::Command::endNEW()	if $c{$cd}{new};
            $ret .= &H2H::Command::startNEW($1);	$c{$cd}{new} = 1;
          } elsif ($ret =~ /^NEW\* +([^ ]+) +(.+)/) {
            undef $ret;
            $ret = &H2H::Command::endP()	if $c{$cd}{p};	$c{$cd}{p} = 0;
            $ret .= &H2H::Command::endPRE()	if $c{$cd}{pre};  $c{$cd}{pre} = 0;
            $ret .= &H2H::Command::endDIV()	if $c{$cd}{div};  $c{$cd}{div} = 0;
            $ret .= &H2H::Command::endSUB()	if $c{$cd}{sub};  $c{$cd}{sub} = 0;
            $ret .= &H2H::Command::endNEW()	if $c{$cd}{new};
            $ret .= &H2H::Command::startNEW($2,$1);	$c{$cd}{new} = 1;
          } elsif ($ret eq 'FN') {
            $ret = &H2H::Command::startFN();	$c{$cd}{fn} = 1;
          } elsif ($ret =~ /^YAMI(?: +(.+))?$/) {
            if ($1) {
              $ret = &H2H::Command::startYAMI($1);
            } else {
              undef $ret;
              $ret = &H2H::Command::endYAMI()	if $c{$cd}{yami}; $c{$cd}{yami} = 0;
              $ret .= &H2H::Command::startYAMI();	$c{$cd}{yami} = 1;
            }
          } elsif ($ret eq '/YAMI') {
            $ret = &H2H::Command::endYAMI($1);	$c{$cd}{yami} = 0;
          } elsif ($ret =~ /^RUBY +([^ ]+) +(.+)$/) {
            $ret = &H2H::Command::textRUBY($1, $2);
          } elsif ($ret =~ /^ACRONYM +([^ ]+) +(.+)$/) {
            $ret = &H2H::Command::textACRONYM($1, $2);
          } elsif ($ret =~ /^ABBR +([^ ]+) +(.+)$/) {
            $ret = &H2H::Command::textABBR($1, $2);
          } elsif ($ret =~ /^LINK +([^ ]+) +(.+)$/) {
            $ret = &H2H::Command::textLINK($1, $2);
          } elsif ($ret =~ /^PERSON +([^ ]+) +(.+)$/) {
            $ret = &H2H::Command::textPERSON($1, $2);
          } elsif ($ret =~ /^LDIARY +(\d\d\d\d) +(\d\d?) +(\d\d?) +(.+)$/) {
            $ret = &H2H::Command::textLDIARY($1, $2, $3, $4);
          } elsif ($ret=~/^LDIARY +(\d\d\d\d\d\d\d\d(?:i\d\d(?:s\d\d)?)?) +(.+)$/) {
            $ret = &H2H::Command::textLDIARY2($1, $2);
          } elsif ($ret=~/^SEE +([^ ]+) +(.+)$/) {
            $ret = &H2H::Command::textSEE($1, $2);
          } elsif ($ret =~ /^SUB +(.+)/) {
            undef $ret;
            $ret = &H2H::Command::endP()	if $c{$cd}{p};  $c{$cd}{p} = 0;
            $ret .= &H2H::Command::endPRE()	if $c{$cd}{pre};  $c{$cd}{pre} = 0;
            $ret .= &H2H::Command::endDIV()	if $c{$cd}{div};  $c{$cd}{div} = 0;
            $ret .= &H2H::Command::endSUB()	if $c{$cd}{sub};
            $ret .= &H2H::Command::startSUB($1);	$c{$cd}{sub} = 1;
          } elsif ($ret =~ /^SUB\* +([^ ]+) +(.+)/) {
            undef $ret;
            $ret = &H2H::Command::endP()	if $c{$cd}{p};  $c{$cd}{p} = 0;
            $ret .= &H2H::Command::endPRE()	if $c{$cd}{pre};  $c{$cd}{pre} = 0;
            $ret .= &H2H::Command::endDIV()	if $c{$cd}{div};  $c{$cd}{div} = 0;
            $ret .= &H2H::Command::endSUB()	if $c{$cd}{sub};
            $ret .= &H2H::Command::startSUB($2,$1);	$c{$cd}{sub} = 1;
          } elsif ($ret =~ /^CITE\*?(?: +([^ ]+)(?: +(.+))?)?$/) {
            undef $ret;
            $ret .= &H2H::Command::endPRE()	if $c{$cd}{pre};  $c{$cd}{pre} = 0;
            $ret = &H2H::Command::startCITE($1, $2);	$cd++;
          } elsif ($ret eq '/CITE') {
            undef $ret;
            $ret = &H2H::Command::endP()	if $c{$cd}{p};  $c{$cd}{p} = 0;
            $ret .= &H2H::Command::endPRE()	if $c{$cd}{pre};  $c{$cd}{pre} = 0;
            $ret .= &H2H::Command::endDIV()	if $c{$cd}{div};  $c{$cd}{div} = 0;
            $ret .= &H2H::Command::endYAMI()	if $c{$cd}{yami}; $c{$cd}{yami} = 0;
            $ret .= &H2H::Command::endCITE();	$cd--;
          } elsif ($ret =~ /^DIV +(.+)$/) {
            undef $ret;
            $ret = &H2H::Command::endP()	if $c{$cd}{p};  $c{$cd}{p} = 0;
            $ret .= &H2H::Command::startDIV($1);	$c{$cd}{div} = 1;
          } elsif ($ret eq '/DIV') {
            $ret = &H2H::Command::endP()	if $c{$cd}{p};  $c{$cd}{p} = 0;
            $ret = &H2H::Command::endPRE()	if $c{$cd}{pre};  $c{$cd}{pre} = 0;
            $ret = &H2H::Command::endDIV();	$c{$cd}{div} = 0;
          } elsif ($ret eq 'PRE') {
            undef $ret;
            $ret = &H2H::Command::endP()	if $c{$cd}{p};  $c{$cd}{p} = 0;
            $ret .= &H2H::Command::startPRE();	$c{$cd}{pre} = 1;
          } elsif ($ret eq '/PRE') {
            $ret = &H2H::Command::endPRE();	$c{$cd}{pre} = 0;
          } elsif ($ret eq 'UL') {
            undef $ret;
            $ret .= &H2H::Command::endPRE()	if $c{$cd}{pre};  $c{$cd}{pre} = 0;
            $ret = &H2H::Command::startUL();	$c{$cd}{ul} = 1;
          } elsif ($ret eq 'OL') {
            undef $ret;
            $ret .= &H2H::Command::endPRE()	if $c{$cd}{pre};  $c{$cd}{pre} = 0;
            $ret = &H2H::Command::startOL();	$c{$cd}{ol} = 1;
          } elsif ($ret =~ /^LMG +([^ ]+) +(.+)$/) {
            $ret = &H2H::Command::textLMG($1,$2,$3);
          } elsif ($ret =~ /^LIMG +([^ ]+) +[^ ] +([^ ]+) +(.+)$/) {
            $ret = &H2H::Command::textLIMG($1,$2,$3);
          } elsif ($ret =~ /^! +(.+)$/) {
            $ret = &H2H::Command::textCOMMENT($1);
          } elsif ($ret =~ /^!# +(.+)$/) {
            $ret = &H2H::Command::textCOMMENT2($1);
          } elsif ($ret eq '/P') {
            $ret = &H2H::Command::endP()	if $c{$cd}{p}; $c{$cd}{p} = 0;
          }
        }
        $rethtml .= $ret.$H2H::nl if $ret;
      }
    }
    
    while ($cd) {
      $rethtml .= &H2H::Command::endP()	if $c{$cd}{p};
      $rethtml .= &H2H::Command::endYAMI()	if $c{$cd}{yami};
      $rethtml .= &H2H::Command::endCITE();	$cd--;
    }
    $rethtml .= &H2H::Command::endP()	if $c{0}{p};
    $rethtml .= &H2H::Command::endYAMI()	if $c{0}{yami};
    $rethtml .= &H2H::Command::endSUB()	if $c{0}{sub};
    $rethtml .= &H2H::Command::endNEW()	if $c{0}{new};
    $rethtml .= &H2H::HnfFile::footnote();
    $rethtml .= &H2H::HnfFile::end();
  $self->{html} = $retheader.&H2H::HnfFile::tree().$rethtml;
  $self->{html};
}

=head1 LICENSE

Public Domain.

=head1 CHANGE

2001-08-13  wakaba <wakaba@suika.fam.cx>

	* H2H::V090.pm: Copied.  H2H/1.0 functions are removed.

2001-04-29  wakaba

	* H2H::V100.pm: Forked.
	* H2H::V100.pm: H2H/1.0 support.

2001-04-03  wakaba

	* H2H.pm: Modulization.
	* H2H.pm: Add `DIV' support.
	* H2H.pm: Add `RUBY' support (in FN).

2001-03-31  wakaba

	* H2H.pm: New file.

=cut

1;
