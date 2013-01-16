{$i xpc.inc}
unit xpc; { cross-platform compilation help }
interface uses sysutils;

  const { Boolean synonyms }
    Yes	 = true;
    No	 = false;
    On	 = true;
    Off	 = false;

  procedure pass;

  { some handy debug routines }
  procedure die( msg :  string );
  procedure pause( msg : string );
  procedure hexdump( data : string );

  type set32 = set of 0 .. 31;
  type int32 = longint;
  function toint( s : set32 ) : int32;
  function hex( x :  int32 ) : string;
  function min( a, b : int32 ): int32;
  function max( a, b : int32 ): int32;
  function paramline : string;

  type thunk = procedure of object;
  type logger = object
    procedure debug( arg : string );
    procedure debug( args : array of const );
  end;
  var log : logger;

implementation

  procedure pass; inline;
  begin
  end; { pass }

  procedure die( msg :  string );
  begin
    writeln;
    write( msg );
    writeln;
    halt;
  end;

  procedure pause( msg : string );
  begin
    writeln;
    write( '---| ', msg, ' |---' );
    writeln;
    readln;
  end; { pause }


  procedure hexdump( data :  string );
    var ch : char; hexstr, ascstr : string; i : integer;
  begin
    i := 0;
    hexstr := ''; ascstr := '';
    for ch in data do begin
      hexstr += hex( ord( ch ));
      if ord( ch ) in [ 0 .. 32, 128 .. 255] then ascstr += '.' else ascstr += ch;
      if i mod 4 = 0 then hexstr += ' ';
    end;
    writeln( '-- hexdump --' );
    writeln( '[', hexstr, ' ', ascstr, ']' );
  end;

  function toint( s : set32 ) : int32;
    var i, p : byte;
   begin
    result := 0;
    p := 1;
    for i := 0 to 31 do begin
      if i in s then result := result + p;
      p := p * 2;
    end;
  end; { toint }


  procedure logger.debug( args :  array of const );
    var i : integer;
  begin
    write( '(DEBUG: ' );
    for i := 0 to length( args ) - 1 do
    begin
      case args[ i ].vtype of
	vtinteger : write( args[ i ].vinteger );
	vtstring  : write( args[ i ].vstring^ );
	vtansistring  : write( ansistring( args[ i ].vansistring ));
	else
	  write( '??' );
      end; { case }
    end;
    writeln( ')' );
  end;

  procedure logger.debug( arg : string );
  begin
    debug([arg]);
  end;

  function hex( x : int32 ) : string;
    const digits = '0123456789ABCDEF';
      len	=  length( digits );
    var i, d : int32; begun :  boolean;
  begin
    result := '';
    begun := false;
    for i := 7 downto 0 do begin
      d := (( x shr ( i * 4 ))  mod 16 );
      if begun or ( d > 0 ) then begin
	result += digits[ d + 1 ];
	begun := true;
      end;
    end;
  end;

  function min( a, b :  int32 ) : int32;
  begin
    if a < b then result := a else result := b;
  end;

  function max( a, b :  int32 ) : int32;
  begin
    if a > b then result := a else result := b;
  end;


  function paramline : string;
    var
      i	: byte;
      s	: string;
  begin
    s := '';
    for i := 1 to paramcount do
      s := s + paramstr( i )+ ' ';
    result := s;
  end;


end.