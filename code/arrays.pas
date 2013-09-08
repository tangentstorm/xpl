{$mode delphi}{$i xpc.inc}
unit arrays;
interface uses sq, sysutils;

type
  IArray<T> = interface ( ISequence<T, cardinal> )
  end;

  GArray<T> = class ( GSeq<T, cardinal>, IArray<T> )
    _items : array of T;
    _count : cardinal;
    _growby : cardinal;
  public
    constructor Create( growBy : cardinal = 16 );
    function Grow : cardinal;
    procedure Append( item : T );
    function Find( item : T; out i : cardinal ) : boolean;
  public { IArray }
    function Length : cardinal; override;
    procedure SetItem( i : cardinal; const item : T ); override;
    function GetItem( i : cardinal ) : T; override;
    property at[ i : cardinal ]: T read GetItem write SetItem; default;
  end;

implementation

constructor GArray<T>.Create( growBy : cardinal = 16 );
  begin
    _count := 0;
    _growBy := growBy;
    if _growBy > 0 then SetLength( _items, _growBy )
    else raise Exception.Create('GArray.growBy must be > 0')
  end;

function GArray<T>.Grow : cardinal;
  begin
    result := _count; inc(_count);
    if _count >= system.Length( _items )
      then SetLength( _items, result + _growBy )
  end;

procedure GArray<T>.Append( item : T );
  begin
    _items[ self.Grow ] := item;
  end;

function GArray<T>.Length : cardinal;
  begin
    result := _count
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

function GArray<T>.Find( item : T; out i : cardinal ) : boolean;
  begin
    i := self.length;
    repeat
      dec( i ); result := item = _items[ i ]
    until result or (i = 0);
  end;

end.
