// Mockup of UTF-8 encoding/decoding system.
// My main interest is exploring the UTF-8 encoding system
// as compression for instructions in retropascal.
{$mode objfpc}{$i xpc.inc}
unit utf8;
interface uses xpc;

  type uchar = string[4];
  function encode( u : int32 ) : uchar;
  function decode( u : uchar ) : word;

implementation

  function encode( u : int32 ) : uchar;
  begin
    // http://www.herongyang.com/Unicode/UTF-8-UTF-8-Encoding-Algorithm.html
    case u of
           0 ..   $7f : result := '' + chr( u );
         $80 ..  $7ff : result := '' + chr( u shr  6 and $1F or $c0 )
	  			     + chr( u        and $3F or $80 );
        $800 .. $ffff : result := '' + chr( u shr 12 and $1F or $e0 )
                                     + chr( u shr  6 and $3F or $80 )
                                     + chr( u        and $3F or $80 );
      $10000 .. $ffffff : result := '' + chr( u shr 18 and $1F or $F0 )
                                     + chr( u shr 12 and $3F or $80 )
                                     + chr( u shr  6 and $3F or $80 )
				     + chr( u        and $3F or $80 );
      else die('outside cp437 range!');
    end
  end;

  //  implement utf8.decode, with error checks
  // http://en.wikipedia.org/wiki/UTF-8#Description
  function decode( u : uchar ) : word;
    var i, b, prev : byte;
  begin
    result := 0;
    for i := 1 to length( u ) do begin
      b := ord(u[i]);
      case b of
	$00 .. $7F : result := b;
	$80 .. $8F : result := b - $80;
	$C0 .. $C1 : die( 'invalid utf-8 sequence ');
	$C2 .. $DF : ; //  2 byte
	$E0 .. $EF : ; //  3 byte
	$F0 .. $F4 : ; //  4 byte
	else die( 'invalid utf-8 sequence ');
      end
    end
  end;


end.
