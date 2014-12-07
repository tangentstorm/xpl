{$mode delphiunicode}{$i xpc.inc}{$i test_uvar.def}
implementation uses uvar;

procedure test_a;
  begin
    chk.equal(0, len( A([]) ));
    chk.equal(1, len( A([1]) ));
    chk.equal(2, len( A([1,2]) ));
  end;

procedure test_implode;
  begin
    chk.equal(0, len( implode( ' ', A([]) )));
    chk.equal(1, len( implode( ' ', A(['1']) )));
    chk.equal(3, len( implode( ' ', A(['1','2']) )));
  end;

procedure test_repr;
  begin
    chk.equal('[]', repr(A([])));
    chk.equal('[ 1 ]', repr(A([1])));
    chk.equal('[ 1 2 ]', repr(A([1,2])));
    chk.equal('[ 1 [ 2 ] ]', repr(A([1, A([2]) ])));
  end;

end.
