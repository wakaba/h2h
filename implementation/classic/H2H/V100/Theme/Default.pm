
=head1 NAME

H2H/1.0
Default Theme

=cut

package H2H::V100;
#%template = ();

sub init_theme {
  my $self = shift;
  $self->{template}->{headerfile} ||= $self->{template}->{directory}.'header.htt';
  $self->{template}->{footerfile} ||= $self->{template}->{directory}.'footer.htt';
  undef $self->{template}->{headerfile} if $self->{template}->{noheader};
  undef $self->{template}->{footerfile} if $self->{template}->{nofooter};
  $self->{template}->{_BODY_param}->{id} = $self->{template}->{prefix};
  $self;
}

=head1 H2H::V100::Document

Templates for output-document.

=cut

package H2H::URI;
  $mine = '';
  $diary = '_diary_';
  $glossary{_} = '_glossary_#';
  $glossary{person} = '_person_#';
  $resolve = '/uri?uri=';

package H2H::V100::Document;
#$template = \%H2H::V100::template;

sub header {
  my $self = shift;
  return unless $self->{template}->{headerfile};
  my $ret;
  if (open HDR, $self->{template}->{headerfile}) {
    $ret = join('', <HDR>);
  close HDR;
  for $i (keys %{$self->{template}}) {
    $ret =~ s/\Q%$i%\E/$self->{template}->{$i}/g;
  }
  }
  $ret;
}
sub footer {
  my $self = shift;
  return unless $self->{template}->{footerfile};
  my $ret;
  if (open HDR, $self->{template}->{footerfile}) {
    $ret = join('', <HDR>);
  close HDR;
  for $i (keys %{$self->{template}}) {
    $ret =~ s/\Q%$i%\E/$self->{template}->{$i}/g;
  }
  }
  $ret;
}

=head1 Tree()

Not implemented yet.

=cut

sub Tree {
}

=head1 H2H::V100::headervalue

HeaderValue.
This will be removed and moved to command module
in future version of H2H.

=head2 replace

%name  => Value Name
%value => Value.

=cut

package H2H::V100::headervalue;
%hdrtemplate = (
  _default => '%name = %value',
);

sub start {
  '<div class="header">';
}
sub end {
  '</div><!-- header -->'."\n";
}

sub replace {
  my $self = shift;
  my %o = @_;
  my $t = $hdrtemplate{$o{name}} || $hdrtemplate{_default};
  $self->{template}->{header}->{$o{name}}->{'text/x-h2h'} = $o{value};
  return &$t(%o) if ref $t;
  $t =~ s/%name/$o{name}/g;
  $t =~ s/%value/$o{value}/g;	## TO DO: __html_ent()
  $o{href} = H2H::V100::Command::_BLOCK::__uri_norm(1, $o{href}) if $o{href};
  $t = '<a href="'.$o{href}.'">'.$t.'</a>' if $o{href};
  '<span class="var '.$o{name}.'">'.$t.'</span>'."\n";
}

=head1 LICENSE

Public Domain.

=head1 CHANGE

2001-09-05  wakaba <wakaba@suika.fam.cx>

	* (headervalue::replace): Fix problem that uri norm wasn't supported.

2001-08-20  wakaba <wakaba@suika.fam.cx>

	* (theme_init): noheader, nofooter support.

2001-08-20  wakaba <wakaba@suika.fam.cx>

	* (theme_init): Fix bug that template->prefix was not applied.

2001-08-11  wakaba <wakaba@suika.fam.cx>

	* New file.

=cut

1;
