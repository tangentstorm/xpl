// 2d geometry unit
{$i xpc.inc}{$mode delphi}
unit ug2d;
interface uses classes;

type IPoint2D = interface// A point in 2D space
  function GetX : integer; procedure SetX( value : integer );
  function GetY : integer; procedure SetY( value : integer );
  property x : integer read GetX write SetX;
  property y : integer read GetY write SetY;
  procedure MoveTo( xval, yval : integer );
end;

type ISize2D = interface // A 2d rectangle with no particular location.
  function GetW : cardinal; procedure SetW( value : cardinal );
  function GetH : cardinal; procedure SetH( value : cardinal );
  property w : cardinal read GetW write SetW;
  property h : cardinal read GetH write SetH;
  procedure Resize( wval, hval : cardinal );
end;

type IBounds2D = interface // fpc lacks multiple inheritance for interfaces :/
  function GetX : integer; procedure SetX( value : integer );
  function GetY : integer; procedure SetY( value : integer );
  function GetW : cardinal; procedure SetW( value : cardinal );
  function GetH : cardinal; procedure SetH( value : cardinal );
  property x : integer read GetX write SetX;
  property y : integer read GetY write SetY;
  property w : cardinal read GetW write SetW;
  property h : cardinal read GetH write SetH;
  { mutators }
  procedure MoveTo( xval, yval : integer );
  procedure MoveBy( dx, dy : integer );
  procedure Resize( wval, hval : cardinal );
  procedure Center( xval, yval : integer );
end;

{ concrete implementations }

type TPoint2D = class (TComponent, IPoint2D)
  protected
    _x, _y : integer;
  public
    function Init( xval, yval : integer ) : TPoint2D;
    function GetX : integer; procedure SetX( val : integer );
    function GetY : integer; procedure SetY( val : integer );
    procedure MoveTo( xval, yval : integer ); virtual;
    procedure MoveBy(dx, dy : integer);
    property x : integer read GetX write SetX;
    property y : integer read GetY write SetY;
  end;

type TBounds2D = class (TPoint2D, ISize2D, IBounds2D)
  protected
    _w, _h : cardinal;
  public
    function Init( xval, yval : integer; wval, hval : cardinal ) : TBounds2D;
      reintroduce;
    function GetW : cardinal; procedure SetW( val : cardinal );
    function GetH : cardinal; procedure SetH( val : cardinal );
    procedure Center( xval, yval : integer );
    procedure Resize( wval, hval : cardinal ); virtual;
    property w : cardinal read GetW write SetW;
    property h : cardinal read GetH write SetH;
  end;

{ interface constructors for convenience }
function Point2D( x, y : integer ) : IPoint2D;
function Bounds2D( x, y : integer; w, h : cardinal ) : IBounds2D;


implementation

{ TPoint2D }

function TPoint2D.Init( xval, yval : integer ) : TPoint2D;
  begin result := self; _x := xval; _y := yval
  end;

function TPoint2D.GetX : integer;
  begin result := self._x
  end;

procedure TPoint2D.SetX( val : integer );
  begin _x := val
  end;

function TPoint2D.GetY : integer;
  begin result := _y
  end;

procedure TPoint2D.SetY( val : integer );
  begin _y := val
  end;

procedure TPoint2D.MoveTo( xval, yval : integer );
  begin _x := xval; _y := yval
  end;

procedure TPoint2D.MoveBy( dx, dy : integer );
  begin MoveTo( _x+dx, _y+dy )
  end;


{ TBounds2D }

function TBounds2D.Init( xval, yval : integer; wval, hval : cardinal ) : TBounds2D;
  begin moveto( xval, yval ); resize( wval, hval ); result := self
  end;

function TBounds2D.GetW : cardinal;
  begin result := _w
  end;

procedure TBounds2D.SetW( val : cardinal );
  begin _w := val
  end;

function TBounds2D.GetH : cardinal;
  begin result := _h
  end;

procedure TBounds2D.SetH( val : cardinal );
  begin _h := val
  end;

procedure TBounds2D.Center( xval, yval : integer );
  begin
    _x := xval - _w div 2;
    _y := yval - _h div 2;
  end;

procedure TBounds2D.Resize( wval, hval : cardinal );
  begin _w := wval; _h := hval
  end;

{ interface constructors }

function Point2D( x, y : integer ) : IPoint2D;
  begin result := TPoint2D.Create( nil ).Init( x, y );
  end;

function Bounds2D( x, y : integer; w, h : cardinal ) : IBounds2D;
  begin result := TBounds2D.Create( nil ).Init( x, y, w, h );
  end;


initialization
end.
