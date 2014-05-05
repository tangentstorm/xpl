// demo of TGridView
{$mode delphiunicode}{$i xpc}
program gridviewdemo;
uses xpc, uapp, num, utv, kvm, ukm, umsg;

type
  TGridViewApp = class (uapp.TCustomApp)
    public
      _grid : utv.TGridView;
      procedure Init; override;
      procedure keys(km : ukm.TKeyMap); override;
      procedure CellSize(gx, gy : word; out cellw, cellh : byte);
      procedure DrawCell(gx, gy : word);
    end;

const gw = 11; gh = 8;

procedure TGridViewApp.Init;
  begin
    _grid := TGridView.Create(self);
    _grid.GridHeight := gh; _grid.GridWidth := gw;
    _grid.w := kvm.width;
    _grid.OnRenderCell := DrawCell;
    _grid.CellSizer := CellSize;
    _grid.ResizeCells;
    _views.append(_grid);                  // this should be inferred.
    _focusables.append(_grid);
    _focus.totop; _focus.value.gainfocus; //  this should be automatic!
    umsg.subscribe( chan_nav, _grid.handle ); // this too
    kvm.clrscr;
  end;

procedure TGridViewApp.keys(km : ukm.TKeyMap);
  begin
    with km do begin
      msg[ ^P ] := msg_nav_up;       msg[ ^N ] := msg_nav_dn;
      msg[ ^I ] := msg_cmd_toggle;   msg[ ^D ] := msg_cmd_delete;
      cmd[ ^L ] := _grid.smudge;     cmd[ ^C ] := self.quit;
    end
  end;

procedure TGridViewApp.CellSize(gx, gy : word; out cellw, cellh : byte);
  begin cellw := gx + 1; cellh := gy + 1;
  end;

procedure TGridViewApp.DrawCell(gx, gy : word);
  var i, j : word;
  begin
    for j := 1 to gy+1 do begin
      fg(18 + gy * 8 + gx);
      for i := 1 to gx + 1 do emit(chr(33 + (gy * gw + gx)))
    end
  end;

begin
  uapp.Run(TGridViewApp)
end.
