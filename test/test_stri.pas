{$i test_stri.def }
implementation uses stri;

  procedure test_startswith;
  begin
    chk.that( stri.startswith('apple', 'a' ),
	     'apple should starts with a.' );
    chk.that( not stri.startswith('a', 'apple'),
	     'a shouldn''t start with apple.');
  end;

  procedure test_nwords;
  begin
    chk.equal( stri.nwords('once upon a time' ), 4 );
  end;

end.