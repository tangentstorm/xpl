{$i xpc.inc}
unit arrays;
interface uses sq;

type
  generic IArray<T> = interface ( specialize ISequence<T, cardinal> )
  end;

  generic GArray<T> = class ( specialize GSeq<T, cardinal>, specialize IArray<T> )
    _items : array of T; 
    constructor Create( sizeHint : cardinal = 16 );
    function Grow : cardinal;
    procedure Append( value : T );
  public { IArray }
    function Length : cardinal; override;
    procedure SetItem( i : cardinal; const value : T ); override;
    function GetItem( i : cardinal ) : T; override;
    property at[ i : cardinal ]: T read GetItem write SetItem; default;
  end;

implementation

  constructor GArray.Create( sizeHint : cardinal );
  begin
    SetLength( _items, sizeHint );
  end;
  
  function GArray.Grow : cardinal;
  begin
    result := self.Length;
    SetLength( _items, result + 1 );
  end;
  
  procedure GArray.Append( value : T );
  begin
    _items[ self.Grow ] := value;
  end;
 
  function GArray.Length : cardinal;
  begin
    result := system.Length( _items );
  end;

  procedure GArray.SetItem( i : cardinal; const value : T );
  begin
    _items[ i ] := value
  end;
  
  function GArray.GetItem( i : cardinal ) : T;
  begin
    result := _items[ i ];
  end;

end.