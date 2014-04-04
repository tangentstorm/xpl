{$mode delphi}
{$i test_grid2d.def }
implementation uses ugrid2d;

var grid : GGrid2d<byte>;

procedure setup;
  begin
    if assigned(grid) then grid.free;
    grid := GGrid2D<byte>.Create(20,16);
  end;

procedure test_accessors;
  var i : byte;
  begin
    for i := 0 to $f do
      begin
	grid[i,i] := (i shl 4) + i; // 1,1 = $11 etc..
	chk.equal(grid[i,i],  (i shl 4) + i);
      end;
  end;

procedure test_fill;
  begin
    grid.fill(99);
    chk.equal(99, grid[0,0]);
  end;

finalization
  if assigned(grid) then grid.free;
end.
