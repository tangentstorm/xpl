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
  function hex( x : int32; pad : byte = 0 ) : string;
  function min( a, b : int32 ): int32;
  function max( a, b : int32 ): int32;

  function paramline : string;
  function fileparam : boolean;

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

  function toint( s : set32 ) : Int32;
    var i : byte;
  begin
    result := 0;
    for i := low(set32) to high(set32) do begin
      if i in s then inc( result );
      {$rangechecks off}
      result := cardinal( result shl 1 );
      {$rangechecks on}
    end
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

  function hex( x : int32; pad : byte = 0 ) : string;
    const digits = '0123456789ABCDEF';
      len	=  length( digits );
    var i, d : int32; count : byte;
  begin
    result := '';
    count := 0;
    for i := 7 downto 0 do begin
      d := (( x shr ( i * 4 ))  mod 16 );
      if (count > 0) or ( d > 0 ) then begin
	result += digits[ d + 1 ];
	inc(count)
      end;
    end;
    while count < pad do begin
      insert( '_', result, 1 );
      inc( count );
    end
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
  end; { paramline }

  function fileparam : boolean;
  begin
    result := false;
    if (paramcount > 0) and fileexists( paramstr( 1 )) then begin
      assign( input, paramstr( 1 ));
      reset( input );
      result := true;
    end
  end;


end.