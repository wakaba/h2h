
=pod

H2H::V100::Command::_ERROR

=cut

package H2H::V100::Command::_ERROR;
use base H2H::V100::Command::_BODY;

sub new {
  my $class = shift;
  my $self = bless {@_}, ref($class) || $class;
  $self->_checkparent();
  $self;
}
sub _checkparent {
  my $self = shift;
  $self->{ok} = 0;
  $self->{error} = 'error!';
  $self;
}

1;
