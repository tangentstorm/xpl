{$DEFINE DumpGrids}
program grid_demo;
uses ugrid2d, chk;

type
  TCharGrid = specialize GGrid2d<Char>;

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
  writeln(g.ToString);
end.
