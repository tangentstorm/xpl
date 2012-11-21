{$i xpc.inc}
unit cw; { colorwrite }
interface uses xpc, crt, num, stri;

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
    ccolors : array [0..15] of char = 'kbgcrmywKBGCRMYW';
    ccolstr : string		    = 'kbgcrmywKBGCRMYW';
    ccolset = [ 'k','b','g','c','r','m','y','w',
		'K','B','G','C','R','M','Y','W' ];

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

  var
    cur, sav	       : point;
    scr		       : rect;
    tXmax, tYmax       : byte;     { CWrite xy max }
    cwcommandmode      : boolean;  { cwrite command mode? }
    cwcurrenttask      : command;  { cwrite current command }
    cwnchexpected      : byte;     { cwrite #chars expected }
    cwchar,                        { cwrite character }
    cwdigit1, cwdigit2,            { 2nd digit of n1 }
    cwdigit3, cwdigit4 : char;     { 2nd digit of n2 }

{ ■ string writing commands }

  { primitives	       : these write text in solid colors }
  procedure colorxy  ( const x, y, c : byte; const s : string );
  procedure colorxyc ( x, y, c : byte; s : string );
  procedure colorxyv ( const x, y, c : byte; const s : string ); // v = vertical


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
  //  maybe this should be called width?
  function cLength( s : string ) : integer;    { length - color codes }
  function cstrip( s : string ) : string;
  function normaltext( s : string; esc : char = trg ) : string;
  function cpadstr( s : string; len : byte;ch : char ) : string;

  { these highlight punctuation and box drawing
    characters using a standard palette }
  procedure StWrite( s : string );
  procedure StWriteln( s : string );
  procedure StWritexy( x, y : byte; s : String );

implementation

  function point.getc : byte;
  begin
    result := (( bg and $0F ) << 4 ) + ( fg and $0F ); //  todo : make this << 8 so I can use 256 colors
  end;
  procedure point.setc( value : byte );
  begin
    self.fg := lo( value );
    self.bg := hi( value );
  end;

  procedure colorxy( const x, y, c : byte; const s : string); inline;
  begin
    crt.TextColor( c );
    crt.GotoXY( x, y );
    write( s );
  end;

  { vertical colorxy }
  procedure Colorxyv( const x, y, c : byte;
		      const s : string );
    var i : byte;
  begin
    for i := 1 to length( s ) do begin
      colorxy( x, y + i - 1, c, s[ i ]);
    end;
  end;

  procedure colorxyc( x, y, c : byte; s : string );
  begin
    colorxy( x + 1 - length( s ) div 2, y, c, s );
  end;

  procedure cwcommand( cn : command; s : string );
    const digits = ['0','1','2','3','4','5','6','7','8','9'];
  begin
    cur.x := crt.wherex;
    cur.y := crt.wherey;
    cur.bg := hi( crt.textattr );
    cur.fg := lo( crt.textattr );
    case cn of
      cwfg : if s[ 1 ] in ccolset then
		       cur.fg := pos( s[ 1 ], ccolors ) - 1;
      cwbg : if s[ 1 ] in ccolset then
		       cur.bg := pos( s[ 1 ], ccolors ) - 1;
      cwCR	   : begin
		       cur.x := 1;
		       inc( cur.y );
		       if cur.y > scr.h then
		       begin
			 //  scrollup1( scr.x, txmax, scr.y, tymax, writeto );
			 cur.y := scr.h;
			 cur.x := 1;
			 cwrite( trg + '%' );
		       end;
		     end;
      cwBS	   : if cur.x <> 1 then
		     begin
		       colorxy( cur.x - 1, cur.y, cur.c, ' ' );
		       dec( cur.x );
		     end;
      cwclrscr	   : begin
		       //  fillbox( scr.x, scr.y, txmax, tymax, tcolor*256 + 32 );
		       cur.x := 1;
		       cur.y := 1;
		     end;
      cwclreol	   : write( stri.chntimes( ' ', max( 0, scr.w - cur.x - 1 )));
      cwsavecol	   : sav.c := crt.textattr;
      cwloadcol	   : crt.textattr := sav.c;
      cwchntimes   : begin
		       if length(s) <> 3 then exit;
		       if ( s[ 2 ] in digits ) and ( s[ 3 ] in digits ) then
			 cwrite( normaltext( stri.chntimes( s[ 1 ], s2n( s[ 2 ] + s[ 3 ])) ));
		     end;
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
    crt.gotoxy( cur.x, cur.y ); crt.textattr := cur.c;
  end; { of cwcommand }

  procedure cwrite( s : string );
    var b : byte;
  begin
    if s = '' then exit; {0311.95: i never bothered to check that!!}
    b := 0;
    repeat
      inc( b );
      if not cwcommandmode then
	case s[ b ] of
	  trg : cwcommandmode := true;
	  #13, #10 : cwcommand( cwcr, '' );
	  #08 : cwcommand( cwbs, '' );
	  else write( s[ b ]);
	end
      else
	case cwcurrenttask of
	  cwnotask     : begin
		       case s[ b ] of
			 '|' : write( '|' );
			 '_' : begin
				cwcommandmode := false;
				cwrite(#13);
			      end;
			 '!' : cwcurrenttask := cwbg;
			 '@' : begin
				cwcurrenttask := cwgotoxy;
				cwnchexpected := 4;
			      end;
			 '#' : begin
				cwcurrenttask := cwchntimes;
				cwnchexpected := 3;
			      end;
			 '$' : begin
				cwcommandmode := false;
				cwcommand( cwclrscr, '' );
			      end;
			 '%' : begin
				cwcommandmode := false;
				cwcurrenttask := cwnotask;
				cwcommand( cwclreol, '' );
			      end;
			 '^' : begin
				cwcurrenttask := cwspecialstr;
				cwnchexpected := 1;
			      end;
			 ')' : cwcommand( cwsavecol, '' );
			 '(' : cwcommand( cwloadcol, '' );
			 ']' : cwcommand( cwsavexy, '' );
			 '[' : cwcommand( cwloadxy, '' );
			 '0'..'9': begin
				     cwdigit1 := s[ b ];
				     cwcurrenttask := cwrenegade;
				     cwnchexpected := 1;
				   end;
			 else
			   if s[ b ] in ccolset then cwcommand( cwfg, s[ b ] );
		       end;
		       if ( cwcurrenttask = cwnotask ) then cwcommandmode := false;
		     end;
	  cwbg : begin
			   if s[b] in ccolset then cwcommand( cwbg, s[ b ] );
			   cwcurrenttask := cwnotask;
			   cwcommandmode := false;
			 end;
	  cwgotoxy     : begin
		       case cwnchexpected of
			 4 : cwdigit1 := s[ b ];
			 3 : cwdigit2 := s[ b ];
			 2 : cwdigit3 := s[ b ];
			 1 : begin
			       cwcommandmode := false;
			       cwcurrenttask := cwnotask;
			       cwcommand( cwgotoxy,
					 cwdigit1 + cwdigit2 + cwdigit3 + s[ b ]);
			     end;
		       end;
		       dec( cwnchexpected );
		     end;
	  cwchntimes   : begin
			 case cwnchexpected of
			   3 : cwchar := s[ b ];
			   2 : cwdigit1 := s[ b ];
			   1 : begin
				 cwcommandmode := false;
				 cwcurrenttask := cwnotask;
				 cwcommand( cwchntimes, cwchar + cwdigit1 + s[ b ]);
			       end;
			 end;
			 dec( cwnchexpected );
		       end;
	  cwspecialstr : if cwnchexpected = 1 then
			 begin
			   cwcommandmode := false;
			   cwcurrenttask := cwnotask;
			   dec( cwnchexpected );
			   cwcommand( cwspecialstr, s[ b ]);
			 end;
	  cwrenegade   : if cwnchexpected = 1 then
		       begin
			 cwcommandmode := false;
			 cwcurrenttask := cwnotask;
			 dec( cwnchexpected );
			 cwcommand( cwrenegade, cwdigit1 + s[ b ]);
		       end;
	end;
    until b = length( s );
  end;

  procedure cwriteln( s : string );
  begin cwrite( s ); writeln;
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
    crt.gotoxy( x, y );
    cwrite( s );
  end;

  procedure ccenterxy( x, y : byte; s : string );
  begin
    cwritexy( x + 1 - clength( s ) div 2, y, s );
  end;

  procedure StWrite( s: string );
    var counter : byte;
  begin
    for counter := 1 to Length(S) do
    begin
      case S[counter] of
	'a'..'z','0'..'9','A'..'Z',' ' : crt.textcolor( $0F );
	'[',']','(',')','{','}','<','>','"' : crt.textcolor( $09 );
	#127 .. #255 : crt.textcolor( $08 ); //  '░'..'▀'
	else crt.textcolor( $07 );
      end;
      cwrite( s[ counter ]);
    end;
  end;

  procedure StWriteln( s : string );
  begin
    stwrite( s + #13 );
  end;

  procedure StWritexy( x, y : byte; s : string );
  begin
    cur.x := x;
    cur.y := y;
    stwrite( s );
  end;

{ ■ string formatting commands }

  function clength( s : string ) : integer;
    var i, c : integer;
  begin
    c := 0;
    i := 1;
    while i <= length( s ) do
      if ( s[ i ] = trg ) and ( i + 1 <= length( s )) then
	case s[ i + 1 ] of
	  '@' : inc( i, 5 );
	  '#' : inc( i, 4 );
	  else inc( i, 2 );
	end
      else
      begin
	inc( c );
	inc( i );
      end;
    clength := c;
  end;

  function cstrip( s : string ) : string;
    var i : integer;
  begin
    result := '';
    i := 1;
    while i <= length( s ) do
      if s[ i ] = trg then
	case s[ i + 1 ] of
	  '@' : inc( i, 5 );
	  '#' : inc( i, 4 );
	  else inc( i, 2 );
	end
      else begin
	result := result + s[ i ];
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
    if clength( s ) > len then s := stri.trunc( s, len );
    while clength( s ) < len do s := s + ch;
    cpadstr := s;
  end;


initialization
  cwcommandmode := false;
  cwcurrenttask := cwnotask;
  cwnchexpected := 0;
  cur.c := $0007;
  sav.c := $000E;
  cur.x := wherex;
  cur.y := wherey;
  sav.x := 1;
  sav.y := 1;
  scr.x := 1;
  scr.y := 1;
  scr.h := crt.windmaxy;
  scr.w := crt.windmaxx;
end.
