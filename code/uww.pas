{$i xpc.inc}{$mode delphi}
unit uww;
interface uses xpc, classes, ug2d, cw{for debug};

type
  TWordWrap = class (TComponent)
    private
      _gw,                 // gap width (space between items)
      _cx, _cy,            // current x, y
      _ww, _lh : cardinal; // wrap width and line height
    published
      constructor create(aOwner : TComponent); override;
      procedure reset;
      procedure place(item : ug2d.IBounds2D);
      procedure debugdraw;
      property width : cardinal read _ww write _ww;
      property gapw : cardinal read _gw write _gw;
    end;

implementation

constructor TWordWrap.Create(aOwner : TComponent);
  begin
    inherited create(aOwner);
    _cx := 0; _cy := 0; _ww := 64; _lh := 1; _gw := 1;
  end;

procedure TWordWrap.Reset;
  begin
    _cx := 0; _cy := 0;
  end;

procedure TWordWrap.Place(item : ug2d.IBounds2D);
  var gap, newx : cardinal;
  begin //  prove this word wrap algorithm works
    if _cx = 0 then gap := 0 else gap := _gw;
    newx := gap + _cx + item.w;
    if newx > _ww then
      begin
	if (_cx = 0) then ok else _cy += _lh;
	item.y := _cy;
	_cx := 0; item.x := 0;
      end
    else item.x := _cx + gap;
    _cx := newx
  end;

procedure TWordWrap.debugdraw;
  begin
    cxy(1, _cx, _cy, '>')
  end;

initialization
end.