{$i xpc.inc}
unit sq;{ sequences }
interface uses xpc, cr, stacks;

  type generic isequence<t, idx> = interface
    function get_at( index : idx ) : t;
    procedure set_at( index : idx; value : t );
    property at[ i : idx ] : t read get_at write set_at; default;
    function length : idx;
  end;

  { abstract sequence class.
    the following lines are here only to declare
    that sequences provide a cursor, specialized to the
    same type. :/
  }
  type generic sequence<t,idx> =
    class( specialize isequence<t,idx> )

      // abstract part
      function get_at( index : idx ) : t;	  virtual; abstract;
      procedure set_at( index : idx; value : t ); virtual; abstract;
      property at[ i : idx ] : t read get_at write set_at; default;
      function length : idx; virtual; abstract;

      { --- begin nested type ----------------------------------- }
      protected type seqcursor = class( specialize cr.cursor<t> )
        private type tseq = specialize sequence<t, idx>;
      public
	constructor create( seq : tseq );

	// reference<t>
	function get_value : t;
        procedure set_value( v : t );
        function is_readable : boolean;        virtual;
        function is_writable : boolean;        virtual;
        property value : t read get_value write set_value;

        // iterator<t>
        function next( out val : t ) : boolean;
        function next : t;                     virtual;

        // enumerator<t>
        procedure reset;
        function get_index : idx;

        // slider<t>
        function prev( out val : t ) : boolean;
        function prev : t;                     virtual;
        procedure set_index( idx : idx );
        property index : idx read get_index write set_index;

        procedure mark;
        procedure back;

      private
        type idxstack = specialize stacks.stack<idx>;
      private
        _seq  : tseq;
        _idx  : idx;
        marks : idxstack;
      end;
      { --- end nested type ----------------------------------- }

    function make_cursor : seqcursor; virtual;
  end;

implementation

  constructor sequence.seqcursor.create( seq : tseq );
  begin
    _seq := seq;
    _idx := 0;
  end;

 // reference<t>
  function sequence.seqcursor.get_value : t;
  begin
    result := _seq[ _idx ];
  end;

  procedure sequence.seqcursor.set_value( v : t );
  begin
    _seq[ _idx ] := t;
  end;
  function sequence.seqcursor.is_readable : boolean;
  begin
    result := true;
  end;

  function sequence.seqcursor.is_writable : boolean;
  begin
    result := true;
  end;

  // iterator<t>
  function sequence.seqcursor.next( out val : t ) : boolean;
  begin
    try val := self.next;
      result := true;
    except
      result := false
    end;
  end;

  function sequence.seqcursor.next : t;
  begin
    inc( _idx );
    result := self.value;
  end;

  // enumerator<t>
  procedure sequence.seqcursor.reset;
  begin
    _idx := 0;
  end;

  function sequence.seqcursor.get_index : idx;
  begin
    result := _idx;
  end;

  // slider<t>
  function sequence.seqcursor.prev( out val : t ) : boolean;
  begin
    try val := self.prev;
      result := true;
    except
      result := false
    end;
  end;

  function sequence.seqcursor.prev : t;
  begin
    dec( _idx );
    result := self.value;
  end;

  procedure sequence.seqcursor.set_index( idx : idx );
  begin
    _idx := idx;
  end;

  // cursor<t>
  procedure sequence.seqcursor.mark;
  begin
    self.marks.push( self.index )
  end;

  procedure sequence.seqcursor.back;
  begin
    self.index := self.marks.pop;
  end;

  function sequence.make_cursor : seqcursor;
    type tseqcur = specialize seqcursor<t>;
  begin
    result := tseqcur.create( self );
  end;

end.
