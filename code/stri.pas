{ all of these are by michal j. wallace, circa 1992.
  extracted from crtstuff.pas and updated 2012 }
{$mode objfpc}{$i xpc.inc}
unit stri; { string interface }
interface uses xpc, sysutils, strutils;

  function pad( s : string; len : integer; ch : char ) : string;
  function lpad( s : string; len : integer; ch : char ) : string;
  function rpad( s : string; len : integer; ch : char ) : string;
  function unpad( s : string; ch : char ) : string;
  function chntimes( c : char; n : byte ) : string;
  function ntimes( const s : string; n : byte ) : string;
  function flushrt( s : string; n : byte; ch : char ) : string;
  function trunc( s : string; len : byte ) : string;
  function UpStr( const s : string ) : String;
  function DnCase( ch : char ) : Char;
  function DnStr( const s : string ) : String;
  function wordn( const s : string; n : cardinal ) : string;
  function nwords( const s : string ) : cardinal;
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

function rpad( s : string; len : integer; ch : char ) : string;
  begin
    if length( s ) > len then s := trunc( s, len );
    while length( s ) < len do s := s + ch;
    result := s;
  end;

function lpad( s : string; len : integer; ch : char ) : string;
  begin
    if length( s ) > len then s := trunc( s, len );
    while length( s ) < len do s := ch + s;
    result := s;
  end;

function pad( s : string; len : integer; ch : char ) : string; inline;
  begin
    rpad( s, len, ch)
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



type
  tokenhandler = procedure( num, pos, len : cardinal; var stop : boolean ) is nested;

procedure foreach_wordloc( s : string; start : cardinal;
			  callback : tokenhandler );
  var pos, tok_end, len, count : cardinal;
  var stop : boolean = false;
begin
  pos := start; len := length( s ); count := 0;
  while pos < len do begin
    if ord( s[ pos ]) <= 32 then inc( pos )
    else begin
      tok_end := pos;
      repeat inc( tok_end )
      until ( tok_end = len ) or ( ord( s[ tok_end ]) <= 32 );
      if ( tok_end = len ) then inc( tok_end );
      inc( count );
      callback( count, pos, tok_end - pos, stop );
      if stop then pos := len else pos := tok_end;
    end;
  end
end;

function wordn( const s : string; n : cardinal ) : string;
  var r : string = '';
  procedure nth_word( num, pos, len : cardinal; var stop : boolean );
  begin
    if num = n then begin
      r := strutils.midstr( s, pos, len );
      stop := true;
    end
  end;
begin
  foreach_wordloc( s, 1, @nth_word );
  result := r;
end;

function nwords( const s : string ) : cardinal;
  procedure count_word_handler( num, pos, len : cardinal; var stop : boolean );
  begin result := num;
  end;
begin
  foreach_wordloc( s, 1, @count_word_handler );
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
