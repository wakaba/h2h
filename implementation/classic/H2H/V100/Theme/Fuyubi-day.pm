
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
  '¤ª¤¯¤Á¤å¡£' => {caption => '<img src="/okuchuu/favicon" class="favicon" alt="¤ª¤¯¤Á¤å¡£" />'},
  '¤ª¤Õ¤æ' => {caption => '<img src="/~wakaba/art/icon/ofuyu" class="favicon" alt="¤ª¤Õ¤æ" />'},
  'À¾±»' => {caption => '<img src="/~wakaba/art/icon/suika" class="favicon" alt="À¾±»" />'},
  'ÅßÆü' => {caption => '<img src="../favicon" class="favicon" alt="ÅßÆü" />'},
  '¤Á¤å¡¼¤Ö' => {caption => '<img src="/chuubu/favicon" class="favicon" alt="¤Á¤å¡¼¤Ö" />'},
  '¤È¤ß¤³¤¦' => {caption => '<img src="/~wakaba/art/icon/tomikou-c" class="favicon" alt="¤È¤ß¤³¤¦" />'},
  'Perl' => {caption => '<img src="/icons/perl" class="favicon" alt="Perl" />'},
  'Ìª´»' => {caption => '<img src="/chuubu/urimikan/favicon" class="favicon" alt="Ìª´»" />'},
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
	TENKI	=> \&tenki, #'[Å·µ¤:%value]',
	TAION	=> 'ÂÎ²¹: %valueÅÙ(ÀÝ»á)',
	LUNCH	=> 'Ãë¿©: %value',
	KEYWORD	=> '[¸°:%value]',
	CAT	=> '[Ê¬Îà:%value]',
	KION	=> '[µ¤²¹:%value]',
	T1	=> '1¸Â:%value',
	T2	=> '2¸Â:%value',
	T3	=> '3¸Â:%value',
	T4	=> '4¸Â:%value',
	T5	=> '5¸Â:%value',
	T6	=> '6¸Â:%value',
	T7	=> '7¸Â:%value',
	SP	=> '%value',
);

sub tenki {
  my %o = @_;
  $o{value} =~ s#&hare;#<img src="../hare" class="xbm_font" alt="¦è" />#g;
  $o{value} =~ s#&kumori;#<img src="../kumori" class="xbm_font" alt="¦é" />#g;
  $o{value} =~ s#&harekumori;#<img src="../hare" class="xbm_font" alt="¦è" /><img src="../kumori" class="xbm_font" alt="¦é" />#g;
  $o{value} =~ s#&ame;#<img src="../ame" class="xbm_font" alt="¦ê" />#g;
  $o{value} =~ s#&yuki;#<img src="../yuki" class="xbm_font" alt="¦ë" />#g;
  $t = '<a href="'.$o{href}.'">'.$t.'</a>' if $o{href};
  '<span class="var '.$o{name}.'">[Å·µ¤:'.$o{value}.']</span>'."\n";
}

package H2H::V100::Command::_BODY;

sub _init {
  my $self = shift;
  $self->{param}->{class}.= ' body';
  $self->{_HTML}->{start} = '<div%ATTR%>'.
    '<h2><a href="#'.$self->{param}->{id}.'" class="self">'.
    '<img src="'.$self->{theme}->{favicon}.'" class="favicon" alt="¡þ" '.
    'title="ÅßÍÍ¤â¤¹¤Ê¤ë¡ùÆüµ­¤È¤¤¤¦¤â¤Î¡£" /></a>'.
    $self->{theme}->{year}.'Ç¯'.
    $self->{theme}->{month}.'·î'.
    $self->{theme}->{day}.'Æü</h2>'."\n".
    $self->{theme}->{hdr}."\n";
  $self->{_HTML}->{end} = <<EOH;
<form class="postmsg" method="post" action="/~wakaba/sendmsg" accept-charset="junet, iso-2022-jp-3, iso-2022-jp">
	<input type="hidden" name="subject" value="[ÅßÆü] $self->{theme}->{year}Ç¯$self->{theme}->{month}·î$self->{theme}->{day}Æü" />
	<strong class="itemname" title="µ¹¤·¤±¤ì¤Ð¡¢¡ÖÆÉ¤ó¤À¤è¡×¥Ü¥¿¥ó¤ò²¡¤·¤Æ²¼¤µ¤¤¡£´¶ÁÛ¤¬¤¢¤ë¤È¡¢Æüµ­¤ò½ñ¤¯Îå¤ß(Ææ)¤Ë¤Ê¤ê¤Þ¤¹¡£">¸æ´¶ÁÛ</strong>:
	
	<span class="fs">
	<label><input type="radio" name="f" value="5" />ºÇ¹â!</label>
	<label><input type="radio" name="f" value="4" />ÎÉ</label>
	<label><input type="radio" name="f" value="3" checked="checked" />ÉáÄÌ</label>
	<label><input type="radio" name="f" value="2" />°­</label>
	<label><input type="radio" name="f" value="1" />ºÇÄã</label>
	</span>
	
	<label class="comments"><nobr>°ì¸À(¤â¤·¤¢¤ì¤Ð¡£): <input type="text" name="comment" value="" /></nobr></label>
	<label class="names"><nobr>Ì¾Á°(¤è¤í¤·¤±¤ì¤Ð¡£): <input type="text" name="name" value="" /></nobr></label>
	
	<input type="submit" value="ÆÉ¤ó¤À¤è¡£" class="readsubmit" title="²¡¤·¤¿¤ê¤·¤Æ¤â²èÌÌ¤¬ÊÑ¤ï¤Ã¤¿¤ê¤Ï¶²¤é¤¯¤·¤Þ¤»¤ó¤¬¡¢ÌäÂê¤¢¤ê¤Þ¤»¤ó¡£" />
</form>
</div><!-- class="body" -->
EOH
  $self->{footnotes}->{parent} = \$self;
  $self;
}

package H2H::V100::Command::NEW;

sub _init_value {
  my $self = shift;
  $self->{command}->{listitem} = '¡ù';
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
