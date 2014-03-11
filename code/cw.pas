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
  ccolors : array [0..15] of char = 'krgybmcwKRGYBMCW';
  ccolstr : string = 'krgybmcwKRGYBMCW';
  ccolset = [ 'k', 'r', 'g', 'y', 'b', 'm', 'c', 'w',
              'K', 'R', 'G', 'Y', 'B', 'M', 'C', 'W' ];


type
  point = object
            x, y, fg, bg : byte;
            procedure setc( value : byte );
            function getc : byte;
	    property c : byte read getc write setc;
	  end;
  rect  = record
            x, y, w, h : integer
          end;

type unichar = string[ 4 ];
var
  cur, sav	     : point;
  scr		     : rect;
  cwcommandmode	     : boolean;  { cwrite command mode? }
  cwcurrenttask	     : command;  { cwrite current command }
  cwnchexpected	     : byte;     { cwrite #chars expected }
  cwchar,                        { cwrite character }
  cwdigit1, cwdigit2,            { 2nd digit of n1 }
  cwdigit3, cwdigit4 : unichar;  { 2nd digit of n2 }

{ ■ string writing commands }

  { primitives : these write text in solid colors }
  procedure cxy(c : word; x, y : byte; const s : string );
  procedure colorxy(x,y:byte;c:word;const s:string); deprecated'use cxy';
  procedure colorxyc( x, y : byte; c : word; const s : string );
  procedure colorxyv( x, y : byte; c : word; const s : string ); // [v]ertical

  { colorwrite : color code interpreter }
  procedure cwcommand( cn : command; s : string );
  procedure cwrite   ( s : string );
  procedure cwriteln ( s : string );
  procedure cwriteln ( args : array of const );
  procedure cwritexy ( x, y : byte; s : string );
  procedure ccenterxy( x, y : byte; s : string );

  { these do padding operations with color-encoded strings. often
    in console mode, what we really want is width in characters on
    the screen, not the length of the actual string in memory. }
  function cLength( s : string ) : integer; deprecated'use cwlen';
  function cwlen( s : string ) : integer;    { length - color codes }
  function cstrip( s : string ) : string;
  function normaltext( s : string; esc : char = trg ) : string;
  function cpadstr(s:string;len:byte;ch:char):string; deprecated'use cwpad';
  function cwpad( s : string; len : byte; ch : char=' ') : string;

  { these highlight punctuation and box drawing
    characters using a standard palette }
  procedure StWrite( s : string );
  procedure StWriteln( s : string );
  procedure StWritexy( x, y : byte; s : String );

implementation

function point.getc : byte;
  begin
    result := (( bg and $0F ) shl 4 ) + ( fg and $0F );
    //  todo : make this << 8 so I can use 256 colors
  end;

procedure point.setc( value : byte );
  begin
    self.fg := lo( value );
    self.bg := hi( value );
  end; { point.setc }

procedure wr( ch : unichar );
  begin
    emit(ch); inc( cur.x );
    if cur.x >= kvm.xMax then cwrite( ^M );
  end;

procedure cxy(c: word; x, y :byte; const s : string); inline;
  var i : integer;
  begin
    kvm.textattr := c;
    kvm.GotoXY( x, y );
    for i := 1 to length(s) do wr( s[i] );
  end; { cxy }

procedure colorxy(x, y :byte; c: word; const s : string); inline;
  begin
    cxy(c,x,y,s)
  end;

{ vertical colorxy }
procedure Colorxyv( x, y : byte; c : word; const s : string );
  var i : byte;
  begin
    for i := 1 to length( s ) do begin
      cxy( c, x, y + i - 1, s[ i ]);
    end;
  end;

{ centered colorxy }
procedure colorxyc( x, y : byte; c : word; const s : string );
  begin
    cxy( c, x + 1 - length( s ) div 2, y, s );
  end;

procedure cwcommand( cn : command; s : string );
  const digits = ['0','1','2','3','4','5','6','7','8','9'];
  begin
    case cn of
      cwfg : if s[ 1 ] in ccolset then
		 cur.fg := pos( s[ 1 ], ccolors ) - 1;
      cwbg : if s[ 1 ] in ccolset then
		 cur.bg := pos( s[ 1 ], ccolors ) - 1;
      cwCR	   : begin
		       cur.x := 0;
		       cur.y := cur.y + 1;
		       { TODO: scroll up }
		       if cur.y > kvm.yMax then
		       begin
			 // scrollup1( txmin, txmax, tymin, tymax, writeto );
			 cur.y := kvm.yMax;
			 cwrite('|%');
		       end
		     end;
      cwBS	   : if cur.x <> 1 then
		     begin
		       cxy( cur.c, cur.x - 1, cur.y, ' ' );
		       dec( cur.x );
		     end;
      cwclrscr	   : begin
		       //  fillbox( scr.x, scr.y, txmax, tymax, tcolor*256 + 32 );
		       kvm.clrscr;
		       cur.x := 0;
		       cur.y := 0;
		     end;
      cwclreol	   : kvm.clreol;
      cwsavecol	   : sav.c := kvm.textattr;
      cwloadcol	   : kvm.textattr := sav.c;
      cwchntimes   : cwrite( normaltext( chntimes( s[1], s2n(s[2]+s[3])) ));
      cwgotoxy	   : begin
		       if length( s ) <> 4 then exit;
		       if ( s[ 1 ] in digits )
			 and ( s[ 2 ] in digits )
			 and ( s[ 3 ] in digits )
			 and ( s[ 4 ] in digits )
			 then
		       begin
			 cur.x := s2n( s[ 1 ] + s[ 2 ]);
			 cur.y := s2n( s[ 3 ] + s[ 4 ]);
		       end;
		     end;
      cwsavexy	   : sav := cur;
      cwloadxy	   : cur := sav;
      cwspecialstr :
	{ //  if i want to do things like this i should make it a 'macro' callback
	  case upcase(s[1]) of
	  'P' : cwrite( thisdir );
	  'D' : cwrite( stardate );
	  end; } ;
	cwrenegade : cur.fg := s2n( s );
    end; { of case cn }
    kvm.fg(cur.fg);
    kvm.bg(cur.bg);
  end; { of cwcommand }

  procedure cwrite( s : string );

    var i : integer;
      ch    : char;
      uch   : unichar;
      bytes : byte;

    procedure next_char;
    begin
      ch := s[ i + 1 ];
      case ord( ch ) of
	$00 .. $7F : bytes := 1;
	$80 .. $BF ,
	$C0 .. $C1 : die( 'invalid utf-8 sequence' );
	$C2 .. $DF : bytes := 2;
	$E0 .. $EF : bytes := 3;
	$F0 .. $F7 : bytes := 4;
	$F8 .. $FF : die( 'invalid utf-8 sequence' );
      end;
      uch := copy( s, i + 1, bytes );
      inc( i, bytes );
    end;

    procedure runcmd( cmd : command; nchars : integer = 0 );
      var j : integer; arg : string;
    begin
      arg := '';
      for j := 1 to nchars do begin
	next_char;
	arg := arg + uch;
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
	  ^G  : write( '␇' ); // 'bell'
	  ^L  : write( ntimes( '- ', kvm.width div 2 - 1 ));
	  ^H  : runcmd( cwbs );
	  else wr( uch );
	end
      else
	case ch of
	  '|' : wr( '|' );
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
	  else if ch in ccolset then begin dec( i ); runcmd( cwfg, 1 ) end
	  else wr( uch ); // ignore invalid triggers
	end
    end
  end;

procedure cwriteln( s : string );
  begin
    cwrite( s ); writeln;
  end;

procedure cwriteln( args : array of const );
  var i : integer;
  begin
    for i := 0 to high( args ) do
      case args[ i ].vtype of
	vtinteger : cwrite( n2s( args[ i ].vinteger ));
	vtstring  : cwrite( args[ i ].vstring^ );
	vtansistring : cwrite( ansistring( args[ i ].vansistring ));
      end;
    writeln;
  end;

procedure cwritexy( x, y : byte; s : string );
  begin
    cur.x := x;
    cur.y := y;
    kvm.gotoxy( x, y );
    cwrite( s );
  end;

procedure ccenterxy( x, y : byte; s : string );
  begin
    cwritexy( x + 1 - cwlen( s ) div 2, y, s );
  end;

procedure StWrite( s: string );
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

procedure StWriteln( s : string );
  begin
    stwrite( s ); writeln;
  end;

procedure StWritexy( x, y : byte; s : string );
  begin
    cur.x := x;
    cur.y := y;
    stwrite( s );
  end;

{ ■ string formatting commands }
function cLength( s : string ) : integer;
  begin result:=cwlen(s)
  end;

function cwlen( s : string ) : integer;
  var i, r : integer;
  procedure incby(x,y:integer);
    begin inc(i,x); inc(r,y);
    end;
  begin
    r := 0;
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

function cstrip( s : string ) : string;
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


{  probably want to rename this to 'escape' }
function normaltext( s : string; esc : char = trg ) : string;
    var i : integer;
  begin
    result := '';
    for i := 1 to length( s ) do
    begin
      if s[ i ] = trg then result := result + esc;
      result := result + s[ i ];
    end;
  end;


function cpadstr( s : string; len : byte; ch : char ) : string;
  begin
    result := cwpad(s,len,ch);
  end;

function cwpad( s : string; len : byte; ch : char=' ') : string;
  begin //TODO: consider codes when truncating
    if cwlen( s ) > len then s := ustr.trunc( s, len );
    while cwlen( s ) < len do s := s + ch;
    result := s;
  end;


initialization
  cwcommandmode := false;
  cwcurrenttask := cwnotask;
  cwnchexpected := 0;
  cur.c := $0007;
  sav.c := $000E;
  cur.x := 0;
  cur.y := 0;
  sav.x := 0;
  sav.y := 0;
  scr.x := 0;
  scr.y := 0;
  scr.h := kvm.height;
  scr.w := kvm.width;
end.
