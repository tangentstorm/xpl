{$mode delphiunicode}{$i xpc.inc}{$i test_ucomb.def}
implementation uses ucomb;

var cc : TComboCursor;

procedure setup;
  begin
    if assigned(cc) then cc.Free;
    cc := TComboCursor.Create(52, 5); // 5 card poker hands
  end;

procedure test_basics;
  begin
    chk.equal( cc.limit, 2598960 );
    chk.equal( cc.length, 5 );
    chk.equal( cc.bases[ 0 ], 48 ); chk.equal( cc.digit[ 0 ], 0 );
    chk.equal( cc.bases[ 1 ], 49 ); chk.equal( cc.digit[ 1 ], 0 );
    chk.equal( cc.bases[ 2 ], 50 ); chk.equal( cc.digit[ 2 ], 0 );
    chk.equal( cc.bases[ 3 ], 51 ); chk.equal( cc.digit[ 3 ], 0 );
    chk.equal( cc.bases[ 4 ], 52 ); chk.equal( cc.digit[ 4 ], 0 );
  end;

procedure test_counting;
  begin
    chk.equal( cc.value, 0 );
    chk.equal( cc.digit[ 4 ], 0 );
    cc.MoveNext;
    chk.equal( cc.value, 1 );
    chk.equal( cc.digit[ 4 ], 1 );
  end;

procedure test_count;
  var i :integer;
  begin
    chk.equal( cc.ToStr, 'TComboCursor(52,5):[ 0 0 0 0 0 ]' );
    cc.MoveNext;
    chk.equal( cc.ToStr, 'TComboCursor(52,5):[ 0 0 0 0 1 ]' );
    for i := 2 to 51 do cc.MoveNext;
    chk.equal( cc.ToStr, 'TComboCursor(52,5):[ 0 0 0 0 51 ]' );
    cc.MoveNext;
    chk.equal( cc.ToStr, 'TComboCursor(52,5):[ 0 0 0 1 0 ]' );
    cc.MoveNext;
    chk.equal( cc.ToStr, 'TComboCursor(52,5):[ 0 0 0 1 1 ]' );
    for i := 2 to 52 do cc.MoveNext;
    chk.equal( cc.ToStr, 'TComboCursor(52,5):[ 0 0 0 2 0 ]' );
  end;

finalization
  if assigned(cc) then cc.Free;
end.
