
=head1 NAME

H2H::V100::Theme::Glossary

=head1 DESCRIPTION

Theme of glossary,
for H2H/1.0.

=head1 ENCODING

EUC-JISX0213

=cut

package H2H::V100;

sub init_theme {
  my $self = shift;
  $self->{template}->{headerfile} 
     ||= $self->{template}->{directory}.'Glossary-header.htt';
  $self->{template}->{footerfile} 
     ||= $self->{template}->{directory}.'Glossary-footer.htt';
  undef $self->{template}->{headerfile} if $self->{template}->{noheader};
  undef $self->{template}->{footerfile} if $self->{template}->{nofooter};
  $self->{template}->{_BODY_param}->{id} = $self->{template}->{prefix};
  $self;
}

%cat = (
  '¤ª¤¯¤Á¤å¡£' => {caption => '<img src="/okuchuu/favicon" class="favicon" alt="¤ª¤¯¤Á¤å¡£" />'},
  '¤ª¤Õ¤æ' => {caption => '<img src="/~wakaba/art/icon/ofuyu" class="favicon" alt="¤ª¤Õ¤æ" />'},
  'À¾±»' => {caption => '<img src="/~wakaba/art/icon/suika" class="favicon" alt="À¾±»" />'},
  'ÅßÆü' => {caption => '<img src="favicon" class="favicon" alt="ÅßÆü" />'},
  '¤Á¤å¡¼¤Ö' => {caption => '<img src="/chuubu/favicon" class="favicon" alt="¤Á¤å¡¼¤Ö" />'},
  '¤È¤ß¤³¤¦' => {caption => '<img src="/~wakaba/art/icon/tomikou-c" class="favicon" alt="¤È¤ß¤³¤¦" />'},
  'Perl' => {caption => '<img src="/icons/perl" class="favicon" alt="Perl" />'},
  'Ìª´»' => {caption => '<img src="/chuubu/urimikan/favicon" class="favicon" alt="Ìª´»" />'},
);

package H2H::URI;
  $diary = 'http://suika.fam.cx/~wakaba/d/';
  $glossary{wakaba} = '/~wakaba/g/#';
  $glossary{r} = '/chuubu/2001/2-7/g/search?subquery=%2Buri%3A%2Fchuubu%2F2001%2F2-7%2Fg%2F&idxname=root&query=';
  $glossary{person} = '_person_#';
  $glossary{_} = $glossary{$glossary_default || 'wakaba'};
  $resolve = '/uri?uri=';
  $mine = $glossary{_};

package H2H::V100::headervalue;
%hdrtemplate = (
	%hdrtemplate,
	TENKI	=> \&tenki, #'[Å·µ¤:%value]',
	TAION	=> 'ÂÎ²¹: %valueÅÙ(ÀÝ»á)',
	LUNCH	=> 'Ãë¿©: %value',
	KEYWORD	=> '[¸°:%value]',
	CAT	=> \&cat, #'[Ê¬Îà:%value]',
	KION	=> '[µ¤²¹:%value]',
	T1	=> '1¸Â:%value',
	T2	=> '2¸Â:%value',
	T3	=> '3¸Â:%value',
	T4	=> '4¸Â:%value',
	T5	=> '5¸Â:%value',
	T6	=> '6¸Â:%value',
	T7	=> '7¸Â:%value',
	SP	=> '%value',
	YOMI	=> '[ÆÉ¤ß:%value]',
	ENGLISH	=> '[±Ñ¸ì:%value]',
	TITLE	=> \&title,
	ALIAS	=> \&title,
);

sub tenki {
  my %o = @_;
  $o{value} =~ s#&hare;#<img src="/~wakaba/d/hare" class="xbm_font" alt="¦è" />#g;
  $o{value}=~s#&kumori;#<img src="/~wakaba/d/kumori" class="xbm_font" alt="¦é" />#g;
  $o{value} =~ s#&ame;#<img src="/~wakaba/d/ame" class="xbm_font" alt="¦ê" />#g;
  $o{value} =~ s#&yuki;#<img src="/~wakaba/d/yuki" class="xbm_font" alt="¦ë" />#g;
  $t = '<a href="'.$o{href}.'">'.$t.'</a>' if $o{href};
  '<span class="var '.$o{name}.'">[Å·µ¤:'.$o{value}.']</span>'."\n";
}
sub cat {
  my $self = shift;
  my $cat = shift;
  $cat = $H2H::V100::cat{$cat}->{caption} || $cat; ## TO DO: self->__html_ent();
  '<span class="var CAT">['.$cat.']</span>'."\n" if $cat;;
}
sub title {
  '';
}

package H2H::V100::Command::_BODY;

sub _init {
  my $self = shift;
  $self->{param}->{class}.= ' body';
  $self->{_HTML}->{start} = '<div%ATTR%>'.
    '<h2><a href="#'.$self->{param}->{id}.'" class="self">'.
    '¡þ</a> '.
    $self->{theme}->{header}->{TITLE}->{'text/x-h2h'}.'</h2>'."\n".
    $self->{theme}->{hdr}."\n";
  $self->{_HTML}->{end} = "</div><!-- class='body' -->\n";
  $self->{footnotes}->{parent} = \$self;
  $self;
}

package H2H::V100::Command::NEW;

sub _init_value {
  my $self = shift;
  $self->{command}->{listitem} = '¡ù';
}

package H2H::V100::Command::SUB;

sub _init_value {
  shift->{command}->{listitem} = '@';
}


=head1 LICENSE

Public Domain.

=head1 CHANGE

2001-10-13  wakaba <wakaba@suika.fam.cx>

	* chuubu-risuuka-diary support.

2001-08-13  wakaba <wakaba@suika.fam.cx>

	* New file.

=cut


1;
