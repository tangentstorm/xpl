{$mode delphiunicode}
{$i test_kvm_gridterm.def }
implementation uses xpc, kvm, num, kbd;

var
  term : IGridTerm;
  cell : TTermCell;

procedure setup;
  begin
    term := GridTerm(8,4);
  end;

procedure dump(term : IGridTerm);
  var y, x : integer;
  begin
    clrscr; writeln;
    write('  '); for x := 0 to term.xmax do write(stdout, x); writeln;
    write(' +'); for x := 0 to term.xmax do write(stdout, '-'); writeln;
    for y := 0 to term.ymax do
      begin
	write(y, '|');
	for x := 0 to term.xmax do write(stdout, term.GetCell(x,y).ch);
	writeln;
      end;
    write(' +'); for x := 0 to term.xmax do write(stdout, '-'); writeln;
    write('  '); for x := 0 to term.xmax do write(stdout, x); writeln;
    writeln;
  end;

procedure test_size;
  begin
    chk.equal( 8, term.width);  chk.equal( 4, term.height);
    chk.equal( 7, term.xmax);   chk.equal( 3, term.ymax);
  end;

procedure test_sanity;
  var a, b : TTermCell;
  begin
    chk.equal(4, sizeof(a));
    a.attr.fg := $99;
    a.attr.bg := $cc;
    a.ch   := 'x';
    b := a;
    chk.equal($99cc, word(b.attr));
    chk.equal('x', b.ch);
  end;

procedure test_cells;
  begin
    cell := term.GetCell(0, 0);
    cell.ch := 'x'; term.PutCell(0, 0, cell);
    cell.ch := 'y'; cell := term.GetCell(0, 0);
    chk.equal(cell.ch, 'x');
  end;

procedure test_emit;
  begin
    chk.equal(0, term.wherex);
    chk.equal(0, term.wherey);
    term.emit('xyz');
    chk.equal(3, term.wherex);
    chk.equal(0, term.wherey);
    chk.equal('x', term.GetCell(0,0).ch);
    chk.equal('y', term.GetCell(1,0).ch);
    chk.equal('z', term.GetCell(2,0).ch);
  end;

procedure test_gotoxy;
  begin
    term.gotoxy(0,0);
    chk.equal(term.wherex, 0);
    chk.equal(term.wherey, 0);
    term.gotoxy(1,2);
    chk.equal(term.wherex, 1);
    chk.equal(term.wherey, 2);
    term.emit('>');
    chk.equal(term.wherex, 2);
    chk.equal(term.wherey, 2);
  end;

procedure test_clrscr;
  begin
    with term do begin
      cell.ch := 'A'; term.PutCell(0,0,cell);
      cell.ch := 'Z'; term.PutCell(7,3,cell);

      gotoxy(0,0); emit('a');
      gotoxy(xmax, ymax); emit('b');

      chk.equal('a', term.GetCell(0,0).ch);
      chk.equal('b', term.GetCell(xmax, ymax).ch);
      chk.equal(wherex, width);
      chk.equal(wherey, ymax);

      clrscr;
      chk.equal(' ', term.GetCell(0,0).ch);
      chk.equal(' ', term.GetCell(xmax, ymax).ch);
      chk.equal(wherex, 0);
      chk.equal(wherey, 0);
    end;
  end;

procedure test_misc;
  {regression test}
  var ch : char;
  begin
    with term do
      begin
	bg(8); fg(15); emit('hello world'); newline;
	for ch in 'hello world' do emit(ch); newline;
      end;
  end;

procedure test_linewrap;
  var y, x : integer;
  begin
    term.clrscr;
    for y := 0 to term.ymax do
      for x := 0 to term.xmax do term.emit(n2s(y));
    chk.equal('0', term.GetCell(0,0).ch);
    chk.equal('1', term.GetCell(2,1).ch);
    chk.equal('2', term.GetCell(5,2).ch);
    chk.equal('3', term.GetCell(7,3).ch);
    chk.equal(8, term.wherex);
    chk.equal(3, term.wherey);
  end;

procedure test_linewrap_bottom;
  begin
    test_linewrap;
    chk.equal(8, term.wherex);
    chk.equal(3, term.wherey);
    term.emit('x');
    chk.equal(1, term.wherex);
    chk.equal(3, term.wherey);
  end;

procedure test_delline;
  begin
    test_linewrap;
    term.gotoxy(1,1);
    term.delline;
    // 1. it should delete the line:
    chk.equal('0', term.GetCell(0,0).ch);
    chk.equal('2', term.GetCell(2,1).ch);
    chk.equal('3', term.GetCell(5,2).ch);
    chk.equal(' ', term.GetCell(7,3).ch);
    // 2. it should restore the cursor position:
    chk.equal(1, term.wherex);
    chk.equal(1, term.wherey);
  end;

finalization
end.
