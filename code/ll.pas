{$i xpc}
unit ll; { linked list support }
interface uses xpc;

type
  base	     = class
    constructor init; virtual;
  end;

  node	     = class( base )
    next, prev : node;
  end;
  listaction = procedure( var n : node );

  {$ifdef FPC}
  predicate	     = function( n : node ) : boolean is nested;
  {$else}
  predicate	     = function( n : node ) : Boolean;
  {$endif}


  list	     = class( base )
   protected
    mLast, mFirst : node;
    count : integer;
   public constructor init; override;
    procedure append( n : node );
    procedure insert( n : node );
    procedure remove( n : node );
    procedure foreach( what : listaction );
    function find( pred : predicate ) : node;
    function is_empty: boolean;
    function first : node;
    function last : node;

    { -- old interface --}
    function next( const n : node ) : node; deprecated;
    function prev( const n : node ) : node; deprecated;
    function empty: boolean; deprecated;
    procedure foreachdo( what : listaction ); deprecated;
    //  procedure killall; deprecated;
  end;

  var NullNode : node;

implementation

  { empty base class }
  constructor base.init;
  begin
  end;

  constructor list.init;
  begin
    mFirst := nil; mLast := nil; count := 0;
  end;

  function List.find( pred : Predicate ) : node;
  begin
    if not self.is_empty then
    begin
      result := self.mFirst;
      repeat result := result.next;
      until pred( result ) or ( result = nil )
    end
    else result := nil
  end; { find }

  procedure list.foreachdo( what : listaction ); inline; deprecated;
  begin foreach( what )
  end;

  procedure list.foreach( what : listaction );
    var p, q : node;
  begin
    p := first;
    while p <> nil do
    begin
      q := p;
      p := p.next;
      what( q );
    end;
  end;



  function addFirstOne( self : list; n : node ) : boolean;
  begin
    inc( self.count );
    if self.mFirst = nil then begin
      self.mLast := n;
      self.mFirst := n;
      result := true;
    end
    else result := false;
  end;

  procedure list.append( n: node );
  begin
    if not addFirstOne( self, n ) then
    begin
      n.prev := mLast;
      mLast.next := n;
      mLast := n;
    end;
  end; { append }


  procedure List.insert(n: node);
    { be sure to change zmenu.add IF you change this!!! }
  begin
    if not addFirstOne( self, n ) then
    begin
      n.next := mFirst;
      mFirst.prev := n;
      mFirst := n;
    end;
  end; { insert }



  procedure List.remove(n: node);
    var
      p: node;
  begin
    if last <> nil then
    begin
      p := first;
      while (p.next <> n) and (p.next <> last) do
	p := p.next;
      if p.next = n then
      begin
	p.next := n.next;
	if last = n then
	begin
	  if p = n then
	    mLast := nil
	  else
	    mLast := p;
	end;
      end;
    end;
  end; { remove }

  function list.empty : boolean; inline; deprecated;
  begin result := self.is_empty;
  end;
  function list.is_empty : boolean;
  begin result := mLast = nil;
  end;

  function list.first: node;
  begin
    result := mFirst;
  end; { first }

  function list.last: node;
  begin
    result := mLast;
  end; { last }


  { i don't really see the point of these }
  function list.next( const n: node ): node; inline; deprecated;
  begin result := n.next;
  end;


  function list.prev( const n: node): node; inline; deprecated;
  begin result := n.prev;
  end;


begin
  nullnode := node.create;
end. { unit }
