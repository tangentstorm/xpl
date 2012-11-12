{$i test_ll.def }
implementation uses ll, sysutils;

  var
    ls	 : list;
    a, b : node;

  procedure setup;
  begin
    ls := list.init;
  end;

  procedure test_init;
  begin
    if ls.first <> nil then
      raise Exception.create( 'expected first = nil' );
    if ls.last <> nil then
      raise Exception.create( 'expected last = nil' );
  end;

  procedure test_append;
  begin
    ls.append( a ); ls.append( b );
    chk.that( ls.first = b );
  end;

end.
