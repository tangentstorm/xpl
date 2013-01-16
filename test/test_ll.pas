{$i test_ll.def }
{ see also test_ll_cur for cursor tests }
implementation uses ll, li, xpc;

  var
    ls	    : stringlist;
    a, b, c : string;

  procedure setup;
  begin
    ls := stringlist.create;
    a := 'a';
    b := 'b';
    c := 'c';
  end;

  procedure test_init;
  begin
    chk.that( ls.is_empty, 'new list should be empty' );
    chk.equal( ls.length, 0, 'new list should have length 0' );
    try
      ls.first; chk.fail('.first should throw exception for empty list' )
    except pass end;
    try
      ls.first; chk.fail('.last should throw exception for empty list' )
    except pass end;
  end;

  procedure test_append;
  begin
    ls.append( a );
    chk.that( ls.first = a,
	     'append to empty should set first' );
    chk.that( ls.last = a,
	     'append to empty should set last' );
    ls.append( b );
    chk.that( ls.first = a,
	     'appending second item should not change .first ' );
    chk.that( ls.last = b,
	     'appending second item should change last' );
  end;


  procedure test_insertion;
    var cur : stringlist.cursor;
  begin
    ls.append( b );
    ls.append( c );
    cur := ls.make_cursor;
    cur.to_end;
    chk.equal( ls.length, 2, 'ls.length' );
    chk.equal( cur.index, 2, 'cur.index' );
  end;

end.
