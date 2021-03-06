
=head1 NAME

H2H::V100::Theme::Fuyubi-day

=head1 DESCRIPTION

Theme of "Fuyusama mo sunaru nikki to ifu mono",
for H2H/1.0.  (One day form)

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
  'おくちゅ。' => {caption => '<img src="/okuchuu/favicon" class="favicon" alt="おくちゅ。" />'},
  'おふゆ' => {caption => '<img src="/~wakaba/art/icon/ofuyu" class="favicon" alt="おふゆ" />'},
  '西瓜' => {caption => '<img src="/~wakaba/art/icon/suika" class="favicon" alt="西瓜" />'},
  '冬日' => {caption => '<img src="../favicon" class="favicon" alt="冬日" />'},
  'ちゅーぶ' => {caption => '<img src="/chuubu/favicon" class="favicon" alt="ちゅーぶ" />'},
  'とみこう' => {caption => '<img src="/~wakaba/art/icon/tomikou-c" class="favicon" alt="とみこう" />'},
  'Perl' => {caption => '<img src="/icons/perl" class="favicon" alt="Perl" />'},
  '蜜柑' => {caption => '<img src="/chuubu/urimikan/favicon" class="favicon" alt="蜜柑" />'},
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
	TENKI	=> \&tenki, #'[天気:%value]',
	TAION	=> '体温: %value度(摂氏)',
	LUNCH	=> '昼食: %value',
	KEYWORD	=> '[鍵:%value]',
	CAT	=> '[分類:%value]',
	KION	=> '[気温:%value]',
	T1	=> '1限:%value',
	T2	=> '2限:%value',
	T3	=> '3限:%value',
	T4	=> '4限:%value',
	T5	=> '5限:%value',
	T6	=> '6限:%value',
	T7	=> '7限:%value',
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
  '<span class="var '.$o{name}.'">[天気:'.$o{value}.']</span>'."\n";
}

package H2H::V100::Command::_BODY;

sub _init {
  my $self = shift;
  $self->{param}->{class}.= ' body';
  $self->{_HTML}->{start} = '<div%ATTR%>'.
    '<h2><a href="#'.$self->{param}->{id}.'" class="self">'.
    '<img src="'.$self->{theme}->{favicon}.'" class="favicon" alt="◇" '.
    'title="冬様もすなる☆日記というもの。" /></a>'.
    $self->{theme}->{year}.'年'.
    $self->{theme}->{month}.'月'.
    $self->{theme}->{day}.'日</h2>'."\n".
    $self->{theme}->{hdr}."\n";
  $self->{_HTML}->{end} = <<EOH;
<form class="postmsg" method="post" action="/~wakaba/sendmsg" accept-charset="utf-8 iso-2022-jp">
	<input type="hidden" name="subject" value="[冬日] $self->{theme}->{year}年$self->{theme}->{month}月$self->{theme}->{day}日" />
	<strong class="itemname" title="宜しければ、「読んだよ」ボタンを押して下さい。感想があると、日記を書く励み(謎)になります。">御感想</strong>:
	
	<span class="fs">
	<label><input type="radio" name="f" value="5" />最高!</label>
	<label><input type="radio" name="f" value="4" />良</label>
	<label><input type="radio" name="f" value="3" checked="checked" />普通</label>
	<label><input type="radio" name="f" value="2" />悪</label>
	<label><input type="radio" name="f" value="1" />最低</label>
	</span>
	
	<label class="comments"><nobr>一言(もしあれば。): <input type="text" name="comment" value="" /></nobr></label>
	<label class="names"><nobr>名前(よろしければ。): <input type="text" name="name" value="" /></nobr></label>
	
	<input type="submit" value="読んだよ。" class="readsubmit" title="押したりしても画面が変わったりは恐らくしませんが、問題ありません。" />
</form>
</div><!-- class="body" -->
EOH
  $self->{footnotes}->{parent} = \$self;
  $self;
}

package H2H::V100::Command::NEW;

sub _init_value {
  my $self = shift;
  $self->{command}->{listitem} = '☆';
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
