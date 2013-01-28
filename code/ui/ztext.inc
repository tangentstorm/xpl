constructor zText.create( a, b : Byte; s, s2 : String );
begin
  inherited create( a, b, a + clength( s ), b );
  st1 := s;
  st2 := s2;
end;

procedure zText.ShowNormal;
var mv : Boolean;
begin
  mv := mVisible;
  if mv then mou.hide;
  cwritexy( self.x, self.y, st1 );
  if mv then mou.show;
end;
  
procedure zText.showInvert;
var mv : Boolean;
begin  
  mv := mvisible;
  if mv then mou.hide;
  cwritexy( self.x, self.y, st2 );
  if mv then mou.show;
end;
