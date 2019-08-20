// unda : n-dimensional, rectangular arrays
{$mode delphiunicode}{$i xpc.inc}
unit unda;
interface uses xpc;

type
  TBit	      = boolean;
  TInt	      = integer;
  TNat	      = cardinal;
  TInts	      = array of TInt;

  ICellRef<T> = interface
    procedure SetIdx( aIdx : TInt );
    function  GetIdx : TInt;
    function  AtEnd : TBit;
    function  Value : T;
    property idx : TInt read GetIdx write SetIdx;
  end;

  INDArray<T> = interface
    procedure SetAtIdx( i : TInt; aValue : T );
    function  GetAtIdx( i : TInt ) : T;
    function  CellRef( i : TInt ) : ICellRef<T>;
    function GetRank : TInt;
    function GetCount : TInt;
    function GetShape : TInts;
    property Rank  : TInt read GetRank;
    property Count : TInt read GetCount;
    property Shape : TInts read GetShape;
  end;

  GNDA<T> = class
    class function new(fill : T; aShape : array of TInt) : INDArray<T>;
  end;


{ I wish i didn't have to expose these next ones, but there doesn't seem
  to be any other way to implement GNDA<T> at the moment.

  http://bugs.freepascal.org/view.php?id=24064
}


{ CellRef provides an interface to a single cell in a particular
  Orthotope. CellRefs are used as the loop variable when iterating through
  an Orthotope, so that explicit nested loops are not required. }

  _TNDArray<T> = class (TInterfacedObject, INDArray<T>)
   protected
     _rank, _count   : TInt;
     _shape, _stride : TInts;
     _data : array of T;
   public type
     INDCellRef = ICellRef<T>;
     TNDCellIter = class (TInterfacedObject {,IEnumerator<INDCellRef>})
       private
         _cur : ICellRef<T>;
       public
         constructor Create( a : INDArray<T> );
         procedure Reset;
         function GetCurrent: ICellRef<T>;
         function MoveNext: Boolean;
         property Current: ICellRef<T> read GetCurrent;
       end;
   public
     constructor Create(value : T; aShape : array of TInt);
     procedure SetAtIdx( i : TInt; aValue : T );
     function  GetAtIdx( i : TInt ) : T;
     function  CellRef( i : TInt ) : ICellRef<T>;
     function GetEnumerator : TNDCellIter;
     function GetRank : TInt;
     function GetCount : TInt;
     function GetShape : TInts;
     property Rank  : TInt read GetRank;
     property Count : TInt read GetCount;
     property Shape : TInts read GetShape;
   end;


  _TCellRef<T> = class (TInterfacedObject, ICellRef<T>)
    private
      _idx : TInt;
      _path : TInts;
      _prev : TInts;
      _nda : INDArray<T>;
      procedure _rebuildPath;
      function _tnda : _TNDArray<T>;
    public
      constructor Create(aNDA : INDArray<T>; aIdx : TInt);
      procedure SetIdx(value : TInt);
      function GetIdx : TInt;
      function GetPath : TInts;
      function Changed( axis : TNat ) : TBit;
      function GetX : TInt;
      function GetY : TInt;
      function GetZ : TInt;
      function AtEnd: TBit;
      function Value: T;
      property Idx : TInt read GetIdx write SetIdx;
    end;


implementation

{ CellRef }

constructor _TCellRef<T>.Create(aNDA : INDArray<T>; aIdx : TInt);
  begin _idx := aIdx; _nda := aNDA
  end;

function _TCellRef<T>.GetIdx : TInt;
  begin result := _idx
  end;

procedure _TCellRef<T>.SetIdx(value : TInt);
  begin
    _idx := value;
    _prev  := _path;
    _rebuildPath();
  end;

function _TCellRef<T>._tnda : _TNDArray<T>;
  begin result := _nda as _TNDArray<T>;
  end;

procedure _TCellRef<T>._rebuildPath;
  var tmp, i : TInt;
  begin
    tmp := _idx;
    for i := 0 to _tnda._rank - 1 do
      begin
	_path[i] := tmp div _tnda._stride[i];
	tmp := tmp mod _tnda._stride[i];
      end;
  end;


function _TCellRef<T>.GetPath : TInts;
  begin result :=  _path;
  end;

function _TCellRef<T>.Changed( axis : TNat ) : TBit;
  begin result :=  _path[_nda.rank] = _prev[_nda.rank];
  end;

function _TCellRef<T>.GetX : TInt; begin result := _path[_nda.rank-1] end;
function _TCellRef<T>.GetY : TInt; begin result := _path[_nda.rank-2] end;
function _TCellRef<T>.GetZ : TInt; begin result := _path[_nda.rank-3] end;
function _TCellRef<T>.AtEnd: TBit; begin result := _idx + 1 >= _nda.count end;
function _TCellRef<T>.Value: T; begin result := _nda.GetAtIdx( _idx ) end;


{_TNDArray stuff}

constructor _TNDArray<T>.Create(value : T; aShape : array of TInt);
  var i : TInt;
  begin
    _shape := G<TInt>.FromOpenArray(aShape);
    _rank  := length(_shape);

    // calculate strides and total count.
    // a stride is simply the distance within the flattened array between two
    // cells that are adjacent on a particular axis. This is equivalent to the
    // count of an individual item in the corresponding rank.
    //
    // For example: the innermost axis (called the x-axis by convention)
    // consists of simple scalars, so the stride is simply 1. In a rank 2 orthotope,
    // we add the y axis, and the stride is equal to the width of one row. For
    // rank 3, we add the z axis, and the stride is equal to the width times the
    // height of the individual rank 2 tables.
    SetLength(_stride, _rank);   // one stride for each axis
    if _rank = 0 then _count := 1
    else begin
      _stride[_rank-1] := 1;   // stride for innermost axis (x) is always 1
      if _rank > 1 then
	for i := _rank - 2 downto 0 do _stride[i] := _stride[i+1] * _shape[i+1];
      // the total cell count would be the stride for the next level up,
      // (if there were one), so we calculate it the exact same way
      _count := _shape[0] * _stride[0];
    end;

    SetLength(_data, _count);
    for i := 0 to _count - 1 do _data[i] := value;
  end; { _TNDArray }


{TNDA stuff}

function _TNDArray<T>.CellRef(i : TInt) : ICellRef<T>;
  begin result := _TCellRef<T>.Create(self, i)
  end;

function _TNDArray<T>.GetAtIdx(i : TInt) : T;
  begin result := _data[i]
  end;

procedure _TNDArray<T>.SetAtIdx(i : TInt; aValue : T );
  begin _data[i] := aValue
  end;

function _TNDArray<T>.GetEnumerator : TNDCellIter;
  begin result := TNDCellIter.Create(self)
  end;

function _TNDArray<T>.GetRank : TInt;
  begin result := _rank
  end;

function _TNDArray<T>.GetCount : TInt;
  begin result := _count
  end;

function _TNDArray<T>.GetShape : TInts;
  begin result := Copy(_shape, 0, Length(_shape));
  end;


{ enumerator }


constructor _TNDArray<T>.TNDCellIter.Create( a : INDArray<T> );
  begin _cur := _TCellRef<T>.Create(a, 0)
  end;

function _TNDArray<T>.TNDCellIter.MoveNext : TBit;
  begin _cur.idx := _cur.idx + 1; result := not _cur.atEnd()
  end;

procedure _TNDArray<T>.TNDCellIter.Reset;
  begin _cur.idx := 0
  end;

function _TNDArray<T>.TNDCellIter.GetCurrent : ICellRef<T>;
  begin result := _cur
  end;


{ generic constructor }

class function GNDA<T>.new(fill : T; aShape : array of TInt) : INDArray<T>;
  begin result := _TNDArray<T>.Create(fill, aShape)
  end;


begin
end.
