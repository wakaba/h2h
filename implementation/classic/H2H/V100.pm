
=head1 NAME

H2H::V100

=head1 DESCRIPTION

H2H/1.0 -> HTML Converter

=cut

package H2H::V100;
use H2H::V100::Command::Base;
#use H2H::V100::Command::Error;
use H2H::V100::Command::Main;
use H2H::V100::Theme::Default;

sub parse {
  my ($class, $options, @HNF) = @_;
  my $self = bless {template => $options}, $class;
  require $options->{directory}.$options->{theme}.'.pm'
     if $options->{theme} && -e $options->{directory}.$options->{theme}.'.pm';
  $self->H2H::V100::init_theme();
  my ($header, @c) = (1);
  my ($rethtml);
  $self->{template}->{hdr} = $self->H2H::V100::headervalue::start();
  #$c[1] = H2H::V100::Command::_BODY->new(name => '_BODY',
  #                                      param => $self->{template}->{_BODY_param},
  #                                      theme => $self->{template});
  
    for (@HNF) {
      my $ret = $_;
      $ret =~ tr/\x0d\x0a//d;
      $ret =~ s/[ \t]+$//;
      if ($ret) {
        ##-- Header
        if ($header) {
          if ($ret eq 'OK') {
            $header = 0;
            $self->{template}->{hdr} .= $self->H2H::V100::headervalue::end();
            $c[1] = H2H::V100::Command::_BODY->new(name => '_BODY',
                                        param => $self->{template}->{_BODY_param},
                                        theme => $self->{template});
            $rethtml.= $c[1]->start();
          } else {
            if ($ret =~ /^([0-9A-Z]+) +(.+)$/) {
              $self->{template}->{hdr} .= $self->H2H::V100::headervalue::replace(
                            name => $1, value => $2);
            } elsif ($ret =~ /^([0-9A-Z]+)\* +([^ ]+) +(.+)$/) {
              $self->{template}->{hdr} .= $self->H2H::V100::headervalue::replace(
                            name => $1, value => $3,
                            href => $2);
            } else {
              $self->{template}->{hdr} .= $self->H2H::V100::headervalue::replace(
                            value => $ret);
            }
          } undef $ret;
        ##-- Body
        } else {
          #if ($ret =~ /^(\/?)([0-9A-Z_-]+)([+*])?(?:\:\{([^{}]+)\})?(?: (.+))?$/) {
            #$ret = &_cmd(\@c, $1, $2, $3, $4, $5);
          if ($ret =~ /^(\/)?([0-9A-Z_-]+)(\+)?(?:\* +([^ ]+))?(?: +(.*))?$/) {
            my ($text, $params);
            ($text, $params) = &__parse_text($5) if $5;
            $params->{link} = $4 if $4;
            $ret = &_cmd(\@c, -text => $text, -param => $params,
                                -end => ($1? 1: 0), -fulltext => $ret,
                                -continue => ($3? 1: 0), -name => $2,
                                theme => $self->{template});
          } elsif ($ret =~ /^!(#?) +([\x00-\xFF]*)$/) {	## Comment
            $ret = $2; undef $ret if $1;
            $ret = '<!-- '.$ret.'-->' if $ret;
          } else {
            $ret = &_txt(\@c, $ret);
          }
        }
        $rethtml .= $ret.$H2H::nl if $ret;
      }
    }
    
    for ($i = $#c; $i > 0; $i--) {
      $rethtml .= $c[$i]->end();
    }
  #$self->{html} = 
                  $self->H2H::V100::Document::header().
                  $rethtml.
                  $self->H2H::V100::Document::footer();
  #$self->{html};
}

sub _cmd {
  #my ($cmd, $endcmd, $cmdname, $cmdopt, $cmdparam, $cmdtext) = @_;
  my ($cmd, %CMD) = @_;
  my ($pi, $i, $ret) = ($#$cmd, $#$cmd+1);
  my $nocommand = 0;
  
  if ($CMD{-end}) {
    if ($$cmd[$pi]->{name} eq $CMD{-name}) {
      $ret = $$cmd[$pi-1]->cmdcontent($$cmd[$pi]->end());
      $#$cmd = $pi-1;
    } elsif ($$cmd[$pi]->{name} eq 'P' && $$cmd[$pi-1]->{name} eq $CMD{-name}) {
      $ret = $$cmd[$pi-1]->cmdcontent($$cmd[$pi]->end());
      $ret.= $$cmd[$pi-2]->cmdcontent($$cmd[$pi-1]->end()) if $pi-1 > 1;
      $#$cmd = $pi-2;
    } else {$nocommand = 1}
  } elsif (!$$cmd[$pi]->mychild($CMD{-name})) {	## Not my child!
    $nocommand = 1;
  } else {
    my $name = 'H2H::V100::Command::'.$CMD{-name};
    my $self =
    $H2H::V100::Command::Enabled{$CMD{-name}}
    ? $name->new(name => $CMD{-name}, param => $CMD{-param},
                 text => $CMD{-text}, parents => $cmd,
                 continue => $CMD{-continue},
                 theme => $CMD{theme})
    : {ok => 0};
    if ($self->{ok} == 2) {	## Inline element (one line command)
      $ret = $$cmd[$#$cmd]->cmdcontent($self->linecontent());
    } elsif ($self->{ok}) {	## Block element (Block command)
      $$cmd[$#$cmd+1] = $self;
      $ret = $$cmd[$#$cmd-1]->cmdcontent($self->start());
    } else {
      #$ret = $self->{error};
      $nocommand = 1;
    }
  }
  
  $ret = _txt($cmd, $CMD{-fulltext}) if $nocommand;
  
  $ret;
}

#sub __cmd {
#  shift; my %params = @_;
#  print $params{-name},  ": ",  "\n";
#  my $are = $params{-param};
#  for (keys %$are) {
#    print "\t",  $_,  ' => ',  $$are{$_},  "\n";
#  }
#  print "Text:\t${params{-text}}\n" if $params{-text};
#}

sub _txt {
  my ($cmd, $content) = @_;
  $$cmd[$#$cmd]->content($content);
}

sub __parse_text {
  my ($texts) = shift;
  my ($text, %params);
  unless ($texts =~ /^\{/) {
    $text = $texts;
  } else {
    $texts =~ s{(?:^\{\x20*|\G[;,]\x20*)([a-z0-9_-]+)\x20*=>\x20*(?:"([^"]+)"|([^\x20;,\}]+))\x20*} {
      $params{$1} = $2 || $3;
      '';
    }gex;
    $texts =~ s/^\} *//;
    $text = $texts;
  }
  
  ($text, \%params);
}

sub header {
  my ($class, $options) = @_;
  my $self = bless {template => $options}, $class;
  require $options->{directory}.$options->{theme}.'.pm'
     if $options->{theme} && -e $options->{directory}.$options->{theme}.'.pm';
  $self->H2H::V100::init_theme();
  $self->H2H::V100::Document::header();
}

sub footer {
  my ($class, $options) = @_;
  my $self = bless {template => $options}, $class;
  require $options->{directory}.$options->{theme}.'.pm'
     if $options->{theme} && -e $options->{directory}.$options->{theme}.'.pm';
  $self->H2H::V100::init_theme();
  $self->H2H::V100::Document::footer();
}

=head1 LICENSE

Public Domain.

=head1 CHANGE

2001-09-05  wakaba <wakaba@suika.fam.cx>

	* H2H::V100.pm (parse): fix header value caller's typo.

2001-08-13  wakaba <wakaba@suika.fam.cx>

	* H2H::V100.pm: H2H/1.0 parser is completed.
	* H2H::V100.pm: H2H/0.9 functions are removed.

2001-04-29  wakaba

	* H2H::V100.pm: Forked.
	* H2H::V100.pm: H2H/1.0 support.

2001-04-03  wakaba

	* H2H.pm: Modulization.
	* H2H.pm: Add `DIV' support.
	* H2H.pm: Add `RUBY' support (in FN).

2001-03-31  wakaba

	* H2H.pm: New file.

=cut

1;
