constructor ZObj.create( a, b, a2, b2 : Byte );
begin
  x  := a;
  y  := b;
  x2 := a2;
  y2 := b2;
end;

procedure zObj.showNormal;
begin
end;

procedure zObj.showInvert;
begin
end;

function zObj.mouseover : Boolean;
begin
  gettextmpos;
  result :=  ( mx >= x ) and ( mx <= x2 ) and
	     ( my >= y ) and ( my <= y2 );
end;

function zObj.pressed : Boolean;
begin
  result := mouseover and ( mou.state and 1 <> 0 );
end;

function zObj.click : Boolean;
begin
  if not pressed then result := false
  else begin
    showInvert;
    repeat until not pressed;
    showNormal;
    result := mouseover; { releasing outside box cancels }
  end
end;
