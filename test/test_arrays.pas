{$mode delphi}
{$i test_arrays.def }
implementation uses arrays, sysutils;

type TInt32Array = GArray<Int32>;
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

procedure test_find;
  var i : cardinal;
  begin
    ints.append( 55 );
    ints.append( 22 );
    chk.that(not ints.find( 33, i ), '33 isn''t in the list.');
    ints.append( 33 );
    chk.that(ints.find( 33, i ), 'should have found 33');
    chk.equal( i, 2 );
  end;

end.
