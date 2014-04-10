{$mode delphi}{$i xpc}
program grid_demo;
uses xpc, ugrid2d, chk, cx;

type
  TCharGrid = class (GGrid2d<TChr>)
    public function CharToStr( ch : TChr ) : TStr;
    end;

function TCharGrid.CharToStr( ch : TChr ) : TStr;
  begin result := a2u(ch)
  end;

const
  hex = '0123456789ABCDEF';
var
  g : TCharGrid;
  i : cardinal;
begin
  g := TCharGrid.Create( $10, $10 );
  chk.equal( g.Count, 256 );
  g.Fill( '.' );
  for i := $0 to $f do g[ i, i ] := hex[ i + 1 ];
  writeln(g.tostr(g.CharToStr));
end.
