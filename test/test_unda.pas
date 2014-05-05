{$mode delphiunicode}{$i xpc.inc}{$i test_unda.def}
implementation uses unda;
	 
var z0, z1, z2, z3, z4 : INDArray<TInt>;

procedure test_scalar;
  begin
    z0 := gnda<TInt>.new(0, []);
    chk.equal(z0.rank, 0);
    chk.equal(z0.count, 1);
    chk.equal(0, length(z0.shape));
  end;

procedure test_vector;
  begin
    z1 := gnda<TInt>.new(0, [10]);
    chk.equal(z1.rank, 1);
    chk.equal(z1.count, 10);
  end;
  
procedure test_matrix;
  begin
    z2 := gnda<TInt>.new(0, [10, 10]);
    chk.equal(z2.rank, 2);
    chk.equal(z2.count, 100);
  end;

procedure test_rank3;
  begin
    z3 := gnda<TInt>.new(0, [10, 10, 10]);
    chk.equal(z3.rank, 3);
    chk.equal(z3.count, 1000);
  end;

procedure test_rank4;
  begin
    z4 := gnda<TInt>.new(0, [10, 10, 10, 10]);
    chk.equal(z4.rank, 4);
    chk.equal(z4.count, 10000);
  end;

  
begin
end.
