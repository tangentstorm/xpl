{$i test_ll_cur.def }
implementation uses ll, li, xpc;

  type charlist = specialize list<char>;
  var
    ls	: charlist;
    cur	: charlist.cursor;
    ch	: char;

  procedure setup;
  begin
    ls := charlist.create;
    for ch := 'a' to 'z' do ls.append( ch );
    cur := ls.make_cursor
  end;

  procedure test_to_top;
  begin
    cur.to_top;
    chk.equal( cur.value, 'a' );
  end;

  procedure test_next_and_prev;
  begin
    cur.to_top;                           chk.equal( cur.index, 1 );
    cur.next( ch ); chk.equal( ch, 'b' ); chk.equal( cur.index, 2 );
    cur.next( ch ); chk.equal( ch, 'c' ); chk.equal( cur.index, 3 );
    cur.prev( ch ); chk.equal( ch, 'b' ); chk.equal( cur.index, 2 );
    cur.prev( ch ); chk.equal( ch, 'a' ); chk.equal( cur.index, 1 );
  end;

  procedure test_to_end;
  begin
    cur.to_end;
    chk.equal( cur.value, 'z' );
    chk.equal( cur.index, ls.count );
    chk.equal( cur.index, 26 );
  end;



end.
