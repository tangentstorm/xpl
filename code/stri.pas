{ all of these are by michal j. wallace, circa 1992.
  extracted from crtstuff.pas and updated 2012 }
{$i xpc.inc}
unit stri; { string interface }
interface uses xpc;

  function pad( s : string; len : integer; ch : char ) : string;
  function unpad( s : string; ch : char ) : string;
  function chntimes( c : char; n : byte ) : string;
  function ntimes( const s : string; n : byte ) : string;
  function flushrt( s : string; n : byte; ch : char ) : string;
  function trunc( s : string; len : byte ) : string;
  function UpStr( s : string ) : String;
  function DnCase( ch : char ) : Char;
  function DnStr( s : string ) : String;

implementation

  function chntimes( c : char; n : byte ) : string; inline;
    var i : byte; s : string = '';
  begin
    for i := 1 to n do s := s + c;
    result := s;
  end;

  function ntimes( const s : string; n : byte ) : string; inline;
    var i : byte;
  begin
    result := s;
    for i := 1 to n - 1 do result := result + s;
  end;

  { todo : profile this. }
  function flushrt( s : string; n : byte; ch : char ) : string;
  begin
    if length( s ) < n then insert( chntimes( ch, n-length( s )), s, 1 );
    result := s;
  end;

  function pad( s : string; len : integer; ch : char ) : string;
  begin
    if length( s ) > len then s := trunc( s, len );
    while length( s ) < len do s := s + ch;
    result := s;
  end;

 function unpad( s : string; ch : char ) : string;
  var i : integer;
  begin
    i := length( s );
    while ( i > 0 ) and ( s[ i ] = ch ) do dec( i );
    setlength( s, i );
    result := s;
  end;

  function trunc( s : string; len : byte ) : string;
  begin
    if length( s ) > len then setlength( s, len );
    result := s;
  end;

  function upstr( s : string ) : string;
    var count : byte;
  begin
    for count := 1 to length( s ) do
      s[ count ] := upcase( s[ count ] );
    upstr := s;
  end;

  function dncase( ch: char ) :char;
  begin
    if ch in [ 'A' .. 'Z' ] then result := chr( ord( ch ) + 32 )
    else result := ch;
  end;

  function dnstr( s : string ) : string;
    var count : integer;
  begin
    for count := 1 to length( s ) do
      s[ count ] := dncase( s[ count ] );
    dnstr := s;
  end;

end.
