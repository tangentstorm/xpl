{$mode objfpc}{$i xpc.inc}
unit cw; { colorwrite }
interface uses xpc, num, ustr, kvm;

const trg = '|'; // trigger char

type command =
  ( cwnotask,
     cwfg,
     cwbg,
     cwCR,
     cwBS,
     cwclrscr,
     cwclreol,
     cwgotoxy,
     cwgotox,
     cwgotoy,
     cwsavexy,
     cwloadxy,
     cwsavecol,
     cwloadcol,
     cwchntimes,
     cwspecialstr,
     cwrenegade );

const //  why do I need both of these?
  ccolors : array [0..15] of TChr = 'krgybmcwKRGYBMCW';
  ccolstr : TStr = 'krgybmcwKRGYBMCW';
  ccolset = [ 'k', 'r', 'g', 'y', 'b', 'm', 'c', 'w',
              'K', 'R', 'G', 'Y', 'B', 'M', 'C', 'W' ];


type
  cwstate = object
            x, y, fg, bg : word;
            procedure setc( value : word );
            function getc : word;
	    property c : word read getc write setc;
	  end;

var
  sav	             : cwstate;
  cwcommandmode	     : boolean;  { cwrite command mode? }
  cwcurrenttask	     : command;  { cwrite current command }
  cwnchexpected	     : byte;     { cwrite #chars expected }
  cwchar,                        { cwrite character }
  cwdigit1, cwdigit2,            { 2nd digit of n1 }
  cwdigit3, cwdigit4 : TChr;  { 2nd digit of n2 }

{ ■ string writing commands }

  { primitives : these write text in solid colors }
  procedure cxy(c : word; x, y : byte; const s : TStr );
  procedure colorxy(x,y:byte;c:word;const s:TStr); deprecated'use cxy';
  procedure colorxyc( x, y : byte; c : word; const s : TStr );
  procedure colorxyv( x, y : byte; c : word; const s : TStr ); // [v]ertical

  { colorwrite : color code interpreter }
  procedure cwcommand( cn : command; s : TStr );
  procedure cwrite   ( s : TStr );
  procedure cwriteln ( s : TStr );
  procedure cwriteln ( args : array of const );
  procedure cwritexy ( x, y : byte; s : TStr );
  procedure ccenterxy( x, y : byte; s : TStr );

  { these do padding operations with color-encoded strings. often
    in console mode, what we really want is width in characters on
    the screen, not the length of the actual string in memory. }
  function cwlen( s : TStr ) : integer;    { length - color codes }
  function cwpad( s : TStr ; len : byte; ch : TChr=' ') : TStr;
  function cwesc( s : TStr ) : TStr;
  function cstrip( s : TStr ) : TStr;

  function cLength( s : TStr ) : integer; deprecated'use cwlen';
  function cpadstr(s:TStr;len:byte;ch:TChr):TStr; deprecated'use cwpad';
  function normaltext(s:TStr;esc:TChr=trg) : TStr; deprecated'use cwesc';

  { these highlight punctuation and box drawing
    characters using a standard palette }
  procedure StWrite( s : TStr );
  procedure StWriteln( s : TStr );
  procedure StWritexy( x, y : byte; s : TStr );

implementation

function cwstate.getc : word;
  begin
    result := (( bg and $00FF ) shl 8 ) + ( fg and $FF );
  end;

procedure cwstate.setc( value : word );
  begin
    self.fg := lo( value );
    self.bg := hi( value );
  end;

procedure cxy(c: word; x, y :byte; const s : TStr); inline;
  begin
    gotoxy( x, y ); kvm.textattr := c; kvm.emit( s );
  end; { cxy }

procedure colorxy(x, y :byte; c: word; const s : TStr); inline;
  begin
    cxy(c,x,y,s)
  end;

{ vertical colorxy }
procedure Colorxyv( x, y : byte; c : word; const s : TStr );
  var i : byte;
  begin
    for i := 1 to length( s ) do begin
      cxy( c, x, y + i - 1, s[ i ]);
    end;
  end;

{ centered colorxy }
procedure colorxyc( x, y : byte; c : word; const s : TStr );
  begin
    cxy( c, x + 1 - length( s ) div 2, y, s );
  end;

procedure cwcommand( cn : command; s : TStr );
  const digits = ['0','1','2','3','4','5','6','7','8','9'];
  begin
    case cn of
      cwfg : if s[ 1 ] in ccolset then kvm.Fg(s[ 1 ]);
      cwbg : if s[ 1 ] in ccolset then kvm.Bg(s[ 1 ]);
      cwCR : kvm.newline;
      cwBS : if wherex > 0 then
               begin
		 gotoxy( wherex-1, wherey ); emit(' ');
		 gotoxy( wherex-1, wherey );
	       end;
      cwclrscr    : kvm.clrscr;
      cwclreol	  : kvm.clreol;
      cwsavecol	  : sav.c := kvm.textattr;
      cwloadcol	  : kvm.textattr := sav.c;
      cwchntimes  : cwrite( cwesc( chntimes( s[1], s2n(s[2]+s[3])) ));
      cwgotoxy	  : begin
		       if length( s ) <> 4 then exit;
		       if ( s[ 1 ] in digits )
			 and ( s[ 2 ] in digits )
			 and ( s[ 3 ] in digits )
			 and ( s[ 4 ] in digits )
                       then
			 kvm.gotoxy(s2n( s[ 1 ] + s[ 2 ]),
				    s2n( s[ 3 ] + s[ 4 ]));
		     end;
      cwsavexy	   : begin sav.x := wherex; sav.y := wherey end;
      cwloadxy	   : gotoxy(sav.x, sav.y);
      cwspecialstr :
	{ //  if i want to do things like this i should make it a 'macro' callback
	  case upcase(s[1]) of
	  'P' : cwrite( thisdir );
	  'D' : cwrite( stardate );
	  end; } ;
	cwrenegade : kvm.fg( s2n( s ));
    end; { of case cn }
  end; { of cwcommand }

procedure cwrite( s : TStr );
  var
    i  : integer;
    ch : TChr;

  procedure next_char;
    begin
      ch := s[ i + 1 ]; inc(i);
      { ch := s[ i + 1 ]; }
      { case ord( ch ) of }
      {		$00 .. $7F : bytes := 1; }
      {		$80 .. $BF , }
      {		$C0 .. $C1 : die( 'invalid utf-8 sequence' ); }
      {		$C2 .. $DF : bytes := 2; }
      {		$E0 .. $EF : bytes := 3; }
      {		$F0 .. $F7 : bytes := 4; }
      {		$F8 .. $FF : die( 'invalid utf-8 sequence' ); }
      { end; }
      { uch := copy( s, i + 1, bytes ); }
      { inc( i, bytes ); }
    end;

  procedure runcmd( cmd : command; nchars : integer = 0 );
    var j : integer; arg : TStr;
    begin
      arg := '';
      for j := 1 to nchars do begin
	next_char;
	arg := arg + ch;
      end;
      // clear the state:
      cwcurrenttask := cwnotask;
      cwcommandmode := false;
      // make the call:
      cwcommand( cmd, arg );
    end;

  begin { cwrite }
    i := 0;
    while i < length( s ) do
    begin
      next_char;
      if not cwcommandmode then
	case ch of
	  trg : cwcommandmode := true;
	  ^J,
	  ^M  : runcmd( cwcr );
	  ^G  : kvm.emit('␇' ); // 'bell'
	  ^L  : kvm.emit( ntimes( '- ', kvm.width div 2 - 1 ));
	  ^H  : runcmd( cwbs );
	  else kvm.emit( ch );
	end
      else
	case ch of
	  '|' : kvm.emit( '|' );
	  '_' : runcmd( cwcr );
	  '!' : runcmd( cwbg, 1 );
	  '@' : runcmd( cwgotoxy, 4 );
	  '#' : runcmd( cwchntimes, 3 );
	  '$' : runcmd( cwclrscr );
	  '%' : runcmd( cwclreol );
	  '^' : runcmd( cwspecialstr, 1 );
	  ')' : runcmd( cwsavecol );
	  '(' : runcmd( cwloadcol );
	  ']' : runcmd( cwsavexy );
	  '[' : runcmd( cwloadxy );
	  '0'..'9': begin
		      dec( i ); // rewind, so ch becomes part of the arg
		      runcmd( cwrenegade, 2 ) // + next char = 2 total
		    end;
	  else if ch in ccolset then begin dec( i );
	    runcmd( cwfg, 1 ) end
	  else kvm.emit( ch ); // ignore invalid triggers
	end
    end
  end;

procedure cwriteln( s : TStr );
  begin
    cwrite( s ); kvm.newline;
  end;

procedure cwriteln( args : array of const );
  var i : integer;
  begin
    for i := 0 to high( args ) do
      case args[ i ].vtype of
	vtinteger : cwrite( n2s( args[ i ].vinteger ));
	vtstring  : cwrite( Utf8Decode( args[ i ].vstring^ ));
	vtansistring : cwrite( Utf8Decode( ansistring( args[ i ].vansistring )));
      end;
    kvm.newline;
  end;

procedure cwritexy( x, y : byte; s : TStr );
  begin
    kvm.gotoxy( x, y ); cwrite( s );
  end;

procedure ccenterxy( x, y : byte; s : TStr );
  begin
    cwritexy( x + 1 - cwlen( s ) div 2, y, s );
  end;

procedure StWrite( s: TStr );
  var counter : byte;
  begin
    for counter := 1 to Length(S) do
    begin
      case S[counter] of
	'a'..'z','0'..'9','A'..'Z',' ' : kvm.fg( $0F );
	'[',']','(',')','{','}','<','>','"' : kvm.fg( $09 );
	#127 .. #255 : kvm.fg( $08 ); //  '░'..'▀'
	else kvm.fg( $07 );
      end;
      cwrite( s[ counter ]);
    end;
  end;

procedure StWriteln( s : TStr );
  begin
    stwrite( s ); cwriteln('');
  end;

procedure StWritexy( x, y : byte; s : TStr );
  begin
    gotoxy( x, y );
    stwrite( s );
  end;

{ ■ string formatting commands }
function cLength( s : TStr ) : integer; // depricated. use cwlen
  begin result:=cwlen(s)
  end;

function cwlen( s : TStr ) : integer;
  var i, r : integer;
  procedure incby(x,y:integer);
    begin inc(i,x); inc(r,y);
    end;
  begin
    r := 0; // result accumulator
    i := 1;
    while i <= length( s ) do
      if ( s[ i ] = trg ) and ( i + 1 <= length( s )) then
	case s[ i + 1 ] of
	  '|': incby( 2, 1 );
	  '@': incby( 5, 0 );
	  '#': incby( 4, 0 );
	  else incby( 2, 0 );
	end
      else incby( 1, 1 );
    result := r;
  end;

function cstrip( s : TStr ) : TStr;
  var i : integer = 1;
  begin
    result := '';
    while i <= length( s ) do
      if s[ i ] = trg then
	case s[ i + 1 ] of
	  '|': begin i += 2; result += '|'; end;
	  '@': inc( i, 5 );
	  '#': inc( i, 4 );
	  else inc( i, 2 );
	end
      else begin
	result += s[ i ];
	inc( i );
      end
  end;


function normaltext( s : TStr; esc : TChr=trg ) : TStr; deprecated 'use cwesc';
  begin
    result := cwesc( s );
  end;

function cwesc( s : TStr ) : TStr;
  var i : integer;
  begin
    result := '';
    for i := 1 to length( s ) do
      begin
	if s[ i ] = trg then result := result + trg;
	result := result + s[ i ];
      end;
  end;

function cpadstr( s : TStr; len : byte; ch : TChr ) : TStr;
  begin
    result := cwpad(s,len,ch);
  end;

function cwpad( s : TStr; len : byte; ch : TChr=' ') : TStr;
  begin //TODO: consider codes when truncating
    if cwlen( s ) > len then s := ustr.trunc( s, len );
    while cwlen( s ) < len do s := s + ch;
    result := s;
  end;


initialization
  cwcommandmode := false;
  cwcurrenttask := cwnotask;
  cwnchexpected := 0;
  sav.c := $0007;
  sav.x := 0;
  sav.y := 0;
end.
