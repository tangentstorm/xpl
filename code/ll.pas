{$i xpc}
unit ll; { linked list support }
interface uses xpc;

type
  generic list<T> = class
  private type
    link = class
      next, prev : link;
      value	 : T;
    public
      constructor create( val : T );
    end;
    tlist = specialize list<t>;
    iter = class
      private
        _lis : tlist;
        _cur : link;
        function _value : T;
      public
        constructor create( lis : tlist );
        function movenext : boolean;
        property current : T read _value;
    end;
    listaction = procedure( var n : T );
    predicate  = function( n : T ) : Boolean;
   protected
      _last, _head : link;
      count : integer;
   private
      function addFirstOne( ln : link ) : boolean;
   public constructor init;
    procedure append( val : T );
    procedure insert( val : T );
    procedure remove( val : T );
    procedure foreach( what : listaction );
    function find( pred : predicate ) : T;
    function is_empty: boolean;
    function first : T;
    function last : T;
    function getenumerator : iter;

    { -- old interface --}
    function next( const n : T ) : T; deprecated;
    function prev( const n : T ) : T; deprecated;
    function empty: boolean; deprecated;
    procedure foreachdo( what : listaction ); deprecated;
    //  procedure killall; deprecated;
  end;



implementation

  { -- link ( internal type ) -- }

  constructor list.link.create( val : t );
  begin
    self.value := val;
  end;

  { -- list iterator ( internal type ) -- }

  constructor list.iter.create( lis : tlist );
  begin
    _lis := lis;
    _cur := nil;
  end;

  function list.iter.movenext : boolean;
  begin
    if _cur = nil then _cur := _lis._head
    else _cur := _cur.next;
    result := ( _cur <> nil );
  end;

  function list.iter._value : t;
  begin
    result := _cur.value
  end;

  { this allows 'for .. in' in the fpc / delphi compilers }
  function list.getenumerator: iter;
  begin
    result := iter.create( self );
  end;


{-- public 'list' type --}

  constructor list.init;
  begin
    _head := nil; _last := nil; count := 0;
  end;

  function List.find( pred : Predicate ) : T;
    var it : iter; found : boolean = false;
  begin
    it := iter.create( self );
    repeat
      found := pred( it.current )
    until found or not it.movenext;
    if found
      then result := it.current
      else result := nil
  end; { find }

  procedure list.foreachdo( what : listaction ); inline; deprecated;
  begin foreach( what )
  end;

  // TODO: this should probably be deprecated too
  procedure list.foreach( what : listaction );
    var p, q : link;
  begin
    p := self._head;
    while p <> nil do
    begin
      q := p;
      p := p.next;
      what( q.value );
    end;
  end;



  { helper routine for insert / append }
  function list.addFirstOne( ln : link ) : boolean;
  begin
    inc( self.count );
    if self._head = nil then begin
      self._last := ln;
      self._head := ln;
      result := true;
    end
    else result := false;
  end;


  procedure List.insert( val : T );
    { be sure to change zmenu.add IF you change this!!! }
    var ln : link;
  begin
    ln := link.create( val );
    if not addFirstOne( ln ) then
    begin
      ln.next := _head;
      _head.prev := ln;
      _head := ln;
    end;
  end; { insert }

  
  procedure list.append( val : T );
    var ln : link;
  begin
    ln := link.create( val );
    if not addFirstOne( ln ) then
    begin
      ln.prev := _last;
      _last.next := ln;
      _last := ln;
    end;
  end; { append }


  procedure List.remove( val : T );
    var p : link;
  begin
    if not self.is_empty then begin
      p := self._head;
      while ( p.next.value <> val )
	and ( p.next <> _last ) do
	p := p.next;

      if p.next.value = val then begin
	p.next := p.next.next;
	if self.last = val then
	  if p.value = val then _last := nil
	  else _last := p
      end
    end
  end; { remove }

  function list.is_empty : boolean;
  begin result := _last = nil;
  end;

  function list.first: T;
  begin
    result := _head.value;
  end; { first }

  function list.last: T;
  begin
    result := _last.value;
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
    result := nil
  end;

  function list.prev( const n: T): T; inline; deprecated;
  begin
    die('do i really need list.prev? ');
    result := nil
  end;


initialization
end.
