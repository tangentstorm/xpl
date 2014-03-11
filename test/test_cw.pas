{$i test_cw.def }
implementation uses cw;

procedure test_cwlen;
  begin
    chk.equal(0, cwlen(''));
    chk.equal(1, cwlen('x'));
    chk.equal(1, cwlen('||'));
  end;

procedure test_cwpad;
  begin
    chk.equal('',   cwpad('', 0));
    chk.equal(' ',  cwpad('', 1));
    chk.equal('x',  cwpad('', 1, 'x'));
    chk.equal('  ', cwpad('', 2));
  end;

end.
