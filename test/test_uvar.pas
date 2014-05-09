{$mode delphiunicode}{$i xpc.inc}{$i test_uvar.def}
implementation uses uvar;

procedure test_a;
  begin
    chk.equal(0, length( A([]) ));
    chk.equal(1, length( A([1]) ));
    chk.equal(2, length( A([1,2]) ));
  end;

procedure test_implode;
  begin
    chk.equal(0, length( implode( ' ', A([]) )));
    chk.equal(1, length( implode( ' ', A(['1']) )));
    chk.equal(3, length( implode( ' ', A(['1','2']) )));
  end;

procedure test_repr;
  begin
    chk.equal('[]', repr(A([])));
    chk.equal('[ 1 ]', repr(A([1])));
    chk.equal('[ 1 2 ]', repr(A([1,2])));
    chk.equal('[ 1 [ 2 ] ]', repr(A([1, A([2]) ])));
  end;

end.
