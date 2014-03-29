{$mode delphi}{$H+}
{$i test_uww.def }
implementation uses uww, ug2d, utv;

var
  g2 : ug2d.IBounds2D;
  ww : uww.TWordWrap;

procedure setup;
  begin
    if assigned(ww) then ww.free;
    ww := TWordWrap.Create(Nil);
  end;

procedure test_first_line;
  begin
    ww.width := 32; ww.gapw := 0;
    g2 := TView.Create(Nil); g2.w := 10; g2.h := 1;
    ww.place(g2); chk.equal(g2.x, 0,'a0'); chk.equal(g2.y, 0,'a1');
    ww.place(g2); chk.equal(g2.x,10,'b0'); chk.equal(g2.y, 0,'b1');
    ww.place(g2); chk.equal(g2.x,20,'c0'); chk.equal(g2.y, 0,'c1');
    ww.place(g2); chk.equal(g2.x, 0,'d0'); chk.equal(g2.y, 1,'d1');
  end;

procedure test_with_gap;
  begin
    ww.width := 32; ww.gapw := 1;
    g2 := TView.Create(Nil); g2.w := 10; g2.h := 1;
    // --------------------------------|
    // aaaaaaaaaa bbbbbbbbbb cccccccccc|
    ww.place(g2); chk.equal(g2.x, 0,'a0'); chk.equal(g2.y, 0,'a1');
    ww.place(g2); chk.equal(g2.x,11,'b0'); chk.equal(g2.y, 0,'b1');
    // this one is tricky due to the gap:
    ww.place(g2); chk.equal(g2.x,22,'c0'); chk.equal(g2.y, 0,'c1');
    ww.place(g2); chk.equal(g2.x, 0,'d0'); chk.equal(g2.y, 1,'d1');
  end;

finalization
  if assigned(ww) then ww.Free;
end.
