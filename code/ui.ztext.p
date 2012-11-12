constructor zText.init( a, b : Byte; s, s2 : String );
begin
  inherited init( a, b, a + clength( s ), b );
  st1 := s;
  st2 := s2;
end;

procedure zText.ShowNormal;
var mv : Boolean;
begin  
  mv := mVisible;
  if mv then ShowMouse( off );
  cwritexy( mX, mY, st1 );
  if mv then ShowMouse( on );
end;

procedure zText.showInvert;
var mv : Boolean;
begin  
  mv := mvisible;
  if mv then showmouse( off );
  cwritexy( mX, mY, st2 );
  if mv then showmouse( on );
end;
