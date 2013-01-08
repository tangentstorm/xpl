{$i xpc}
unit ll; { linked list support }
interface uses xpc, sysutils;

type
  generic list<T> = class

    { -- inner types -------------------------------------------------------- }

    { list.link : adds the forward and backward links to the base type }
    private type link = class
      next, prev : link;
      value	 : T;
      public
      constructor create( val : T );
    end;

    { list.specialized : just an internal name for this same generic type }
    private type specialized  = specialize list<t>;

    public { procedure types used by foreach, find }
      type listaction = procedure( var n : T ) is nested;
      type predicate  = function( n : T ) : Boolean is nested;

    { list.cursor : tracks a position in the list, even through inserts/deletes }
    public type cursor = class
      private
        _lis : specialized;
        _lnk : link;
        _idx : cardinal;
        function _get_value : T;
        function _get_index : cardinal;
      public
        constructor create( lis : specialized );
        procedure reset;
        procedure to_top;
        procedure to_end;
        function at_top : boolean;
        function at_end : boolean;
        procedure move_to( other : cursor );
        function move_next : boolean;
        function move_prev : boolean;
        function next( out t : T ) : boolean;
        function prev( out t : T ) : boolean;
        procedure inject_prev( const val : T );
        procedure inject_next( const val : T );
        property value : T
          read _get_value;
        property index : cardinal
          read _get_index;
      public  { for..in loop interface }
        function movenext : boolean;
        property current  : t
          read _get_value;
    end;

   { -- interface for the main list<t> type --------------------------------- }
   protected
    _clasp : link; // special empty link that holds the two ends together
    _count : cardinal;
   public
    constructor create;
    procedure append( val : T );
    procedure insert( val : T );
    procedure insert_at( val : T;  at_index : cardinal = 0 );
    procedure remove( val : T );
    procedure drop;
    procedure foreach( action : listaction );
    function find( pred : predicate ) : T;
    function is_empty: boolean;
    function first : T;
    function last : T;
    function make_cursor : cursor;
    property count : cardinal read _count;

   { -- interface for for..in loops -- }
   public
    function getenumerator : cursor;

   { -- ancient deprecated interface -- }
   public
    function next( const n : T ) : T; deprecated;
    function prev( const n : T ) : T; deprecated;
    function empty: boolean; deprecated;
    procedure foreachdo( what : listaction ); deprecated;
    //  procedure killall; deprecated;
  end;

  { -- specialized types, just for convenience ------------------------------ }
  type
    stringlist = specialize list<string>;

implementation

  { -- link ( internal type ) -- }

  constructor list.link.create( val : t );
  begin
    self.value := val;
    self.next := nil;
    self.prev := nil;
  end;

  { -- list cursor ( internal type ) -- }

  constructor list.cursor.create( lis : specialized );
    var len : cardinal;
  begin
    _lis := lis;
    self.reset;
  end;

  procedure list.cursor.reset;
  begin
    _lnk := _lis._clasp;
    _idx := 0;
  end;

  function list.cursor.move_next : boolean;
  begin
    if _lis.is_empty then result := false
    else begin
      _lnk := _lnk.next;
      inc( _idx );
      result := ( _lnk <> _lis._clasp );
    end
  end;

  function list.cursor.next( out t : t ) : boolean;
  begin
    result := self.move_next;
    if result then t := _lnk.value;
  end;

  { this is only here to allow for..in loops }
  function list.cursor.movenext : boolean; inline;
  begin result := self.move_next
  end;


  function list.cursor.move_prev : boolean;
  begin
    if _lis.is_empty then result := false
    else begin
      _lnk := _lnk.prev;
      if _idx = 0 then _idx := _lis.count else dec( _idx );
      result := ( _lnk <> _lis._clasp );
    end
  end; { list.cursor.move_prev }

  function list.cursor.prev( out t : t ) : boolean;
  begin
    result := self.move_prev;
    if result then t := _lnk.value;
  end; { list.cursor.prev }


  procedure list.cursor.to_top;
  begin
    if _lis.is_empty then raise Exception.create('no top item to go to')
    else begin
      self.reset;
      self.move_next
    end
  end;

  procedure list.cursor.to_end;
  begin
    if _lis.is_empty then raise Exception.create('no end item to go to')
    else begin
      self.reset;
      self.move_prev
    end
  end;

  function list.cursor.at_top : boolean;
  begin
    result := (_lnk.prev = _lis._clasp) and not _lis.is_empty;
  end;

  function list.cursor.at_end : boolean;
  begin
    result := (_lnk.next =  _lis._clasp) and not _lis.is_empty;
  end;

  procedure list.cursor.move_to( other : cursor );
  begin
    _lnk := other._lnk;
    _idx := other._idx;
    _lis := other._lis;
  end;


  function list.cursor._get_value : t;
  begin
    if _lnk = _lis._clasp then begin
      writeln( int64( _lnk ));
      writeln( int64( _lis._clasp ));
      raise Exception.create( 'index outside of list' )
    end
    else result := _lnk.value
  end;

  function list.cursor._get_index : cardinal;
  begin
    result := _idx;
  end;

  procedure list.cursor.inject_prev( const val : T );
    var ln : link;
  begin
    inc( self._lis._count );
    inc( self._idx );
    ln := link.create( val );
    ln.next := self._lnk;
    ln.prev := self._lnk.prev;
    self._lnk.prev.next := ln;
    self._lnk.prev := ln;
  end; { list.cursor.inject_prev }

  procedure list.cursor.inject_next( const val : T );
    var ln : link;
  begin
    // we don't increase the index here because we're injecting *after*
    inc( self._lis._count );
    ln := link.create( val );
    ln.prev := self._lnk;
    ln.next := self._lnk.next;
    self._lnk.next.prev := ln;
    self._lnk.next := ln;
  end; { list.cursor.inject_next }


  function list.make_cursor : cursor;
  begin
    result := cursor.create( self )
  end;

  { this allows 'for .. in' in the fpc / delphi compilers }
  function list.getenumerator: cursor;
  begin
    result := self.make_cursor
  end;


{-- public 'list' type --}

  constructor list.create;
  begin
    _clasp := link.create( default( t ));
    _clasp.next := _clasp;
    _clasp.prev := _clasp;
    _count := 0;
  end;

  function list.find( pred : Predicate ) : t;
    var cur : cursor; found : boolean = false;
  begin
    cur := self.make_cursor;
    repeat
      found := pred( cur.value )
    until found or not cur.move_next;
    if found then result := cur.value
  end; { find }

  procedure list.foreachdo( what : listaction ); inline; deprecated;
  begin foreach( what )
  end;

  procedure list.foreach( action : listaction );
    var item : T;
  begin
    for item in self do action( item );
  end;


  { insert : add to the start of the list, right after the clasp }
  procedure list.insert( val : T );
    var ln : link;
  begin
    inc(_count);
    ln := link.create( val );
    ln.prev := _clasp;
    ln.next := _clasp.next;
    _clasp.next.prev := ln;
    _clasp.next := ln;
  end; { insert }

  procedure list.insert_at( val	: T; at_index : cardinal );
    var cur : cursor;
  begin
    cur := self.make_cursor;
    if at_index >= _count then cur.to_end
    else while cur.index < at_index do cur.move_next;
    cur.inject_next( val );
  end; { insert_at }

  { append : add to the end of the list, right before the clasp }
  procedure list.append( val : T );
    var ln : link;
  begin
    inc(_count);
    ln := link.create( val );
    ln.next := _clasp;
    ln.prev := _clasp.prev;
    _clasp.prev.next := ln;
    _clasp.prev := ln;
  end; { append }


  procedure List.remove( val : T );
    var p : link;
  begin
    if not self.is_empty then begin
      p := _clasp;
      while ( p.next.value <> val )
        and ( p.next <> _clasp ) do
	p := p.next;

      if p.next.value = val then begin
	p.next := p.next.next;
	//  ERROR
	if self.last = val then
          if p.value = val then _clasp := nil
          else _clasp := p
      end
    end
  end; { remove }

  procedure list.drop;
    var temp : link;
  begin
    if is_empty then raise Exception.create('attempted to drop from empty list')
    else begin
      temp := _clasp.prev;
      _clasp.prev := _clasp.prev.prev;
      temp.prev := nil;
      temp.next := nil;
      temp.free;
    end
  end;

  function list.is_empty : boolean;
  begin result := count = 0
  end;

  function list.first : t;
  begin
    if is_empty then raise Exception.create('empty list has no first member.')
    else result := _clasp.next.value
  end; { first }

  function list.last: T;
  begin
    if is_empty then raise Exception.create('empty list has no last member.')
    else result := _clasp.prev.value
  end; { last }


{-- deprecated list interface --}

  { this on is bad because "empty" can be a verb }
  function list.empty : boolean; inline; deprecated;
  begin result := self.is_empty;
  end;

  { i don't really see the point of these }
  function list.next( const n: T ): T; inline; deprecated;
  begin
    die('do i really need list.next? ');
    result := n;
  end;

  function list.prev( const n: T): T; inline; deprecated;
  begin
    die('do i really need list.prev? ');
    result := n;
  end;


initialization
end.
