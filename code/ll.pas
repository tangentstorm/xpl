{$i xpc}
unit ll; { li list support }
interface uses xpc, sysutils, stacks;

const maxdepth = 8;
type
  generic list<T> = class

    { -- inner types -------------------------------------------------------- }

   private type
     { list.listof_t : just an internal name for this type }
     listof_t = specialize list<t>;

     { list.link : abstract link class with .nextlink, .prevlink }
     link = class
       nextlink, prevlink : link;
       constructor create;
       function length : cardinal; virtual;
     end;

     { list.cell : contains values }
     cell = class( link )
     protected
       _val : t;
       procedure _set( v : t );
       function _get : T;
      public
       property value : T read _get write _set;
       constructor create( v : t );
       function length : cardinal; override;
       function is_clasp : boolean; virtual;
     end;

     { list.cell : a special cell that joins the ends of the list }
     clasp = class( cell )
       parent : link;
       constructor create;
       function length : cardinal; override;
       function is_clasp : boolean; override;
     end;

     { list.child : allows creation of nested lists (trees) }
     child = class( link )
       items : listof_t;
       constructor create;
       function length : cardinal; override;
     end;
     path = specialize stacks.stack<child>;

    public { procedure types used by foreach, find }
      type listaction = procedure( var n : T ) is nested;
      type predicate  = function( n : T ) : Boolean is nested;


    { list.cursor : tracks a position in the list, even through inserts/deletes }
  public type cursor = class
    type path = specialize stack<child>;
    protected
        _lis  : listof_t; // the main list
        _cel  : cell;
        _idx  : cardinal;
        _path : path;
        function _get_value : T;
        procedure _set_value( v : T );
        function _get_index : cardinal;
        function nextcell : cell; virtual;
        function prevcell : cell; virtual;
      public
        constructor create( lis : listof_t );
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
        procedure delete_next;
        property value : T
          read _get_value write _set_value;
        property index : cardinal
          read _get_index;
      public  { for..in loop interface }
        function movenext : boolean;
        property current  : t
          read _get_value;
    end;

   { -- interface for the main list<t> type --------------------------------- }
   protected
     _clasp : cell; // holds the two ends together
     _count : cardinal;
     function findnextcell
       ( const start : cell; var p : path; out v : cell ) : boolean;
     function findprevcell
       ( const start : cell; var p : path; out v : cell ) : boolean;
     function firstcell: cell;
     function lastcell: cell;
   public
     constructor create;
     procedure append( val : T );
     procedure insert( val : T );
     procedure insert_at( val : T;  at_index : cardinal	= 0 );
     procedure remove( val : T );
     procedure drop;
     procedure foreach( action : listaction );
     function find( pred : predicate ) : T;
     function is_empty: boolean;
     function first : T;
     function last : T;
     function make_cursor : cursor;
     function length : cardinal;

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

  constructor list.link.create;
  begin
    self.nextlink := nil;
    self.prevlink := nil;
  end;

  function list.link.length : cardinal;
  begin
    result := 0;
  end;


  constructor list.cell.create( v : t );
  begin
    inherited create;
    self.value := v;
  end;

  procedure list.cell._set( v : T );
  begin self._val := v;
  end;

  function list.cell._get : T;
  begin result := self._val;
  end;

  function list.cell.is_clasp : boolean;
  begin
    result := false;
  end;

  function list.cell.length : cardinal;
  begin
    result := 1;
  end;

  constructor list.clasp.create;
  begin
    self.nextlink := self;
    self.prevlink := self;
  end;

  function list.clasp.is_clasp : boolean;
  begin
    result := true;
  end;

  function list.clasp.length : cardinal;
  begin
    result := 0;
  end;


  constructor list.child.create;
  begin
    inherited create;
    items := listof_t.create;
  end;

  function list.child.length : cardinal;
  begin
    result := items.length;
  end;


  { -- list cursor ( internal type ) -- }

  constructor list.cursor.create( lis : listof_t );
  begin
    _lis := lis;
    _path.init( maxdepth ); //  todo: use a dynamically resizable stack
    self.reset;
  end;

  procedure list.cursor.reset;
  begin
    _cel := _lis._clasp;
    _idx := 0;
  end;

  // default implementation does a depth-first walk of the tree

  function list.cursor.nextcell : cell;
  begin
    _lis.findnextcell( _cel, _path, result )
  end;

  function list.cursor.prevcell : cell;
  begin
    _lis.findprevcell( _cel, _path, result )
  end;

  function list.cursor.move_next : boolean;
  begin
    if _lis.is_empty then result := false
    else begin
      _cel := self.nextcell;
      inc( _idx );
      result := ( _cel <> _lis._clasp );
    end
  end;

  function list.cursor.next( out t : t ) : boolean;
  begin
    result := self.move_next;
    if result then t := _cel.value;
  end;

  { this is only here to allow for..in loops }
  function list.cursor.movenext : boolean; inline;
  begin result := self.move_next
  end;


  function list.cursor.move_prev : boolean;
  begin
    if _lis.is_empty then result := false
    else begin
      _cel := self.prevcell;
      if _idx = 0 then _idx := _lis.length else dec( _idx );
      result := ( _cel <> _lis._clasp );
    end
  end; { list.cursor.move_prev }

  function list.cursor.prev( out t : t ) : boolean;
  begin
    result := self.move_prev;
    if result then t := _cel.value;
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
    result := (self.prevcell = _lis._clasp) and not _lis.is_empty;
  end;

  function list.cursor.at_end : boolean;
  begin
    result := (self.nextcell = _lis._clasp) and not _lis.is_empty;
  end;

  procedure list.cursor.move_to( other : cursor );
  begin
    _cel := other._cel;
    _idx := other._idx;
    _lis := other._lis;
  end;


  function list.cursor._get_value : t;
  begin
    if _cel = _lis._clasp then
      raise Exception.create(
	      'can''t get value at the clasp. move the cursor.' )
    else result := _cel.value
  end;

  procedure list.cursor._set_value( v : t );
  begin
    if _cel = _lis._clasp then
      raise Exception.create(
	      'can''t set value at the clasp. move the cursor.' )
    else _cel.value := v
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
    ln := cell.create( val );
    ln.nextlink := self._cel;
    ln.prevlink := self._cel.prevlink;
    self._cel.prevlink.nextlink := ln;
    self._cel.prevlink := ln;
  end; { list.cursor.inject_prev }

  procedure list.cursor.inject_next( const val : T );
    var ln : link;
  begin
    // we don't increase the index here because we're injecting *after*
    inc( self._lis._count );
    ln := cell.create( val );
    ln.prevlink := self._cel;
    ln.nextlink := self._cel.nextlink;
    self._cel.nextlink.prevlink := ln;
    self._cel.nextlink := ln;
  end; { list.cursor.inject_next }

  //  this is probably leaking memory. how to deal with pointers?
  procedure list.cursor.delete_next;
    var temp : link;
  begin
    temp := self._cel.nextlink;
    if temp <> self._lis._clasp then
    begin
      self._cel.nextlink := temp.nextlink;
      self._cel.nextlink.prevlink := self._cel;
      temp.nextlink := nil;
      temp.prevlink := nil;
      // todo: temp.free
    end
  end;

  function list.make_cursor : cursor;
  begin
    result := cursor.create( self )
  end;

  function list.length : cardinal;
    var ln : link;
  begin
    result := 0;
    ln := _clasp;
    repeat
      inc( result, ln.length );
      ln := ln.nextlink;
    until ln = _clasp;
  end;

  { this allows 'for .. in' in the fpc / delphi compilers }
  function list.getenumerator: cursor;
  begin
    result := self.make_cursor
  end;


{-- public 'list' type --}

  constructor list.create;
  begin
    _clasp := clasp.create;
    _count := 0;
  end;

  function list.find( pred : Predicate ) : t;
    var cur : cursor; found : boolean = false;
  begin
    cur := self.make_cursor;
    cur.to_top;
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
    var ln : cell;
  begin
    inc(_count);
    ln := cell.create( val );
    ln.prevlink := _clasp;
    ln.nextlink := _clasp.nextlink;
    _clasp.nextlink.prevlink := ln;
    _clasp.nextlink := ln;
  end; { insert }

  procedure list.insert_at( val	: T; at_index : cardinal );
    var cur : cursor;
  begin
    cur := self.make_cursor;
    if at_index >= length then cur.to_end
    else while cur.index < at_index do cur.move_next;
    cur.inject_next( val );
  end; { insert_at }

  { append : add to the end of the list, right before the clasp }
  procedure list.append( val : T );
    var ln : link;
  begin
    inc(_count);
    ln := cell.create( val );
    ln.nextlink := _clasp;
    ln.prevlink := _clasp.prevlink;
    _clasp.prevlink.nextlink := ln;
    _clasp.prevlink := ln;
  end; { append }


  procedure List.remove( val : T );
    var c : cursor; found : boolean = false;
  begin
    if not self.is_empty then pass
    else begin
      c := self.make_cursor;
      repeat
	c.move_next;
	found := c.value = val;
      until found or c.at_end;
      if found then begin
	c.move_prev;
	c.delete_next
      end
    end
  end; { remove }

  procedure list.drop;
    var temp : link;
  begin
    if is_empty then raise Exception.create('attempted to drop from empty list')
    else begin
      temp := _clasp.prevlink;
      _clasp.prevlink := _clasp.prevlink.prevlink;
      temp.prevlink := nil;
      temp.nextlink := nil;
      temp.free;
    end
  end;

  function list.is_empty : boolean;
  begin result := _count = 0
  end;

  function list.findnextcell(
    const start : cell; var p : path; out v : cell ) : boolean;
    var ln : link;
  begin
    result := false;
    ln := start;
    repeat
      ln := ln.nextlink;
      if ( ln is child ) then with ln as child do begin
	p.push( ln as child );
	if items.length = 0 then ln := ln.nextlink
	else ln := items._clasp
      end
      else if ln is clasp then begin
        if p.sp > 0 then ln := p.pop
	else ln := _clasp
      end
      else if ln is cell then begin
        result := true;
        v := ln as cell;
      end
    until result or ( ln = _clasp );
    v := ln as cell;
  end;

  { should be exactly the same as above but s/next/prev/g }
  function list.findprevcell(
    const start : cell; var p : path; out v : cell ) : boolean;
    var ln : link;
  begin
    result := false;
    ln := start;
    repeat
      ln := ln.prevlink;
      if ( ln is child ) then with (ln as child) do begin
        p.push( ln as child );
	if ( items.length = 0 ) then ln := ln.prevlink
	else result := items.findprevcell(items._clasp, p, v )
      end
      else if ln is clasp then begin
        if p.sp > 0 then ln := p.pop
	else ln := _clasp
      end
      else if ln is cell then begin
	result := true;
	v := ln as cell;
      end
    until result or ( ln = _clasp );
    v := ln as cell;
  end;

  function list.firstcell : cell;
  var p : path;
  begin
    p.init( maxdepth );
    if self.is_empty then
      raise Exception.create('empty list has no first member.')
    else if not findnextcell( _clasp, p, result ) then
      raise Exception.create('nested empty list has no first member.')
  end;

  function list.first: t;
  begin
    result := self.firstcell.value;
  end;

  function list.lastcell : cell;
  var p : path;
  begin
    p.init( maxdepth );
    if is_empty then
      raise Exception.create('empty list has no last member.')
    else if not findprevcell( _clasp, p, result ) then
      raise Exception.create('nested empty list has no last member.')
  end;

  function list.last: T;
  begin
    result := self.lastcell.value;
  end; { last }


{-- deprecated list interface --}

  { this on is bad because "empty" can be a verb }
  function list.empty : boolean; inline; deprecated;
  begin result := self.is_empty;
  end;

  { i don't really see the point of these }
  function list.next( const n: T ): T; inline; deprecated;
  begin
    die('do i really need list.nextn? ');
    result := n;
  end;

  function list.prev( const n: T): T; inline; deprecated;
  begin
    die('do i really need list.prev? ');
    result := n;
  end;


initialization
end.
