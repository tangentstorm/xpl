
constructor zObj.create(aOwner : TComponent);
begin
  inherited create(aOwner);
  x := 0;
  y := 0;
  x2 := 1;
  y2 := 1;
  is_dirty := false;
end;

constructor ZObj.create( a, b, a2, b2 : Byte );
begin
  inherited create(nil);
  x  := a;
  y  := b;
  x2 := a2;
  y2 := b2;
end;

procedure zObj.show;
begin
  showNormal; self.is_dirty := false;
end;


procedure zObj.showNormal;
begin
end;

procedure zObj.showInvert;
begin
end;

procedure zObj.smudge;
begin
  self.is_dirty := true;
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
