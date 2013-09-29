{$mode delphi}
{$i test_rings.def }
implementation uses rings;

var
  ints : GRing<UInt32>;
  cur : IRingCursor<UInt32>;

procedure test_basics;
  begin
    ints := GRing<UInt32>.Create;
    chk.equal(0, ints.length);
    
    ints.append(456);
    chk.equal(1, ints.length);
    chk.equal(456, ints[0]);
    
    ints.insert(123);
    chk.equal(2, ints.length);
    chk.equal(123, ints[0]);
    chk.equal(456, ints[1]);
  end;

procedure test_cursor;
  begin
    ints := GRing<UInt32>.Create;
    ints.append(0);
    cur  := ints.MakeCursor;
    cur.ToTop;
    chk.that(cur.AtTop, 'cursor should be AtTop after ToTop');
  end;

  procedure test_DeleteAt;
  begin
    ints := GRing<UInt32>.Create;
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

end.
