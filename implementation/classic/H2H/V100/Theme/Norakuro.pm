
=head1 NAME

H2H::V100::Theme::Norakuro - H2H/1.0 Theme Implementation for "Norakuro" diary

=head1 DESCRIPTION

Theme of "Norakuro Nikki", for H2H/1.0.

=cut

package H2H::V100;

sub init_theme {
  my $self = shift;
  $self->{template}->{headerfile} 
     ||= $self->{template}->{directory}.'Norakuro-header.htt';
  $self->{template}->{footerfile} 
     ||= $self->{template}->{directory}.'Norakuro-footer.htt';
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
  $glossary{_} = '/~wakaba/-temp/wiki/wiki?_charset_=euc-jp;mypage=';
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
  $self->{param}->{class}.= ' body section';
  $self->{_HTML}->{start} = sprintf
    '<div%%ATTR%%>
       <h2><a href="/~wakaba/d/d%04d%02d#d%02d" class="self"
       >%d年%d月%d日</a></h2>%s',
    $self->{theme}->{year}, $self->{theme}->{month},
    $self->{theme}->{day}, $self->{theme}->{year},
    $self->{theme}->{month}, $self->{theme}->{day},
    "\n" . $self->{theme}->{hdr} . "\n";
  $self->{_HTML}->{end} = <<EOH;
<form class="postmsg" method="post" action="sendmsg"
    accept-charset="iso-2022-jp utf-8">
<div class="column">
  <div class="caption">ご感想 (著者に直接送る)</div>
  <div class="fig-body">
    <div class="nonpara">
      <span class="line">
        <input type="hidden" name="date" value="$self->{theme}->{year}, $self->{theme}->{month}, $self->{theme}->{day}">
	<span class="fs">
	<label><input type="radio" name="f" value="5" /> 最高!</label>
	<label><input type="radio" name="f" value="4" /> 良</label>
	<label><input type="radio" name="f" value="3" checked="checked"
                                                      /> 普通</label>
	<label><input type="radio" name="f" value="2" /> 悪</label>
	<label><input type="radio" name="f" value="1" /> 最低</label>
	</span>
      </span>
      <span class="line">
	<label class="comments">一言 <span class="weak">(もしあれば)</span>:
          <input type="text" name="comment" value="" size="40" /></label>
      </span>
      <span class="line">
	<label class="names">名前 <span class="weak">(よろしければ)</span>:
          <input type="text" name="name" value="" size="40"></label>
      </span>
      <span class="line">
	<input type="submit" value="読んだよ。" class="readsubmit"
          title="押しても画面が変わったりは恐らくしませんが、問題ありません。" />
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


=head1 SEE ALSO

Norakuro-header.htt, Norakuro-footer.htt.

=head1 AUTHOR

Wakaba <w@suika.fam.cx>

=head1 LICENSE

Public Domain.

=cut

1;
