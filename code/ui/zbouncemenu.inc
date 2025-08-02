
constructor zBounceMenu.create(
    x_, y_, w : Byte; p : String; e, a : Boolean; head:zChoice );
begin
  tx    := x;
  ty    := y;
  width := w;
  setpal( p );
  height := 1;
  zMenu.create( e, a, true, head );
  insert( newChoiceXY( x, y, top, '', false, #255, 255, nil ));
  add( newChoiceXY( x, y + height, bottom, '', false, #255, 255, nil ));
  settofirst;
  inc( height, 1 );
  inc( width, 1 );
end;


procedure zbouncemenu.Render;
var
  mv :  Boolean;
begin
  mv  := mvisible;
  if mv then mou.hide;
  fx.greyshadow( tx, ty, tx + width, ty + height - 1 );
  inherited Render;
  if mv then mou.show
end;


procedure zBounceMenu.format( choice : zChoice );
begin
  if choice.st2 = ''
  then choice.st2 := invertstr( choice.st1 );

  if choice.st1 <> ''
  then choice.st1 := normalstr( choice.st1 )
  else choice.st1 := sepbar;

  choice.x  := tx;
  choice.x2 := tx + width + 1;
  choice.y  := ty + height;
  choice.y2 := ty + height;
  inc( height, 1 );
end;


function zbouncemenu.normalstr( s : String ) : String;
begin
  s := cwpad( s, width, ' ' );
  result := '|!' + zbmb + '|' + zbmf + '│|' + zbmt + s + '|' + zbmf + '│';
end;


function zbouncemenu.invertstr( s : String ) : String;
begin
  s := cwpad( s, width, ' ' );
  result :=
    '|!' + zbmb + '|' + zbmf + '│|!' + zbhb + '|' + zbhf + s +
    '|!' + zbmb + '|' + zbmf + '│';
end;


function zbouncemenu.top : String;
begin
  result := '|!' + zbmb + '|' + zbmf + '┌' + chntimes( '─'[1], width ) + '┐';
end;


function zbouncemenu.sepbar : String;
begin
  result := '|!' + zbmb + '|' + zbmf + '├' + chntimes( '─'[1], width ) + '┤';
end;


function zbouncemenu.bottom : String;
begin
  result := '|!' + zbmb + '|' + zbmf + '└' + chntimes( '─'[1], width ) + '┘';
end;

