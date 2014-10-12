{$mode delphiunicode}{$i xpc.inc}{$i test_ucomb.def}
implementation uses ucomb;

var cc : TComboCursor;

procedure test_limit;
  var count : cardinal;
  begin
    cc := TComboCursor.Create(52, 5); // 5 card poker hands
    chk.equal( cc.limit, 2598960 );
  end;

end.
