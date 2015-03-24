{$mode objfpc}{$i xpc.inc}
unit num; { ■ number/conversion commands }
interface uses xpc, sysutils, ustr, math;

  function min( p, q : longint ) : longint;
  function max( p, q : longint ) : longint;
  function inc2( goesto, amt, max : longint ) : longint;
  function dec2( from, amt, min : longint ) : longint;
  function incwrap( goesto, amt, min, max : longint ) : longint;
  function decwrap( from, amt, min, max : longint ) : longint;
  function stepwrap( x, amt, min, max : longint ) : longint;
  function h2s( w : word ) : TStr; deprecated 'use n2h';
  function s2h( s : TStr ) : word; deprecated 'use h2n';
  function n2s( x : longint ) : TStr;
  function s2n( s : TStr ) : longint;
  function n2h( n : cardinal ) : TStr;
  function h2n( s : TStr ) : cardinal;
  function truth(p : longint ) : byte;
  function power(a, b : longint ) : longint;
  function sgn( x : longint ) : shortint;
  function fact( n : cardinal ): cardinal;
  function choose( n, k	: cardinal ): cardinal;

implementation

  function min( p, q : longint ) : longint;
  begin
    if p > q then min := q else min := p;
  end;

  function max( p, q : longint ) : longint;
  begin
    if p < q then max := q else max := p;
  end;

  //  rename inc2->incmax (inc with clamp)
  function inc2( goesto, amt, max : longint ) : longint;
  begin
    if goesto + amt <= max then inc( goesto, amt )
    else goesto := max;
    result := goesto;
  end;

 function dec2( from, amt, min : longint ) : longint;
 begin
   if from - amt >= min then dec( from, amt )
   else from := min;
   result := from;
 end;

  function incwrap( goesto, amt, min, max : longint ) : longint;
  begin
    if goesto + amt <= max then inc( goesto, amt )
    else goesto := min;
    result := goesto;
  end;

  function decwrap( from, amt, min, max : longint ) : longint;
  begin
    if from - amt >= min then dec( from, amt )
    else from := max;
    result := from;
  end;

  function stepwrap( x, amt, min, max : longint ) : longint;
  begin
    if x + amt <= max then
      if x + amt >= min then x := x + amt
      else x := max
    else x := min;
    stepwrap := x;
  end;

// hex ↔ number conversions

function n2h( n : cardinal ) : TStr;
  const hexits = '0123456789ABCDEF';
  function n2h_aux( t : cardinal) : TStr;
    begin
      if t = 0 then result := ''
      else result := n2h_aux( t shr 4 ) + TChr(hexits[ (t and $0f) + 1 ]);
    end;
  begin result := '$' + n2h_aux(n);
  end;

function h2n( s : TStr ) : cardinal;
  var ch : TChr;
  begin
    result := 0;
    for ch in s do begin
      result := result shl 4;
      case ch of
	'$' : ok;
	'0'..'9' : result := result + ord( ch ) - 48;
	'A'..'F' : result := result + ord( ch ) - 55;  { ord('A')-55 = 10 }
	'a'..'f' : result := result + ord( ch ) - 87;  { ord('a')-87 = 10 }
      end
    end
  end;

// ancient confusing names:
function h2s( w : word) : TStr; begin result := n2h(w); end;
function s2h( s : TStr) : word; begin result := h2n(s); end;


function n2s( x : longint ) : TStr;
  var s : TStr;
  begin
    str( x, s );
    n2s := s;
  end;

function s2n( s : TStr ) : longint;
  var i, e : Integer;
  begin
    val( s, i, e );
    if e <> 0 then raise Exception.create( utf8encode('bad number:' + s) )
    else s2n := i;
  end;

function truth( p : longint ) : byte;
  begin
    if boolean( p ) then truth := 1
    else truth := 0;
  end;

function power( a, b : longint ) : longint;
  var c, d : longint;
  begin
    d := 1;
    if b > 0 then
      for c := 1 to b do
	d := d * a;
    power := d;
  end;

function sgn( x : longint ) : shortint;
  begin
    if x > 0 then sgn :=  1;
    if x = 0 then sgn :=  0;
    if x < 0 then sgn := -1;
  end;

function fact( n : cardinal ): cardinal;
  var i : cardinal;
  begin
    result := 1;
    for i := 2 to n do result *= i;
  end;

function choose( n, k : cardinal ): cardinal;
  var i : cardinal; r : extended = 1.0;
  begin
    for i := 0 to k-1 do r := r * (n-i) / (i+1);
    result := floor(r);
  end;

initialization
end.

