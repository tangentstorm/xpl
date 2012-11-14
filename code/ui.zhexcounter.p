
constructor zHexCounter.create( a, b, tc, ac : Byte; minVal, maxVal, strt : Word );
begin
  zcounter.create( a, b, tc, ac, minVal, maxVal, strt );
  x2 := a + 8;
end;


function zhexcounter.showstring : String;
begin
  result := h2s( value );
end;

