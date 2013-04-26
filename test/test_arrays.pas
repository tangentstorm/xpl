{$mode delphi}
{$i test_arrays.def }
implementation uses arrays;

  type TInt32Array = GArray<Int32>;
  var ints : TInt32Array;

  procedure setup;
  begin
    ints := TInt32Array.Create( 32 );
  end;

  procedure test_append;
    const x = 0;
  begin
    chk.equal( 32, ints.length );
    ints.append( x );
    chk.equal( 33, ints.length );
  end;

end.
