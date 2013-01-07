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
    _first_link, _last_link : link;
    _count : cardinal;
    function is_first_insert( ln : link ) : boolean;
   public
    constructor create;
    procedure append( val : T );
    procedure insert( val : T );
    procedure insert_at( val : T;  at_index : cardinal = 0 );
    procedure remove( val : T );
    procedure drop;
    procedure foreach( what : listaction );
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
  end;

  { -- list cursor ( internal type ) -- }

  constructor list.cursor.create( lis : specialized );
  begin
    _lis := lis;
    self.reset;
  end;

  procedure list.cursor.reset;
  begin
    _lnk := nil;
    _idx := 0;
  end;

  function list.cursor.move_next : boolean;
  begin
    result := _lis._first_link <> nil;
    if _lnk = nil then begin
      _lnk := _lis._first_link;
      _idx := 1
    end
    else if _lnk.next <> nil then begin
      _lnk := _lnk.next;
      inc( _idx );
    end
    else result := false
  end;

  { this is only here to allow for..in loops }
  function list.cursor.movenext : boolean; inline;
  begin result := self.move_next end;

  function list.cursor.move_prev : boolean;
  begin
    if _lnk = nil then result := false
    else begin
      _lnk := _lnk.prev;
      dec( _idx );
      result := ( _lnk <> nil );
    end
  end;

  procedure list.cursor.to_top;
  begin
    self.reset;
    if not self.move_next then
      raise Exception.create('no top item to go to');
  end;

  procedure list.cursor.to_end;
  begin
    _lnk := _lis._last_link;
    if _lis.count = 0 then _idx := 0
    else _idx := _lis._count;
  end;

  function list.cursor.at_top : boolean;
  begin
    result := _lnk = _lis._first_link;
  end;

  function list.cursor.at_end : boolean;
  begin
    result := _lnk =  _lis._last_link;
  end;

  procedure list.cursor.move_to( other : cursor );
  begin
    _lnk := other._lnk;
    _idx := other._idx;
    _lis := other._lis;
  end;

  function list.cursor.next( out t : t ) : boolean;
  begin
    result := self.move_next;
    if result then t := _lnk.value;
  end;

  function list.cursor.prev( out t : t ) : boolean;
  begin
    result := self.move_prev;
    if result then t := _lnk.value;
  end;

  function list.cursor._get_value : t;
  begin
    if _lnk = nil then raise Exception.create( 'the list is empty' )
    else result := _lnk.value
  end;

  function list.cursor._get_index : cardinal;
  begin
    result := _idx;
  end;

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
    _first_link := nil; _last_link := nil; _count := 0;
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

  // TODO: this should probably be deprecated too
  procedure list.foreach( what : listaction );
    var p, q : link;
  begin
    p := self._first_link;
    while p <> nil do
    begin
      q := p;
      p := p.next;
      what( q.value );
    end;
  end;



  { helper routine for insert / append }
  function list.is_first_insert( ln : link ) : boolean;
  begin
    inc( self._count );
    if _first_link = nil then begin
      _last_link := ln;
      _first_link := ln;
      result := true;
    end
    else result := false;
  end;

  procedure List.insert( val : T );
    { be sure to change zmenu.add IF you change this!!! }
    var ln : link;
  begin
    ln := link.create( val );
    if not is_first_insert( ln ) then
    begin
      ln.next := _first_link;
      _first_link.prev := ln;
      _first_link := ln;
    end
  end; { insert }

  procedure list.insert_at( val	: T; at_index : cardinal );
    var cur : cursor; ln : link;
  begin
    cur := self.make_cursor;
    if at_index >= _count then cur.to_end
    else while cur.index < at_index do cur.move_next;
    inc(self._count);
    ln := link.create( val );
    ln.next := cur._lnk;
    ln.prev := cur._lnk.prev;
    cur._lnk.prev := ln;
  end; { insert_at }


  procedure list.append( val : T );
    var ln : link;
  begin
    ln := link.create( val );
    if not is_first_insert( ln ) then
    begin
      ln.prev := _last_link;
      _last_link.next := ln;
      _last_link := ln;
    end;
  end; { append }


  procedure List.remove( val : T );
    var p : link;
  begin
    if not self.is_empty then begin
      p := _first_link;
      while ( p.next.value <> val )
        and ( p.next <> _last_link ) do
	p := p.next;

      if p.next.value = val then begin
	p.next := p.next.next;
	if self.last = val then
          if p.value = val then _last_link := nil
          else _last_link := p
      end
    end
  end; { remove }

  procedure list.drop;
  begin
    self._last_link := self._last_link.prev;
    self._last_link.next := nil;
  end;

  function list.is_empty : boolean;
  begin result := _last_link = nil;
  end;

  function list.first : t;
  begin
    if _first_link <> nil then result := _first_link.value
    else raise Exception.create('empty list has no first member.');
  end; { first }

  function list.last: T;
  begin
    if assigned( _last_link ) then result := _last_link.value
    else raise Exception.create('empty list has no last member.');
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
