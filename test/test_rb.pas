{$i test_rb.def }
implementation uses rb;

  type TRBTree = specialize rb.TRBMap<cardinal,byte>;
  var tree : TRbTree;

  procedure setup;
  begin
    tree := TRBTree.Create;
  end;

end.
