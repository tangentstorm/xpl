{$i test_ll_cur.def }
implementation uses ll, li, xpc;

  var
    ls	 : stringlist;
    cur  : stringlist.cursor;

  procedure setup;
    var ch : char;
  begin
    ls := stringlist.create;
    for ch := 'a' to 'z' do ls.append( ch );
    cur := ls.make_cursor
  end;

  procedure test_cursor;
  begin
    cur.to_top; chk.equal( cur.value, 'a' );
    cur.to_end; chk.equal( cur.value, 'z' );
  end;

end.
