{ all of these are by michal j. wallace, circa 1992.
  extracted from crtstuff.pas and updated 2012 }
{$mode objfpc}{$i xpc.inc}
unit ustr; { string interface }
interface uses xpc, sysutils, strutils;

  function pad( s : TStr; len : cardinal; ch : TChr ) : TStr;
    deprecated 'use rpad';
  function lpad( s : TStr; len : cardinal; ch : TChr=' ') : TStr;
  function rpad( s : TStr; len : cardinal; ch : TChr=' ') : TStr;
  function lfit( s : TStr; len : cardinal; ch : TChr=' ') : TStr;
  function rfit( s : TStr; len : cardinal; ch : TChr=' ') : TStr;
  function unpad( s : TStr; ch : TChr ) : TStr;
  function chntimes( c : TChr; n : cardinal ) : TStr;
  function ntimes( const s : TStr; n : cardinal ) : TStr;
  function flushrt( s : TStr; n : cardinal; ch : TChr ) : TStr;
  function trunc( s : TStr; len : cardinal ) : TStr;
  function UpStr( const s : TStr ) : TStr;
  function DnCase( ch : TChr ) : TChr;
  function DnStr( const s : TStr ) : TStr;
  function wordn( const s : TStr; n : cardinal ) : TStr;
  function nwords( const s : TStr ) : cardinal;
  function startswith(const haystack, needle : TStr) : boolean;
  function boolstr(const b : boolean; const trueStr, falseStr : TStr ) : TStr;

implementation


function chntimes( c : TChr; n : cardinal ) : TStr; inline;
  var i : cardinal; s : TStr = '';
begin
  for i := 1 to n do s := s + c;
  result := s;
end;

function ntimes( const s : TStr; n : cardinal ) : TStr; inline;
  var i : cardinal;
begin
  result := s;
  for i := 1 to n do result := result + s;
end;

{ todo : profile this. }
function flushrt( s : TStr; n : cardinal; ch : TChr ) : TStr;
begin
  if length( s ) < n then insert( chntimes( ch, n-length( s )), s, 1 );
  result := s;
end;

function rpad( s : TStr; len : cardinal; ch : TChr=' ' ) : TStr;
  begin
    if length( s ) > len then s := trunc( s, len );
    while length( s ) < len do s := s + ch;
    result := s;
  end;
  
function lpad( s : TStr; len : cardinal; ch : TChr=' ') : TStr;
  begin
    if length( s ) > len then s := trunc( s, len );
    while length( s ) < len do s := ch + s;
    result := s;
  end;

function pad( s : TStr; len : cardinal; ch : TChr) : TStr; inline;
  begin
    result := rpad( s, len, ch)
  end;

function unpad( s : TStr; ch : TChr ) : TStr;
  var i : cardinal;
begin
  i := length( s );
  while ( i > 0 ) and ( s[ i ] = ch ) do dec( i );
  setlength( s, i );
  result := s;
end;

function trunc( s : TStr; len : cardinal ) : TStr;
begin
  if length( s ) > len then setlength( s, len );
  result := s;
end;

function lfit( s : TStr; len : cardinal; ch : TChr = ' ' ) : TStr;
begin
  if length( s ) > len then setlength( s, len )
  else s := lpad(s, len, ch);
  result := s;
end;

function rfit( s : TStr; len : cardinal; ch : TChr = ' ' ) : TStr;
begin
  if length( s ) > len then setlength( s, len )
  else s := rpad(s, len, ch);
  result := s;
end;

function upstr( const s : TStr ) : TStr;
  var count : cardinal;
begin
  setlength( result, length( s ));
  for count := 1 to length( s ) do
    result[ count ] := upcase( s[ count ]);
end;

function dncase( ch: TChr ) : TChr;
begin
  if ch in [ 'A' .. 'Z' ] then result := chr( ord( ch ) + 32 )
  else result := ch;
end;

function dnstr( const s : TStr ) : TStr;
  var count : cardinal;
begin
  setlength( result, length( s ));
  for count := 1 to length( s ) do
    result[ count ] := dncase( s[ count ] )
end; { dnstr }



type
  tokenhandler = procedure( num, pos, len : cardinal; var stop : boolean ) is nested;

procedure foreach_wordloc( s : TStr; start : cardinal; callback : tokenhandler );
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

function wordn( const s : TStr; n : cardinal ) : TStr;
  var r : TStr = '';
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

function nwords( const s : TStr ) : cardinal;
  procedure count_word_handler( num, pos, len : cardinal; var stop : boolean );
    begin result := num;
    end;
  begin
    foreach_wordloc( s, 1, @count_word_handler );
  end;

function startswith(const haystack, needle : TStr) : boolean;
  var i : cardinal = 1;
  begin
    result := length( needle ) <= length( haystack );
    while result and ( i < length( needle )) do
      begin
	result := haystack[ i ] = needle[ i ];
	inc( i )
      end
  end;

function boolstr(const b : boolean; const trueStr, falseStr : TStr ) : TStr; inline;
  begin
    if b then result := trueStr else result := falseStr
  end;

end.
