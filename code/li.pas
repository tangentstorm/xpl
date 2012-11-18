{
| a tiny lisp interpreter
}
{$i xpc.inc }
unit li;
interface uses oo, xpc, ascii;

  const
    kStrLen =  128;

  type
    kinds = ( kINT, kSYM, kSTR, kREF, kNUL, kOBJ );
    pNull = pointer;
    pSym  = ^tSym;
    pNode = ^tNode;
    pCell = ^tCell;

    tSym  = string [ kStrLen ];
    tNode = record case kind : kinds of
	      kINT : ( int : integer );
	      kSYM : ( sym : pSym );
	      kSTR : ( str : pSym );
	      kREF : ( ref : pCell );
	      kNUL : ( ptr : pNull );
	      kOBJ : ( obj : oo.pObj );
	    end;
    tCell = record
	      car, cdr : pNode; { lisp tradition }
	    end;
  var
    null : pNode;

  function cons( car, cdr : pNode ) : pNode;
  procedure print( value : pNode );
  procedure repl;

implementation

  const NL = ascii.LF;
  const whitespace = [ #0 .. #32 ];

  var done : boolean = false;
  var sym_minus : tSym = '-';
  const
    prompt0 = 'li> ';
    prompt1 = '..> ';

  function cons( car, cdr : pNode ) : pNode;
  begin
    new( result );
    result^.kind := kREF;
    new( result^.ref );
    result^.ref^.car := car;
    result^.ref^.cdr := cdr;
  end; { cons }


  var
    ch	  : char = #0;
    lx	  : integer = 1;
    ly	  : integer = 1;
    depth : integer = 0;

  procedure error( const err : string );
  begin
    write( 'error at line ', ly, ', column ', lx, ' : ' );
    writeln( err );
    halt;
  end; { error }


  var line : string[ 255 ] = '';

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

  procedure read_ch;
  begin
    while lx > length( line ) do prompt;
    inc( lx );
    ch := line[ lx ];
  end; { read_ch }

  function read_value : pNode;
    var
      i	  : integer = 0;
      buf : string[ kStrLen ];
      esc : boolean = false;

    procedure bufch;
    begin
      if ( i < kStrLen ) and ( not esc ) then
      begin
	inc( i );
	setlength( buf, i );
	buf[ i ] := ch;
      end;
    end; { bufch }

    function unbuf( kind : kinds ): pNode;
    begin
      new( result );
      result^.kind := kind;
      new( result^.sym );
      result^.sym^  := buf;
      i := 0;
      setlength( buf, 0 );
    end; { unbuf }

    function read_string : pNode;
      var
	esc : boolean = false;
	eos : boolean = false;
    begin
      inc( depth );
      repeat
	read_ch;
	if esc then begin
	  bufch;
	  esc := false;
	end else case ch of
	  '\' : esc := true;
	  '"' : eos := true;
	  else bufch;
	end;
      until eos;
      dec( depth );
      result := unbuf( kSTR );
    end; { read_string }

    function read_integer : pNode;
    var
      x      : integer = 0;
      base   : byte = 10;
      digits : set of char = [ '0' .. '9' ];
    begin
      if ch = '0' then
        begin
          read_ch; { consuming the 0 }
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
	read_ch
      end;
      new( result );
      result^.kind := kINT;
      result^.int  := x;
    end; { read_integer }

    function read_list : pNode;
      const kSize = 64;
    begin
      { TODO : support reading dotted pairs }
      new( result );
      result := read_value;
      if result <> null then
	result := cons( result, read_list );
    end; { read_list }

    function read_symbol : pNode;
    begin
      while not ( ch in whitespace ) do
      begin
	bufch;
	read_ch;
      end;
      result := unbuf( kSYM )
    end; { read_symbol }

  begin { read_value }
    read_ch;
    while ch in whitespace do read_ch; { skip whitespace }
    case ch of
      ';'      : begin
                   repeat read_ch until ch = NL;
                   result := read_value;
                 end;
      '"'      : begin inc(depth); result := read_string; dec(depth) end;
      '0'..'9' : result := read_integer;
      '-'      : begin
                   read_ch;
                   if ch in whitespace then
		   begin
		     new( result );
		     result^.kind := kSYM;
		     result^.sym  := @sym_minus;
		   end else begin
		     result := read_integer;
		     result^.int := -result^.int;
		   end
                 end;
      '('      : begin inc(depth); read_ch; result := read_list end;
      ')'      : begin dec(depth); read_ch; result := null end;
      EOT      : begin result := null; done := true; end;
      else result := read_symbol
    end; { case }
  end; { read_value }


  //  need to add if, lambda, etc
  function evaluate( value : pNode ) : pNode;
  begin
    result := value;
  end; { evaluate }


  procedure print( value : pNode );

    procedure write_list( start_char : char; head : pCell );
      var cdr : pNode;
    begin
      write( start_char );
      print( head^.car );
      cdr := head^.cdr;
      case cdr^.kind of
	kNUL : write( ')' );
	kREF : write_list( ' ', cdr^.ref );
	else begin
	  write(' . ');
	  print( cdr );
	end;
      end; { case }
    end; { print_cell }

  begin { print }
    case value^.kind of
      kINT : write( value^.int );
      kSYM : write( value^.sym^ );
      kSTR : write( '"', value^.sym^, '"' );
      kNUL : write( 'null' );
      kREF : write_list( '(', value^.ref );
      else
	writeln( '{ unknown value : ', ord( value^.kind ), ' }' );
    end;
  end; { print }

  procedure repl;
    var val : pNode;
  begin
    repeat
      { we can't inline the temp value because read_value
	is also responsible for showing the prompt, and we
	need to keep the prompt and reply outputs separate. }
      val := read_value;
      print( evaluate( val ));
      writeln;
    until done;
  end; { repl }

begin
  new( null ); null^.kind := kNUL; null^.ptr := nil;
end.
