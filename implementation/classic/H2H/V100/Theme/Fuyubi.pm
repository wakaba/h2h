
=head1 NAME

H2H::V100::Theme::Fuyubi - H2H/1.0 Theme Implementation for "Fuyubi" diary

=head1 DESCRIPTION

Theme of "Fuyusama mo sunaru nikki to ifu mono",
for H2H/1.0.

=cut

package H2H::V100;

sub init_theme {
  my $self = shift;
  $self->{template}->{headerfile} 
     ||= $self->{template}->{directory}.'Fuyubi-header.htt';
  $self->{template}->{footerfile} 
     ||= $self->{template}->{directory}.'Fuyubi-footer.htt';
  undef $self->{template}->{headerfile} if $self->{template}->{noheader};
  undef $self->{template}->{footerfile} if $self->{template}->{nofooter};
  $self->{template}->{YYYY} = $self->{template}->{year};
  $self->{template}->{MM} = sprintf('%02D',$self->{template}->{month});
  $self->{template}->{DD} = sprintf('%02D',$self->{template}->{day});
  $self->{template}->{_BODY_param}->{id} = 'd'.$self->{template}->{day};
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
  $mine = 'http://suika.fam.cx/~wakaba/d/';
  $diary = $mine;
  #$glossary{wakaba} = '../g/#';
  $glossary{wakaba} = '/~wakaba/-temp/wiki/wiki?mycmd=read;mypage=';
  $glossary{person} = '_person_#';
  #$glossary{r} = '/chuubu/2001/2-7/g/search/?subquery=%2Buri%3A%2Fchuubu%2F2001%2F2-7%2Fg%2F&idxname=root&query=';
  $glossary{r} = '/~wakaba/-temp/wiki/wiki?mycmd=read;mypage=';
  #$glossary{_} = $glossary{$glossary_default || 'wakaba'};
  $glossary{_} = '/~wakaba/-temp/wiki/wiki?_charset_=euc-jp;mypage=';
  $resolve = '/uri-res/N2L?';


package H2H::V100::headervalue;
%hdrtemplate = (
	%hdrtemplate,
	TENKI	=> \&tenki, #'[ŷ��:%value]',
	KION	=> '[����:%value]',
	T1	=> '1��:%value',
	T2	=> '2��:%value',
	T3	=> '3��:%value',
	T4	=> '4��:%value',
	T5	=> '5��:%value',
	T6	=> '6��:%value',
	T7	=> '7��:%value',
	SP	=> '%value',
	THEME	=> '%value��',
);

sub tenki {
  my %o = @_;
  $o{value} =~ s#&hare;#<img src="hare" alt="��" />#g;
  $o{value} =~ s#&kumori;#<img src="kumori" alt="��" />#g;
  $o{value} =~ s#&ame;#<img src="ame" alt="��" />#g;
  $o{value} =~ s#&yuki;#<img src="yuki" alt="��" />#g;
  $t = '<a href="'.$o{href}.'">'.$t.'</a>' if $o{href};
  '<span class="var '.$o{name}.'">[ŷ��:'.$o{value}.']</span>'."\n";
}

package H2H::V100::Command::_BODY;

sub _init {
  my $self = shift;
  $self->{param}->{class}.= ' body section';
  $self->{_HTML}->{start} = sprintf
    '<div%%ATTR%%>
       <h2><a href="/~wakaba/d/d%04d%02d#d%02d" class="self"
       >%dǯ%d��%d��</a></h2>%s',
    $self->{theme}->{year}, $self->{theme}->{month},
    $self->{theme}->{day}, $self->{theme}->{year},
    $self->{theme}->{month}, $self->{theme}->{day},
    "\n" . $self->{theme}->{hdr} . "\n";
  $self->{_HTML}->{end} = <<EOH;
<form class="postmsg" method="post" action="/~wakaba/sendmsg"
    accept-charset="iso-2022-jp utf-8">
<div class="column">
  <div class="caption">������ (���Ԥ�ľ������)</div>
  <div class="fig-body">
    <div class="nonpara">
      <span class="line">
        <input type="hidden" name="date" value="$self->{theme}->{year}, $self->
{theme}->{month}, $self->{theme}->{day}">
	<span class="fs">
	<label><input type="radio" name="f" value="5" /> �ǹ�!</label>
	<label><input type="radio" name="f" value="4" /> ��</label>
	<label><input type="radio" name="f" value="3" checked="checked"
                                                      /> ����</label>
	<label><input type="radio" name="f" value="2" /> ��</label>
	<label><input type="radio" name="f" value="1" /> ����</label>
	</span>
      </span>
      <span class="line">
	<label class="comments">��� <span class="weak">(�⤷�����)</span>:
          <input type="text" name="comment" value="" size="40" /></label>
      </span>
      <span class="line">
	<label class="names">̾�� <span class="weak">(��������)</span>:
          <input type="text" name="name" value="" size="40"></label>
      </span>
      <span class="line">
	<input type="submit" value="�ɤ���衣" class="readsubmit"
          title="�����Ƥ���̤��Ѥ�ä���϶��餯���ޤ��󤬡����ꤢ��ޤ���" />
        [<a href="/~wakaba/d/d200507#d4-6" rel="help">����ϲ�?</a>]
      </span>
    </div><!-- nonpara -->
  </div><!-- fig-body -->
</div><!-- column -->
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


=head1 SEE ALSO

Fuyubi-header.htt, Fuyubi-footer.htt.

=head1 AUTHOR

Wakaba <w@suika.fam.cx>

=head1 LICENSE

Public Domain.

=cut

1; # $Date: 2006/05/06 15:23:26 $

