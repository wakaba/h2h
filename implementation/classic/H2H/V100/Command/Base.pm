
=head1 NAME

H2H::V100::Command::Base

=head1 DESCRIPTION

H2H/1.0 -- Command Module -- Base

=cut

package H2H::V100::Command::_BLOCK;

sub new {
  my $class = shift;
  my $self = bless {@_}, ref($class) || $class;
  $self->_checkparent()->_init();
  $self;
}

sub _checkparent {
  my $self = shift;
  if ($#{$self->{parents}} > 0 && $self->{option}->{parenttof}->{
      $self->{parents}->[$#{$self->{parents}}]->{name}} == -1) {
    $self->{ok} = 0;
  } else {
    $self->{ok} = 1;
    undef $self->{error};
    if ($#{$self->{parents}} > 0
        && ($self->{parents}->[$#{$self->{parents}}]->{_have_link}
        ||  $self->{parents}->[$#{$self->{parents}}]->{_parent_link})) {
      $self->{_parent_link} = 1;
    }
  }
  $self;
}

sub _init {
  my $self = shift;
  $self->{_HTML}->{start} = '<div%ATTR%>';
  $self->{_HTML}->{end} = '</div>';
  $self->{option}->{specials_not_to_entity} = 1;	## & -> &amp;, <, >, ".
  $self->{option}->{child_default_no} = 0;
  %{$self->{option}->{child_tof}} = (
    ## True = 1, False = -1
    LI => -1,
    RB => -1,
    RT => -1,
  );
  $self->{parentid} = $self->{parents}->[$#{$self->{parents}}]->{parentid};
  $self->{parentid} = $self->{parents}->[$#{$self->{parents}}]
    if $self->{parents}->[$#{$self->{parents}}]->{param}->{id};
  $self->{fnid} = 0;
  $self->{childid} = 0;
  $self;
}

sub mychild {
  my $self = shift;  my $cmd = shift;
  my $ret = 1;
  $ret = 0 if $self->{option}->{child_default_no} == 1;
  $ret = 0 if $self->{option}->{child_tof}->{$cmd} == -1;
  $ret = 1 if $self->{option}->{child_tof}->{$cmd} == 1;
  $ret;
}

sub start {
  my $self = shift;
  my $ret; $ret = $self->{_buffer}; undef $self->{_buffer};
  $ret.$self->_replace_attr($self->{_HTML}->{start});
}

sub _replace_attr {
  my $self = shift;
  my $str = shift;
  my ($attr);
  if ($self->{param}->{id}) {$attr .= ' id="'.$self->{param}->{id}.'"'}
  if ($self->{param}->{class}) {$attr .= ' class="'.$self->{param}->{class}.'"'}
  if ($self->{param}->{lang}) {$attr .= ' lang="'.$self->{param}->{lang}.'"'}
  if ($self->{param}->{title}) {
    $attr .= ' title="'.$self->__html_ent($self->{param}->{title}).'"';
  }
  if ($self->{param}->{style}) {
    $attr .= ' style="'.$self->__html_ent($self->{param}->{style}).'"';
  }
  $str =~ s/%ATTR%/$attr/;
  $str;
}

sub end {shift->{_HTML}->{end}}

sub content {shift->__html_ent($_[0])}
sub cmdcontent {$_[1]}

## for One Line Command.
sub linecontent {
  my $self = shift;
  $self->start().$self->content($self->{text}).$self->end();
}

## FootNote
sub footnote_start {
  my $self = shift;
  unless ($self->{footnotes}->{parent}) {
    for $i (reverse 1..$#{$self->{parents}}) {
      if ($self->{parents}->[$i]->{name} eq 'SUB' ||
          $self->{parents}->[$i]->{name} eq 'NEW' ||
          $self->{parents}->[$i]->{name} eq '_BODY') {
        $self->{footnotes}->{parent} = $self->{parents}->[$i];
        last;
      }
    }
  }
  my $index = $self->{parentid}->{fnid}++ + 1;
  push @{$self->{footnotes}->{parent}->{footnote}}, {@_,
    id => $self->{parentid}->{param}->{id}.'-fn'.$index};
  ($index,$self->{parentid}->{param}->{id}.'-fn'.$index);
}

sub footnote_text {
  my $self = shift;
  my ($fntext) = shift;
  $self->{footnotes}->{parent}->{footnote}->
      [$#{$self->{footnotes}->{parent}->{footnote}}]->{text} .= $fntext;
  $self;
}

sub footnote_tohtml {
  my $self = shift;
  my $r;
  for $i (@{$self->{footnote}}) {
    my ($attr);
    if ($$i{id}) {$attr .= ' id="'.$$i{id}.'"'}
    if ($$i{class}) {$attr .= ' class="'.$$i{class}.'"'}
    if ($$i{lang}) {$attr .= ' lang="'.$$i{lang}.'"'}
    if ($$i{title}) {$attr .= ' title="'.$self->__html_ent($$i{title}).'"'}
    if ($$i{style}) {$attr .= ' style="'.$self->__html_ent($$i{style}).'"'}
    $r .= '<li'.$attr.'>'.$$i{text}.'</li>'."\n";
  }
  @{$self->{footnote}} = ();
  if ($r) {
    $r = '<ol class="footnote">'."\n".$r.'</ol>';
  }
  $r;
}

## Normalization or convert URI.
sub __uri_norm {shift;
  my $uri = shift;
    if ($uri eq '.') {
    ## Dummy.
      undef $uri;
    } elsif ($uri =~ /^[({](\d{4})(?:,?(\d{1,2})(?:,?(\d{1,2})(?:[i,]?(\d{1,2})(?:[s,]?(\d{1,2}))?)?)?)?[)}]$/) {
    ## Diary
      my ($year,$month,$day,$sec,$ssc) = ($1,$2,$3,$4,$5);
      for ($year,$month,$day,$sec,$ssc) {$_+=0}
      if ($month) {
        $month = sprintf('%02d', $month);
        $uri = $H2H::URI::diary.'d'.$year.$month.'#d'.$day;
        $uri.= '-'.$sec if $sec;
        $uri.= '-'.$ssc if $ssc;
      } else {
        $uri = $H2H::URI::diary.'list#d'.$year;
      }
    } elsif ($uri =~ /^\?\?(?:\{([A-Za-z0-9_.-]+)\})?[(]?([\x00-\xFF]+?)[)]?$/) {
    ## Glossary
      my ($gid, $gwd) = ($1,$2);
      $gwd =~ s/([^A-Za-z0-9_@.-])/sprintf('%%%02X', ord($1))/eg;
      $uri = ($H2H::URI::glossary{($gid || '_')} || $gid).$gwd;
    } elsif ($uri =~ /^urn:/i) {
      $uri =~ s/([^A-Za-z0-9_@.-])/sprintf('%%%02X', ord($1))/eg;
      $uri = $H2H::URI::resolve.$uri;
    }
  $uri;
}

## HTML entitize
sub __html_ent {
  my $self = shift;
  my $a = shift;
  if (!$self->{option}->{specials_not_to_entity}) {
    $a =~ s/&/&amp;/g;
    $a =~ s/</&lt;/g;
    $a =~ s/>/&gt;/g;
    $a =~ s/"/&quot;/g;
  }
  $a;
}


sub _makelink_start {
  my ($self, $uri) = @_;
  $uri ||= $self->{param}->{link};
  $uri = $self->__uri_norm($uri);
  return unless $uri;
  return if $self->{_parent_link};
  
  my $attr;
  for ('title', 'class', 'id') {
    $attr .= ' '.$_.'="'.$self->__html_ent($self->{param}->{'link-'.$_}).'"'
           if $self->{param}->{'link-'.$_};
  }
  
  $self->{_have_link} = 1;
  '<a href="'.$self->__html_ent($uri).'"'.$attr.'>';
}


package H2H::V100::Command::_BODY;
use base H2H::V100::Command::_BLOCK;
push @H2H::V100::Command::Block, '_BODY';

sub _init {
  my $self = shift;
  $self->{_HTML}->{start} = '<div class="body">';
  $self->{_HTML}->{end} = '</div><!-- class="body" -->';
  $self->{footnotes}->{parent} = \$self;
  $self;
}

sub content {
  my $ret = shift->__html_ent($_[0]);
  '<p class="invalid">'.$ret.'</p>' if $ret;
}

sub end {
  my $self = shift;
  $self->footnote_tohtml().$self->SUPER::end();
}


package H2H::V100::Command::_INLINE;
use base H2H::V100::Command::_BLOCK;


sub new {
  my $class = shift;
  my $self = bless {@_}, ref($class) || $class;
  $self->_init()->_checkparent();
  $self->{ok} = 2 if $self->{ok} && !$self->{continue};
  $self;
}

sub start {
  my $self = shift;
  $self->SUPER::start().$self->_makelink_start();
}

sub end {
  my $self = shift;
  ($self->{_have_link}? '</a>': '').$self->SUPER::end();
}

sub _init {
  my $self = shift;
  $self->SUPER::_init();
  $self->{_HTML}->{start} = '<span%ATTR%>';
  $self->{_HTML}->{end} = '</span>';
  $self->{option}->{parenttof}->{_BODY} = -1;
  #$self->{option}->{parenttof}->{$self->{name}} = -1;
  $self;
}

=head1 LICENSE

Public Domain.

=head1 CHANGE

2001-09-05  wakaba <wakaba@suika.fam.cx>

	* (_replace_attr): support style attribute.
	* (footnote_tohtml): likewise.

2001-08-14  wakaba <wakaba@suika.fam.cx>

	* (__uri_norm()): Fix bug of fuyubi.

2001-08-14  wakaba <wakaba@suika.fam.cx>

	* (_makelink_start()): Moved from _INLINE to _BLOCK.

=cut

1;
