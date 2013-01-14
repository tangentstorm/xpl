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
    const s = 'once upon a time';
  begin
    chk.equal( stri.nwords( s ), 4 );
    chk.equal( stri.wordn( s, 1 ), 'once' );
    chk.equal( stri.wordn( s, 4 ), 'time' );
    chk.equal( stri.nwords( '' ), 0 );
    chk.equal( stri.nwords( ' ' ), 0 );
  end;

end.
