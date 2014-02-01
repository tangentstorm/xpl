// geometry unit
{$i xpc.inc}{$mode delphi}
unit ugeom2d;
interface

// A 2d rectangle with no particular location.
type
  ISize2D = interface
    function GetW : cardinal;
    function GetH : cardinal;
    procedure SetW( value : cardinal );
    procedure SetH( value : cardinal );
    procedure Resize( w, h : cardinal );
    property w : cardinal read GetW write SetW;
    property h : cardinal read GetH write SetH;
  end;
  IPoint2D = interface
    function GetX : integer;
    function GetY : integer;
    procedure SetX( value : integer );
    procedure SetY( value : integer );
    property x : integer read GetX write SetX;
    property y : integer read GetY write SetY;
  end;

  // fpc doesn't have multiple inheritance for interfaces yet. :/
  IBounds2D = interface
    function GetW : cardinal;
    function GetH : cardinal;
    procedure SetW( value : cardinal );
    procedure SetH( value : cardinal );
    procedure Resize( w, h : cardinal );
    property w : cardinal read GetW write SetW;
    property h : cardinal read GetH write SetH;
    function GetX : integer;
    function GetY : integer;
    procedure SetX( value : integer );
    procedure SetY( value : integer );
    property x : integer read GetX write SetX;
    property y : integer read GetY write SetY;
  end;

implementation
begin
end.
