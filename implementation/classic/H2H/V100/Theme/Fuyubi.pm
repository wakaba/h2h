
=head1 NAME

H2H::V100::Theme::Fuyubi

=head1 DESCRIPTION

Theme of "Fuyusama mo sunaru nikki to ifu mono",
for H2H/1.0.

=head1 ENCODING

EUC-JISX0213

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
  $mine = 'http://suika.fam.cx/~wakaba/d/';
  $diary = $mine;
  #$glossary{wakaba} = '../g/#';
  $glossary{wakaba} = '/~wakaba/-temp/wiki/wiki?mycmd=read;mypage=';
  $glossary{person} = '_person_#';
  #$glossary{r} = '/chuubu/2001/2-7/g/search/?subquery=%2Buri%3A%2Fchuubu%2F2001%2F2-7%2Fg%2F&idxname=root&query=';
  $glossary{r} = '/~wakaba/-temp/wiki/wiki?mycmd=read;mypage=';
  #$glossary{_} = $glossary{$glossary_default || 'wakaba'};
  $glossary{_} = '/~wakaba/-temp/wiki/wiki?mycmd=read;mypage=';
  $resolve = '/uri-res/N2L?';


package H2H::V100::headervalue;
%hdrtemplate = (
	%hdrtemplate,
	TENKI	=> \&tenki, #'[天気:%value]',
	KION	=> '[気温:%value]',
	T1	=> '1限:%value',
	T2	=> '2限:%value',
	T3	=> '3限:%value',
	T4	=> '4限:%value',
	T5	=> '5限:%value',
	T6	=> '6限:%value',
	T7	=> '7限:%value',
	SP	=> '%value',
	THEME	=> '%value編',
);

sub tenki {
  my %o = @_;
  $o{value} =~ s#&hare;#<img src="hare" alt="晴" />#g;
  $o{value} =~ s#&kumori;#<img src="kumori" alt="曇" />#g;
  $o{value} =~ s#&ame;#<img src="ame" alt="雨" />#g;
  $o{value} =~ s#&yuki;#<img src="yuki" alt="雪" />#g;
  $t = '<a href="'.$o{href}.'">'.$t.'</a>' if $o{href};
  '<span class="var '.$o{name}.'">[天気:'.$o{value}.']</span>'."\n";
}

package H2H::V100::Command::_BODY;

sub _init {
  my $self = shift;
  $self->{param}->{class}.= ' body';
  $self->{_HTML}->{start} = '<div%ATTR%>'.
    '<h2><a href="/uri-res/N2L?urn:x-suika-fam-cx:'.
    $self->{theme}->{year}.':'.$self->{theme}->{month}.':'.
    $self->{theme}->{day}.'" class="self">'.
    '<img src="favicon" class="favicon" alt="◇" '.
    'title="冬様もすなる☆日記というもの。"></a>'.
    $self->{theme}->{year}.'年'.
    $self->{theme}->{month}.'月'.
    $self->{theme}->{day}.'日</h2>'."\n".
    $self->{theme}->{hdr}."\n";
  $self->{_HTML}->{end} = <<EOH;
<form class="postmsg" method="post" action="mailto:w\@suika.fam.cx" enctype="text/plain" accept-charset="iso-2022-jp">
<div>
	<input type="hidden" name="subject" value="[冬日] $self->{theme}->{year}年$self->{theme}->{month}月$self->{theme}->{day}日">
	<strong class="itemname" title="宜しければ、「読んだよ」ボタンを押して下さい。感想があると、日記を書く励み(謎)になります。">御感想 (わかばに直接送る)</strong>:
	
	<span class="fs">
	<label><input type="radio" name="f" value="5">最高!</label>
	<label><input type="radio" name="f" value="4">良</label>
	<label><input type="radio" name="f" value="3" checked="checked">普通</label>
	<label><input type="radio" name="f" value="2">悪</label>
	<label><input type="radio" name="f" value="1">最低</label>
	</span>
	
	<label class="comments">一言(もしあれば。): <input type="text" name="comment" value=""></label>
	<label class="names">名前(よろしければ。): <input type="text" name="name" value=""></label>
	
	<input type="submit" value="読んだよ。" class="readsubmit" title="メッセージ (記入されていれば。) をメイルで送信します。押したりしても画面が変わったりは恐らくしませんが、問題ありません。">
</div>
</form>
<!--
<div>
	<strong>ご感想 (掲示板 : 公開)</strong>:
	<object type="text/html" data="/~wakaba/-temp/wiki/wiki?mycmd=lo-&#x2E;light;mypage=%E5%86%AC%E6%97%A5%2F%2F%E6%84%9F%E6%83%B3%2F%2F$self->{theme}->{year}%2F%2F$self->{theme}->{month}%2F%2F$self->{theme}->{day}" style="width: 98%; height: 5em; margin-left: auto; margin-right: auto; display: block; text-align: center">
	  <a href="/~wakaba/-temp/wiki/wiki?mycmd=lo-&#x2E;light;mypage=%E5%86%AC%E6%97%A5%2F%2F%E6%84%9F%E6%83%B3%2F%2F$self->{theme}->{year}%2F%2F$self->{theme}->{month}%2F%2F$self->{theme}->{day}" class="wiki">感想掲示板</a>
	</object>
</div>-->
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

2001-09-05  wakaba <wakaba@suika.fam.cx>

	* (init_theme): Fix bug.  _BODY id => {day} (was {DD}).

2001-08-14  wakaba <wakaba@suika.fam.cx>

	* (Category): Its output is supported.

2001-08-13  wakaba <wakaba@suika.fam.cx>

	* New file.

=cut

1;
