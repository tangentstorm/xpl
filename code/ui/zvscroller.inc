
constructor zVScroller.create(
  a, b, _min, _max, strt : Byte; bc, hc : Char; ba, ha : Byte );
begin
  inherited create( a, b, a, b + _max - _min );
  bch   := bc;
  bat   := ba;
  hch   := hc;
  hat   := ha;
  min   := _min;
  max   := _max;
  value := strt;
  show;
end;


constructor zVScroller.default( a, b, _min, _max, strt : Byte );
begin
  create( a, b, _min, _max, strt, '│', '■', $08, $0A );
end;


procedure zVScroller.domousestuff;
begin
  if pressed and ( my = mY + value - min )
  then while pressed do begin
    value := my - mY + min;
    show
  end
end;


procedure zVScroller.show;
var mv : Boolean;
begin
  mv := mvisible;
  mou.hide;
  colorxyv( mX, mY, bat, chntimes( bch, max - min + 1 ) );
  cxy( hat, mX, mY + value, hch );
  mou.show_if( mv )
end;


procedure zVScroller.handle( ch : Char );
begin
  case ch of
    #0 : handle( ReadKey );
    kbd.UP : value := decwrap( value, 1, min, max );
    kbd.DOWN : value := incwrap( value, 1, min, max );
  end;
  show;
end;
