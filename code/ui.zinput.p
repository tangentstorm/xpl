
constructor zInput.create(
  a, b, tl, dl, tc, ac : Byte; esc : Boolean; start : String );
begin
  inherited create( a, b, a, b );
  tlen     := tl;
  dlen     := dl;
  tcol     := tc;
  acol     := ac;
  cpos     := 1;
  escexits := esc;
  back     := start;
  strg     := start;
  isdone   := false;
  frst     := true;
  tovr     := false;
  d1st     := 1;
end;
  
  
constructor zInput.Default( a, b, tl, dl : Byte; start : String );
begin
  create( a, b, tl, dl, $4E, $07, true, start );
end;
  
  
procedure zInput.Reset;
begin
  strg := back;
  frst := true;
  cpos := 1;
  d1st := 1;
  setovr( false );
  isdone := false;
end;
  

procedure zInput.Show;
var v : String;
begin
  if tovr then //doscursorbig else //doscursoron;
  
  if length( strg ) > dlen
  then colorxy( mX + dlen, mY, acol, '¯' )
  else colorxy( mX + dlen, mY, acol, ' ' );
  
  if cpos = tlen + 1 then //doscursoroff;
  
  while cpos > d1st + dlen do d1st := d1st + 1;
  while cpos < d1st do d1st := d1st - 1;
  
  v := copy( strg, d1st, dlen );
  while length( v ) < dlen do v := v + ' ';
  
  colorxy( mX, mY, tcol, v );
  gotoxy( mX + cpos - d1st, mY );
end;


procedure zInput.del;
begin
  { renamed from delete because I couldn't figure out
    to call the global one in gpc. }
  // {$ifdef FPC}System.delete( strg, cpos, 1 );{$endif}
  delete( strg, cpos, 1 );
  show;
end;


procedure zInput.BackSpace;
begin
  if cpos <> 1 then
    begin
      self.movecursor( cpos - 1 );
      self.del;
    end;
end;

procedure zInput.movecursor( newpos : Byte );
begin
  if newpos = 0 then cpos := 1
  else if ( newpos <= tlen + 1 ) then
    begin
      if ( newpos <= length( strg ) + 1 )
      then cpos := newpos
      else cpos := length( strg ) + 1
    end
  else cpos := tlen;
  show
end;
  
  
procedure zInput.SetOvr( p : Boolean );
begin
  tovr := p;
  show;
end;
  

procedure zInput.getkey( ch : Char );
begin
  if frst then begin
      strg := ch;
      cpos := 2;
      show;
    end
  else if tovr then
    begin
      if cpos <= length( strg ) then strg[cpos] := ch
      else strg := strg + ch;
      movecursor( cpos + 1 );
    end
  else if length( strg ) < tlen then
    begin
      insert( ch, strg, cpos );
      movecursor( cpos + 1 );
    end;
  show
end;


procedure zInput.handle( ch : Char );
begin
  case ch of
    #0 : handleStripped( ReadKey );
    #6,
    #8,
    kbd.ENTER,
    #20,
    #24,
    kbd.ESC,
    #127 : handlestripped( ch );
  otherwise getkey( ch )
  end;
  if frst then frst := False;
end;
  
  
procedure zInput.handlestripped( ch : Char );
const bullets = [' ', '/', '\', '-'];
begin
  case ch of
    #6, #20 : { ^Del <-doesn't seem to work!!,^T }
      begin
        while ( cpos > 1 ) and not ( strg[cpos - 1] in bullets )
        do handlestripped( kbd.LEFT );
        while ( cpos <= length( strg )) and ( not ( strg[cpos] in bullets ))
        do self.del;
        self.del;
      end;
    #8 : backspace;
    kbd.ENTER :
      begin
        back := strg;
        finish;
      end;
    #24 : { ^X }
      while ( cpos > 1 ) do backspace;
    kbd.ESC :
      if escexits then
      begin
        strg := back;
        finish;
      end;
    #71 : { home }
      movecursor( 1 );
    kbd.LEFT :
      movecursor( cpos - 1 );
    kbd.RIGHT :
      movecursor( cpos + 1 );
    #79  :
      begin
        movecursor( 1 );
        movecursor( length( strg ) + 1 ); { end }
      end;
    #82  : setovr( not tovr );
    #83  : self.del;
    #115 : { ^Left}
      begin
        while ( cpos > 1 ) and ( strg[cpos - 1] in bullets )
        do handlestripped( kbd.LEFT );
        while ( cpos > 1 ) and ( not ( strg[cpos - 1] in bullets ) )
        do handlestripped( kbd.LEFT );
      end;
    #116 : { ^Right}
      begin
        while ( cpos <= length( strg ))
              and ( strg[cpos - 1] in bullets )
        do handlestripped( kbd.RIGHT );
        while ( cpos < length( strg ))
              and ( not ( strg[ cpos - 1 ] in bullets ))
        do handlestripped( kbd.RIGHT )
      end;
    #117 : { ^End }
      while cpos <= Length( strg ) do self.del;
    #127 : { ^BS }
      begin
        while ( cpos <= length( strg ))
              and not ( strg[cpos] in bullets ) do 
          handlestripped( kbd.RIGHT );
        while ( cpos > 1 ) and not ( strg[ cpos - 1 ] in bullets ) do
          backspace;
        backspace
      end
  end;
  if frst then frst := false;
end;


procedure zInput.Finish;
begin
  isdone := true;
  //doscursorOff;
end;


function zInput.value : String;
begin
  result:= strg;
end;

function zInput.Get : String;
begin
  Reset;
  repeat handle( readkey ) until isDone;
  result := strg;
end;
