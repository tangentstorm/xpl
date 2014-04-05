{

  Simple stack objects.
  author  : michal j wallace
  license : MIT / ngaro

}
{$mode delphi}
{$i xpc.inc}
unit stacks;
interface uses xpc, sysutils;

  type GStack<A> = class
    _count   : cardinal;  // stack pointer
    cells : array of A;
    overflow, underflow : thunk;
    show : function( x : A ) : string;
    constructor Create( len:word );
    procedure push( t : A );
    function pop: A;
    procedure pop1( var t : A );
    procedure push2( n, t : A );
    procedure pop2( var t, n : A );
    procedure push3( x, n, t : A );
    procedure pop3( var t, n, x : A );
    function pick( const i : integer ) : A;
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
    property peek : A read tos;
    property count : cardinal read _count;
    property items[ i : integer ] : A read pick; default;
  end;

implementation

  constructor GStack<a>.Create( len: word );
  begin
    _count := 0;
    setlength( cells, len );
    overflow := default_overflow;
    underflow := default_underflow;
  end;

procedure GStack<a>.push( t : A );
  begin
    inc( _count );
    if _count >= length( cells ) then overflow
    else cells[ _count ] := t;
  end; { GStack<a>.push }

function GStack<a>.pop : A;
  begin
    result := tos;
    drop;
  end; { GStack<a>.pop }

procedure GStack<a>.pop1( var t : A );
  begin
    t := pop
  end; { GStack<a>.pop1 }

procedure GStack<a>.push2( n, t :  A );
  begin
    self.push( n );
    self.push( t );
  end; { GStack<a>.push2 }

procedure GStack<a>.pop2( var t, n :  A );
  begin
    t := self.pop;
    n := self.pop;
  end; { GStack<a>.pop2 }

procedure GStack<a>.push3( x, n, t :  A );
  begin
    self.push( x );
    self.push( n );
    self.push( t );
  end; { GStack<a>.push3 }

procedure GStack<a>.pop3( var t, n, x :  A );
  begin
    t := self.pop;
    n := self.pop;
    x := self.pop
  end; { GStack<a>.pop3 }

function GStack<a>.tos : A;
  begin
    result := cells[ _count ];
  end; { GStack<a>.tos }

function GStack<a>.nos : A;
  begin
    result := cells[ _count - 1 ];
  end; { GStack<a>.nos }

procedure GStack<a>.dup;
  begin
    push( tos );
  end; { GStack<a>.dup }

procedure GStack<a>.swap;
    var t : A;
  begin
    if _count >= 2 then
      begin
        t := tos;
        cells[ _count ] := nos;
        cells[ _count - 1 ] := t;
      end
    else underflow;
  end; { GStack<a>.swap }

procedure GStack<a>.drop;
  begin
    if _count = 0 then underflow
    else dec( _count );
  end; { GStack<a>.drop }

function GStack<A>.pick( const i : integer ) : A;
  var j : integer;
  begin
    if i >= 0 then j := count - i
    else j := -i;
    if (j > 0) and (j <= count) then result := cells[j]
    else raise Exception.Create('Invalid Index: ' + IntToStr(i));
  end;


  procedure GStack<a>.default_overflow;
  begin
    writeln( 'error: GStack<a> overflow' );
    halt
  end;

  procedure GStack<a>.default_underflow;
  begin
    writeln( 'error: GStack<a> underflow' );
    halt
  end;

function GStack<a>.dumps : string;
  var i : word;
  begin
    result := '';
    if assigned( self.show ) then
      if _count > 0 then begin
	for i := 1 to _count - 1 do result += self.show(cells[ i ]) + ' ';
	result += self.show( cells[ _count ]);
      end else result := '<stack.show not defined>';
  end; { GStack<a>.dumps }

procedure GStack<a>.dump;
  begin
    writeln( dumps );
  end; { GStack<a>.dump }

function GStack<a>.limit : cardinal;
  begin
    result := length( cells );
  end;

end.
