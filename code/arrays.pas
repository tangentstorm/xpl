{$mode delphi}{$i xpc.inc}
unit arrays;
interface uses xpc, sq;

type
  IArray<T> = interface ( ISequence<T> )
    function _GetLength : cardinal;
    procedure _SetLength( len : cardinal );
    function Append( item : T ) : cardinal;
    function Extend( items : array of T ) : cardinal; overload;
    function Extend( items : IArray<T> ) : cardinal; overload;
    procedure Fill( item : T );
    property length : cardinal read _GetLength write _SetLength;
    function GetEnumerator : IEnumerator<T>;
  end;

  GArray<T> = class ( GSeq<T>, IArray<T> )
    _items : array of T;
    _count : cardinal;
    _growby : cardinal;
  public { IArray }
    constructor Create( growBy : cardinal = 16 ); overload;
    constructor Create( items : array of T ); overload;
    constructor Create( newCount : cardinal; fillWith:T ); overload;
    function Grow : cardinal;
    function Append( item : T ) : cardinal;
    function Extend( items : array of T ) : cardinal; overload;
    function Extend( items : IArray<T> ) : cardinal; overload;
    procedure Fill( item : T );
  public { ISeq }
    function _GetLength : cardinal; override;
    procedure _SetLength( len : cardinal ); override;
    procedure SetItem( i : cardinal; const item : T ); override;
    function GetItem( i : cardinal ) : T; override; overload;
    function GetItem( i : cardinal; default : T) : T; overload;
    property at[ i : cardinal ]: T read GetItem write SetItem; default;
    property length : cardinal read _GetLength write _SetLength;
    function GetEnumerator : IEnumerator<T>;
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
    if _growBy > 0 then SetLength( _items, _growBy )
    else throw('GArray.growBy must be > 0')
  end;

constructor GArray<T>.Create( items : array of T );
  begin self.Create(16); self.Extend(items);
  end;

constructor GArray<T>.Create( newCount : cardinal; fillWith:T );
  begin self.Create; self.Length:=newCount; self.Fill(fillWith);
  end;


function GArray<T>.Grow : cardinal;
  begin
    result := _count; inc(_count);
    if _count >= system.Length( _items )
    then SetLength( _items, result + _growBy )
  end;

function GArray<T>.Append( item : T ) : cardinal;
  begin result := self.Grow; _items[ result ] := item;
  end;

function GArray<T>.Extend( items : array of T ) : cardinal;
  var item : T;
  begin for item in items do result := self.append(item);
  end;

function GArray<T>.Extend( items : IArray<T> ) : cardinal;
  var item : T;
  begin for item in items do result := self.append(item);
  end;

procedure GArray<T>.Fill( item : T);
  var i : cardinal;
  begin for i := 0 to length-1 do _items[ i ] := item
  end;

{ iseq interface }
function GArray<T>._GetLength : cardinal;
  begin
    result := _count
  end;

procedure GArray<T>._SetLength( len : cardinal );
  begin
    _count := len;
    SetLength( _items, _count );
  end;

procedure GArray<T>.SetItem( i : cardinal; const item : T );
  begin
    if i < _count then _items[ i ] := item
    else throw('array index out of bounds')
  end;

function GArray<T>.GetItem( i : cardinal ) : T;
  begin
    if i < _count then result := _items[ i ]
    else throw('array index out of bounds: %d[%d]', [_count, i])
  end;

function GArray<T>.GetItem( i : cardinal; default : T ) : T;
  begin
    if i < _count then result := _items[ i ]
    else result := default
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

function GArray<T>.GetEnumerator : IEnumerator<T>;
  begin result := GSeq<T>(self).GetEnumerator;
  end;

end.
