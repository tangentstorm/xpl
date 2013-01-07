{ zinput : single line text editor control
------------------------------------------------------------------}

const bullets = [' ', '/', '\', '-'];


constructor zinput.create;
begin
  inherited create;
end;

constructor zinput.create(
  a, b, tl, dl, tc, ac : integer; esc : Boolean; start : String );
begin
  inherited create( a, b, a, b );
  maxlen   := tl;
  dlen     := dl;
  tcol     := tc;
  acol     := ac;
  escexits := esc;
  back     := start;
  self.reset;
end;

constructor zinput.default( a, b, tl, dl : integer; start : String );
begin
  create( a, b, tl, dl, $4E, $07, true, start );
end;

procedure zinput.reset;
begin
  work := back;
  frst := true;
  cpos := 1;
  d1st := 1;
  setovr( false );
  isdone := false;
end;


procedure zinput.fw_token;
begin
  while ( cpos <= length( work ))
    and not ( work[cpos] in bullets )
    do handlestripped( kbd.RIGHT );
  while ( cpos < length( work ))
    and ( not ( work[ cpos - 1 ] in bullets ))
    do handlestripped( kbd.RIGHT )
end;

procedure zinput.bw_token;
begin
  while ( cpos > 1 )
    and ( work[cpos - 1] in bullets )
    do handlestripped( kbd.LEFT );
  while ( cpos > 1 )
    and ( not ( work[cpos - 1] in bullets ) )
    do handlestripped( kbd.LEFT );
end;

procedure zinput.bw_del_token;
begin
  while ( cpos > 1 )
    and not ( work[ cpos - 1 ] in bullets ) do
    backspace;
end;


procedure zinput.del_this_token;
begin
  while ( cpos > 1 )
    and not ( work[cpos - 1] in bullets )
    do handlestripped( kbd.LEFT );
  while ( cpos <= length( work ))
    and ( not ( work[cpos] in bullets ))
    do self.del;
  self.del;
end;

procedure zinput.del_to_end;
begin
  while cpos <= Length( work ) do self.del;
end;

procedure zinput.accept;
begin
  back := work;
  finish;
end;

procedure zinput.cancel;
begin
  work := back;
  finish;
end;

procedure zinput.show;
var v : String;
begin
  //if tovr then //doscursorbig else //doscursoron;

  if length( work ) > dlen
    then colorxy( self.x + dlen, self.y, acol, '¯' )
    else colorxy( self.x + dlen, self.y, acol, ' ' );

  //if cpos = maxlen + 1 then //doscursoroff;

  while cpos > d1st + dlen do inc( d1st );
  while cpos < d1st do dec( d1st );

  v := pad( copy( work, d1st, dlen ), dlen, ' ' );
  colorxy( self.x, self.y, tcol, v );
  gotoxy( self.x + cpos - d1st - 1 , self.y  - 1 );
end;


procedure zinput.movecursor( newpos : integer );
begin
  if newpos = 0 then cpos := 1
  else if (maxlen = 0) or ( newpos <= maxlen + 1 ) then
    cpos := min( newpos, length( work ) + 1 )
  else cpos := maxlen;
  show
end;


procedure zinput.del;
begin
  { renamed from delete because I couldn't figure out
    to call the global one in gpc. }
  // {$ifdef FPC}System.delete( work, cpos, 1 );{$endif}
  delete( work, cpos, 1 );
  show;
end;


procedure zinput.backspace;
begin
  if cpos <> 1 then
    begin
      self.movecursor( cpos - 1 );
      self.del;
    end;
end;


procedure zinput.setovr( p : Boolean );
begin
  tovr := p;
  show;
end;


procedure zinput.getkey( ch : Char );
begin
  if frst then begin
      work := ch;
      cpos := 2;
      show;
    end
  else if tovr then
    begin
      if cpos <= length( work ) then work[cpos] := ch
      else work := work + ch;
      movecursor( cpos + 1 );
    end
  else if (maxlen=0) or (length( work ) < maxlen) then
    begin
      insert( ch, work, cpos );
      movecursor( cpos + 1 );
    end;
  show
end;

procedure zinput.handle( ch : Char );
begin
  if ch in [ #6, #8, kbd.ENTER, #20, #24, kbd.ESC, #127 ] then
    handlestripped( ch )
  else if ch = #0 then
    handleStripped( ReadKey )
  else getkey( ch );
  frst := false;
end;

procedure zinput.handlestripped( ch : Char );
begin
  case ch of
    #6, ^T      : del_this_token; { ^Del <-doesn't seem to work!!,^T }
    kbd.BKSP    : backspace;
    kbd.ENTER   : accept;
    ^x	        : while ( cpos > 1 ) do backspace;
    kbd.ESC     : if escexits then cancel;
    kbd.HOME    : movecursor( 1 );
    kbd.LEFT    : movecursor( cpos - 1 );
    kbd.RIGHT   : movecursor( cpos + 1 );
    kbd.END_    : movecursor( length( work ) + 1 ); { end }
    kbd.INS     : setovr( not tovr );
    kbd.DEL     : self.del;
    kbd.C_LEFT  : bw_token;
    kbd.C_RIGHT : fw_token;
    kbd.C_END   : del_to_end;
    kbd.C_BKSP  : begin fw_token; bw_del_token; backspace; end
  end;
  frst := false;
end;


procedure zinput.finish;
begin
  isdone := true;
  //doscursorOff;
end;

function zinput.value : String;
begin
  result:= work;
end;

function zinput.get : String;
begin
  Reset;
  repeat handle( readkey ) until isDone;
  result := work;
end;

{ end of input.p }
