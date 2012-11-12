
constructor zInputbox.init( a, b, border : Byte; s1, s2 : String; l : Byte );
begin
  zConfirmbox.init( a, b, border, s1, s2 );
  i.init( x + 1 + clength( s2 ), y + 2, l, l, $4E, $07, true, '' );
end;

  
constructor zInputbox.default( a, b : Byte; s1, s2 : String; l : Byte );
begin
  zInputbox.init( a, b, $08, s1, s2, l );
end;


function zInputbox.get : String;
begin
  bar( mX, mY, mX + 1 + clength( str1 ), mY + 3, bcol );
  greyshadow( mX, mY, mX + 1 + clength( str1 ), mY + 3 );
  cwritexy( mX + 1, mY + 1, str1 );
  cwritexy( mX + 1, mY + 2, str2 );
  result := i.get;
end;
