{
| a tiny lisp interpreter
}
{$i xpc.inc}
unit li;
interface uses classes, xpc, ascii, ll, num;

  type
    kinds = ( kINT, kSYM, kSTR, kLIS, kEND, kNUL, kOBJ );
    {TODO: come back to this once I have syntax
       for algebraic data types }
    node = class kind : kinds end;
    nodelist = specialize ll.list< node >;
    LisNode = class( node )
      lis : nodelist;
      constructor create( _lis : nodelist );
    end;
    IntNode = class( node )
      int : integer;
      constructor create( _int : integer );
    end;
    SymNode = class( node )
      sym : String;
      constructor create( _sym : string );
    end;
    StrNode = class( node )
      str : String;
      constructor create( _str : string  );
    end;
    ObjNode = class( node )
      obj : TObject;
      constructor create( _obj : TObject );
    end;
  type chargen = procedure( var ch : char ) is nested;
  var
    null : node;
    endl : node; // end of list marker. never actually assigned

  function read_value( const  next : chargen ) : node;
  procedure print( value : node );
  procedure repl;



implementation

  const whitespace = [ #0 .. #32 ];

  var done       : boolean = false;
  var sym_minus	 : string = '-';
  const
    prompt0 = 'li> ';
    prompt1 = '..> ';

  {$IFDEF DEBUG}
  const debug_mode = true;
  {$ELSE}
  const debug_mode = false;
  {$ENDIF}
  procedure debug( msg : string ); inline;
  begin
    {$IFDEF DEBUG}
    if debug_mode then writeln( msg )
    {$ENDIF}
  end;


  constructor intnode.create( _int: integer );
  begin
    self.kind	       := kint;
    self.int	       := _int;
  end;

  constructor symnode.create( _sym: string );
  begin
    self.kind	       := ksym;
    self.sym	       := _sym;
  end;

  constructor strnode.create( _str: string  );
  begin
    self.kind	       := kstr;
    self.str	       := _str;
  end;

  constructor lisnode.create( _lis: nodelist );
  begin
    self.kind	       := klis;
    self.lis	       := _lis;
  end;

  constructor objnode.create( _obj: TObject );
  begin
    self.kind	       := kobj;
    self.obj	       := _obj;
  end;

  var
    lx      : integer = 0;  // line number
    ly      : integer = 0;  // colunn number
    depth   : integer = 0;  // to decide which prompt to show
    line    : string;       // the last line read from input

  procedure error( const err: string );
  begin
    write( 'error at line ', ly, ', column ', lx, ': ' );
    writeln( err );
    halt;
  end; { error }




  procedure from_prompt( var ch : char );

    { basically, we use this prompt to do our own buffering because
    the input from the shell is line-oriented. :/ I tried just using
    read, but couldn't get more than two of [ eof, eoln, read ]
    working at any given time. :/ So... if i just go with readln,
    it handles eoln, and I can just test for eof. }
    procedure prompt;
    begin
      { write the prompt first, because eof() blocks. }
      if depth > 0 then write( prompt1 ) else write( prompt0 );
      if eof then begin
        ch := ascii.EOT;
        line := ch;
        done := true;
        if depth > 0 then error( 'unexpected end of file' );
        writeln;
        halt; { todo : remove this once depth-checking works correctly }
      end else begin
        readln( line );
        line := line + ascii.LF; { so we can do proper lookahead. }
        inc( ly );
        lx := 0;
      end
    end;

  begin
    while lx + 1 > length( line ) do prompt;
    inc( lx );
    ch := line[ lx ];
    debug( '[ line ' + n2s( ly ) + ', col ' + n2s( lx ) + ' : ' +  ch + ']' );
  end; { next( ch ) }

{-- read_value ( recursive descent parser )  -- }

  function read_value( const next : chargen ) : node;
    var
      i	  : integer = 0;
      buf : string;
      esc : boolean = false;
      ch  : char = #0;

    procedure bufch;
    begin
      if not esc then
      begin
	inc( i );
	setlength( buf, i );
	buf[ i ] := ch;
      end;
    end; { bufch }

    function unbuf( kind : kinds ): node;
    begin
      case kind of
        kStr : result := StrNode.create( buf );
        kSym : result := SymNode.create( buf );
      else
        begin
          writeln('don''t know how to unbuf kind:', kind);
          halt;
        end
      end;
      i := 0;
      setlength( buf, 0 );
    end; { unbuf }

{-- read_value >> read_string --}

    function read_string : node;
      var
      esc : boolean = false;
      eos : boolean = false;
    begin
      inc( depth );
      repeat
	next( ch );
	if esc then begin
	  bufch;
	  esc := false;
	end else case ch of
	  '\' : esc := true;
	  '"' : eos := true;
	  else bufch;
	end;
      until eos;
      next( ch );
      dec( depth );
      result := unbuf( kSTR );
    end; { read_string }

{-- read_value >> read_integer --}

    function read_integer : integer;
      var
      x      : integer = 0;
      base   : byte = 10;
      digits : set of char = [ '0' .. '9' ];
    begin
      if ch = '0' then
        begin
          next( ch ); { consuming the 0 }
          case ch of
            'x'	: begin
                    base := 16;
		    digits := digits + [ 'A'..'F' ] + [ 'a'..'f' ];
                  end;
            'b'	: begin base := 2; digits := [ '0', '1' ] end;
            'o'	: begin base := 8; digits := [ '0'..'8' ] end;
	    else if not (ch in whitespace) then
	      error( 'invalid digit after 0: "' + ch + '"' );
	  end { case }
	end;
      while ( ch in digits ) do
      begin
	x := x * base;
	case ch of
	  '0' : x := x + $0;  '8'      : x := x + $8;
	  '1' : x := x + $1;  '9'      : x := x + $9;
	  '2' : x := x + $2;  'A', 'a' : x := x + $A;
	  '3' : x := x + $3;  'B', 'b' : x := x + $B;
	  '4' : x := x + $4;  'C', 'c' : x := x + $C;
	  '5' : x := x + $5;  'D', 'd' : x := x + $D;
	  '6' : x := x + $6;  'E', 'e' : x := x + $E;
	  '7' : x := x + $7;  'F', 'f' : x := x + $F;
	  else error( 'unexpected character in number: ' + ch )
	end; { case }
	next( ch )
      end;
      result := x
    end; { read_integer }

{-- read_value >> read_list --}

    function read_list : node;
      var this : node; res : nodelist;
    begin
      inc( depth );
      debug('---read_list---');
      this := read_value( next );
      if this = endl then begin
	result := null;
	debug('-- result was null --');
      end
      else begin
	res := nodelist.create;
	repeat
	  res.append( this );
	  this := read_value( next )
	until this = endl;
	result := lisnode.create( res );
	debug('-- result was list of ' + n2s( res.length ) + ' items --')
      end;
      dec( depth );
    end; { read_list }

{-- read_value >> read_symbol and main routine --}

    function read_symbol : node;
    begin
      while not ( ch in whitespace ) do
      begin
	bufch;
	next( ch );
      end;
      result := unbuf( kSYM )
    end; { read_symbol }

  begin { read_value }
    while ch in whitespace do next( ch ); { skip whitespace }
    case ch of
      ';'      : begin
		   repeat next( ch ) until ch = ascii.lf;
                   result := read_value( next ); // recurse
                 end;
      '"'      : result := read_string;
      '0'..'9' : result := IntNode.create( read_integer );
      '-'      : begin
                   next( ch );
                   if ch in whitespace then result := SymNode.create( sym_minus )
		   else result := IntNode.create( read_integer * -1 )
                 end;
      '('      : begin next( ch ); result := read_list() end;
      ')'      : begin next( ch ); result := endl end;
      ascii.EOT: begin result := null; done := true; end;
      else result := read_symbol
    end; { case }
    if debug_mode then writeln( 'read_value -> ', result.kind );
  end; { read_value }


{-- expression evaluator --}

  //  TODO : evaluate
  function evaluate( value : node ) : node;
  begin
    result := value;
  end; { evaluate }


{-- printer --}

  procedure print( value : node );

    procedure print_list( ln : lisnode );
      var each : node; first : boolean = true;
    begin
      write( '(' );
      for each in ln.lis do begin
	if first then first := false
	else write( ' ' );
	print( each )
      end;
      write( ')' );
    end; { print_list }

  begin { print }
    assert( assigned( value ));
    case value.kind of
      kINT : write(( value as intnode ).int );
      kSYM : write(( value as symnode ).sym );
      kSTR : write( '"', ( value as strnode ).str, '"' );
      kNUL : write( 'null' );
      kLIS : print_list(( value as lisnode ));
      else
	writeln( '{ unknown kind : ', integer(value.kind), ' }' );
    end;
  end; { print }

{-- main code ( repl and initialization block ) --}

  procedure repl;
    var val : node;
  begin
    repeat
      { we can't inline the temp value ( val ) because read_value
	is also responsible for showing the prompt, and we need to
        keep the prompt and reply outputs separate. }
      val := read_value( @from_prompt );
      print( evaluate( val ));
      writeln;
    until done;
  end; { repl }

begin
  null := node.create;
  null.kind := kNUL;
  endl := node.create;
  null.kind := kEND;
end.
