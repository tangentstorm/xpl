{$mode delphi}
{$i test_rings.def }
implementation uses rings;

var
  ints : GRing<Int32>;
  elem : GElement<Int32>;
  cur  : IRingCursor<Int32>;

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

    ints.free;
  end;

procedure test_cursor;
  begin
    ints := GRing<Int32>.Create;
    ints.append(0);
    cur  := ints.MakeCursor;
    cur.ToTop;
    chk.that(cur.AtTop, 'cursor should be AtTop after ToTop');
    ints.free;
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
    ints.free;
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
    elem.Free;
    ints.Free;
  end;

end.
