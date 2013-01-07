{$i test_ui_zinput.def }
implementation uses xpc, ui;

  var inp : ui.zinput;

  procedure setup;
  begin
    inp := ui.zinput.create;
  end;

  procedure test_create;
  begin
    chk.equal( inp.value, '' );
    chk.equal( inp.cpos, 0 );
  end;

  procedure test_insert;
  begin
    chk.equal( inp.cpos, 0 );
    inp.insert( 'a' );
    chk.equal( inp.cpos, 1 );
    chk.equal( inp.value, 'a' );
    inp.insert( 'b' );
    chk.equal( inp.cpos, 2 );
    chk.equal( inp.value, 'ab' );
  end;

end.
