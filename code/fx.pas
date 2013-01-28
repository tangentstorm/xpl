{$i xpc.inc}
unit fx;
interface uses xpc, cw, stri,cli,kvm;

  Type
    { 80x50 screen }
    ScreenType	= array[ 0..7999 ] of byte;
    VGAtype	= array [ 0..319, 0..200 ] of byte;
    Cel		= array[ 0 .. 0 ] of byte;
    PCel	= ^Cel;                                     { ^TextPicture }
  ScreenTypePtr	= ^ScreenType;

  
  Var
    sw	       : word;           { width of screen * 2}
    Screen     : ScreenType      { co80 screen  }
		 {$IFDEF TPC}
		 absolute $B800$0000
		 {$ENDIF};
    WriteTo    : ScreenTypePtr;  { Directs Writes }
    DOSscreen  : ScreenTypePtr;  { saved DOS screen }
    DOSxPos,                     { saved xpos from DOS }
    DOSyPos    : byte;           { saved ypos from DOS }
    CursorOn   : boolean;        { is cursor on? }
    CursorAttr : word;           { cursorattribs }

  {■ ascii graphics }
  procedure txtline( a, b, x, y, c : byte );
  procedure greyshadow( a1, b1, a2, b2 : byte );
  procedure Rectangle( a, b, x, y : byte; c : word );
  procedure Bar( a, b, x, y : byte; c : word );
  procedure metalbar( a1, b1, a2, b2 : byte );
  procedure metalbox( a1, b1, a2, b2 : byte );
  procedure Button( a1, b1, a2, b2 : byte );
  procedure blackshadow( a1, b1, a2, b2 : byte );


  { ■ screen/window handling commands }
  procedure fillscreen( at : word; uc : string );
  procedure fillbox( a1, b1, a2, b2 : byte; atch : word );
  procedure slidedown( x1, x2, y1, y2 : byte;
		      offwhat	      : screentypeptr );
  procedure slidedownoff( offwhat : screentypeptr );
  procedure scrollup1( x1, x2, y1, y2 : byte;
		      offwhat	      : screentypeptr );
  procedure scrolldown1( x1, x2, y1, y2	: byte;
			offwhat		: screentypeptr );
  procedure scrolldown( x1, x2, y1, y2 : byte;
		       offwhat	       : screentypeptr );
  procedure scrolldownoff( offwhat : screentypeptr );
  procedure scrollright(  x1, x2, y1, y2 : byte;
			offwhat		 : screentypeptr );
  procedure scrollrightoff( offwhat : screentypeptr );


implementation

  //  break this into vl / hl
  procedure txtline( a, b, x, y, c : byte );
  begin
    if a = x then
      colorxyv( a, b, c, stri.ntimes( '│',  y - b + 1 ) )
    else if b = y then
      colorxy( a, b, c, stri.ntimes( '─', x - a + 1 ) );
  end;

  procedure Rectangle( a, b, x, y : byte; c : word );
    var count : byte;
  begin
    for count := a + 1 to x - 1 do
    begin
      ColorXY( count, b, c, '─' );
      ColorXY( count, y, c, '─' );
    end;
    //  this should be one loop, but for some reason, crt screws
    // up when rendering these two characters on the same line:
    // whichever one is written second gets displaced 2 spaces to
    // the left...
    for count := B+1 to Y-1 do ColorXY( a, count, c, '│' );
    for count := B+1 to Y-1 do ColorXY( x, count, c, '│' );
    ColorXY( a, b, c, '┌' );
    ColorXY( a, y, c, '└' );
    ColorXY( x, b, c, '┐' );
    ColorXY( x, y, c, '┘' );
  end;

  procedure Bar(a,b,x,y	: byte; c: word);
    var cx,cy : byte;
  begin
    Rectangle(a,b,x,y, c);
    For cy := b +1  to y-1 do
      cw.colorxy( a+1, cy, c and $ff00, chntimes(' ', x-a-1));
  end;

  procedure greyshadow( a1, b1, a2, b2 : byte );
    var i, w, h : byte;
  begin
    w := a2 - a1;
    h := b2 - b1;
    for i := 1 to w do
      writeto^[ (a1 + i) * 2 - 1 + (b2 * sw) ] := $08;
    if a2 < scr.w+1 then
      for i := 0 to h do
	writeto^[ (a2 * 2) + 1 + ( b1 + i ) * sw ] := $08;
  end;
  
  procedure metalbar( a1, b1, a2, b2 : byte );
    var i, w, c  : byte; z : string;
  begin
    c := cw.cur.c;
    w := a2 - a1 - 1;
    z := chntimes( ' ', w );
    cwritexy( a1, b1, '|W|!w█' + stri.ntimes( '▀', w ) + '|K█');
    for i := 2 to b2 - b1 do
    begin
      colorxy( a1, b1 + i, $7F ,'█' + z );
      colorxy( a2, b1 + i, $78, '█' );
    end;
    cwritexy( a1, b2, '|W|!w█|K' + stri.ntimes( '▄', w ) + '|K█');
    greyshadow(a1,b1+1,a2,b2+1);
    cw.cur.c := c;
  end;

  procedure metalbox( a1, b1, a2, b2 : byte );
    var i, w  : byte;
  begin
    w := a2 - a1 - 1;
    cwritexy( a1, b1, '|W~w█' + stri.ntimes( '▀', w ) + '|K█');
    for i := 1 to b2 - b1 - 1 do
    begin
      colorxy( a1, b1 + i, $7F ,'█' );
      colorxy( a2, b1 + i, $78, '█' );
    end;
    cwritexy( a1, b2, '|W~w█|K' + stri.ntimes( '▄', w ) + '|K█');
  end;
  
  procedure Button(A1,B1,A2,B2 : byte);
    var Count : Byte;
  Begin
    Bar(A1,B1,A2,B2,$0200);
    ColorXY(A1,B1,$07FF,'┌');
    For Count := A1 to A2-1 do ColorXY(Count,B1,$07FF,'─');
    For Count := B1 to B2-1 do ColorXY(A1,Count,$07FF,'│');
    ColorXY(A1,B2,$07FF,'└');
  End;

  
  procedure blackshadow( a1, b1, a2, b2 : byte );
  begin
    colorxy ( a1 + 1, b2 + 1, $0F, chntimes( ' ', a2 - a1 ) );
    colorxyv( a2 + 1, b1 + 1, $0F, chntimes( ' ', b2 - b1 + 1 ) );
  end;




  procedure fillScreen( at : Word; uc:string); {ATTR then unicode Char}
    var
      i	: byte;
      s	: string;
  begin
    s := ntimes( uc, windmaxx-2 );
    for i := kvm.windmaxy-1 downto 1 do colorxy( 0, i, at, s );
    readln;
  end; { FillScreen }


  procedure fillBox( a1, b1, a2, b2 : Byte; atCh : Word );
    var
      count : Word;
      a :     Byte;
      s :     string;
  begin
    a := hi( atCh );
    s := chntimes( chr( lo( atch ) ), a2 - a1 + 1 );
    for count := b1 to b2 do colorxy( a1, count, a, s );
  end; { fillbox }


  { TODO fix the massive duplication in the cw.slidexxx/scrollxxx commands }

  procedure slidedown( x1, x2, y1, y2 : Byte; offwhat : screentypeptr );
    var
      count, count2 : Byte;
      thingy, offset, len : Word;
  begin
    len := ( x2 - x1 + 1 ) * 2;
    for count := pred( y1 ) to pred( y2 ) do
    begin
      //  delay( 10 );
      offset := sw * count + pred( x1 );
      { first, slide old screen section down 1 line }
      for count2 := pred( y2 ) downto count do begin
	thingy := sw * count2 + pred( x1 );
	move( screen[ thingy - sw ],
	      screen[ thingy ], len );
      end;
      { now add the next line }
      move( offwhat^[ offset ],
	    screen[ offset ], len );
    end;
  end; { slidedown }


  procedure slidedownoff( offwhat : screentypeptr );
  begin
    slidedown( 1, 80, 1, 25, offwhat );
  end; { slidedownoff }


  procedure scrollup1( x1, x2, y1, y2 : Byte; offwhat : screentypeptr );
    var
      count : Byte;
      offset, len : Word;
  begin
    dec( x1 );
    dec( x2 );
    dec( y1 );
    dec( y2 );
    len    := ( x2 - x1 + 1 ) * 2;
    offset := y1 * sw + x1 * 2;
    { first, slide old screen section up 1 line }
    for count := SUCC( y1 ) to y2 do begin
      move( writeto^[offset + sw], writeto^[offset], len );
      inc( offset, sw );
    end;
    {now, add the next line}
    if offwhat <> nil then begin
      move( offwhat^[( sw * y2 ) + ( x1 * 2 )],
            writeto^[( sw * y2 ) + ( x1 * 2 )], len );
    end;
  end; { scrollup1 }


  procedure scrolldown1( x1, x2, y1, y2 : Byte; offwhat : screentypeptr );
    var
      count	  : Byte;
      offset, len : Word;
  begin
    dec( x1 );
    dec( x2 );
    dec( y1 );
    dec( y2 );
    len    := ( x2 - x1 + 1 ) * 2;
    offset := sw * y2 + x1 * 2;
    { first, slide old screen section down 1 line }
    for count := pred( y2 ) downto y1 do begin
      move( writeto^[offset - sw], writeto^[offset], len );
      dec( offset, sw );
    end;
    { now, add the next line }
    if offwhat <> nil then begin
      move( offwhat^[( sw * y1 ) + ( x1 * 2 )], writeto^[( sw * y1 ) +
							 ( x1 * 2 )], len );
    end;
  end; { scrolldown1 }


  procedure scrolldown( x1, x2, y1, y2 : Byte; offwhat : screentypeptr );
    var
      count, count2 : Byte;
      thingy, offset, len : Word;
  begin
    x1  := pred( x1 );
    x2  := pred( x2 );
    y1  := pred( y1 );
    y2  := pred( y2 );
    len := ( x2 - x1 + 1 ) * 2;
    for count := y1 to y2 do begin
      //   delay( 10 );
      offset := sw * ( y2 - count + 2 ) + x1 * 2;
      { first, slide old screen section down 1 line }
      for count2 := y2 downto SUCC( y1 ) do begin
	thingy := ( sw * count2 ) + ( x1 * 2 );
	move( screen[thingy - sw], screen[thingy], len );
      end;
      { now, add the next line }
      move( offwhat^[offset], screen[( sw * y1 ) + ( x1 * 2 )], len );
    end;
  end; { scrolldown }


  procedure scrolldownoff( offwhat : screentypeptr );
  begin
    slidedown( 1, 80, 1, 25, offwhat );
  end; { scrolldownoff }


  procedure scrollright( x1, x2, y1, y2 : Byte; offwhat : screentypeptr );
    var
      count, count2 : Byte;
      thingy, len : Word;
  begin
    x1  := pred( x1 );
    x2  := pred( x2 );
    y1  := pred( y1 );
    y2  := pred( y2 );
    len := ( x2 - x1 ) * 2;
    for count := x1 to x2 do begin
      for count2 := y1 to y2 do begin
	thingy := ( count2 * sw ) + ( x1 * 2 );
	move( screen[thingy], screen[thingy + 2], len );
	move( offwhat^[( count2 * sw ) + ( x2 - count ) * 2], screen[thingy], 2 );
      end;
    end;
  end; { scrollright }


  procedure scrollrightoff( offwhat : screentypeptr );
  begin
    scrollright( 1, 80, 1, 25, offwhat );
  end; { scrollrightoff }

  
initialization
end.
