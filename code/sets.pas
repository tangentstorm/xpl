{$mode delphi}
unit sets;
interface

type
  ISet<t> = interface
    procedure include( val : T );
{    function contains( val : T ): boolean;
    function isSubsetOf( other : ISet<T> ): boolean;
    function isSupersetOf( other : ISet<T> ): boolean;
    function withval( val : T ) : ISet<T>;
    function without( val : T ) : ISet<T>;
    function union( other : ISet<T> ): ISet<T>;
    function intersect( other : ISet<t> ): ISet<T>;
    function difference( other : ISet<t> ): Iset<T>;
}
  end;
  
  TSet<t> = class( TInterfacedObject, ISet<T> )
    constructor Create;
    destructor Destroy; override;

    procedure include( val : T ); virtual;
    procedure remove( val : T ); virtual;
{    function contains( val : T ): boolean; virtual;
    function withval( val : T ) : ISet<T>;virtual; abstract;
    function without( val : T ) : ISet<T>;virtual; abstract;
    function isSubsetOf( other : ISet<T> ): boolean;virtual; abstract;
    function isSupersetOf( other : ISet<T> ): boolean;virtual; abstract;
    function union( other : ISet<T> ): ISet<T>;virtual; abstract;
    function intersect( other : ISet<t> ): ISet<T>;virtual; abstract;
    function difference( other : ISet<t> ): Iset<T>;virtual; abstract;
}
  end;

implementation


  constructor TSet<t>.Create;
  begin
    inherited
  end;

  destructor TSet<T>.Destroy;
  begin
    
  end;
  
  procedure TSet<T>.include( val : T );
  begin
  end;

  procedure TSet<T>.remove( val : T );
  begin
  end;

end.
