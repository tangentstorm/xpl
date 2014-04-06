
constructor zPassword.create(
  a, b, tl, dl, tc, ac : integer; pwc : Char; start : String );
begin
  zInput.create( a, b, tl, dl, tc, ac, true, start );
  pwchar := pwc;
end;


constructor zPassword.default( a, b, tl, dl : integer; start : String );
begin
  create( a, b, tl, dl, $0A, $0E, '■', start );
end;


procedure zPassword.Render;
var temp : String;
begin
  temp := value;
  FillChar( work, length( self.work ), self.pwchar );
  inherited Render;
  work := temp;
end;
