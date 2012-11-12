
constructor zBounceMenu.init(
    x_, y_, w : Byte; p : String; e, a : Boolean; head:pzChoice );
begin
  tx    := x;
  ty    := y;
  width := w;
  setpal( p );
  height := 1;
  zMenu.init( e, a, on, head );
  insert( newChoiceXY( x, y, top, '', off, #255, 255, nil, head ));
  add( newChoiceXY( x, y + height, bottom, '', off, #255, 255, nil, head ));
  settofirst;
  inc( height, 1 );
  inc( width, 1 );
end;


procedure zbouncemenu.show;
var
  mv :  Boolean;
begin
  mv  := mvisible;
  if mv then showmouse( off );
  greyshadow( tx, ty, tx + width, ty + height - 1 );
  inherited show;
  if mv then showmouse( on )
end;
  

procedure zBounceMenu.format( choice : pzChoice );
begin
  if choice^.st2 = ''
  then choice^.st2 := invertstr( choice^.st1 );
  
  if choice^.st1 <> ''
  then choice^.st1 := normalstr( choice^.st1 )
  else choice^.st1 := sepbar;
  
  choice^.x  := tx;
  choice^.x2 := tx + width + 1;
  choice^.y  := ty + height;
  choice^.y2 := ty + height;
  inc( height, 1 );
end;
  

function zbouncemenu.normalstr( s : String ) : String;
begin
  s := cpadstr( s, width, ' ' );
  result := '|!' + zbmb + '|' + zbmf + '³|' + zbmt + s + '|' + zbmf + '³';
end;


function zbouncemenu.invertstr( s : String ) : String;
begin
  s := cpadstr( s, width, ' ' );
  result :=
    '|!' + zbmb + '|' + zbmf + '³|!' + zbhb + '|' + zbhf + s +
    '|!' + zbmb + '|' + zbmf + '³';
end;


function zbouncemenu.top : String;
begin
  result := '|!' + zbmb + '|' + zbmf + 'Ú' + chntimes( 'Ä', width ) + '¿';
end;


function zbouncemenu.sepbar : String;
begin
  result := '|!' + zbmb + '|' + zbmf + 'Ã' + chntimes( 'Ä', width ) + '´';
end;


function zbouncemenu.bottom : String;
begin
  result := '|!' + zbmb + '|' + zbmf + 'À' + chntimes( 'Ä', width ) + 'Ù';
end;

