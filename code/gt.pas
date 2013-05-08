{$mode delphi}
unit gt; { graph theory }
interface uses arrays, sysutils;

type
  TNid	     =  cardinal; { node id }
  TNidArray  = GArray<TNid>;

  { ISimpleGraph is for graphs without labels. }
  ISimpleGraph = interface
    function Node : cardinal;
    function Edge( a, b : cardinal ) : cardinal;
    function Incoming( nid : cardinal ) : TNidArray;
    function Outgoing( nid : cardinal ) : TNidArray;
    function GetNodeCount : cardinal;
    function GetEdgeCount : cardinal;
    property nodeCount : cardinal read GetNodeCount;
    property edgeCount : cardinal read GetEdgeCount;
  end;

  { IGraph lets you associate arbitrary objects with each node/edge }
  IGraph<nodeT, edgeT> = interface( ISimpleGraph )
    function GetNode( nid : cardinal ) : nodeT;
    function GetEdge( eid : cardinal ) : edgeT;
    property nodes[ nid : cardinal ] : nodeT read GetNode;
    property edges[ eid : cardinal ] : edgeT read GetEdge;
  end;

  TGraphData = class ( TInterfacedObject, ISimpleGraph )
  private
    type TEdgeArray = GArray<TNidArray>;
    { !! TEdgeArray is nested because there's one array per node. }
  private
    _nodeCount : cardinal;
    _edgeCount : cardinal;
    _incoming : TEdgeArray;
    _outgoing : TEdgeArray;
  public
    constructor Create;
  public { IGraph }
    function Node : cardinal;
    function Edge( a, b : cardinal ) : cardinal;
    function GetNodeCount : cardinal;
    function GetEdgeCount : cardinal;
    function Incoming( nid : cardinal ) : TNidArray;
    function Outgoing( nid : cardinal ) : TNidArray;
  public
    function TopSort : TNidArray;
  end;

implementation

  constructor TGraphData.Create;
  begin
    _nodeCount := 0;
    _incoming := TEdgeArray.Create( 0 );
    _outgoing := TEdgeArray.Create( 0 );
  end;

  function TGraphData.Node : cardinal;
  begin
    result := _nodeCount;
    inc( _nodeCount );
    _incoming.Append( TNidArray.Create( 0 ));
    _outgoing.Append( TNidArray.Create( 0 ));
  end;

  function TGraphData.Edge( a, b : cardinal ) : cardinal;
    var c : cardinal;
  begin
    for c in [ a, b ] do if c >= _nodeCount then
      raise Exception.Create( 'invalid node: ' + IntToStr( a ));
    result := _edgeCount;
    inc( _edgeCount );
  end;


  function TGraphData.GetNodeCount : cardinal;
  begin
    result := _nodeCount;
  end;

  function TGraphData.GetEdgeCount : cardinal;
  begin
    result := _edgeCount;
  end;

  { TODO : Incoming and Outgoing should make copies... }

  function TGraphData.Incoming( nid : cardinal ) : TNidArray;
  begin
    result := _incoming[ nid ];
  end;

  function TGraphData.Outgoing( nid : cardinal ) : TNidArray;
  begin
    result := _outgoing[ nid ];
  end;


  function TGraphData.TopSort : TNidArray;
    var
      marked : array of boolean;
      node   : cardinal = 0;
      slot   : cardinal = 0;

    function find_unmarked : boolean;
    begin
      result := false;
      repeat
	result := ( node < length( marked )) and not marked[ node ];
	inc( node );
      until result or ( node = length( marked ));
    end; { find_unmarked }

    procedure visit( n : cardinal );
      var m : cardinal;
    begin
      if marked[ n ] then raise Exception.Create( 'Not a DAG' )
      else begin
	marked[ n ] := true;
	for m in _incoming[ n ] do visit( m );
	result[ slot ] := n;
	inc( slot );
      end
    end; { visit }

  begin { TopSort }
    { based on Tarjan's algorithm, as described here:
      http://en.wikipedia.org/wiki/Topological_sorting }
    SetLength( marked, _nodeCount );
    result := TNidArray.Create( _nodeCount );
    for node := 0 to _nodeCount - 1 do marked[ node ] := false;
    node := 0;
    while find_unmarked do visit( node );
  end; { TopSort }

end.
