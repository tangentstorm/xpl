{$mode delphi}{$i xpc.inc}
unit arrays;
interface uses sq, sysutils;

type
  IArray<T> = interface ( ISequence<T, cardinal> )
    function GetLength : cardinal;
    procedure SetLength( len : cardinal );
    property length : cardinal read GetLength write SetLength;
  end;

  GArray<T> = class ( GSeq<T, cardinal>, IArray<T> )
    _items : array of T;
    _count : cardinal;
    _growby : cardinal;
  public
    constructor Create( growBy : cardinal = 16 );
    function Grow : cardinal;
    function Append( item : T ) : cardinal;
  public { IArray }
    function GetLength : cardinal; override;
    procedure SetLength( len : cardinal ); override;
    procedure SetItem( i : cardinal; const item : T ); override;
    function GetItem( i : cardinal ) : T; override;
    property at[ i : cardinal ]: T read GetItem write SetItem; default;
    property length : cardinal read GetLength write SetLength;
  end;

  // Find uses an equality check, so it only works on types where
  // the = operator is overloaded.
  GEqArray<T> = class( GArray<T> )
    function Find( item : T; out i : cardinal ) : boolean;
  end;

implementation

constructor GArray<T>.Create( growBy : cardinal = 16 );
  begin
    _count := 0;
    _growBy := growBy;
    if _growBy > 0 then system.SetLength( _items, _growBy )
    else raise Exception.Create('GArray.growBy must be > 0')
  end;

function GArray<T>.Grow : cardinal;
  begin
    result := _count; inc(_count);
    if _count >= system.Length( _items )
      then system.SetLength( _items, result + _growBy )
  end;

function GArray<T>.Append( item : T ) : cardinal;
  begin
    result := self.Grow;
    _items[ result ] := item;
  end;

function GArray<T>.GetLength : cardinal;
  begin
    result := _count
  end;

procedure GArray<T>.SetLength( len : cardinal );
  begin
    _count := len;
    system.SetLength( _items, _count );
  end;

procedure GArray<T>.SetItem( i : cardinal; const item : T );
  begin
    if i < _count then _items[ i ] := item
    else raise Exception.Create('array index out of bounds')
  end;

function GArray<T>.GetItem( i : cardinal ) : T;
  begin
    if i < _count then result := _items[ i ]
    else raise Exception.Create('array index out of bounds')
  end;

function GEqArray<T>.Find( item : T; out i : cardinal ) : boolean;
  begin
    i := self.length;
    if i = 0 then result := false
    else
      repeat
	dec( i ); result := item = _items[ i ]
      until result or (i = 0);
  end;

end.
