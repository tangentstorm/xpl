{$mode delphi}
{$i test_kvm_gridterm.def }
implementation uses kvm;

var
  term : TGridTerm;
  cell : TTermCell;

procedure setup;
  begin
    if assigned(term) then term.free;
    term := TGridTerm.Create(8,16);
  end;

procedure test_size;
  begin
    chk.equal( 8, term.width);
    chk.equal(16, term.height);
    chk.equal( 8, term.grid.w);
    chk.equal(16, term.grid.h);
  end;

procedure test_cells;
  begin
    cell := term.grid[0,0];
    cell.ch := 'x';
    term.grid[0,0] := cell;
    cell.ch := 'y';
    cell := term.grid[0,0];
    chk.equal(cell.ch, 'x');
  end;

procedure test_clrscr;
  begin
    term.gotoxy(1,1);
    term.grid.chars[0,0] := 'x';
    term.clrscr;
    chk.equal(' ', term.grid.chars[0,0]);
    chk.equal(term.wherex, 0);
    chk.equal(term.wherey, 0);
  end;

procedure test_gotoxy;
  begin
    term.gotoxy(0,0);
    chk.equal(term.wherex, 0);
    chk.equal(term.wherey, 0);
    term.gotoxy(1,2);
    chk.equal(term.wherex, 1);
    chk.equal(term.wherey, 2);
  end;

procedure test_misc;
  {regression test}
  var ch : char;
  begin
    with term do
      begin
	bg(8);
	fg(15);
	for ch in 'hello world' do emit(ch);
      end;
  end;

finalization
  if assigned(term) then term.free;
end.
