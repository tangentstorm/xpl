
constructor zPassword.create(
  a, b, tl, dl, tc, ac : Byte; pwc : Char; start : String );
begin
  zInput.create( a, b, tl, dl, tc, ac, true, start );
  pwchar := pwc;
end;


constructor zPassword.default( a, b, tl, dl : Byte; start : String );
begin
  create( a, b, tl, dl, $0A, $0E, 'þ', start );
end;


procedure zPassword.show;
var temp : String;
begin
  temp := value;
  FillChar( strg[1], length( self.strg ), self.pwchar );
  inherited show;
  strg := temp;
end;
