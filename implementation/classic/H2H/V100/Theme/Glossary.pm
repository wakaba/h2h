
=head1 NAME

H2H::V100::Theme::Glossary

=head1 DESCRIPTION

Theme of glossary,
for H2H/1.0.

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
  'おくちゅ。' => {caption => '<img src="/okuchuu/favicon" class="favicon" alt="おくちゅ。" />'},
  'おふゆ' => {caption => '<img src="/~wakaba/art/icon/ofuyu" class="favicon" alt="おふゆ" />'},
  '西瓜' => {caption => '<img src="/~wakaba/art/icon/suika" class="favicon" alt="西瓜" />'},
  '冬日' => {caption => '<img src="favicon" class="favicon" alt="冬日" />'},
  'ちゅーぶ' => {caption => '<img src="/chuubu/favicon" class="favicon" alt="ちゅーぶ" />'},
  'とみこう' => {caption => '<img src="/~wakaba/art/icon/tomikou-c" class="favicon" alt="とみこう" />'},
  'Perl' => {caption => '<img src="/icons/perl" class="favicon" alt="Perl" />'},
  '蜜柑' => {caption => '<img src="/chuubu/urimikan/favicon" class="favicon" alt="蜜柑" />'},
);

package H2H::URI;
  $diary = 'http://suika.fam.cx/~wakaba/d/';
  $glossary{wakaba} = '/~wakaba/g/#';
  $glossary{r} = '/chuubu/2001/2-7/g/';
  $glossary{person} = '_person_#';
  $glossary_default ||= 'r';
  $glossary{_} = $glossary{$glossary_default || 'wakaba'};
  $resolve = '/uri?uri=';
  $mine = $glossary{_};

package H2H::V100::headervalue;
%hdrtemplate = (
	%hdrtemplate,
	TENKI	=> \&tenki, #'[天気:%value]',
	TAION	=> '体温: %value度(摂氏)',
	LUNCH	=> '昼食: %value',
	KEYWORD	=> '[鍵:%value]',
	CAT	=> \&cat, #'[分類:%value]',
	KION	=> '[気温:%value]',
	T1	=> '1限:%value',
	T2	=> '2限:%value',
	T3	=> '3限:%value',
	T4	=> '4限:%value',
	T5	=> '5限:%value',
	T6	=> '6限:%value',
	T7	=> '7限:%value',
	SP	=> '%value',
	YOMI	=> '[読み:%value]',
	ENGLISH	=> '[英語:%value]',
	TITLE	=> \&title,
	ALIAS	=> \&title,
);

sub tenki {
  my %o = @_;
  $o{value} =~ s#&hare;#<img src="/~wakaba/d/hare" class="xbm_font" alt="��" />#g;
  $o{value}=~s#&kumori;#<img src="/~wakaba/d/kumori" class="xbm_font" alt="��" />#g;
  $o{value} =~ s#&ame;#<img src="/~wakaba/d/ame" class="xbm_font" alt="��" />#g;
  $o{value} =~ s#&yuki;#<img src="/~wakaba/d/yuki" class="xbm_font" alt="��" />#g;
  $t = '<a href="'.$o{href}.'">'.$t.'</a>' if $o{href};
  '<span class="var '.$o{name}.'">[天気:'.$o{value}.']</span>'."\n";
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
    '◇</a> '.
    $self->{theme}->{header}->{TITLE}->{'text/x-h2h'}.'</h2>'."\n".
    $self->{theme}->{hdr}."\n";
  $self->{_HTML}->{end} = "</div><!-- class='body' -->\n";
  $self->{footnotes}->{parent} = \$self;
  $self;
}

package H2H::V100::Command::NEW;

sub _init_value {
  my $self = shift;
  $self->{command}->{listitem} = '☆';
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
