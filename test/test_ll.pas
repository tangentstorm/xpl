{$i test_ll.def }
implementation uses ll;

  var
    ls	 : list;
    a, b : node;

  procedure setup;
  begin
    ls := list.init;
    a := node.create;
    b := node.create;
  end;

  procedure test_init;
  begin
    chk.that( ls.first = nil, '.first should = nil for empty list' );
    chk.that( ls.last = nil, '.last should = nil for empty list' );
  end;

  procedure test_append;
  begin
    ls.append( a );
    chk.that( ls.first = a, 'append to empty should set first' );
    chk.that( ls.last = a, 'append to empty should set last' );
    ls.append( b );
    chk.that( ls.first = a,
	     'appending second item should not change .first ' );
    chk.that( ls.last = b, 'appending second item should change last' );
  end;

end.
