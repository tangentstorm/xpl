{$mode delphi}
{$i test_arrays.def }
implementation uses arrays, sysutils, cw;

type TInt32Array = GEqArray<Int32>;
var ints : TInt32Array;

procedure setup;
  begin
    if Assigned(ints) then FreeAndNil(ints);
    ints := TInt32Array.Create;
  end;

procedure test_append;
  begin
    chk.equal( 0, ints.length );
    chk.equal( 0, ints.append( 12345 ));
    chk.equal( 1, ints.length );
    chk.equal( 1, ints.append( 23456 ));
  end;

procedure test_new;
  begin
    ints.free; ints := TInt32Array.Create([0,1,2]);
    chk.equal(3, ints.length);
    chk.equal(0, ints[0]);
    chk.equal(1, ints[1]);
    chk.equal(2, ints[2]);
  end;

procedure test_find;
  var i : cardinal;
  begin
    chk.that(not ints.Find( 33, i ), 'nothing should be in empty list.');
    ints.append( 55 );
    ints.append( 22 );
    chk.that(not ints.Find( 33, i ), '33 isn''t in the list.');
    ints.append( 33 );
    chk.that(ints.Find( 33, i ), 'should have found 33');
    chk.equal( i, 2 );
  end;

procedure test_forloop;
  var count : Int32 = 0; i, j : cardinal;
  begin
    ints.append( 123 );
    ints.append( 456 );
    for i in ints do inc(count);
    chk.equal(count, 2);

    { regression test: what about looping twice? }
    for j in ints do inc(count);
    chk.equal(count, 4);
  end;

end.
