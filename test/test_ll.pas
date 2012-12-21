{$i test_ll.def }
implementation uses ll, li, xpc;

  var
    ls	 : specialize list<string>;
    a, b : string;

  procedure setup;
  begin
    ls := list.init;
    a := 'a';
    b := 'b';
  end;

  procedure test_init;
  begin
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

end.
