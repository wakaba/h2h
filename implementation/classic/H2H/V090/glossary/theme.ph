
=pod

H2H  --  Glossary Template

Copyright 2001 the Watermelon Project.

2001-04-03  wakaba
	- New file.

=cut

## -- Include default diary style.
require $H2H::themepath.'general/theme.ph';

## -- Information about this template.
package H2H::Template;
  $basepath = $H2H::themepath.'glossary/';
  $header = $basepath.'head.htt';
  $footer = $basepath.'foot.htt';
  
package HNS::Hnf::UserVar;
  $Templates{YOMI}	= '[%value]';
  $Templates{ENGLISH}	= '(= %value)';
  $Templates{ALIAS}	= '(<acronym title="Also Known As" lang="en">aka</acronym> %value)';

1;
