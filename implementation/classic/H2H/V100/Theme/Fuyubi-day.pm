
=head1 NAME

H2H::V100::Theme::Fuyubi-day

=head1 DESCRIPTION

Theme of "Fuyusama mo sunaru nikki to ifu mono",
for H2H/1.0.  (One day form)

=head1 ENCODING

EUC-JISX0213

=cut

package H2H::V100;

sub init_theme {
  my $self = shift;
  $self->{template}->{headerfile} 
     ||= $self->{template}->{directory}.'Fuyubi-day-header.htt';
  $self->{template}->{footerfile} 
     ||= $self->{template}->{directory}.'Fuyubi-day-footer.htt';
  undef $self->{template}->{headerfile} if $self->{template}->{noheader};
  undef $self->{template}->{footerfile} if $self->{template}->{nofooter};
  $self->{template}->{YYYY} = $self->{template}->{year};
  $self->{template}->{MM} = sprintf('%02D',$self->{template}->{month});
  $self->{template}->{DD} = sprintf('%02D',$self->{template}->{day});
  $self->{template}->{_BODY_param}->{id} = 'd'.$self->{template}->{DD};
  if ($self->{template}->{month} == 1) {
    $self->{template}->{'YYYYMM+1'} = $self->{template}->{year}.'02';
    $self->{template}->{'YYYYMM-1'} = ($self->{template}->{year}-1).'12';
  } elsif ($self->{template}->{month} == 12) {
    $self->{template}->{'YYYYMM+1'} = ($self->{template}->{year}+1).'01';
    $self->{template}->{'YYYYMM-1'} = $self->{template}->{year}.'11';
  } else {
    $self->{template}->{'YYYYMM+1'} = $self->{template}->{year}.
      sprintf('%02D', $self->{template}->{month}+1);
    $self->{template}->{'YYYYMM-1'} = $self->{template}->{year}.
      sprintf('%02D', $self->{template}->{month}-1);
  }
  $self->{template}->{favicon} ||= '../favicon';
  $self;
}

%cat = (
  '�������塣' => {caption => '<img src="/okuchuu/favicon" class="favicon" alt="�������塣" />'},
  '���դ�' => {caption => '<img src="/~wakaba/art/icon/ofuyu" class="favicon" alt="���դ�" />'},
  '����' => {caption => '<img src="/~wakaba/art/icon/suika" class="favicon" alt="����" />'},
  '����' => {caption => '<img src="../favicon" class="favicon" alt="����" />'},
  '���塼��' => {caption => '<img src="/chuubu/favicon" class="favicon" alt="���塼��" />'},
  '�Ȥߤ���' => {caption => '<img src="/~wakaba/art/icon/tomikou-c" class="favicon" alt="�Ȥߤ���" />'},
  'Perl' => {caption => '<img src="/icons/perl" class="favicon" alt="Perl" />'},
  '̪��' => {caption => '<img src="/chuubu/urimikan/favicon" class="favicon" alt="̪��" />'},
);

package H2H::URI;
  $mine = 'http://suika.fam.cx/~wakaba/d/';
  $diary = $mine;
  $glossary{wakaba} = '../../g/#';
  $glossary{person} = '_person_#';
  $glossary{_} = $glossary{wakaba};
  $resolve = '/uri?uri=';


package H2H::V100::headervalue;
%hdrtemplate = (
	%hdrtemplate,
	TENKI	=> \&tenki, #'[ŷ��:%value]',
	TAION	=> '�β�: %value��(�ݻ�)',
	LUNCH	=> '�뿩: %value',
	KEYWORD	=> '[��:%value]',
	CAT	=> '[ʬ��:%value]',
	KION	=> '[����:%value]',
	T1	=> '1��:%value',
	T2	=> '2��:%value',
	T3	=> '3��:%value',
	T4	=> '4��:%value',
	T5	=> '5��:%value',
	T6	=> '6��:%value',
	T7	=> '7��:%value',
	SP	=> '%value',
);

sub tenki {
  my %o = @_;
  $o{value} =~ s#&hare;#<img src="../hare" class="xbm_font" alt="��" />#g;
  $o{value} =~ s#&kumori;#<img src="../kumori" class="xbm_font" alt="��" />#g;
  $o{value} =~ s#&harekumori;#<img src="../hare" class="xbm_font" alt="��" /><img src="../kumori" class="xbm_font" alt="��" />#g;
  $o{value} =~ s#&ame;#<img src="../ame" class="xbm_font" alt="��" />#g;
  $o{value} =~ s#&yuki;#<img src="../yuki" class="xbm_font" alt="��" />#g;
  $t = '<a href="'.$o{href}.'">'.$t.'</a>' if $o{href};
  '<span class="var '.$o{name}.'">[ŷ��:'.$o{value}.']</span>'."\n";
}

package H2H::V100::Command::_BODY;

sub _init {
  my $self = shift;
  $self->{param}->{class}.= ' body';
  $self->{_HTML}->{start} = '<div%ATTR%>'.
    '<h2><a href="#'.$self->{param}->{id}.'" class="self">'.
    '<img src="'.$self->{theme}->{favicon}.'" class="favicon" alt="��" '.
    'title="���ͤ⤹�ʤ�������Ȥ�����Ρ�" /></a>'.
    $self->{theme}->{year}.'ǯ'.
    $self->{theme}->{month}.'��'.
    $self->{theme}->{day}.'��</h2>'."\n".
    $self->{theme}->{hdr}."\n";
  $self->{_HTML}->{end} = <<EOH;
<form class="postmsg" method="post" action="/~wakaba/sendmsg" accept-charset="junet, iso-2022-jp-3, iso-2022-jp">
	<input type="hidden" name="subject" value="[����] $self->{theme}->{year}ǯ$self->{theme}->{month}��$self->{theme}->{day}��" />
	<strong class="itemname" title="��������С����ɤ����ץܥ���򲡤��Ʋ����������ۤ�����ȡ�����������(��)�ˤʤ�ޤ���">�洶��</strong>:
	
	<span class="fs">
	<label><input type="radio" name="f" value="5" />�ǹ�!</label>
	<label><input type="radio" name="f" value="4" />��</label>
	<label><input type="radio" name="f" value="3" checked="checked" />����</label>
	<label><input type="radio" name="f" value="2" />��</label>
	<label><input type="radio" name="f" value="1" />����</label>
	</span>
	
	<label class="comments"><nobr>���(�⤷����С�): <input type="text" name="comment" value="" /></nobr></label>
	<label class="names"><nobr>̾��(�������С�): <input type="text" name="name" value="" /></nobr></label>
	
	<input type="submit" value="�ɤ���衣" class="readsubmit" title="�������ꤷ�Ƥ���̤��Ѥ�ä���϶��餯���ޤ��󤬡����ꤢ��ޤ���" />
</form>
</div><!-- class="body" -->
EOH
  $self->{footnotes}->{parent} = \$self;
  $self;
}

package H2H::V100::Command::NEW;

sub _init_value {
  my $self = shift;
  $self->{command}->{listitem} = '��';
  if ($self->{param}->{cat}) {
    my @cat = split /, */, $self->{param}->{cat};
    my $cat;
    for (@cat) {
      s/^[\x20\t]+//; s/[\x20\t]+$//;
      $cat.= $self->_cat($_) if $_;
    }
    $self->{command}->{beforetitle} = '<span class="cats">'.$cat.'</span>'."\n"
       if $cat;
  }
}
sub _cat {
  my $self = shift;
  my ($cat) = shift;
  $cat = $H2H::V100::cat{$cat}->{caption} || $self->__html_ent($cat);
  '<span class="cat">['.$cat.']</span>'."\n";
}


package H2H::V100::Command::SUB;

sub _init_value {
  shift->{command}->{listitem} = '@';
}

=head1 LICENSE

Public Domain.

=head1 CHANGE

2001-08-20  wakaba <wakaba@suika.fam.cx>

	* H2H::V100::Theme::Fuyubi-day.pm: New.

=cut

1;
