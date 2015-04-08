{$i xpc.inc}{$mode delphi}
unit xpc; { cross-platform compilation help }
interface uses sysutils, classes, variants;

const { Boolean synonyms }
  Yes    = true;
  No     = false;
  On     = true;
  Off    = false;
type
  TStr = UnicodeString;
  TChr = WideChar;
  set32 = set of 0 .. 31;
  int32 = longint;
  tbytes = array of byte;
type
  TStrEvent = procedure (s : TStr) of object;
  thunk = procedure of object;
  ENotImplementedError = class(Exception);

  var XPCOUT : text;

function u2a(const u : TStr) : ansistring;
function a2u(const a : ansistring) : TStr;


  procedure indent;
  procedure dedent;
  procedure trace( s : variant ); overload;
  procedure trace( ss : array of variant; ln : boolean = true ); overload;


procedure ok;

{ some handy debug routines }
procedure die( msg :  TStr );
procedure pause( msg : TStr );
procedure hexdump( data : TStr );
function StackTrace(E :  Exception):TStr;

function toint( s : set32 ) : int32;
function hex( x : int32; pad : byte = 0 ) : TStr;
function min( a, b : int32 ): int32;
function max( a, b : int32 ): int32;

function paramline : TStr;
function fileparam : boolean;

type logger = object
  procedure debug( arg : TStr );
  procedure debug( args : array of const );
end;
var log : logger;

type
  TCmp = (cmpLT, cmpEQ, cmpGT);
  TCmpFn<T> = function(a,b : T):TCmp;
  TPred2<TX,TY> = function(x: TX; y:TY) : boolean;
  G<T> = class { generic helper }
   public
      type ArrayOfT = array of T;
      class function FromOpenArray( a : array of T ) : ArrayOfT;
      class procedure Sort( a:ArrayOfT; cmp:TCmpFn<T> );
      class procedure Sort( a:ArrayOfT; cmp:TCmpFn<T>; lo,hi: cardinal );
    end;

function bytes(data : array of byte):tbytes;
function vinc(var i:integer):integer;
function incv(var i:integer):integer;
function vdec(var i:integer):integer;
function decv(var i:integer):integer;

type
  Weak<T:IUnknown> = class
    class function Ref(obj : T) : T;
  end;


implementation

procedure ok; inline;
  begin
  end; { ok }

procedure die( msg :  TStr );
  begin
    writeln;
    write( msg );
    writeln;
    halt;
  end;

procedure pause( msg : TStr );
  begin
    writeln;
    write( '---| ', msg, ' |---' );
    writeln;
    readln;
  end; { pause }



procedure hexdump( data : TStr );
  var ch : TChr; hexstr, ascstr : TStr; i : integer;
  begin
    i := 0;
    hexstr := ''; ascstr := '';
    for ch in data do begin
      hexstr += hex( ord( ch ));
      if ord( ch ) in [ 0 .. 32, 128 .. 255] then ascstr += '.'
      else ascstr += ch;
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


function u2a(const u : TStr) : ansistring; inline;
  begin
    result := utf8encode(u);
  end;

function a2u(const a : ansistring) : TStr; inline;
  begin
    result := utf8decode(a);
  end;


procedure logger.debug( args :  array of const );
  var i : integer;
  begin
    write('[', DateTimeToStr(now), '] DEBUG: ' );
    for i := 0 to length( args ) - 1 do begin
      case args[ i ].vtype of
        vtinteger : write( args[ i ].vinteger );
        vtstring  : write( args[ i ].vstring^ );
        vtansistring : write( ansistring( args[ i ].vansistring ));
        vtunicodestring : write( unicodestring( args[i].vunicodestring ));
        else write( '??' );
      end; { case }
    end;
    writeln;
  end;

procedure logger.debug( arg : TStr );
  begin debug([arg]);
  end;

// http://wiki.freepascal.org/Logging_exceptions
function StackTrace(E :  Exception):TStr;
  var I : Integer; Frames : PPointer;
  begin
    if E <> nil then
      WriteStr(Result,'Exception class: ', E.ClassName, LineEnding,
                'Message: ', E.Message, LineEnding)
    else Result:= '';
    Writestr(Result, Result, BackTraceStrFunc(ExceptAddr));
    Frames := ExceptFrames;
    for I := 0 to ExceptFrameCount - 1 do
      Writestr(Result, Result, LineEnding, BackTraceStrFunc(Frames[I]));
  end;


function hex( x : int32; pad : byte = 0 ) : TStr;
  const hexits = '0123456789ABCDEF';
  var i, d : int32; count : byte;
  begin
    result := '';
    count := 0;
    for i := 7 downto 0 do begin
      d := (( x shr ( i * 4 ))  mod 16 );
      if (count > 0) or ( d > 0 ) then begin
        result += TChr(hexits[ d + 1 ]);
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


function paramline : TStr;
  var i : byte; s : TStr;
  begin
    if paramcount > 0 then s := paramstr(1) else s:= '';
    if paramcount > 1 then for i := 2 to paramcount do
      s := s + ' ' + paramstr( i );
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

{ convert open arrays to dynamic arrays }

class function G<T>.FromOpenArray( a : array of T) : ArrayOfT;
  var i : cardinal;
  begin
    setlength(result, length(a));
    if length(a) > 0 then for i := low(a) to high(a) do result[i] := a[i];
  end;

function bytes(data : array of byte):tbytes;
  begin
    result := G<byte>.FromOpenArray(data)
  end;

class procedure G<T>.Sort( a : ArrayOfT; cmp:TCmpFn<T>; lo,hi:cardinal );
  var i,j,k{,n} : cardinal; pivot,tmp:T;
  begin
    assert(lo<=hi);
    if lo = hi then ok
    else begin
      // writeln('sorting[',lo,'..',hi,']'); writeln('pivot:', pivot); readln;
      i:=lo; k:=hi; j:=(i+k) div 2;
      // place pivot on the far right so it ends up in its proper place.
      pivot := a[j]; a[j]:=a[k]; a[k]:=pivot;
      // we store values < pivot at a[j++], so j trails behind i
      j := lo;
      for i := lo to hi-1 do begin
	// write( i:3, ' ', k:3, '  ', cmp(a[i], pivot), ' ');
	case cmp(a[i], pivot) of
	  cmpLT	: begin tmp:=a[j]; a[j]:=a[i]; a[i]:=tmp; inc(j) end;
	  cmpEQ	: ok;
	  cmpGT	: ok;
	end;
	// for n := low(a) to high(a) do begin
	//   if n = lo then write('[') else if n = i then write('>')
	//   else if n=j then write('*') else write(' ');
	//   write(a[n]:3);
	//   if n = hi then write(']') else write(' ');
	// end;
	// writeln;
      end;
      // swap pivot with first value > pivot, but leave j alone
      tmp:=a[j]; a[j]:=a[hi]; a[hi]:=tmp; assert(cmp(a[j],pivot)=cmpEQ);
      if j > lo then sort(a, cmp, lo, j-1);
      if j < hi then sort(a, cmp, j+1, hi);
    end;
  end;

class procedure G<T>.Sort( a : ArrayOfT; cmp:TCmpFn<T> );
  // Generic methods cannot have nested procedures (yet?), so..
  begin Sort(a, cmp, low(a),high(a))
  end;

function vinc(var i:integer):integer;
  // take value, then increment it
  begin result := i; i := i+1;
  end;

function incv(var i:integer):integer;
  // increment, then take the value
  begin i := i+1; result := i;
  end;

function vdec(var i:integer):integer;
  begin result := i; i := i+1;
  end;

function decv(var i:integer):integer;
  begin i := i-1; result := i;
  end;

class function Weak<T>.Ref(obj : T) : T;
  begin obj._addRef; result := obj;
  end;

  var _indent : integer = 0;
  procedure indent; begin inc(_indent) end;
  procedure dedent; begin dec(_indent) end;
  procedure trace( ss : array of variant; ln : boolean = true );
    var s : variant; i : integer;
    begin
      for i := 0 to _indent-1 do write(XPCOUT, '  ');
      for s in ss do write(XPCOUT, s);
      if ln then writeln(XPCOUT, ^M);
    end;
  procedure trace( s : variant ); begin trace([s]) end;

initialization assign(XPCOUT, ''); rewrite(XPCOUT);
finalization close(XPCOUT);
end.
