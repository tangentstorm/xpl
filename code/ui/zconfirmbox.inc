constructor zConfirmbox.create( a, b, border : Byte; s1, s2 : String );
begin
  mX    := a;
  mY    := b;
  bcol := border;
  str1 := s1;
  str2 := s2;
end;


constructor zConfirmbox.default( a, b : Byte; s1, s2 : String );
begin
  zConfirmbox.create( a, b, $08, s1, s2 );
end;


function zConfirmbox.get : Boolean;
begin
  fx.bar( mX, mY, mX + 1 + clength( str1 ), mY + 3, bcol );
  fx.greyshadow( mX, mY, mX + 1 + clength( str1 ), mY + 3 );
  cwritexy( mX + 1, mY + 1, str1 );
  ccenterxy( mX + clength( str1 ) div 2, mY + 2, str2 );
  result := yesno;
end;
