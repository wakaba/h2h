
=pod

H2H -- (extended) hnf -> HTML Cnverter

Copyright 2001 the Watermelon Project.

2001-04-03  wakaba
	- Modulization.
	- Add `DIV' support.
	- Add `RUBY' support (in FN).

2001-03-31  wakaba
	- New file.

=cut

package H2H;

sub toHTML {
  my $class = shift;
  my ($options, @h2h) = @_;
  my $ret;
  if ($h2h[0] =~ /^H2H\/[\d\.]+/) {
    $options->{version} = shift(@h2h);
    $options->{version} =~ tr/\x0d\x0a//d;
  }
  unless ($options->{version}) {
    $options->{version} = $options->{version_default} || 'H2H/0.9';
  }
  if ($options->{version} eq 'H2H/0.9') {
    require H2H::V090;
    $H2H::themepath = $options->{theme09_directory};
    require $H2H::themepath.'default/theme.ph';
    require $H2H::themepath.$options->{theme09}.'/theme.ph'
     if $options->{theme09} && -e $H2H::themepath.$options->{theme09}.'/theme.ph';
    $ret = H2H::V090->parse($options, @h2h);
    if ($ret) {
      $H2H::Page::options = $options;
      $ret = ($options->{noheader}? '': &H2H::Page::start())
             .$ret.
             ($options->{nofooter}? '': &H2H::Page::end());
    }
  } else{ #if ($options->{version} eq 'H2H/1.0') {
    require H2H::V100;
    $ret = H2H::V100->parse($options, @h2h);
  }
  $ret;
}

sub header {
  my $class = shift;
  my $options = shift;
  $options->{version} ||= 'H2H/0.9';
  my $ret;
  if ($options->{version} eq 'H2H/0.9') {
    require H2H::V090;
    $H2H::themepath = $options->{theme09_directory};
    require $H2H::themepath.'default/theme.ph';
    require $H2H::themepath.$options->{theme09}.'/theme.ph'
     if $options->{theme09} && -e $H2H::themepath.$options->{theme09}.'/theme.ph';
    $ret = H2H::Page::start();
  } else{ #if ($options->{version} eq 'H2H/1.0') {
    require H2H::V100;
    $ret = H2H::V100->header($options);
  }
  $ret;
}

sub footer {
  my $class = shift;
  my $options = shift;
  $options->{version} ||= 'H2H/0.9';
  my $ret;
  if ($options->{version} eq 'H2H/0.9') {
    require H2H::V090;
    $H2H::themepath = $options->{theme09_directory};
    require $H2H::themepath.'default/theme.ph';
    require $H2H::themepath.$options->{theme09}.'/theme.ph'
     if $options->{theme09} && -e $H2H::themepath.$options->{theme09}.'/theme.ph';
    $ret = H2H::Page::end();
  } else{ #if ($options->{version} eq 'H2H/1.0') {
    require H2H::V100;
    $ret = H2H::V100->footer($options);
  }
  $ret;
}

1;
