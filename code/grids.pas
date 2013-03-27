{ Generic Grid Class }
{$mode objfpc}
unit grids;
interface

type
  generic TGrid<T> = class
  private
    _w, _h : cardinal;
    data : array of T;
  public
    constructor Create;
    constructor Create( w, h : cardinal );
    destructor Destroy; override;
  public { 2D interface }
    procedure SetItem( x, y : cardinal; value : T );
    function GetItem( x, y : cardinal ) : T;
    property at2[ x, y : cardinal ]: T read GetItem write SetItem; default;
  public { 1D array interface }
    procedure SetItem( i : cardinal; value : T );
    function GetItem( i : cardinal ) : T;
    property at[ i : cardinal ]: T read GetItem write SetItem;
  public
    procedure Resize( w, h : cardinal );
    property w : cardinal read _w;
    property h : cardinal read _w;
  end;

implementation

constructor TGrid.Create;
begin
  Create(16,16);
end;

constructor TGrid.Create( w, h : cardinal );
begin
  Resize( w, h );
end;

{ 2D interface }
procedure TGrid.SetItem( x, y : cardinal; value : T );
begin
  data[ y * _w + x ] := value;
end;

function TGrid.GetItem( x, y : cardinal ) : T;
begin
  result := data[ y * _w + x ];
end;

{ 1D direct interface }
procedure TGrid.SetItem( i : cardinal; value : T );
begin
  data[ i ] := value;
end;

function TGrid.GetItem( i : cardinal ) : T;
begin
  result := data[ i ];
end;

procedure TGrid.Resize( w, h : cardinal );
begin
  _w := w; _h := h;
  SetLength(data, _w * _h);
end;

destructor TGrid.Destroy;
begin
  data := nil;
end;

begin
end.
