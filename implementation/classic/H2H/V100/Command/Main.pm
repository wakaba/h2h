
=head1 NAME

H2H::V100::Command::Main

=head1 DESCRIPTION

H2H/1.0 -- Command Module -- Main

=cut

package H2H::V100::Command::NEW;
use base H2H::V100::Command::_BLOCK;
$H2H::V100::Command::Enabled{NEW} = 1;

sub _init {
  my $self = shift;
  $self->SUPER::_init();
  $self->{footnotes}->{parent} = \$self;
  $self->{param}->{id} = $self->{parentid}->{param}->{id}.'-'.
    ($self->{parentid}->{childid}++ +1);
  $self->_init_value();
  $self;
}
sub _init_value {
  shift->{command}->{listitem} = '*';
}

sub _checkparent {
  my $self = shift;
  for ($i = $#{$self->{parents}}; $i > 1; $i--) {
    $self->{_buffer} .= ${$self->{parents}}[$i]->end();
  } $#{$self->{parents}} = 1;
  $self->{ok} = 1;
  undef $self->{error};
  $self;
}


sub start {
  my $self = shift;
  my $ret; $ret = $self->{_buffer}; undef $self->{_buffer};
  $self->{param}->{class} .= ' section';
  $ret .= $self->_replace_attr('<div%ATTR%>')."\n";
  $ret .= '<h3>'.
    '<a href="#'.$self->{param}->{id}.'" class="self">'.
    $self->{command}->{listitem}.'</a> '.$self->{command}->{beforetitle};
  if ($self->{param}->{link}) {
    $self->{text} = $self->__html_ent($self->{text} || $self->{param}->{link});
    $ret .= $self->_makelink_start().$self->{text}.
            ($self->{_have_link}? '</a></h3>': '</h3>')
  } else {
    $ret .= $self->__html_ent($self->{text}).'</h3>' if $self->{text};
  }
  $ret."\n";
}

sub end {
  shift->footnote_tohtml().'</div><!-- class="section" -->'."\n";
}


package H2H::V100::Command::SUB;
use base H2H::V100::Command::NEW;
$H2H::V100::Command::Enabled{SUB} = 1;

sub _init_value {
  shift->{command}->{listitem} = '-';
}

sub _checkparent {
  my $self = shift;
  if ($#{$self->{parents}} < 2 || ${${$self->{parents}}[2]}{name} ne 'NEW') {
    $self->{ok} = 0;  $self->{error} = 'SUB command cannot come here.';
    return $self;
  }
  for ($i = $#{$self->{parents}}; $i > 2; $i--) {
    $self->{_buffer} .= ${$self->{parents}}[$i]->end();
  } $#{$self->{parents}} = 2;
  $self->{ok} = 1;
  undef $self->{error};
  $self;
}


sub start {
  my $self = shift;
  my $ret; $ret = $self->{_buffer}; undef $self->{_buffer};
  $self->{param}->{class} .= ' subsection';
  $ret .= $self->_replace_attr('<div%ATTR%>')."\n";
  $ret .= '<h4>'.
    '<a href="#'.$self->{param}->{id}.'" class="self">'.
    $self->{command}->{listitem}.'</a> '.$self->{command}->{beforetitle};
  if ($self->{param}->{link}) {
    $self->{text} = $self->__html_ent($self->{text} || $self->{param}->{link});
    $ret .= $self->_makelink_start().$self->{text}.
            ($self->{_have_link}? '</a></h4>': '</h4>')
  } else {
    $ret .= $self->__html_ent($self->{text}).'</h4>' if $self->{text};
  }
  $ret."\n";
}

sub end {
  shift->footnote_tohtml().'</div><!-- class="subsection" -->'."\n";
}


package H2H::V100::Command::P;
use base H2H::V100::Command::_BLOCK;
$H2H::V100::Command::Enabled{P} = 1;
push @H2H::V100::Command::Block, 'P';

sub _checkparent {
  my $self = shift;
  if (${$self->{parents}}[$#{$self->{parents}}]->{name} eq 'P') {
    $self->{_buffer} .= ${$self->{parents}}[$#{$self->{parents}}]->end();
    $#{$self->{parents}}--;
  }
  $self->{ok} = 1;
  undef $self->{error};
  $self;
}


sub _init {
  my $self = shift;
  $self->SUPER::_init();
  $self->{_HTML}->{start} = '<p%ATTR%>';
  $self->{_HTML}->{end} = '</p>';
  $self->{option}->{child_tof}->{DIV} = -1;
  $self;
}

package H2H::V100::Command::CITE;
use base H2H::V100::Command::_BODY;
$H2H::V100::Command::Enabled{CITE} = 1;
push @H2H::V100::Command::Block, 'CITE';

sub start {
  my $self = shift;
  my $ret; $ret = $self->{_buffer}; undef $self->{_buffer};
  $ret .= '<blockquote';
  my $uri = $self->__uri_norm($self->{param}->{uri} || $self->{param}->{link});
  if ($uri) {
    $ret .= ' cite="'.$self->__html_ent($uri).'"';
  }
  $ret .= '>';
  $ret;
}

sub end {
  my $self = shift;
  my $ret; $ret = $self->{_buffer}; undef $self->{_buffer};
  my $urio = $self->{param}->{link} || $self->{param}->{uri};
  my $uri = $self->__uri_norm($urio);
  $ret .= $self->footnote_tohtml();
  my $linktext = $self->__html_ent($self->{text} ||
                                   $self->{param}->{source} || $urio);
  if ($uri) {
    $linktext = '<cite><a href="'.$self->__html_ent($uri).'">'.
                $linktext.'</a></cite>';
  }
  $ret .= '<cite>'.$linktext.'</cite>';
  $ret .= '</blockquote>'."\n";
  $ret;
}

package H2H::V100::Command::DIV;
use base H2H::V100::Command::_BLOCK;
$H2H::V100::Command::Enabled{DIV} = 1;
push @H2H::V100::Command::Block, 'DIV';

sub _init {
  my $self = shift;
  $self->SUPER::_init();
  $self->{param}->{class} .= ' '.$self->{text} if $self->{text};
  $self->{_HTML}->{start} = '<div%ATTR%>';
  $self->{_HTML}->{end} = '</div>'."\n";
  $self;
}

package H2H::V100::Command::PRE;
use base H2H::V100::Command::_BLOCK;
$H2H::V100::Command::Enabled{PRE} = 1;
push @H2H::V100::Command::Block, 'PRE';

sub _init {
  my $self = shift;
  $self->SUPER::_init();
  $self->{_HTML}->{start} = '<pre%ATTR%>';
  $self->{_HTML}->{end} = '</pre>';
  for (@H2H::V100::Command::Block) {
    $self->{option}->{child_tof}->{$_} = -1;
  }
  $self;
}


package H2H::V100::Command::UL;
use base H2H::V100::Command::_BLOCK;
$H2H::V100::Command::Enabled{UL} = 1;
push @H2H::V100::Command::Block, 'UL';

sub _init {
  my $self = shift;
  $self->SUPER::_init();
  $self->{_HTML}->{start} = '<ul%ATTR%>';
  $self->{_HTML}->{end} = '</ul>';
  $self->{option}->{child_default_no} = 1;
  $self->{option}->{child_tof}->{LI} = 1;
  $self;
}

sub content {
  my $self = shift;
  my $text = shift;
  '<li>'.$text.'</li>';
}

package H2H::V100::Command::OL;
use base H2H::V100::Command::UL;
$H2H::V100::Command::Enabled{OL} = 1;
push @H2H::V100::Command::Block, 'OL';

sub _init {
  my $self = shift;
  $self->SUPER::_init();
  $self->{_HTML}->{start} = '<ol%ATTR%>';
  $self->{_HTML}->{end} = '</ol>';
  $self;
}

package H2H::V100::Command::DL;
use base H2H::V100::Command::_BLOCK;
$H2H::V100::Command::Enabled{DL} = 1;
push @H2H::V100::Command::Block, 'DL';

sub _init {
  my $self = shift;
  $self->SUPER::_init();
  $self->{_HTML}->{start} = '<dl%ATTR%>';
  $self->{_HTML}->{end} = '</dl>';
  $self->{option}->{child_default_no} = 1;
  $self->{option}->{child_tof}->{DT} = 1;
  $self->{option}->{child_tof}->{DD} = 1;
  $self;
}

sub content {
  my $self = shift;
  my $text = shift;
  '<dd>'.$text.'</dd>';
}


package H2H::V100::Command::LI;
use base H2H::V100::Command::_BLOCK;
$H2H::V100::Command::Enabled{LI} = 1;
push @H2H::V100::Command::Block, 'LI';

sub new {
  my $class = shift;
  my $self = bless {@_}, ref($class) || $class;
  $self->_init()->_checkparent();
  $self->{ok} = 2 if $self->{ok} && $self->{text};
  $self;
}

sub _init {
  my $self = shift;
  $self->SUPER::_init();
  $self->{_HTML}->{start} = '<li%ATTR%>';
  $self->{_HTML}->{end} = '</li>';
  $self;
}

package H2H::V100::Command::DT;
use base H2H::V100::Command::_BLOCK;
$H2H::V100::Command::Enabled{DT} = 1;
push @H2H::V100::Command::Block, 'DT';

sub new {
  my $class = shift;
  my $self = bless {@_}, ref($class) || $class;
  $self->_init()->_checkparent();
  $self->{ok} = 2 if $self->{ok} && $self->{text};
  $self;
}

sub _init {
  my $self = shift;
  $self->SUPER::_init();
  $self->{_HTML}->{start} = '<dt%ATTR%>';
  $self->{_HTML}->{end} = '</dt>';
  $self;
}


package H2H::V100::Command::DD;
use base H2H::V100::Command::_BLOCK;
$H2H::V100::Command::Enabled{DD} = 1;
push @H2H::V100::Command::Block, 'DD';

sub new {
  my $class = shift;
  my $self = bless {@_}, ref($class) || $class;
  $self->_init()->_checkparent();
  $self->{ok} = 2 if $self->{ok} && $self->{text};
  $self;
}

sub _init {
  my $self = shift;
  $self->SUPER::_init();
  $self->{_HTML}->{start} = '<dd%ATTR%>';
  $self->{_HTML}->{end} = '</dd>';
  $self;
}


package H2H::V100::Command::YAMI;
use base H2H::V100::Command::_BLOCK;
$H2H::V100::Command::Enabled{YAMI} = 1;
push @H2H::V100::Command::BlockInline, 'YAMI';

sub new {
  my $class = shift;
  my $self = bless {@_}, ref($class) || $class;
  $self->_init()->_checkparent();
  $self->{ok} = 2 if $self->{ok} && $self->{text};
  $self;
}

sub _init {
  my $self = shift;
  $self->SUPER::_init();
  $self->{param}->{class} .= ' ' if $self->{param}->{class};
  $self->{param}->{class} .= 'yami';
  if ($self->{text}) {
    $self->{_HTML}->{start} = '<span%ATTR%>';
    $self->{_HTML}->{end} = '</span>';
    $self->{option}->{parenttof}->{_BODY} = -1;
  } else {
    $self->{_HTML}->{start} = '<div%ATTR%>';
    $self->{_HTML}->{end} = '</div>';
    #for (@H2H::V100::Command::Block) {
    #  $self->{option}->{parenttof}->{$_} = -1;
    #}
    $self->{option}->{parenttof}->{_BODY} = 1;
  }
  $self;
}

sub linecontent {
  my $self = shift;
  $self->start().$self->content($self->{text}).$self->end();
}


sub _checkparent {
  my $self = shift;
  if ($#{$self->{parents}} > 0 && $self->{option}->{parenttof}->{
      $self->{parents}->[$#{$self->{parents}}]->{name}} == -1) {
    $self->{ok} = 0;
  } else {
    $self->{ok} = 1;
    undef $self->{error};
  }
  $self;
}

package H2H::V100::Command::INS;
use base H2H::V100::Command::_BLOCK;
$H2H::V100::Command::Enabled{INS} = 1;
push @H2H::V100::Command::BlockInline, 'INS';

sub new {
  my $class = shift;
  my $self = bless {@_}, ref($class) || $class;
  $self->_init()->_checkparent();
  $self->{ok} = 2 if $self->{ok} && $self->{text};
  $self;
}

sub _init {
  my $self = shift;
  $self->SUPER::_init();
  $self->{_HTML}->{start} = '<ins%ATTR%>';
  $self->{_HTML}->{end} = '</ins>';
  $self->{option}->{parenttof}->{_BODY} = ($self->{text}? -1: 1);
  $self;
}

sub linecontent {
  my $self = shift;
  $self->start().$self->vcontent($self->{text}).$self->end();
}

sub content {
  my $ret = shift->__html_ent($_[0]);
  #'<p class="invalid">'.$ret.'</p>' if $ret;
  $ret;
}
sub vcontent {shift->__html_ent($_[0]);}

sub _checkparent {
  my $self = shift;
  if ($#{$self->{parents}} > 0 && $self->{option}->{parenttof}->{
      $self->{parents}->[$#{$self->{parents}}]->{name}} == -1) {
    $self->{ok} = 0;
  } else {
    $self->{ok} = 1;
    undef $self->{error};
  }
  $self;
}

package H2H::V100::Command::DEL;
use base H2H::V100::Command::INS;
$H2H::V100::Command::Enabled{DEL} = 1;
push @H2H::V100::Command::BlockInline, 'DEL';

sub _init {
  my $self = shift;
  $self->SUPER::_init();
  $self->{_HTML}->{start} = '<del%ATTR%>';
  $self->{_HTML}->{end} = '</del>';
  $self;
}

package H2H::V100::Command::FN;
use base H2H::V100::Command::INS;
$H2H::V100::Command::Enabled{FN} = 1;
push @H2H::V100::Command::BlockInline, 'FN';

sub _init {
  my $self = shift;
  $self->SUPER::_init();
  my ($index,$id) = $self->footnote_start( #id => $self->{param}->{id},
                     class => $self->{param}->{class},
                      lang => $self->{param}->{lang},
                     title => $self->{param}->{title},
                       );
  $self->{_HTML}->{start} = '<sup><a href="#'.$id.'"%ATTR%>'.
    ($self->{param}->{'anchor-text'} || '*'.$index);
  $self->{_HTML}->{end} = '</a></sup> ';
  for ('id','class','lang','title') {
    $self->{param}->{$_} = $self->{param}->{'anchor-'.$_};
  }
  $self->{param}->{class} .= ' fn_anchor';
  $self;
}

sub linecontent {
  my $self = shift;
  $self->start().$self->content($self->{text}).$self->end();
}

sub content {
  my $self = shift;
  $self->footnote_text($self->__html_ent($_[0]));
  '';
}
sub cmdcontent {
  my $self = shift;
  $self->footnote_text(shift);
  '';
}

package H2H::V100::Command::RUBY;
use base H2H::V100::Command::INS;
$H2H::V100::Command::Enabled{RUBY} = 1;
push @H2H::V100::Command::BlockInline, 'RUBY';

sub _init {
  my $self = shift;
  $self->SUPER::_init();
  if ($self->{text}) {
    $self->{text} =~ s{^([^ ]+) +(.+)$}{<rb>$1</rb><rp>(</rp><rt>$2</rt><rp>)</rp>}g;
  }
  $self->{_HTML}->{start} = '<ruby%ATTR%>';
  $self->{_HTML}->{end} = '</ruby>';
  $self->{option}->{child_default_no} = 1;
  $self->{option}->{child_tof}->{RB} = 1;
  $self->{option}->{child_tof}->{RT} = 1;
  $self;
}

sub content {
  my $ret = shift->__html_ent($_[0]);
  '<span class="invalid">'.$ret.'</span>' if $ret;
}

package H2H::V100::Command::RB;
use base H2H::V100::Command::_INLINE;
$H2H::V100::Command::Enabled{RB} = 1;
push @H2H::V100::Command::Inline, 'RB';

sub _init {
  my $self = shift;
  $self->SUPER::_init();
  $self->{_HTML}->{start} = '<rb%ATTR%>';
  $self->{_HTML}->{end} = '</rb>';
  $self;
}

package H2H::V100::Command::RT;
use base H2H::V100::Command::_INLINE;
$H2H::V100::Command::Enabled{RT} = 1;
push @H2H::V100::Command::Inline, 'RT';

sub _init {
  my $self = shift;
  $self->SUPER::_init();
  $self->{_HTML}->{start} = '<rp>(</rp><rt%ATTR%>';
  $self->{_HTML}->{end} = '</rt><rp>)</rp>';
  $self;
}

package H2H::V100::Command::SPAN;
use base H2H::V100::Command::_INLINE;
$H2H::V100::Command::Enabled{SPAN} = 1;
push @H2H::V100::Command::Inline, 'SPAN';

sub _init {
  my $self = shift;
  $self->SUPER::_init();
  unless ($self->{param}->{class}) {
    ($self->{param}->{class}, $self->{text}) = split / +/, $self->{text}, 2;
  }
  $self;
}


package H2H::V100::Command::LINK;
use base H2H::V100::Command::_INLINE;
$H2H::V100::Command::Enabled{LINK} = 1;
push @H2H::V100::Command::Inline, 'LINK';

sub _init {
  my $self = shift;
  $self->SUPER::_init();
  $self->{option}->{parenttof}->{LINK} = -1;
  $self->{option}->{parenttof}->{LDIARY} = -1;
  $self->{option}->{parenttof}->{SEE} = -1;
  $self->{option}->{parenttof}->{PERSON} = -1;
  $self->{_HTML}->{end} = "";
  $self;
}

sub start {
  my $self = shift;
  my $uri = $self->{param}->{link};
  my $text = $self->{text};
  unless ($uri) {
    ($uri, $text) = split / +/, $text, 2;
    $self->{text} = $text;
  }
  $self->{text} ||= $uri;
  for ('class', 'id') {
    $self->{param}->{'link-'.$_}.= ' '.$self->{param}->{$_} if $self->{param}->{$_};
  }
  $self->{param}->{'link-title'} ||= $self->{param}->{title};
  $self->_makelink_start($uri);
}

package H2H::V100::Command::LDIARY;
use base H2H::V100::Command::LINK;
$H2H::V100::Command::Enabled{LDIARY} = 1;
push @H2H::V100::Command::Inline, 'LDIARY';

sub _init {
  my $self = shift;
  $self->SUPER::_init();
  unless ($self->{param}->{link}) {
    if ($self->{text} =~ /^([0-9]+) +([0-9]+) +([0-9]+) +([\x00-\xFF]+)$/) {
      ## format1
      $self->{param}->{link} = '('.$1.','.$2.','.$3.')';
      $self->{text} = $4;
    } elsif ($self->{text} =~ /^([0-9]{4})([0-9]{2})([0-9]{2})(?:s([0-9]{1,2})(?:i([0-9]{1,2}))?)? ([\x00-\xFF]+)$/) {
      $self->{param}->{link} = '('.$1.','.$2.','.$3;
      $self->{param}->{link}.= ','.$4 if $4;
      $self->{param}->{link}.= ','.$5 if $5;
      $self->{param}->{link}.= ')';
      $self->{text} = $6;
    }
  }
  $self;
}

package H2H::V100::Command::SEE;
use base H2H::V100::Command::LINK;
$H2H::V100::Command::Enabled{SEE} = 1;
push @H2H::V100::Command::Inline, 'SEE';

sub _init {
  my $self = shift;
  $self->SUPER::_init();
  unless ($self->{param}->{link}) {
    ($self->{param}->{link}, $self->{text}) = split / +/, $self->{text}, 2;
    $self->{text} = $self->{param}->{link} unless $self->{text};
    $self->{param}->{link} = '??('.$self->{param}->{link}.')';
  }
  $self;
}

package H2H::V100::Command::PERSON;
use base H2H::V100::Command::LINK;
$H2H::V100::Command::Enabled{PERSON} = 1;
push @H2H::V100::Command::Inline, 'PERSON';

sub _init {
  my $self = shift;
  $self->SUPER::_init();
  unless ($self->{param}->{link}) {
    ($self->{param}->{link}, $self->{text}) = split / +/, $self->{text}, 2;
    $self->{text} = $self->{param}->{link} unless $self->{text};
    $self->{param}->{link} = '??{person}('.$self->{param}->{link}.')';
  }
  $self;
}

package H2H::V100::Command::STRONG;
use base H2H::V100::Command::_INLINE;
$H2H::V100::Command::Enabled{STRONG} = 1;
push @H2H::V100::Command::Inline, 'STRONG';

sub _init {
  my $self = shift;
  $self->SUPER::_init();
  $self->{option}->{parenttof}->{STRONG} = -1;
  if ($self->{param}->{level} == 1) {
    $self->{_HTML}->{start} = '<strong%ATTR%>';
    $self->{_HTML}->{end} = '</strong>';
  } else {
    $self->{_HTML}->{start} = '<em%ATTR%>';
    $self->{_HTML}->{end} = '</em>';
  }
  $self;
}

package H2H::V100::Command::ACRONYM;
use base H2H::V100::Command::_INLINE;
$H2H::V100::Command::Enabled{ACRONYM} = 1;
push @H2H::V100::Command::Inline, 'ACRONYM';

sub _init {
  my $self = shift;
  $self->SUPER::_init();
  $self->{option}->{parenttof}->{ACRONYM} = -1;
  $self->{option}->{parenttof}->{ABBR} = -1;
  $self->{_HTML}->{start} = '<acronym%ATTR%>';
  $self->{_HTML}->{end} = '</acronym>';
  unless ($self->{param}->{title}) {
    ($self->{text}, $self->{param}->{title}) = split / +/, $self->{text}, 2;
  }
  $self;
}

package H2H::V100::Command::ABBR;
use base H2H::V100::Command::_INLINE;
$H2H::V100::Command::Enabled{ABBR} = 1;
push @H2H::V100::Command::Inline, 'ABBR';

sub _init {
  my $self = shift;
  $self->SUPER::_init();
  $self->{option}->{parenttof}->{ACRONYM} = -1;
  $self->{option}->{parenttof}->{ABBR} = -1;
  $self->{_HTML}->{start} = '<abbr%ATTR%>';
  $self->{_HTML}->{end} = '</abbr>';
  unless ($self->{param}->{title}) {
    ($self->{text}, $self->{param}->{title}) = split / +/, $self->{text}, 2;
  }
  $self;
}

=head1 LICENSE

Public Domain.

=head1 CHANGE

2001-09-03  wakaba <wakaba@suika.fam.cx>

	* (DL, DT, DD): New command.

2001-08-14  wakaba <wakaba@suika.fam.cx>

	* (NEW, SUB): Fix bug that link did not work.
	* (SEE): Fix incorrect anchor.

=cut

1;
