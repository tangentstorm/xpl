{$mode delphi}
unit build.dom;
interface uses dom, build;

type
  IDomBuilder = interface( IBuilder<TDOMNode> )
  end;
  TDomBuilder = class( TInterfacedObject, IDomBuilder )
    _last ,
    _root : TDomNode;
    constructor Create;
    function GetRoot : TDomNode;
    function GetLast : TDomNode;
    procedure Append( item : TDomNode );
    procedure Branch( item : TDomNode );
    procedure Return;
  end;

implementation

  constructor TDomBuilder.Create;
  begin
  end;

  function TDomBuilder.GetRoot : TDomNode;
  begin
    result := _root;
  end;

  function TDomBuilder.GetLast : TDomNode;
  begin
    result := _last;
  end;

  procedure TDomBuilder.Append( item : TDomNode );
  begin
  end;

  procedure TDomBuilder.Branch( item : TDomNode );
  begin
  end;

  procedure TDomBuilder.Return;
  begin
  end;

end.
