{ Generic Grid Class }
{$mode delphi}{$i xpc.inc}
{$PointerMath on}
unit ugrid2d;
interface uses xpc, sysutils;
{TODO: add Reshape(w,h,s) and handle creating the whitespace }
type
  GAbstractGrid2d<T> = class
    type
      P		= ^T;
      GVisitFn	= procedure (x, y : cardinal; val : T) of object;
      GFormatFn	= function (val : T ) : TStr of object;
    protected _origin : P; _w, _h : cardinal;
      _ramsize : cardinal;  { how much ram have we allocated, in bytes? }
    public
      constructor Create; overload; reintroduce;
      constructor Create( w, h : cardinal ); overload;
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
      procedure Resize( w, h : cardinal ); virtual; abstract;
      property ramSize : cardinal read _ramsize;
      function count : cardinal;
      property w : cardinal read _w;
      property h : cardinal read _h;
    public { utility interface }
      //  procedure ForEach(task : GGridVisitFn<T>);
      function ToStr(f : GFormatFn) : TStr;
      procedure Fill( value : T );
    end;

{ concrete subclasses }

 { this one uses an array internally }
 GGrid2d<T>	= class (GAbstractGrid2d<T>)
  protected _data : array of T;
  public
   destructor Destroy; override;
   procedure Resize( w, h : cardinal ); override;
 end;

  { this one can latch onto existing ram in memory }
  GSharedGrid2d<T>= class (GAbstractGrid2d<T>)
   public
    constructor CreateAt( w, h, s : cardinal; at : pointer ); overload;
    procedure Resize( w, h : cardinal ); override;
  end;

implementation

constructor GAbstractGrid2d<T>.Create;
  begin Create(16, 16);
  end;

constructor GAbstractGrid2d<T>.Create( w, h : cardinal );
  begin inherited Create; Resize(w, h);
  end;

constructor GSharedGrid2d<T>.CreateAt( w, h, s : cardinal; at : pointer );
  begin _origin := at; inherited create(w,h);
  end;


{ 2D interface }

function GAbstractGrid2d<T>.xyToI( x, y : cardinal ) : cardinal; inline;
  begin result := y * _w + x
  end;

procedure GAbstractGrid2d<T>.SetItem( x, y : cardinal; value : T );
  begin _origin[ xyToI( x, y ) ] := value;
  end;

function GAbstractGrid2d<T>.GetItem( x, y : cardinal ) : T;
  begin result := _origin[ xyToI( x, y ) ];
  end;

{ 1D direct interface }

procedure GAbstractGrid2d<T>.SetItem( i : cardinal; value : T );
  begin _origin[ i ] := value;
  end;

function GAbstractGrid2d<T>.GetItem( i : cardinal ) : T;
  begin result := _origin[ i ];
  end;


function GAbstractGrid2d<T>.ToStr(f : GFormatFn) : TStr;
  var x, y : word;
  begin result := '';
    for y := 0 to h-1 do begin
      for x := 0 to w-2 do result += f( _origin[ y * w + x ]) + ' ';
      result += f( _origin[ y * w + (w - 1) ]) + lineending;
    end
  end;

function GAbstractGrid2d<T>.count : cardinal; inline;
  begin result := _w * _h
  end;

procedure GAbstractGrid2d<T>.Fill( value : T );
  var i : word;
  begin
    for i := 0 to count - 1 do self.at[ i ] := value
  end;


procedure GSharedGrid2d<T>.Resize( w, h : cardinal );
  var temp : pointer; newsize : cardinal;
  begin
    { For now, do nothing, though perhaps this should be virtual.
      The idea here is provide a way to talk directly to third
      party image / array libraries, so we occasionally do want
      to just declare data has some particular shape in ram. }
    _w := w; _h := h;
    newsize := w * h * SizeOf( T );
    if ( newsize = _ramsize ) then ok
    else if ( newsize < _ramsize ) then ok { TODO: reclaim? }
    else if ( newsize > _ramsize ) then _ramsize := newsize
  end;

procedure GGrid2d<T>.Resize( w, h :  cardinal );
  begin
    _w := w; _h := h;
    SetLength(_data, count);
    if count = 0 then _origin := nil else _origin := @(_data[0])
  end;

destructor GGrid2d<T>.Destroy;
  begin _data := nil; inherited destroy;
  end;

begin
end.
