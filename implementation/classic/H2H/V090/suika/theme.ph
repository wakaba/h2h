
=head1 NAME

H2H  --  General Template for Suika Server

=head1 LICENSE

Public Domain.

=head1 CHANGE

2001-08-20  wakaba <wakaba@suika.fam.cx>

	* H2H::V090/suika/theme.ph: New.

2001-04-03  wakaba
	- New file.

=cut

## -- Include default diary style.
require $H2H::themepath.'general/theme.ph';

## -- Information about this template.
package H2H::Template;
  $basepath = $H2H::themepath.'suika/';
  $header = $basepath.'head.htt';
  $footer = $basepath.'foot.htt';
  
  ## Initialization of theme.
  sub init {
    package H2H::Command;
      $_new	= 1;
      $_sub	= 1;
      $_fn	= 1;
      $fn	= '';
      $prefix	= $_[3] || 'f'.$_[0].substr('0'.$_[1],-2).substr('0'.$_[2],-2);
    package H2H::HnfFile;
      $header = '';
      $headered = 0;
  }

package H2H::Page;

  sub start {
    return unless $H2H::Template::header;
    my $ret;
    open TEMP, $H2H::Template::header; while (<TEMP>) {$ret .= $_} close TEMP;
    for $i (keys %$options) {
      $ret =~ s/\Q%$i%\E/$options->{$i}/g;
    }
    $ret;
  }


package H2H::Command;
  sub textSEE	{'<a href="#'.$_[0].'">'.$_[1].'</a>'}

package H2H::HnfFile;
  
  sub start	{'<div class="day" id="'.$H2H::Command::prefix.'">'.$H2H::nl}
  sub headervar {
    my ($name, $val) = @_;  my $ret;
    if ($name eq 'TITLE') {
      $ret = '<h2><a href="'.$H2H::Page::uri.'#'.$H2H::Command::prefix.
             '" class="self">¢£</a> '.$val.'</h2><div class="header">'.
             $H2H::nl.$header;
      undef $header;  $headered = 1;
    } else {
      $ret = $HNS::Hnf::UserVar::Templates{$name};
              $ret =~ s/\%value/$val/g;
              $ret = $H2H::Error::invalidheader.$name unless $ret;
      if ($headered) {
        $ret = '<span class="var '.$name.'">'.$ret.'</span>';
      } else {
        $header .= '<span class="var '.$name.'">'.$ret.'</span>';
        undef $ret;
      }
    }
    $ret;
  }
  sub endheader {
    $headered ? '</div>'.$H2H::nl :
    $header   ? '<div class="header">'.$H2H::nl.$header.'</div>'.$H2H::nl: $H2H::nl;
  }
  sub end {'</div>'.$H2H::nl}
  sub tree {}


1;
