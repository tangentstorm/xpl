{$i test_rb.def }
implementation uses rb;

type TRBTree = rb.TRBMap<cardinal,byte>;
var tree : TRbTree;

procedure test_create;
  begin
    tree := TRBTree.Create;
    tree.free;
  end;


end.
