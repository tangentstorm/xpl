{

  Simple stack objects.
  author  : michal j wallace
  license : MIT / ngaro

}
{$mode delphiunicode}
{$i xpc.inc}
unit stacks;
interface uses xpc, sysutils;

  type
    EStackError = class (Exception) end;
    EStackOverflow = class (EStackError) end;
    EStackUnderflow = class (EStackError) end;
    EStackIndexError = class (EStackError) end;

  type GStack<A> = class
    _count   : cardinal;  // stack pointer
    cells : array of A;
    overflow, underflow : thunk;
    show : function( x : A ) : TStr;
    constructor Create( len:word );
    function push( t : A ) : A;
    function pop: A;
    function popGet( default : A ) : A;
    function shift: A;
    procedure pop1( var t : A );
    procedure push2( n, t : A );
    procedure pop2( var n, t : A );
    procedure push3( x, n, t : A );
    procedure pop3( var x, n, t : A );
    function pick( const i : integer ) : A;
    function GetItem(const i : integer; const default : A) : A;
    function tos: A;
    function nos: A;
    procedure dup;
    procedure swap;
    procedure drop;
    procedure default_overflow;
    procedure default_underflow;
    function dumps:TStr;
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

function GStack<a>.push( t : A ) : A;
  begin
    inc( _count );
    if _count >= length( cells ) then overflow
    else cells[ _count ] := t;
    result := t;
  end; { GStack<a>.push }

function GStack<a>.pop : A;
  begin
    result := tos;
    drop;
  end; { GStack<a>.pop }

function GStack<a>.popGet( default : A ): A;
  begin
    if count = 0 then result := default
    else begin result := tos; drop; end;
  end; { GStack<a>.popGet }

function GStack<a>.shift : A;
  var i : integer;
  begin
    result := cells[ 1 ];
    for i := 1 to count-1 do cells[i] := cells[i+1];
    _count -= 1;
  end; { GStack<a>.popGet }

procedure GStack<a>.pop1( var t : A );
  begin
    t := pop
  end; { GStack<a>.pop1 }

procedure GStack<a>.push2( n, t :  A );
  begin
    self.push( n );
    self.push( t );
  end; { GStack<a>.push2 }

procedure GStack<a>.pop2( var n, t :  A );
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

procedure GStack<a>.pop3( var x, n, t :  A );
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
    else raise EStackIndexError.Create(
      Format('Invalid Index: %d', [ i ]));
  end;

function GStack<A>.GetItem(const i : integer; const default : A) : A;
  begin
    try result := pick(i)
    except on EStackIndexError do result := default end;
  end;


  procedure GStack<a>.default_overflow;
  begin
    raise EStackOverflow.Create('error: GStack<a> overflow' );
  end;

  procedure GStack<a>.default_underflow;
  begin
    raise EStackUnderflow.Create('error: GStack<a> underflow' );
  end;

function GStack<a>.dumps : TStr;
  var i : word;
  begin
    result := '';
    if assigned( self.show ) then
      if _count > 0 then begin
        for i := 1 to _count - 1 do result += self.show(cells[i]) + ' ';
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
