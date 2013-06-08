{ Generic Grid Class }
{$mode objfpc}{$i xpc.inc}
unit grids;
interface uses xpc, sysutils;

type
  generic TGrid<T> = class
    type P = ^T;
  private
    _w, _h   : cardinal;
    _count   : cardinal;  { how many items? }
    _ramsize : cardinal;  { how much ram have we allocated, in bytes? }
    _dynamic : boolean;
    _data    : P;
  public
    constructor Create;
    constructor Create( w, h : cardinal; s : cardinal = 0 );
    constructor CreateAt( w, h, s : cardinal; at : pointer );
    destructor Destroy; override;
  public { 2D interface }
    procedure SetItem( x, y : cardinal; value : T );
    function GetItem( x, y : cardinal ) : T;
    property at2[ x, y : cardinal ]: T read GetItem write SetItem; default;
  public { 1D array interface }
    procedure SetItem( i : cardinal; value : T );
    function GetItem( i : cardinal ) : T;
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

constructor TGrid.Create;
begin
  CreateAt(16, 16, 0, nil );
end;

constructor TGrid.Create( w, h : cardinal; s : cardinal = 0 );
begin
  CreateAt( w, h, s, nil );
end;

constructor TGrid.CreateAt( w, h, s : cardinal; at : pointer );
begin
  _ramsize := 0;
  _count   := 0;
  _dynamic := ( at = nil );
  _data    := at;
  ReSize( w, h );
  if _dynamic then FillDWord( _data[0], _ramsize div sizeof(dword), 0 );
end;


{ 2D interface }
procedure TGrid.SetItem( x, y : cardinal; value : T );
begin
  _data[ y * _w + x ] := value;
end;

function TGrid.GetItem( x, y : cardinal ) : T;
begin
  result := _data[ y * _w + x ];
end;

{ 1D direct interface }
procedure TGrid.SetItem( i : cardinal; value : T );
begin
  _data[ i ] := value;
end;

function TGrid.GetItem( i : cardinal ) : T;
begin
  result := _data[ i ];
end;


{$IFDEF DumpGrids}
{ This is ifdeffed because I don't know how to convert arbitrary types to strings. :/ }
function TGrid.ToString : string;
  var x, y : word;
  begin
    for y := 0 to h-1 do begin
      for x := 0 to w-2 do result += ToStr( _data[ y * w + x ]) + ' ';
      result += ToStr( _data[ y * w + (w - 1) ]);
    end
  end;

procedure TGrid.Dump;
begin
  writeln( self.ToString )
end;
{$ENDIF}

procedure TGrid.Fill( value : T );
  var i : word;
begin
  for i := 0 to _count- 1 do self.at[ i ] := value
end;

{TODO: TGrid.Resize should probably only deal with count/ramsize }
{TODO: add TGrid.Reshape(w,h,s) and handle creating the whitespace }
procedure TGrid.Resize( w, h : cardinal );
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
	{ TODO fill new space with zeros }
	_data := temp;
      end
    else
      begin
	{ For now, do nothing, though perhaps this should be virtual.
	  The idea here is provide a way to talk directly to third
	  party image / array libraries, so we occasionally do want
	  to just declare data has some particular shape in ram. }
      end;
  if ( newsize < _ramsize ) then pass; { TODO }
  _ramsize := newsize;
  _count := newcount;
end;

destructor TGrid.Destroy;
begin
  if _dynamic then FreeMem( _data, _ramsize );
  _data := nil;
end;

begin
end.
