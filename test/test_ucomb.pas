{$mode delphiunicode}{$i xpc.inc}{$i test_ucomb.def}
implementation uses ucomb;

var cc : TComboCursor;

procedure test_basics;
  var count : cardinal;
  begin
    cc := TComboCursor.Create(52, 5); // 5 card poker hands
    chk.equal( cc.limit, 2598960 );
    chk.equal( cc.length, 5 );
    chk.equal( cc.bases[ 0 ], 52 );
    chk.equal( cc.bases[ 1 ], 51 );
    chk.equal( cc.bases[ 2 ], 50 );
    chk.equal( cc.bases[ 3 ], 49 );
    chk.equal( cc.bases[ 4 ], 48 );
  end;

end.
