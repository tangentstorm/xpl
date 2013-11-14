// geometry unit
{$mode delphi}
unit ugeom2d;

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
  
begin
end.
