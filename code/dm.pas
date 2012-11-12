unit dm; { doc model }
interface uses seq;

  (* DocSeq is a Seq for dom nodes. *)
  type DocSeq  = class
    constructor DocSeq.create(doc);
    function DocSeq.iter: pNode;
    function DocSeq.first: pNode;
    function DocSeq.first: pNode;
    function DocSeq.final: pNode;
    function DocSeq.after ( item : pNode ): pNode;
    function DocSeq.offset ( item : pNode, k : integer ): pNode;
    function DocSeq.keyed ( index : pNode ): pNode;
  end;

implementation

  constructor DocSeq.create(doc)
  begin
    self.doc = doc # TODO check.type(dom.Node)
  end;

  function DocSeq.iter: pNode;
  begin
    self.doc.flatten
  end;

  function DocSeq.first: pNode;
  begin
    self.doc
  end;

  function DocSeq.final: pNode;
  begin
    node = self.first;
    while node.children <> nil do
      node = node.children[node.children.length];
    result := node
  end;

  function DocSeq.after: (item): pNode;
  begin
    check.valued( item, parent, "can't find after(#{item}), as it has no parent" );
    siblings = item.parent.children;
    index = siblings.ix(item);
    if index < siblings.length - 1 then
      result := siblings[ index + 1 ]
    else
      result := self.after( item.parent )
  end;

  function DocSeq.offset: (item, k): pNode;
  begin
    { TODO: why not allow negative offsets?
      this used to be "ahead_of" for lookahead, but why limit it? }
    check.that(k > 0, "negative offsets not (yet) implemented for nodes");
    result := item;
    for x in range(k) do result = self.after(result);
  end;

  function DocSeq.keyed: (index): pNode;
  begin
    result := self.doc.getElementById(index)
  end;

begin
end.
