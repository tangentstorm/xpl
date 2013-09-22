
{-- code generated from rings.pas.org --}

{$mode delphi}{$i xpc.inc}
unit rings;
interface uses xpc, sysutils, stacks;

  const kMaxDepth = 16;
  
  
  
  
  type
    GRing<T> = class
  
      private type
        { TLinkNode : link class with .nextLink, .prevLink }
        GNode = class
          nextLink, prevLink : GNode;
          constructor create;
          function length : cardinal; virtual;
        end;
        GCellNode = class( GNode )
        protected
          _val : t;
          procedure _set( v : T );
          function _get : T;
         public
          property value : T read _get write _set;
          constructor create( v : T );
          function length : cardinal; override;
          function is_clasp : boolean; virtual;
        end;
        { allow creation of nested lists (trees) }
        GRingNode = class ( GNode )
           items : GRing<T>;
           constructor create;
           function length : cardinal; override;
         end;
        { list.TClaspNode : a special node that joins the ends of the list }
        { It's only a cell node because that made the implementation of
          the cursor simpler. Probably there's a better design involving
          nterfaces, though. }
        //  TODO : refactor the node class hierarchy
        GClaspNode = class( GCellNode )
          parent : GNode;
          constructor create;
          function length : cardinal; override;
          function is_clasp : boolean; override;
        end;
        GNodeStack = GStack<GNode>;
        { tracks a position in the list, even through inserts/deletes }
        type GCursor = class
          private type GNodeStack = GStack<GNode>;
          protected
            _ring  : GRing<T>; // the main list
            _cell  : GCellNode;
            _idx  : cardinal;
            _path : GNodeStack;
            function _get_value : T;
            procedure _set_value( v : T );
            function _get_index : cardinal;
            function nextcell : GCellNode; virtual;
            function prevcell : GCellNode; virtual;
          public
            constructor create( lis : GRing<T> );
            procedure reset;
            procedure to_top;
            procedure to_end;
            function at_top : boolean;
            function at_end : boolean;
            function at_clasp : boolean;
            procedure move_to( other : GCursor );
            function move_next : boolean;
            function move_prev : boolean;
            function next( out t : T ) : boolean;
            function prev( out t : T ) : boolean;
            procedure inject_prev( const val : T );
            procedure inject_next( const val : T );
            procedure delete_next;
            property value : T read _get_value write _set_value;
            property index : cardinal read _get_index;
          public  { for..in loop interface }
            function movenext : boolean;
            property current  : T read _get_value;
          end;
  
      public { procedure types used by foreach, find }
        type GNodeAction = procedure( var n : T ) is nested;
        type GNodePredicate = function( n : T ) : Boolean is nested;
  
      protected
        _clasp : GClaspNode; // holds the two ends together
        _count : cardinal;
        function FindNext( const start : GCellNode;
                             var p     : GNodeStack; out v : GCellNode ) : boolean;
        function FindPrev( const start : GCellNode;
                             var p     : GNodeStack; out v : GCellNode ) : boolean;
      function firstcell: GCellNode;
      function lastcell: GCellNode;
     public
      constructor create;
      procedure append( val : T );
      procedure insert( val : T );
      procedure insert_at( val : T;  at_index : cardinal = 0 );
      procedure remove( val : T );
      procedure drop;
      procedure foreach( action : GNodeAction );
      function find( pred : GNodePredicate ) : T;
      function is_empty: boolean;
      function first : T;
      function last : T;
      function make_cursor : GCursor;
      function length : cardinal;
  
      { -- interface for for..in loops -- }
     public
      function getenumerator : GCursor;
  
    end;

implementation
  { -- link ( internal type ) -- }
  
  constructor GRing<T>.GNode.create;
  begin
    self.nextlink := nil;
    self.prevlink := nil;
  end;
  
  function GRing<T>.GNode.length : cardinal;
  begin
    result := 0;
  end;
  
  constructor GRing<T>.GCellNode.create( v : T );
    begin
    inherited create;
    self.value := v;
  end;
  
  procedure GRing<T>.GCellNode._set( v : T );
  begin self._val := v;
  end;
  
  function GRing<T>.GCellNode._get : T;
  begin result := self._val;
  end;
  
  function GRing<T>.GCellNode.is_clasp : boolean;
  begin
    result := false;
  end;
  
  function GRing<T>.GCellNode.length : cardinal;
  begin
    result := 1;
  end;
  
  constructor GRing<T>.GClaspNode.create;
    begin
      self.nextlink := self;
      self.prevlink := self;
    end;
  
  function GRing<T>.GClaspNode.is_clasp : boolean;
    begin
      result := true;
    end;
  
  function GRing<T>.GClaspNode.length : cardinal;
    begin
      result := 0;
    end;
  
  constructor GRing<T>.GRingNode.create;
    begin
      inherited create;
      items := GRing<T>.create;
    end;
  
  function GRing<T>.GRingNode.length : cardinal;
    begin
      result := items.length;
    end;
    { -- list cursor ( internal type ) -- }
  
  constructor GRing<T>.GCursor.Create( lis : GRing<T> );
    begin
      _ring := lis;
      //  todo: use a dynamically resizable stack
      _path := GNodeStack.Create( kMaxDepth );
      self.reset;
    end;
  
  procedure GRing<T>.GCursor.reset;
    begin
      _cell := _ring._clasp;
      _idx := 0;
    end;
  
  function GRing<T>.GCursor.nextCell : GCellNode;
    begin
      _ring.FindNext( _cell, _path, result )
    end;
  
  function GRing<T>.GCursor.prevCell : GCellNode;
    begin
      _ring.FindPrev( _cell, _path, result )
    end;
  
  function GRing<T>.GCursor.move_next : boolean;
    begin
      if _ring.is_empty then result := false
      else begin
        _cell := self.nextcell;
        inc( _idx );
        result := ( _cell <> _ring._clasp );
      end
    end;
  
  function GRing<T>.GCursor.next( out t : T ) : boolean;
    begin
      result := self.move_next;
      if result then t := _cell.value;
    end;
  
  { this is only here to allow 'for..in' loops }
  function GRing<T>.GCursor.movenext : boolean; inline;
    begin result := self.move_next
    end;
  
  function GRing<T>.GCursor.move_prev : boolean;
    begin
      if _ring.is_empty then result := false
      else begin
        _cell := self.prevcell;
        if _idx = 0 then _idx := _ring.length else dec( _idx );
        result := ( _cell <> _ring._clasp );
      end
    end; { GRing<T>.cursor.move_prev }
  
  function GRing<T>.GCursor.prev( out t : T ) : boolean;
    begin
      result := self.move_prev;
      if result then t := _cell.value;
    end; { GRing<T>.cursor.prev }
  
  procedure GRing<T>.GCursor.to_top;
    begin
      if _ring.is_empty then raise Exception.create('no top item to go to')
      else begin
        self.reset;
        self.move_next
      end
    end;
  
    procedure GRing<T>.GCursor.to_end;
    begin
      if _ring.is_empty then raise Exception.create('no end item to go to')
      else begin
        self.reset;
        self.move_prev
      end
    end;
  
    function GRing<T>.GCursor.at_top : boolean;
    begin
      result := (self.prevcell = _ring._clasp) and not _ring.is_empty;
    end;
  
    function GRing<T>.GCursor.at_end : boolean;
    begin
      result := (self.nextcell = _ring._clasp) and not _ring.is_empty;
    end;
  
    function GRing<T>.GCursor.at_clasp : boolean;
    begin
      result := (self._cell = _ring._clasp);
    end;
  
    procedure GRing<T>.GCursor.move_to( other : GCursor );
    begin
      _cell := other._cell;
      _idx := other._idx;
      _ring := other._ring;
    end;
  function GRing<T>.GCursor._get_value : t;
  begin
    if _cell = _ring._clasp then
      raise Exception.create(
              'can''t get value at the clasp. move the cursor.' )
    else result := _cell.value
  end;
  
  procedure GRing<T>.GCursor._set_value( v : T );
  begin
    if _cell = _ring._clasp then
      raise Exception.create(
              'can''t set value at the clasp. move the cursor.' )
    else _cell.value := v
  end;
  
  function GRing<T>.GCursor._get_index : cardinal;
  begin
    result := _idx;
  end;
  procedure GRing<T>.GCursor.inject_prev( const val : T );
    var ln : GNode;
  begin
    inc( self._ring._count );
    inc( self._idx );
    ln := GCellNode.Create( val );
    ln.nextlink := self._cell;
    ln.prevlink := self._cell.prevlink;
    self._cell.prevlink.nextlink := ln;
    self._cell.prevlink := ln;
  end; { GRing<T>.cursor.inject_prev }
  
  procedure GRing<T>.GCursor.inject_next( const val : T );
    var ln : GNode;
  begin
    // we don't increase the index here because we're injecting *after*
    inc( self._ring._count );
    ln := GCellNode.Create( val );
    ln.prevlink := self._cell;
    ln.nextlink := self._cell.nextlink;
    self._cell.nextlink.prevlink := ln;
    self._cell.nextlink := ln;
  end; { GRing<T>.cursor.inject_next }
  //  this is probably leaking memory. how to deal with pointers?
  procedure GRing<T>.GCursor.delete_next;
    var temp : GNode;
  begin
    temp := self._cell.nextlink;
    if temp <> self._ring._clasp then
    begin
      self._cell.nextlink := temp.nextlink;
      self._cell.nextlink.prevlink := self._cell;
      temp.nextlink := nil;
      temp.prevlink := nil;
      // todo: temp.free
    end
  end;
  
  
  constructor GRing<T>.create;
    begin
      _clasp := GClaspNode.Create;
      _count := 0;
    end;
  
  function GRing<T>.make_cursor : GCursor;
    begin
      result := GCursor.Create( self )
    end;
  
  { this allows 'for .. in' in the fpc / delphi compilers }
  function GRing<T>.getenumerator: GCursor;
    begin
      result := self.make_cursor
    end;
  
  
  function GRing<T>.length : cardinal;
    var ln : GNode;
    begin
      result := 0;
      ln := _clasp;
      repeat
        inc( result, ln.length );
        ln := ln.nextlink;
      until ln = _clasp;
    end;
  
  
  function GRing<T>.find( pred : GNodePredicate ) : t;
    var cur : GCursor; found : boolean = false;
    begin
      cur := self.make_cursor;
      cur.to_top;
      repeat
        found := pred( cur.value )
      until found or not cur.move_next;
      if found then result := cur.value
    end; { find }
  
  procedure GRing<T>.foreach( action : GNodeAction );
    var item : T;
    begin
      for item in self do action( item );
    end;
  
  { insert : add to the start of the list, right after the clasp }
  procedure GRing<T>.insert( val : T );
    var ln : GCellNode;
  begin
    inc(_count);
    ln := GCellNode.Create( val );
    ln.prevlink := _clasp;
    ln.nextlink := _clasp.nextlink;
    _clasp.nextlink.prevlink := ln;
    _clasp.nextlink := ln;
  end; { insert }
  
  procedure GRing<T>.insert_at( val : T; at_index : cardinal );
    var cur : GCursor;
  begin
    cur := self.make_cursor;
    if at_index >= length then cur.to_end
    else while cur.index < at_index do cur.move_next;
    cur.inject_next( val );
  end; { insert_at }
  
  { append : add to the end of the list, right before the clasp }
  procedure GRing<T>.append( val : T );
    var ln : GNode;
  begin
    inc(_count);
    ln := GCellNode.Create( val );
    ln.nextlink := _clasp;
    ln.prevlink := _clasp.prevlink;
    _clasp.prevlink.nextlink := ln;
    _clasp.prevlink := ln;
  end; { append }
  procedure GRing<T>.remove( val : T );
    var c : GCursor; found : boolean = false;
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
    
  procedure GRing<T>.drop;
      var temp : GNode;
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
    
  function GRing<T>.is_empty : boolean;
    begin result := _count = 0
    end;
    
  function GRing<T>.FindNext( const start : GCellNode; var p : GNodeStack;
                           out v : GCellNode ) : boolean;
    var ln : GNode;
    begin
      result := false;
      ln := start;
      repeat
        if ( ln is GCellNode ) then 
          with ln as GCellNode do ln := ln.nextlink;
        if ( ln is GRingNode ) then 
          with ln as GRingNode do begin
            p.push( ln );
            if items.length = 0 then ln := ln.nextlink
            else ln := items._clasp
          end
        else if ln is GClaspNode then
          if p.count > 0 then ln := p.pop
          else ln := _clasp
        else if ln is GCellNode then 
          begin
            result := true;
            v := ln as GCellNode;
          end
      until result or ( ln = _clasp );
      v := ln as GCellNode;
    end;
    
  { should be exactly the same as above but s/next/prev/g }
  function GRing<T>.FindPrev(
      const start : GCellNode; var p : GNodeStack; out v : GCellNode ) : boolean;
      var ln : GNode;
    begin
      result := false;
      ln := start;
      repeat
        ln := ln.prevlink;
        if ( ln is GRingNode ) then with (ln as GRingNode) do begin
          p.push( ln as GRingNode );
          if ( items.length = 0 ) then ln := ln.prevlink
          else result := items.FindPrev(items._clasp, p, v )
        end
        else if ln is GClaspNode then begin
          if p.count > 0 then ln := p.pop
          else ln := _clasp
        end
        else if ln is GCellNode then begin
          result := true;
          v := ln as GCellNode;
        end
      until result or ( ln = _clasp );
      v := ln as GCellNode;
    end;
    
  function GRing<T>.FirstCell : GCellNode;
    var p : GNodeStack;
    begin
      p := GNodeStack.Create( kMaxDepth );
      if self.is_empty then
        raise Exception.create('empty list has no first member.')
      else if not FindNext( _clasp, p, result ) then
        raise Exception.create('nested empty list has no first member.')
    end;
    
  function GRing<T>.First: t;
    begin
      result := self.FirstCell.value;
    end;
    
  function GRing<T>.LastCell : GCellNode;
    var p : GNodeStack;
    begin
      p := GNodeStack.Create( kMaxDepth );
      if is_empty then
        raise Exception.create('empty list has no last member.')
      else if not FindPrev( _clasp, p, result ) then
        raise Exception.create('nested empty list has no last member.')
    end;
    
  function GRing<T>.last: T;
    begin
      result := self.lastcell.value;
    end; { last }
initialization
end.
