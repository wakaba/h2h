
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
  '�������塣' => {caption => '<img src="/okuchuu/favicon" class="favicon" alt="�������塣" />'},
  '���դ�' => {caption => '<img src="/~wakaba/art/icon/ofuyu" class="favicon" alt="���դ�" />'},
  '����' => {caption => '<img src="/~wakaba/art/icon/suika" class="favicon" alt="����" />'},
  '����' => {caption => '<img src="favicon" class="favicon" alt="����" />'},
  '���塼��' => {caption => '<img src="/chuubu/favicon" class="favicon" alt="���塼��" />'},
  '�Ȥߤ���' => {caption => '<img src="/~wakaba/art/icon/tomikou-c" class="favicon" alt="�Ȥߤ���" />'},
  'Perl' => {caption => '<img src="/icons/perl" class="favicon" alt="Perl" />'},
  '̪��' => {caption => '<img src="/chuubu/urimikan/favicon" class="favicon" alt="̪��" />'},
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
	TENKI	=> \&tenki, #'[ŷ��:%value]',
	TAION	=> '�β�: %value��(�ݻ�)',
	LUNCH	=> '�뿩: %value',
	KEYWORD	=> '[��:%value]',
	CAT	=> \&cat, #'[ʬ��:%value]',
	KION	=> '[����:%value]',
	T1	=> '1��:%value',
	T2	=> '2��:%value',
	T3	=> '3��:%value',
	T4	=> '4��:%value',
	T5	=> '5��:%value',
	T6	=> '6��:%value',
	T7	=> '7��:%value',
	SP	=> '%value',
	YOMI	=> '[�ɤ�:%value]',
	ENGLISH	=> '[�Ѹ�:%value]',
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
  '<span class="var '.$o{name}.'">[ŷ��:'.$o{value}.']</span>'."\n";
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
    '��</a> '.
    $self->{theme}->{header}->{TITLE}->{'text/x-h2h'}.'</h2>'."\n".
    $self->{theme}->{hdr}."\n";
  $self->{_HTML}->{end} = "</div><!-- class='body' -->\n";
  $self->{footnotes}->{parent} = \$self;
  $self;
}

package H2H::V100::Command::NEW;

sub _init_value {
  my $self = shift;
  $self->{command}->{listitem} = '��';
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
