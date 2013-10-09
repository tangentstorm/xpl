{$i test_dicts.def }
implementation uses dicts;

var
  dict : TIntDict;

procedure setup;
  begin
    if Assigned(dict) then dict.Free;
    dict := TIntDict.Create;
    dict[ 'ten' ] := 10;
    dict[ '$ff' ] := $ff;
    dict[ 'negative one' ] := -1;
    dict[ 'x' ] := 1;
  end;

procedure test_basics;
  begin
    chk.equal(  10, dict['ten']);
    chk.equal( $ff, dict['$ff']);
    chk.equal(  -1, dict['negative one']);
    chk.equal(   1, dict['x' ]);
  end;
  
procedure test_reassign;
  begin
    chk.equal( 1, dict[ 'x' ]);
    dict[ 'x' ] := 2;
    chk.equal( 2, dict[ 'x' ]);
    dict[ 'x' ] := 1;
    dict[ 'X' ] := 7; // make sure we ignore unrelated keys
    chk.equal( 1, dict[ 'x' ]);
  end;

procedure test_Get;
  begin
    chk.equal( 1, dict.Get( 'x', 0));
    chk.equal( 0, dict.Get( 'y', 0));
  end;

procedure test_HasKey;
  begin
    chk.that( dict.HasKey( 'x' ), 'dict should have "x" as a  key!');
    chk.that( not dict.HasKey( 'X' ), 'dict should not have "X" as a  key!');
    chk.that( not dict.HasKey( 'y' ), 'dict should not have "y" as a key!');
  end;

procedure test_setdefault;
  begin
    chk.equal( 0, dict.setdefault( 'y', 0 ));
    chk.equal( 0, dict.setdefault( 'y', 2 ));
    chk.equal( 2, dict.setdefault( 'z', 2 ));
    chk.equal( 2, dict.setdefault( 'z', 0 ));
  end;

end.
