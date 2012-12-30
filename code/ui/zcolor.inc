constructor zcolor.create( a, b, tc, ac, strt : Byte );
begin
  zcounter.create( a, b, tc, ac, 0, $f, strt );
  x2 := a + 8;
  truecol := tcol;
end;


function zcolor.showstring : String;
var
  s : String;
begin
  case value of
    $0 : s := 'black';
    $1 : s := 'blue';
    $2 : s := 'green';
    $3 : s := 'cyan';
    $4 : s := 'red';
    $5 : s := 'magenta';
    $6 : s := 'brown';
    $7 : s := 'light grey';
    $8 : s := 'darkgrey';
    $9 : s := 'light blue';
    $A : s := 'lightgreen';
    $B : s := 'light cyan';
    $C : s := 'bright red';
    $D : s := 'lightmagenta';
    $E : s := 'yellow';
    $F : s := 'white';
  end; 
  if value = truecol SHR 4 then
    tcol := truecol and $F0 + not value and $0F
  else
    tcol := truecol and $F0 + value;
  result := s;
end;
