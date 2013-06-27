
{$mode delphi}
unit sets;
interface uses rb;
  type ISet<T> = interface
    { stateful operations }
    procedure include( val : T );
    procedure exclude( val : T );
    { predicates, comparisons, and queries }
    function contains( val : T ): boolean;
    function isSubsetOf( other : ISet<T> ): boolean;
    function isSupersetOf( other : ISet<T> ): boolean;
    function isEqualTo( other : ISet<T> ): boolean;
    function count : cardinal;
    { algebraic operations }
    function copy : ISet<T>;
    function withval( val : T ) : ISet<T>;
    function without( val : T ) : ISet<T>;
    function union( other : ISet<T> ): ISet<T>;
    function intersect( other : ISet<t> ): ISet<T>;
    function difference( other : ISet<t> ): Iset<T>;
    function symdiff( other : ISet<t> ): Iset<T>;
  end;
  type GSet<t> = class // ( TInterfacedObject, ISet<T> )
  private
    type TRBTree = TRBMap<T,byte>;
  private
    _tree : TRBTree;
  public
    constructor Create;
    destructor Destroy; override;
    { stateful operations }
    procedure include( val : T ); virtual;
    procedure exclude( val : T ); virtual;
    { predicates, comparisons, and queries }
    function contains( val : T ): boolean; virtual;
    // function isSubsetOf( other : ISet<T> ): boolean;virtual;
    // function isSupersetOf( other : ISet<T> ): boolean;virtual;
    { algebraic operations }
    // function copy : ISet<T>;
    // function withval( val : T ) : ISet<T>;virtual;
    // function without( val : T ) : ISet<T>;virtual;
    // function union( other : ISet<T> ): ISet<T>;virtual;
    // function intersect( other : ISet<t> ): ISet<T>;virtual;
    // function difference( other : ISet<t> ): Iset<T>;virtual;
    // function symdiff( other : ISet<t> ): Iset<T>;virtual;
  end;
implementation

  constructor GSet<t>.Create;
  begin
    inherited;
    _tree := TRBTree.Create;
  end;

  destructor GSet<T>.Destroy;
  begin
    _tree.Free;
  end;


  procedure GSet<T>.include( val : T );
  begin
  end;

  procedure GSet<T>.exclude( val : T );
  begin
  end;

  function GSet<T>.contains( val : T ) : boolean;
  begin
  end;

end.
