{$i xpc.inc}
unit sq;{ sequences }
interface uses xpc, cr, stacks;

  type generic ISequence<TVal, Tkey> = interface
    function Length : cardinal;
    function GetItem( i : TKey ) : TVal;
    procedure SetItem( i : TKey; value : TVal );
    property item[ i : TKey ] : TVal read GetItem write SetItem; default;
  end;

  { abstract sequence class.
    the following lines are here only to declare
    that sequences provide a cursor, specialized to the
    same type. :/
  }
  type generic GSeq<t,idx> =
    class( TInterfacedObject, specialize ISequence<t,idx> )

      // abstract part
      function GetItem( index : idx ) : t; virtual; abstract;
      procedure SetItem( index : idx; value : t ); virtual; abstract;
      function length : idx; virtual; abstract;
      property item[ ix : idx ] : T
	read GetItem write SetItem; default;

      { --- begin nested type ----------------------------------- }
    type NSeqCursor = class( TInterfacedObject, specialize cr.ICursor<t> )
      private type SSeq = specialize ISequence<T,idx>;
      public
	constructor create( seq : SSeq );

	// reference<t>
	function get_value : t;
        procedure set_value( v : t );
        function is_readable : boolean;        virtual;
        function is_writable : boolean;        virtual;
        property value : t read get_value write set_value;

        // iterator<t>
        function next( out val : t ) : boolean;
        function next : t; virtual;

        // enumerator<t>
        procedure reset;
        function get_index : idx;

        // slider<t>
        function prev( out val : t ) : boolean;
        function prev : t;                     virtual;
        procedure set_index( index : idx );
        property index : idx read get_index write set_index;

        procedure mark;
        procedure back;

      public  { for..in loop interface }
        function MoveNext : boolean;
	property Current : T read get_value;

      private
        type idxstack = specialize stack<idx>;
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

  constructor GSeq.NSeqcursor.create( seq : SSeq );
  begin
    _seq := seq;
    _idx := 0;
  end;

 // reference<t>
  function GSeq.NSeqcursor.get_value : t;
  begin
    result := _seq[ _idx ];
  end;

  procedure GSeq.NSeqcursor.set_value( v : t );
  begin
    _seq[ _idx ] := v;
  end;
  function GSeq.NSeqcursor.is_readable : boolean;
  begin
    result := true;
  end;

  function GSeq.NSeqcursor.is_writable : boolean;
  begin
    result := true;
  end;

  // iterator<t>
  function GSeq.NSeqcursor.next( out val : t ) : boolean;
  begin
    try val := self.next;
      result := true;
    except
      result := false
    end;
  end;

  function GSeq.NSeqcursor.next : t;
  begin
    inc( _idx );
    result := self.value;
  end;

  // enumerator<t>
  procedure GSeq.NSeqcursor.reset;
  begin
    _idx := 0;
  end;

  function GSeq.NSeqcursor.get_index : idx;
  begin
    result := _idx;
  end;

  // slider<t>
  function GSeq.NSeqcursor.prev( out val : t ) : boolean;
  begin
    try val := self.prev;
      result := true;
    except
      result := false
    end;
  end;

  function GSeq.NSeqcursor.prev : t;
  begin
    dec( _idx );
    result := self.value;
  end;

  procedure GSeq.NSeqcursor.set_index( index : idx );
  begin
    _idx := index;
  end;

  // cursor<t>
  procedure GSeq.NSeqcursor.mark;
  begin
    self.marks.push( self.index )
  end;

  procedure GSeq.NSeqcursor.back;
  begin
    self.index := self.marks.pop;
  end;

  function GSeq.make_cursor : GSeq.NSeqCursor;
  begin
    result := GSeq.NSeqCursor.create( self );
  end;

  { IEnumerator Interaface for FOR .. IN ... DO  loops }

  function GSeq.GetEnumerator : NSeqCursor;
  begin
    result := self.make_cursor;
  end;

  function GSeq.NSeqcursor.MoveNext : boolean;
  begin
    try self.next; result := true;
    except result := false end;
  end;

end.
