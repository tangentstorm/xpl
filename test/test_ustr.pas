{$i test_ustr.def }
implementation uses ustr;

  procedure test_startswith;
  begin
    chk.that( ustr.startswith('apple', 'a' ),
	     'apple should starts with a.' );
    chk.that( not ustr.startswith('a', 'apple'),
	     'a shouldn''t start with apple.');
  end;

  procedure test_nwords;
    const s = 'once upon a time';
  begin
    chk.equal( ustr.nwords( s ), 4 );
    chk.equal( ustr.wordn( s, 1 ), 'once' );
    chk.equal( ustr.wordn( s, 4 ), 'time' );
    chk.equal( ustr.nwords( '' ), 0 );
    chk.equal( ustr.nwords( ' ' ), 0 );
  end;

end.
