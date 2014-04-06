constructor zObj.Create(aOwner : TComponent);
begin
  inherited create(aOwner);
  x := 0;
  y := 0;
  x2 := 1;
  y2 := 1;
end;

constructor ZObj.create( a, b, a2, b2 : Byte );
begin
  inherited create(nil);
  x  := a;
  y  := b;
  x2 := a2;
  y2 := b2;
end;

procedure zObj.Show;
  begin self.render;
  end;

procedure zObj.Render;
begin showNormal;
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

procedure ZObj.Keys( km : ukm.TKeyMap );
    var ch : widechar;
  begin
    for ch := #0 to #225 do km.crt[ ch ] := OnKey;
    for ch := #$EE00  to #$EEFF do km.crt[ ch ] := OnKey;
  end;

{  temp. scaffolding to delegate new-style keyboard events
     to the old-style handlers. }
procedure ZObj.OnKey( ext : boolean; ch : char );
  begin
    if ext then handlestripped(ch)
    else handle(ch);
  end;

procedure ZObj.handle( ch : Char );
  begin
  end;

procedure ZObj.handlestripped( ch : Char );
  begin
  end;
