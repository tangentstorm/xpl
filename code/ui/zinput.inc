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


procedure zinput.fw_del_token;
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
  while (Length(work) > cpos) do self.del;
end;

function zinput.str_to_end : string;
begin
  result := rightstr( work, length(work) - cpos );
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
    then colorxy( self.x + dlen, self.y, acol, '»' )
    else colorxy( self.x + dlen, self.y, acol, ' ' );

  //if cpos = maxlen + 1 then //doscursoroff;

  while cpos > d1st + dlen do inc( d1st );
  while cpos < d1st do dec( d1st );

  v := pad( copy( work, d1st, dlen ), dlen, ' ' );
  colorxy( self.x, self.y, tcol, v );
  gotoxy( self.x + cpos - d1st, self.y );
end;


procedure zinput.movecursor( newpos : cardinal );
begin
  if (maxlen = 0) or ( newpos <= maxlen ) then
    cpos := min( newpos, length( work ))
  else cpos := maxlen;
  smudge
end;


procedure zinput.del;
begin
  { renamed from delete because I couldn't figure out
    to call the global one in gpc. }
  // {$ifdef FPC}System.delete( work, cpos, 1 );{$endif}
  if length( work ) > cpos then
  begin
    delete( work, cpos + 1, 1 );
    smudge;
  end
end;


procedure zinput.backspace;
begin
  if cpos > 0 then
    begin
      self.left;
      self.del;
    end;
end;


procedure zinput.setovr( p : Boolean );
begin
  tovr := p;
  smudge;
end;


procedure zinput.insert( ch : char );
begin
  if frst then begin
      work := ch;
      cpos := 2;
      smudge;
    end
  else if tovr then
    begin
      if cpos <= length( work ) then work[cpos] := ch
      else work := work + ch;
      movecursor( cpos + 1 );
    end
  else if (maxlen=0) or (length( work ) < maxlen) then
    begin
      system.insert( ch, work, cpos + 1 );
      movecursor( cpos + 1 );
    end;
  smudge
end;

procedure zinput.handle( ch : Char );
begin
  case ch of
    ^A : to_start;
    ^B : left;
    ^C : ;
    ^D : del;
    ^E : to_end;
    ^F : right;
    ^G : ;
    ^H : backspace;
    ^I : ;
    ^J : ;
    ^K : del_to_end;
    ^L : smudge;
    ^M : ;
    ^N : ;
    ^O : ;
    ^P : ;
    ^Q : ;
    ^R : ;
    ^S : ;
    ^T : ;
    ^U : fw_del_token;
    ^V : ;
    ^W : bw_del_token;
    ^X : ;
    ^Y : ;
    ^Z : ;
    { special characters }
    ^@ : ; // #0 ( null )
    ^[ : ;
    ^\ : ; // file separator
    ^] : ; // group separator
    ^^ : ; // record separator
    ^_ : ; // unit separator
    ^? : backspace;
    else if ch = #0 then handleStripped( ReadKey )
    else self.insert( ch )
  end;
  frst := false;
end;


procedure zinput.to_start;
begin
  movecursor( 0 );
end;

procedure zinput.to_end;
begin movecursor( length( work ) + 1 );
end;

function zinput.at_end : boolean;
begin
  result := cpos >= length( work ) + 1;
end;

procedure zinput.left;
begin movecursor( cpos - 1 );
end;

procedure zinput.right;
begin movecursor( cpos + 1 );
end;

procedure zinput.handlestripped( ch : Char );
begin
  case ch of
    kbd.BKSP    : backspace;
    kbd.ENTER   : accept;
    ^x	   : while ( cpos > 1 ) do backspace;
    kbd.ESC     : if escexits then cancel;
    kbd.HOME    : to_start;
    kbd.LEFT    : left;
    kbd.RIGHT   : right;
    kbd.END_    : to_end;
    kbd.INS     : setovr( not tovr );
    kbd.DEL     : self.del;
    kbd.C_LEFT  : bw_token;
    kbd.C_RIGHT : fw_token;
    kbd.C_END   : del_to_end;
    kbd.C_DEL   : fw_del_token;
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

{ eof }
