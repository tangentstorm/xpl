{$mode delphiunicode}{$i xpc.inc}{$i test_num.def}
implementation uses num;

  procedure test_choose;
    begin
      chk.equal(choose(5,6), 0,
		'should not be able to choose 6 items out of 5');
    end;

  procedure test_n2h;
    begin
      chk.equal(n2h($ffccdd), '$FFCCDD');
    end;

  procedure test_h2n;
    begin
      chk.equal(h2n('$fFcCdD'), $ffccdd);
    end;

end.
