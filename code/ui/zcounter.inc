
constructor zcounter.create( a, b, tc, ac : Byte; minVal, maxVal, strt : Word );
begin
  inherited create( a, b, a + 6, b );
  acol    := ac;
  tcol    := tc;
  value   := strt;
  start   := strt;
  min     := minVal;
  max     := maxVal;
  endloop := False;
end;


procedure zcounter.show;
var mv : Boolean;
begin  
  mv := mvisible;
  mou.hide;
  if value > min then
    colorxy( x, y, acol, '®' )
  else
    colorxy( x, mY, acol, 'þ' );
  colorxy( x + 1, mY, tcol, chntimes( ' ', x2 - x ) );
  colorxyc( x + ( x2 - x ) div 2 - 1, mY, tcol, showstring );
  if value < max then
    colorxy( x2, mY, acol, '¯' )
  else
    colorxy( x2, mY, acol, 'þ' );
  mou.show_if( mv )
end;

  
procedure zcounter.handle( ch : Char );
begin
  case ch of
    #0        : handle( readkey );
    kbd.LEFT  : value := dec2( value, 1, min );
    kbd.RIGHT : value := inc2( value, 1, max );
    kbd.ENTER : EndLoop := true;
    kbd.ESC   : begin
                  value   := start;
                  endloop := true;
                end
  end;
  show
end;
  

function zcounter.get : Word;
begin
  endloop := false;
  show;
  repeat handle( readkey ) until endloop;
  result := value
end;

procedure zcounter.domousestuff;
begin
  if pressed then
    begin
      sleep( 50 );
      if mou.mx = x then handle( kbd.LEFT );
      if mou.mx = x2 then handle( kbd.RIGHT );
    end;
end;


function zcounter.showstring : String;
begin
  result := n2s( value );
end;
 
