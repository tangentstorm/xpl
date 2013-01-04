{ all of these are by michal j. wallace, circa 1992.
  extracted from crtstuff.pas and updated 2012 }
{$i xpc.inc}
unit stri; { string interface }
interface uses xpc, sysutils;

  function pad( s : string; len : integer; ch : char ) : string;
  function unpad( s : string; ch : char ) : string;
  function chntimes( c : char; n : byte ) : string;
  function ntimes( const s : string; n : byte ) : string;
  function flushrt( s : string; n : byte; ch : char ) : string;
  function trunc( s : string; len : byte ) : string;
  function UpStr( const s : string ) : String;
  function DnCase( ch : char ) : Char;
  function DnStr( const s : string ) : String;
  function wordn( const s : string; index : byte ) : string;
  function nwords( const s : string ) : byte;
  function startswith(const haystack, needle : string) : boolean;

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

function upstr( const s : string ) : string;
  var count : cardinal;
begin
  setlength( result, length( s ));
  for count := 1 to length( s ) do
    result[ count ] := upcase( s[ count ]);
end;

function dncase( ch: char ) :char;
begin
  if ch in [ 'A' .. 'Z' ] then result := chr( ord( ch ) + 32 )
  else result := ch;
end;

function dnstr( const s : string ) : string;
  var count : cardinal;
begin
  setlength( result, length( s ));
  for count := 1 to length( s ) do
    result[ count ] := dncase( s[ count ] )
end; { dnstr }




function wordn( const s : string; index:  byte ) : string;
  var i, j, len : cardinal;
begin
  i := index;
  len := length( s );
  while (i <= len) and (ord(s[ i ]) > 32) do inc( i );
  if ( i = len ) then
    raise Exception.create('invalid token index')
  else begin
    j := i;
    while (j <= len) and (ord(s[ j ]) > 32) do inc( j );
    result := copy( s, i, j-i )
  end
end;


function nwords( const s : string ) : byte;
  var c, n : byte;
begin
  c := 1;
  n := 0;
  while wordn( s, c ) <> '' do
  begin
    inc( c );
    inc( n );
  end;
  result := n;
end;

function startswith(const haystack, needle : string) : boolean;
  var i : cardinal = 1;
begin
  result := length( needle ) <= length( haystack );
  while result and ( i < length( needle )) do
  begin
    result := haystack[ i ] = needle[ i ];
    inc( i )
  end
end;

end.
