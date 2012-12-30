
constructor zInputbox.create( a, b, border : Byte; s1, s2 : String; l : Byte );
begin
  zConfirmbox.create( a, b, border, s1, s2 );
  i.create( x + 1 + clength( s2 ), y + 2, l, l, $4E, $07, true, '' );
end;

  
constructor zInputbox.default( a, b : Byte; s1, s2 : String; l : Byte );
begin
  zInputbox.create( a, b, $08, s1, s2, l );
end;


function zInputbox.get : String;
begin
  fx.bar( mX, mY, mX + 1 + clength( str1 ), mY + 3, bcol );
  fx.greyshadow( mX, mY, mX + 1 + clength( str1 ), mY + 3 );
  cwritexy( mX + 1, mY + 1, str1 );
  cwritexy( mX + 1, mY + 2, str2 );
  result := i.get;
end;
