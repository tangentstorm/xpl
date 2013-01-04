{

  Simple stack objects.
  author  : michal j wallace
  license : MIT / ngaro

}
{$i xpc.inc}
unit stacks;
interface uses xpc;

  {!! for now, this is an object rather than a
        class. usually a stack is a global resource,
        so it makes sense for it to be static, like
        an array. therefore: use init, not create. }

  type generic stack< A > = object
    sp   : integer;  // stack pointer
    cells : array of A;
    overflow, underflow : thunk;
    show : function( x : A ) : string;
    constructor init( len:word );
    procedure push( t : A );
    function pop: A;
    procedure pop1( var t : A );
    procedure push2( n, t : A );
    procedure pop2( var t, n : A );
    procedure push3( x, n, t : A );
    procedure pop3( var t, n, x : A );
    function tos: A;
    function nos: A;
    procedure dup;
    procedure swap;
    procedure drop;
    procedure default_overflow;
    procedure default_underflow;
    function dumps:string;
    procedure dump;
    function limit : cardinal;
  end;

implementation

  constructor stack.init( len: word );
  begin
    sp := 0;
    setlength( cells, len );
    overflow := @default_overflow;
    underflow := @default_underflow;
  end; { stack.init }

  procedure stack.push( t : A );
  begin
    inc( sp );
    if sp >= length( cells ) then overflow
    else cells[ sp ] := t;
  end; { stack.push }

  function stack.pop : A;
  begin
    result := tos;
    drop;
  end; { stack.pop }

  procedure stack.pop1( var t : A );
  begin
    t := pop
  end; { stack.pop1 }

  procedure stack.push2( n, t :  A );
  begin
    self.push( n );
    self.push( t );
  end; { stack.push2 }

  procedure stack.pop2( var t, n :  A );
  begin
    t := self.pop;
    n := self.pop;
  end; { stack.pop2 }

  procedure stack.push3( x, n, t :  A );
  begin
    self.push( x );
    self.push( n );
    self.push( t );
  end; { stack.push3 }

  procedure stack.pop3( var t, n, x :  A );
  begin
    t := self.pop;
    n := self.pop;
    x := self.pop
  end; { stack.pop3 }

  function stack.tos : A;
  begin
    result := cells[ sp ];
  end; { stack.tos }

  function stack.nos : A;
  begin
    result := cells[ sp - 1 ];
  end; { stack.nos }

  procedure stack.dup;
  begin
    push( tos );
  end; { stack.dup }

  procedure stack.swap;
    var t : A;
  begin
    if sp >= 2 then
      begin
        t := tos;
        cells[ sp ] := nos;
        cells[ sp - 1 ] := t;
      end
    else underflow;
  end; { stack.swap }

  procedure stack.drop;
  begin
    dec( sp );
    if sp < 0 then underflow;
  end; { stack.drop }

  procedure stack.default_overflow;
  begin
    writeln( 'error: stack overflow' );
    halt
  end;

  procedure stack.default_underflow;
  begin
    writeln( 'error: stack underflow' );
    halt
  end;

  function stack.dumps : string;
    var i : word;
  begin
    result := '';
    if assigned( self.show ) then
      if sp > 0 then begin
	for i := 1 to sp - 1 do result += self.show( cells[ i ]) + ' ';
	result += self.show( cells[ sp ]);
      end
      else result := '<stack.show not defined>';
  end; { stack.dumps }

  procedure stack.dump;
  begin
    writeln( dumps );
  end; { stack.dump }

  function stack.limit : cardinal;
  begin
    result := length( cells );
  end;

end.
