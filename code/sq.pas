{$mode delphi}{$i xpc.inc}
unit sq;{ sequences }
interface uses xpc, cr, stacks;

  type ISequence<TVal, Tkey> = interface
    function Length : cardinal;
    function GetItem( i : TKey ) : TVal;
    procedure SetItem( i : TKey; const value : TVal );
    property item[ i : TKey ] : TVal read GetItem write SetItem; default;
  end;

  { abstract sequence class.
    the following lines are here only to declare
    that sequences provide a cursor, specialized to the
    same type. :/
  }
  type GSeq<t,idx> =
    class( TInterfacedObject, ISequence<t,idx> )

      // abstract part
      function GetItem( index : idx ) : t; virtual; abstract;
      procedure SetItem( index : idx; const value : t ); virtual; abstract;
      function length : idx; virtual; abstract;
      property item[ ix : idx ] : T
	read GetItem write SetItem; default;

      { --- begin nested type ----------------------------------- }
    type NSeqCursor = class( TInterfacedObject, ICursor<T> )
      private type SSeq = ISequence<T,idx>;
      public
	constructor create( seq : SSeq );

	// reference<t>
	function get_value : t;
        procedure set_value( v : t );
        function is_readable : boolean;        virtual;
        function is_writable : boolean;        virtual;
        property value : t read get_value write set_value;

        // iterator<t>
	function Next( out val : t ) : boolean; overload;
	function Next : t; virtual; overload;

        // enumerator<t>
        procedure Reset;
        function get_index : idx;

        // slider<t>
	function Prev( out val : T ) : boolean; overload;
	function Prev : T; virtual; overload;
        procedure set_index( index : idx );
        property index : idx read get_index write set_index;

        procedure Mark;
        procedure Back;

      public  { for..in loop interface }
        function MoveNext : boolean;
	property Current : T read get_value;

      private
        type idxstack = GStack<idx>;
      private
        _seq  : SSeq;
        _idx  : idx;
        marks : idxstack;
      end;
      { --- end nested type ----------------------------------- }
  public
    function make_cursor : NSeqcursor; virtual;
    function GetEnumerator : NSeqcursor;
  end;

implementation

  constructor GSeq<T,Idx>.NSeqcursor.create( seq : SSeq );
  begin
    _seq := seq;
    _idx := 0;
    marks := idxStack.Create(32);
  end;

 // reference<t>
  function GSeq<T,Idx>.NSeqcursor.get_value : T;
  begin
    result := _seq[ _idx ];
  end;

  procedure GSeq<T,Idx>.NSeqcursor.set_value( v : t );
  begin
    _seq[ _idx ] := v;
  end;
  function GSeq<T,Idx>.NSeqcursor.is_readable : boolean;
  begin
    result := true;
  end;

  function GSeq<T,Idx>.NSeqcursor.is_writable : boolean;
  begin
    result := true;
  end;

  // iterator<t>
  function GSeq<T,Idx>.NSeqcursor.next( out val : T ) : boolean;
  begin
    try val := self.next;
      result := true;
    except
      result := false
    end;
  end;

  function GSeq<T,Idx>.NSeqcursor.next : T;
  begin
    inc( _idx );
    result := self.value;
  end;

  // enumerator<t>
  procedure GSeq<T,Idx>.NSeqcursor.Reset;
  begin
    _idx := 0;
  end;

  function GSeq<T,Idx>.NSeqcursor.get_index : Idx;
  begin
    result := _idx;
  end;

  // slider<t>
  function GSeq<T,Idx>.NSeqcursor.prev( out val : t ) : boolean;
  begin
    try val := self.prev;
      result := true;
    except
      result := false
    end;
  end;

  function GSeq<T,Idx>.NSeqcursor.Prev : t;
  begin
    dec( _idx );
    result := self.value;
  end;

  procedure GSeq<T,Idx>.NSeqcursor.set_index( index : idx );
  begin
    _idx := index;
  end;

  // cursor<t>
  procedure GSeq<T,Idx>.NSeqcursor.mark;
  begin
    self.marks.push( self.index )
  end;

  procedure GSeq<T,Idx>.NSeqcursor.back;
  begin
    self.index := self.marks.pop;
  end;

  function GSeq<T,Idx>.make_cursor : NSeqCursor;
  begin
    result := NSeqCursor.create( self );
  end;

  { IEnumerator Interaface for FOR .. IN ... DO  loops }

  function GSeq<T,Idx>.GetEnumerator : NSeqCursor;
  begin
    result := self.make_cursor;
  end;

  function GSeq<T,Idx>.NSeqcursor.MoveNext : boolean;
  begin
    try self.next; result := true;
    except result := false end;
  end;

end.
