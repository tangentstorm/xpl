{$mode delphi}
{$i test_rings.def }
implementation uses xpc, rings;

var
  ints : GRing<Int32>;
  elem : GElement<Int32>;
  cur  : IRingCursor<Int32>;
  strs : GRing<TStr>;
  a, b, c : TStr;

procedure setup;
  begin
//TODO:    if assigned(ints) then ints.free;
    if assigned(strs) then strs.free;
    a := 'a'; b := 'b'; c := 'c';
  end;

procedure test_init;
  begin
    ints := GRing<Int32>.Create;
    chk.that( ints.IsEmpty, 'new list should be empty' );
    chk.equal( ints.Length, 0, 'new list should have length 0' );
    try ints.first; chk.fail('.first should throw exception for empty list' )
    except ok end;
    try ints.first; chk.fail('.last should throw exception for empty list' )
    except ok end;
  end;
  
procedure test_basics;
  begin
    ints := GRing<Int32>.Create;
    chk.equal(0, ints.length);

    ints.append(456);
    chk.equal(1, ints.length);
    chk.equal(456, ints[0]);

    ints.insert(123);
    chk.equal(2, ints.length);
    chk.equal(123, ints[0]);
    chk.equal(456, ints[1]);
  end;


procedure test_append;
  begin
    strs := GRing<TStr>.Create;
    strs.append( a );
    chk.that( strs.first = a, 'append to empty should set first' );
    chk.that( strs.last = a, 'append to empty should set last' );
    strs.append( b );
    chk.that( strs.first = a, 'append shouldn not change .first ' );
    chk.that( strs.last = b, 'append should change .last' );
  end;

  
procedure test_cursor;
  begin
    ints := GRing<Int32>.Create;
    ints.append(0);
    cur  := ints.MakeCursor;
    cur.ToTop;
    chk.that(cur.AtTop, 'cursor should be AtTop after ToTop');
  end;

procedure test_DeleteAt;
  begin
    ints := GRing<Int32>.Create;
    ints.Append(100);
    ints.Append(101);
    ints.Append(102);
    chk.equal(100, ints[0]);
    chk.equal(101, ints[1]);
    chk.equal(102, ints[2]);
    ints.DeleteAt(0);
    chk.equal(101, ints[0]);
    chk.equal(102, ints[1]);
    ints.DeleteAt(1);
    chk.equal(101, ints[0]);
    ints.DeleteAt(0);
    chk.equal(0, ints.length);
  end;

procedure test_elements;
  var i : Int32;
  begin
    elem := GElement<Int32>.Create('negs');
    ints := elem as GRing<Int32>;
    elem['about'] := 'some negative numbers';
    elem['max'] := -1;
    elem['min'] := -10;
    for i := elem.attrs['max'] downto elem.attrs['min'] do elem.Append(i);
    chk.equal(ints[0], -1);    chk.equal(elem.items[0], -1);
    chk.equal(ints[9], -10);   chk.equal(elem.items[9], -10);
    ints := GRing<Int32>.Create;
    ints.Append(elem);
    elem.Append(ints);
    elem.Append(elem);
    //  TODO: pretty sure there's a memory leak here.
    // The fix would be to add a proper destructor to TRing.
    elem.Free;
  end;

end.
