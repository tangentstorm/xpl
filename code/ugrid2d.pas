{ Generic Grid Class }
{$mode delphi}{$i xpc.inc}
{$PointerMath on}
unit ugrid2d;
interface uses xpc, sysutils;

type
  GGrid2d<T> = class
    type P = ^T;
  protected
    _w, _h   : cardinal;
    _count   : cardinal;  { how many items? }
    _ramsize : cardinal;  { how much ram have we allocated, in bytes? }
    _dynamic : boolean;
    _data    : P;
  public
    constructor Create; overload; reintroduce;
    constructor Create( w, h : cardinal; s : cardinal = 0 ); overload;
    constructor CreateAt( w, h, s : cardinal; at : pointer ); overload;
    destructor Destroy; override;
  public { 2D interface }
    function xyToI( x, y : cardinal ) : cardinal; inline;
    procedure SetItem( x, y : cardinal; value : T ); overload;
    function GetItem( x, y : cardinal ) : T; overload;
    property at2[ x, y : cardinal ]: T read GetItem write SetItem; default;
  public { 1D array interface }
    procedure SetItem( i : cardinal; value : T ); overload;
    function GetItem( i : cardinal ) : T; overload;
    property at[ i : cardinal ]: T read GetItem write SetItem;
  public { Sizing interface }
    procedure Resize( w, h : cardinal );
    property ramSize : cardinal read _ramsize;
    property count : cardinal read _count;
    property w : cardinal read _w;
    property h : cardinal read _h;
  public { utility interface }
    {$IFDEF DumpGrids}
    function ToString : String; override;
    procedure Dump;
    {$ENDIF}
    procedure Fill( value : T );
  end;

implementation

constructor GGrid2d<T>.Create;
begin
  CreateAt(16, 16, 0, nil );
end;

constructor GGrid2d<T>.Create( w, h : cardinal; s : cardinal = 0 );
begin
  CreateAt( w, h, s, nil );
end;

constructor GGrid2d<T>.CreateAt( w, h, s : cardinal; at : pointer );
begin
  inherited create;
  _ramsize := 0;
  _count   := 0;
  _dynamic := ( at = nil );
  _data    := at;
  Resize( w, h );
end;


{ 2D interface }

function GGrid2d<T>.xyToI( x, y : cardinal ) : cardinal; inline;
  begin
    result := y * _w + x
  end;

procedure GGrid2d<T>.SetItem( x, y : cardinal; value : T );
  begin
    _data[ xyToI( x, y ) ] := value;
  end;

function GGrid2d<T>.GetItem( x, y : cardinal ) : T;
begin
  result := _data[ xyToI( x, y ) ];
end;

{ 1D direct interface }
procedure GGrid2d<T>.SetItem( i : cardinal; value : T );
begin
  _data[ i ] := value;
end;

function GGrid2d<T>.GetItem( i : cardinal ) : T;
begin
  result := _data[ i ];
end;


{$IFDEF DumpGrids}
{ This is ifdeffed because I don't know how to convert arbitrary types to strings. :/ }
function GGrid2d<T>.ToString : string;
  var x, y : word;
  begin
    for y := 0 to h-1 do begin
      for x := 0 to w-2 do result += ToStr( _data[ y * w + x ]) + ' ';
      result += ToStr( _data[ y * w + (w - 1) ]);
    end
  end;

procedure GGrid2d<T>.Dump;
begin
  writeln( self.ToString )
end;
{$ENDIF}

procedure GGrid2d<T>.Fill( value : T );
  var i : word;
begin
  for i := 0 to _count- 1 do self.at[ i ] := value
end;

{TODO: GGrid2d.Resize should probably only deal with count/ramsize }
{TODO: add GGrid2d.Reshape(w,h,s) and handle creating the whitespace }
procedure GGrid2d<T>.Resize( w, h : cardinal );
  var temp : pointer; newsize, newcount : cardinal;
begin
  _w := w; _h := h;
  newcount := w * h;
  newsize := newcount * SizeOf( t );
  if ( newsize > _ramsize ) then
    if _dynamic then
      begin
	GetMem( temp, newsize );
	{ move the old data }
	Move( _data, temp, _ramsize );
	FreeMem(_data, _ramsize );
	{ TODO fill new space with zeros.
          (unfortunately, sizeof(T) is broken in 2.6.2 for generics. }
        //if _dynamic then FillDWord( _data[0], _ramsize div sizeof(T), 0 );
	_data := temp;
      end
    else
      begin
	{ For now, do nothing, though perhaps this should be virtual.
	  The idea here is provide a way to talk directly to third
	  party image / array libraries, so we occasionally do want
	  to just declare data has some particular shape in ram. }
      end;
  if ( newsize < _ramsize ) then ok; { TODO }
  _ramsize := newsize;
  _count := newcount;
end;

destructor GGrid2d<T>.Destroy;
begin
  if _dynamic then FreeMem( _data, _ramsize );
  _data := nil;
end;

begin
end.
