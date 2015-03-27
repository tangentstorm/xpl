{$mode delphi}{$i xpc.inc}
unit sq;{ sequences }
interface uses xpc, cr, stacks;

// ugh. this provides generic sequences with for..in..do support,
// but it's a mess because of problems with the generics parser in fpc.

type
{  ISequence<X> = interface;
  TSequenceEnumerator<T> = class
//private type ISeq = ISequence<T>; // sq.pas(8,36) Fatal: Internal error 2012101001
//constructor Create(seq:ISequence<T>); // sq.pas(9,36) Fatal: Internal error 2012101001
    function MoveNext : boolean;
    function GetCurrent:T;
    property Current : T; read GetCurrent;
  end; }
  ISequence<T> = interface
    function GetItem( i : cardinal ) : T;
//    function GetEnumerator:TSequenceEnumerator<T>;
    procedure SetItem( i : cardinal; const value : T );
    property item[ i : cardinal ] : T read GetItem write SetItem; default;
  end;

  { abstract sequence class.
    the following lines are here only to declare
    that sequences provide a cursor, specialized to the
    same type. :/
  }
  type GSeq<T> =
    class( TInterfacedObject, ISequence<T> )

      // abstract part
      function GetItem( index : cardinal ) : t; virtual; abstract;
      procedure SetItem( index : cardinal; const value : t ); virtual; abstract;
      function _GetLength : cardinal; virtual; abstract;
      procedure _SetLength( len : cardinal ); virtual; abstract;
      property item[ ix : cardinal ] : T
	read GetItem write SetItem; default;
      property length : cardinal read _GetLength;

      { --- begin nested type ----------------------------------- }
    type NSeqCursor = class( TInterfacedObject, ICursor<T>, IEnumerator<T> )
      private type SSeq = GSeq<T>;
      public
	constructor create( seq : SSeq );
	destructor destroy; override;

	// reference<t>
	function get_value : t;
        procedure set_value( v : t );
        function is_readable : boolean; virtual;
        function is_writable : boolean; virtual;
        property value : t read get_value write set_value;

        // iterator<t>
	function Next( out val : t ) : boolean; overload;
	function Next : t; virtual; overload;

        // enumerator<t>
        procedure Reset;
        function get_index : cardinal;

        // slider<t>
	function Prev( out val : T ) : boolean; overload;
	function Prev : T; virtual; overload;
        procedure set_index( idx : cardinal );
        property index : cardinal read get_index write set_index;

        procedure Mark;
        procedure Back;

      public  { for..in loop interface }
        function MoveNext : boolean;
        function GetCurrent : T;
      private
        type idxstack = GStack<cardinal>;
      private
        _seq  : SSeq;
        _idx  : cardinal;
        marks : idxstack;
      end;
      { --- end nested type ----------------------------------- }
  public
    function make_cursor : NSeqcursor; virtual;
    function GetEnumerator :NSeqCursor;
  end;

implementation

  constructor GSeq<T>.NSeqcursor.create( seq : SSeq );
  begin
    _seq := seq;
    _idx := 0;
    marks := idxStack.Create(32);
  end;

  destructor GSeq<T>.NSeqcursor.destroy;
  begin
    _seq := nil;
    marks.free;
  end;

 // reference<t>
  function GSeq<T>.NSeqcursor.get_value : T;
  begin
    result := _seq[ _idx - 1 ]; // -1 because 0 indicates not started
  end;

  procedure GSeq<T>.NSeqcursor.set_value( v : t );
  begin
    _seq[ _idx - 1 ] := v;
  end;

  function GSeq<T>.NSeqcursor.is_readable : boolean;
  begin
    result := true;
  end;

  function GSeq<T>.NSeqcursor.is_writable : boolean;
  begin
    result := true;
  end;

  // iterator<t>
  function GSeq<T>.NSeqcursor.next( out val : T ) : boolean;
  begin
    try val := self.next;
      result := true;
    except
      result := false
    end;
  end;

  function GSeq<T>.NSeqcursor.next : T;
  begin
    inc( _idx );
    result := self.value;
  end;

  // enumerator<t>
  procedure GSeq<T>.NSeqcursor.Reset;
  begin
    _idx := 0;
  end;

  function GSeq<T>.NSeqcursor.get_index : cardinal;
  begin
    result := _idx;
  end;

  // slider<t>
  function GSeq<T>.NSeqcursor.prev( out val : t ) : boolean;
  begin
    try val := self.prev;
      result := true;
    except
      result := false
    end;
  end;

  function GSeq<T>.NSeqcursor.Prev : t;
  begin
    dec( _idx );
    result := self.value;
  end;

  procedure GSeq<T>.NSeqcursor.set_index( idx : cardinal );
  begin
    _idx := idx;
  end;

  // cursor<t>
  procedure GSeq<T>.NSeqcursor.mark;
  begin
    self.marks.push( self.index )
  end;

  procedure GSeq<T>.NSeqcursor.back;
  begin
    self.index := self.marks.pop;
  end;

  function GSeq<T>.make_cursor : NSeqCursor;
  begin
    result := NSeqCursor.create( self );
  end;

{ IEnumerator Interaface for FOR .. IN ... DO  loops }

function GSeq<T>.GetEnumerator : NSeqCursor;
  begin result := self.make_cursor;
  end;

function GSeq<T>.NSeqcursor.MoveNext : boolean;
  begin
    try self.next; result := true;
    except result := false end;
  end;

function GSeq<T>.NSeqcursor.GetCurrent : T;
  begin result := get_value;
  end;

end.
