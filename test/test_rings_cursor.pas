{$mode delphiunicode}{$i xpc.inc}
{$i test_rings_cursor.def }
implementation uses rings, xpc;

  type charlist = GRing<char>;
  var
    ls	: charlist;
    cur	: IRingCursor<char>;
    ch	: char;
  const chars = 'abcxyz';

  procedure setup;
  begin
    ls := charlist.create;
    cur := ls.MakeCursor
  end; { setup }

  function as_string : string;
  begin
    result := '';
    if ls.IsEmpty then ok
    else for ch in ls do result += ch
  end;

  procedure add_chars;
  begin
    for ch in chars do ls.append( ch )
  end;

  procedure test_as_string;
  begin
    chk.equal( as_string, '' );
    add_chars;
    chk.that( not ls.IsEmpty, 'added chars so should not be empty!');
    chk.equal( 6, ls.length );
    chk.equal( as_string, 'abcxyz' )
  end;


  procedure test_create;
  begin
    chk.that( cur.index = 0, 'cursor should start on the clasp' );
  end;

  procedure test_toTop;
  begin
    add_chars;
    cur.toTop;
    chk.equal( cur.value, 'a' );
  end;

  procedure test_next_and_prev;
  begin
    add_chars;
    cur.toTop;                           chk.equal( cur.index, 1 );
    cur.next( ch ); chk.equal( ch, 'b' ); chk.equal( cur.index, 2 );
    cur.next( ch ); chk.equal( ch, 'c' ); chk.equal( cur.index, 3 );
    cur.prev( ch ); chk.equal( ch, 'b' ); chk.equal( cur.index, 2 );
    cur.prev( ch ); chk.equal( ch, 'a' ); chk.equal( cur.index, 1 );
  end;

  procedure test_toEnd;
  begin
    add_chars;
    cur.toEnd;
    chk.equal( cur.value, 'z' );
    chk.equal( cur.index, ls.length );
    chk.equal( cur.index, 6 ); // abcxyz
  end;

  procedure test_InjectNext;
  begin
    add_chars;
    cur.reset;
    cur.injectNext( '[' );
    chk.equal( as_string, '[abcxyz' );
    cur.injectPrev( ']' );
    chk.equal( as_string, '[abcxyz]' );
  end;

end.
