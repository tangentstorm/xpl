
constructor ztoggle.create(
    a, b, tc : Byte; ts, fs : String; startval : Boolean );
begin
  inherited create( a, b, a, b );
  tcol     := tc;
  truestr  := ts;
  falsestr := fs;
  start    := startval;
  value    := startval;
  endloop  := false;
end;

  
procedure ztoggle.show;
begin
  if value
    then colorxy( mX, mY, tcol, truestr )
  else colorxy( mX, mY, tcol, falsestr )
end;

  
procedure ztoggle.handle( ch : Char );
var ts, fs : Char;
begin      
  ts := UpCase( truestr[ 1 ]);
  fs := UpCase( falsestr[ 1 ]);
  ch := UpCase( ch );
  case ch of
    kbd.ENTER : endloop := true;
    kbd.ESC : begin
            value   := start;
            endloop := true
          end;
  otherwise if ch = ts then value := true
  else if ch = fs then value := false
  end;
  show;
end;

function ztoggle.toggle : Boolean;
begin
  value := not value;
  show;
  result := value;
end;


function ztoggle.get : Boolean;
var
  ch : Char;
begin
  endloop := False;
  repeat
    show;
    ch := ReadKey;
    if ch = #0 then ch := ReadKey
    else handle( ch )
  until EndLoop;
  result := value;
end;
