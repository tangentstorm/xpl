{$i test_ll_cur.def }
implementation uses ll, li, xpc;

  type charlist = specialize list<char>;
  var
    ls	: charlist;
    cur	: charlist.cursor;
    ch	: char;
  const chars = 'abcxyz';

  procedure setup;
  begin
    ls := charlist.create;
    cur := ls.make_cursor
  end; { setup }

  function as_string : string;
  begin
    result := '';
    if ls.is_empty then pass
    else for ch in ls do result += ch;
  end;

  procedure add_chars;
  begin
    for ch in chars do ls.append( ch )
  end;

  procedure test_as_string;
  begin
    chk.equal( as_string, '' );
    add_chars;
    chk.that( not ls.is_empty, 'added chars so should not be empty!');
    chk.equal( 6, ls.length );
    chk.equal( as_string, 'abcxyz' )
  end;


  procedure test_create;
  begin
    chk.that( cur.index = 0, 'cursor should start on the clasp' );
  end;

  procedure test_to_top;
  begin
    add_chars;
    cur.to_top;
    chk.equal( cur.value, 'a' );
  end;

  procedure test_next_and_prev;
  begin
    add_chars;
    cur.to_top;                           chk.equal( cur.index, 1 );
    cur.next( ch ); chk.equal( ch, 'b' ); chk.equal( cur.index, 2 );
    cur.next( ch ); chk.equal( ch, 'c' ); chk.equal( cur.index, 3 );
    cur.prev( ch ); chk.equal( ch, 'b' ); chk.equal( cur.index, 2 );
    cur.prev( ch ); chk.equal( ch, 'a' ); chk.equal( cur.index, 1 );
  end;

  procedure test_to_end;
  begin
    add_chars;
    cur.to_end;
    chk.equal( cur.value, 'z' );
    chk.equal( cur.index, ls.length );
    chk.equal( cur.index, 6 ); // abcxyz
  end;

  procedure test_inject_next;
  begin
    add_chars;
    cur.reset;
    cur.inject_next( '[' );
    chk.equal( as_string, '[abcxyz' );
    cur.inject_prev( ']' );
    chk.equal( as_string, '[abcxyz]' );
  end;

end.
