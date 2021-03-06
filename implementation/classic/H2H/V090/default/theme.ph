
=pod

H2H  --  Default Template (for Diary)

Copyright 2001 the Watermelon Project.

2001-05-20  wakaba
	- Fix new/sub id counting bug.
2001-04-07  wakaba
	- Add `ACRONYM' and `ABBR' commands.
2001-04-03  wakaba
	- Revision of most part.
2001-03-31  wakaba
	- New file.

=cut

package H2H;
  $nl = "\x0d\x0a";	## Newline character(s).

## -- Information about this template.
package H2H::Template;
  $basepath = $H2H::themepath.'default/';
  $header = $basepath.'head.htt';
  $footer = $basepath.'foot.htt';
  
  ## Initialization of theme.
  sub init {
    package H2H::Command;
      $_new	= 0;
      $_sub	= 0;
      $_fn	= 0;
      $fn	= '';
      ($d{mon}, $d{day}) = (@_[1,2]);
      ($d{y}, $d{m}, $d{d}) = ($_[0], substr('0'.$_[1],-2), substr('0'.$_[2],-2));
      $prefix	= $_[3] || 'f'.$d{y}.$d{m}.$d{d};
    package H2H::HnfFile;
      undef $tree;
  }
  
## -- Page
package H2H::URI;
  $mine = 'http://suika.fam.cx/~wakaba/d/';
  $diary = $mine;
  $glossary{_} = '_glossary_#';
  $glossary{person} = '_person_#';
  $resolve = '/uri?uri=';

package H2H::Page;
  $uri	= '';	## Base URI.
  $diaryuri	= '';	## Diary Base URI.
  $glossaryuri	= '.temp/g.ja.html';
  $personuri	= '';
  $basepath	= '';	## URI base path of related files.
  $uriuri	= '/uri-res/N2L?';
  
  sub start {
    return unless $H2H::Template::header;
    my $ret;
    open TEMP, $H2H::Template::header; while (<TEMP>) {$ret .= $_} close TEMP;
    $ret =~ s/%title%/$_[0]/g;  $ret =~ s/%baseuri%/$basepath/g;
    $ret =~ s/%YYYY%/$H2H::Command::d{y}/g if $H2H::Command::d{y};
    $ret =~ s/%MM%/$H2H::Command::d{m}/g if $H2H::Command::d{m};
    $ret;
  }
  sub end {
    return unless $H2H::Template::footer;
    my $ret;
    open TEMP, $H2H::Template::footer; while (<TEMP>) {$ret .= $_} close TEMP;
    $ret =~ s/%title%/$_[0]/g;  $ret =~ s/%baseuri%/$basepath/g;
    $ret;
  }

package HNS::Hnf::UserVar;
  %Templates = (
	TENKI	=> '[天気:%value]',
	BASHO	=> "(%value)",
	TAION	=> '体温: %value度(摂氏)',
	LUNCH	=> '昼食: %value',
	TAIJU	=> " 体重:%valueKg",
	SUIMIN	=> " 睡眠:%value時間",
	BGM	=> " BGM:%value",
	HOSU	=> " %value歩",
	HON	=> " 読書:%value",
	KITAKU	=> " 帰宅時間:%value",
	WALK	=> " 散歩:%value",
	RUN	=> " ジョギング:%value",
	KEYWORD	=> '[鍵:%value]',
	CAT	=> '[分類:%value]',
	KION	=> '[気温:%value]',
	T1	=> '1限:%value',
	T2	=> '2限:%value',
	T3	=> '3限:%value',
	T4	=> '4限:%value',
	T5	=> '5限:%value',
	T6	=> '6限:%value',
	T7	=> '7限:%value',
	SP	=> '%value',
  );


package H2H::Command;
  
  sub startP	{'<p>'}
  sub endP	{'</p>'}
  
  sub startCITE {
    ($cite, $citet) = @_;
    $cite = _link2uri($cite);
    $cite ? '<blockquote cite="'.$cite.'">' : '<blockquote>'}
  sub endCITE {
    $cite ? '<cite title="引用元"><a href="'.$cite.'">'.($citet||$cite).
    '</a></cite></blockquote>':
    $citet ? '<cite title="引用元">'.$citet.'</cite></blockquote>':
    '</blockquote>';
  }
  
  sub startUL	{'<ul>'}
  sub endUL	{'</ul>'."\n"}
  sub startOL	{'<ol>'}
  sub endOL	{'</ol>'."\n"}
  sub textLI	{'<li>'.$_[0].'</li>'}
  
  sub startPRE	{'<pre>'}
  sub endPRE	{'</pre>'}
  
  sub startDIV	{$_[0] ? '<div class="'.$_[0].'">' : '<div>'}
  sub endDIV	{'</div>'."\n"}
  
  sub startYAMI {
    $_[0] ? '<span class="yamimi">'.$_[0].'</span>':
            '<div class="yami">';
  }
  sub endYAMI	{'</div>'}
  
  sub startNEW {
    my $new = &_new();  $_sub = 0;
    my $secname = $_[0];
    $H2H::HnfFile::tree .= '<li><a href="'.'#d'.$d{day}.'-'.$new.'">'
      .$secname.'</a>';
    my $link = _link2uri($_[1]);
    if ($link) {
      $secname = '<a href="'.$link.'">'.$secname.'</a>';
    }
    '<div class="section" id="d'.$d{day}.'-'.$new.'">'.$H2H::nl.
    '<h3><a href="'.$H2H::Page::uriuri.'urn:x-suika.fam.cx:fuyubi:'.
    "$d{y}:$d{m}:$d{d}:${new}\" class=\"self\">".
    '★</a> '.$secname.'</h3>';
  }
  sub _new	{$_new++; $_new}
  sub endNEW {
  	$H2H::HnfFile::tree .= '</li>'."\n";
  	&H2H::HnfFile::footnote().'</div>'.$H2H::nl
  }
  
  sub startSUB {
    my $new = $_new;
    my $sub = &_sub;
    my $secname = $_[0];
    my $link = _link2uri($_[1]);
    if ($link) {
      $secname = '<a href="'.$link.'">'.$secname.'</a>';
    }
    '<div class="subsection" id="d'.$d{day}.'-'.$new.'-'.$sub.'">'.$H2H::nl.
    '<h4><a href="'.$H2H::Page::uriuri.'urn:x-suika.fam.cx:fuyubi:'.
    "$d{y}:$d{m}:$d{d}:${new}:${sub}\" class=\"self\">".
    '@</a> '.$secname.'</h4>';
  }
  sub _sub	{$_sub++; $_sub}
  sub endSUB	{'</div>'.$H2H::nl}
  
  sub startFN {my $_fn = &_fn;
    $fn .= "<li id=\"d$d{day}-fn${_fn}\">".
           '<a href="'.$H2H::Page::uriuri.'urn:x-suika.fam.cx:fuyubi'.
           ":$d{y}:$d{m}:$d{d}:fn${_fn}\" class=\"self\">*${_fn}</a> ";
    "<a href=\"#d$d{day}-fn${_fn}\" class=\"fn\">*${_fn}</a>"
  }
  sub _fn	{$_fn++; $_fn}
  sub textFN	{$fn .= $_[0]}
  sub endFN	{$fn .= '</li>'."\n"}
  
  sub textLINK {my $link = _link2uri(shift); _dolink($link, $_[0])}
  sub textLIMG	{'<a href="'.$_[0].'"><img src="'.$_[1].'" alt="'.$_[2].'" /></a>'}
  sub textLMG	{'<a href="'.$_[0].'"><img src="'.$_[0].'" alt="'.$_[1].'" /></a>'}
  
  sub textPERSON	{'[<a href="'.$H2H::Page::personuri.
                	 '#person_'.$_[0].'">'.$_[1].'</a>]'}
  
  sub textCOMMENT	{'<!-- '.$_[0].' -->'}
  sub textCOMMENT2	{''}
  
  sub textRUBY	{'<ruby><rb>'.$_[0].'</rb><rp>(</rp><rt>'.$_[1].
  	'</rt><rp>)</rp></ruby>'}
  sub textACRONYM	{'<acronym title="'.$_[1].'">'.$_[0].'</acronym>'}
  sub textABBR	{'<abbr title="'.$_[1].'">'.$_[0].'</abbr>'}
  
  sub textLDIARY	{my ($y, $m, $d, $t) = @_;
  	$m = substr('0'.$m,-2);  $d = substr('0'.$d,-2);
  	'<a href="'.$H2H::Page::uriuri."urn:x-suika.fam.cx:fuyubi:".
  	"$y:$m:$d\">".
  	$t.'</a>'}
  sub textLDIARY2	{my ($f, $t, $y, $m) = ($_[0], $_[1]);
        my ($d, $s, $ss, $ret);
  	if ($f =~ /^(\d{4})(\d{2})(?:(\d{2})(?:i(\d{2})(?:s(\d{2}))?)?)?/)
  	   {($y, $m, $d, $s, $ss) = ($1, $2, $3, $4, $5)}
  	$ret = '<a href="'.$H2H::Page::uriuri."urn:x-suika.fam.cx:fuyubi:".
  	       "$y:$m";
  	$ret .= ":$d" if $d;
  	$ret .= ":$s" if $d && $s;
  	$ret .= ":$ss" if $d && $s && $ss;
  	$ret .= "\">${t}</a>"}
  sub textSEE	{&textLDIARY2(@_)}
  
  sub _dolink {
    my ($href, $content, $title) = @_;
    my $ret;
    if ($href) {
      $ret = '<a href="'.$href.'"';
      $ret.= $title ? ' title="'.$title.'">' : '>';
      $ret.= $content.'</a>';
    } else {$ret = $content}
    $ret =~ tr/\x0d\x0a//d;
    $ret;
  }
  
  sub _link2uri {
    my $link = shift;
    if ($link eq '.') {
    ## Dummy.
      undef $link;
    } elsif ($link =~ /[({](\d{4}),?(\d{2}),?(\d{2})(?:[i,]?(\d{2})(?:[s,]?(\d{2}))?)?[)}]/) {
    ## Diary
      my ($i, $s) = ($4, $5);
      $link = $H2H::Page::uriuri."urn:x-suika.fam.cx:fuyubi:$1:$2:$3";
      $link.= ':'.$i if $i;
      $link.= ':'.$s if $i && $s;
    } elsif ($link =~ /\?[({]([A-Za-z0-9_.-]+)[}}]/) {
    ## Glossary
      $link = $H2H::Page::glossaryuri.'#'.$1;
    } elsif ($link =~ /^urn:/i) {
      $link = $H2H::Page::uriuri.&Suika::CGI::Encode::uri($link);
    }
    $link;
  }
  
package H2H::HnfFile;
  
  sub start	{'<div class="day" id="'.$H2H::Command::prefix.'">'.$H2H::nl.
                 '<h2><a href="'.$H2H::Page::uri.'#'.$H2H::Command::prefix.
                 '" class="self"><img src="favicon" class="favicon" alt="■" title="冬様もすなる☆日記というもの。" /></a> '.
                           $H2H::Command::d{y}.'年'.$H2H::Command::d{m}.'月'.
                           $H2H::Command::d{d}.'日</h2>'.
                 '<div class="header">'.$H2H::nl}
  sub endheader	{'</div>'.$H2H::nl}
  sub end {
  	<<EOH;
<form class="postmsg" method="post" action="/~wakaba/sendmsg" accept-charset="junet, iso-2022-jp-3, iso-2022-jp">
	<input type="hidden" name="subject" value="[冬日] ${H2H::Command::d{y}}年${H2H::Command::d{m}}月${H2H::Command::d{d}}日" />
	<strong class="itemname" title="宜しければ、「読んだよ」ボタンを押して下さい。感想があると、日記を書く励み(謎)になります。">御感想</strong>:
	
	<span class="fs">
	<label><input type="radio" name="f" value="5" />最高!</label>
	<label><input type="radio" name="f" value="4" />良</label>
	<label><input type="radio" name="f" value="3" checked="checked" />普通</label>
	<label><input type="radio" name="f" value="2" />悪</label>
	<label><input type="radio" name="f" value="1" />最低</label>
	</span>
	
	<label class="comments"><nobr>一言(もしあれば。): <input type="text" name="comment" value="" /></nobr></label>
	<label class="names"><nobr>名前(よろしければ。): <input type="text" name="name" value="" /></nobr></label>
	
	<input type="submit" value="読んだよ。" class="readsubmit" title="押したりしても画面が変わったりは恐らくしませんが、問題ありません。" />
</form>
</div>
EOH
  }
  
  sub headervar {
           my ($name, $val, $href) = @_;
           my $ret = $HNS::Hnf::UserVar::Templates{$name};
              $val = '<a href="'.$href.'">'.$val.'</a>' if $href;
              $ret =~ s/\%value/$val/g;
              $ret = $H2H::Error::invalidheader.$name unless $ret;
           if ($name eq 'TENKI') {
             $ret =~ s#&hare;#<img src="hare" class="xbm_font" alt="��" />#g;
             $ret =~ s#&kumori;#<img src="kumori" class="xbm_font" alt="��" />#g;
             $ret =~ s#&ame;#<img src="ame" class="xbm_font" alt="��" />#g;
             $ret =~ s#&yuki;#<img src="yuki" class="xbm_font" alt="��" />#g;
           }
           '<span class="var '.$name.'">'.$ret.'</span>';
  }
  sub footnote {
    return unless $H2H::Command::fn;
    my $ret = '<ol class="footnote">'.$H2H::Command::fn.'</ol>';
    undef $H2H::Command::fn;  $ret;
  }
  
  sub tree {'<ol class="tree">'.$tree.'</ol>' if $tree}
  
  
package H2H::Error;
  $invalidheader = '不正な利用者変数です: ';


package Suika::CGI::Encode;

sub uri {
  my $s = shift;
  $s =~ s/([^A-Za-z0-9_@.-])/sprintf('%%%02X', ord($1))/eg;
$s;
}

1;
