
{$mode objfpc}{$i xpc.inc}
unit rings;
interface uses xpc, sysutils, stacks;

  const kMaxDepth = 16;
  
  
  
  
  type
    generic GRing<t> = class
  
      private type 
        { TLinkNode : link class with .nextLink, .prevLink }
        GLinkNode = class
          nextLink, prevLink : GLinkNode;
          constructor create;
          function length : cardinal; virtual;
        end;
        GCellNode = class( GLinkNode )
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
        { allow creation of nested lists (trees) }
        GRingNode = class ( GLinkNode )
           items : GRing;
           constructor create;
           function length : cardinal; override;
         end;
        { list.TClaspNode : a special node that joins the ends of the list }
        { It's only a cell node because that made the implementation of 
          the cursor simpler. Probably there's a better design involving
          nterfaces, though. }
        //  TODO : refactor the node class hierarchy
        GClaspNode = class( GCellNode )
          parent : GLinkNode;
          constructor create;
          function length : cardinal; override;
          function is_clasp : boolean; override;
        end;
        SRingOfT = specialize GRing<t>; { internal name for this type }
        SNodeStack = specialize stacks.GStack<GCellNode>;
        { tracks a position in the list, even through inserts/deletes }
        type GRingCursor = class
          type SNodeStack = specialize stacks.GStack<GCellNode>;
          protected
            _ring  : SRingOfT; // the main list
            _cell  : GCellNode;
            _idx  : cardinal;
            _path : SNodeStack;
            function _get_value : T;
            procedure _set_value( v : T );
            function _get_index : cardinal;
            function nextcell : GCellNode; virtual;
            function prevcell : GCellNode; virtual;
          public
            constructor create( lis : SRingOfT );
            procedure reset;
            procedure to_top;
            procedure to_end;
            function at_top : boolean;
            function at_end : boolean;
            function at_clasp : boolean;
            procedure move_to( other : GRingCursor );
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
            property current  : t read _get_value;
          end;
    
      public { procedure types used by foreach, find }
        type GNodeAction = procedure( var n : T ) is nested;
        type GNodePredicate = function( n : T ) : Boolean is nested;
    
      protected
        _clasp : GClaspNode; // holds the two ends together
        _count : cardinal;
        function FindNext( const start : GCellNode; 
                             var p     : SNodeStack; out v : GCellNode ) : boolean;
        function FindPrev( const start : GCellNode; 
                             var p     : SNodeStack; out v : GCellNode ) : boolean;
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
      function make_cursor : GRingCursor;
      function length : cardinal;
  
      { -- interface for for..in loops -- }
     public
      function getenumerator : GRingCursor;
  
    end;

implementation
  { -- link ( internal type ) -- }
  
  constructor GRing.GLinkNode.create;
  begin
    self.nextlink := nil;
    self.prevlink := nil;
  end;
    
  function GRing.GLinkNode.length : cardinal;
  begin
    result := 0;
  end;
    
  constructor GRing.GCellNode.create( v : t );
    begin
    inherited create;
    self.value := v;
  end;
    
  procedure GRing.GCellNode._set( v : T );
  begin self._val := v;
  end;
    
  function GRing.GCellNode._get : T;
  begin result := self._val;
  end;
    
  function GRing.GCellNode.is_clasp : boolean;
  begin
    result := false;
  end;
    
  function GRing.GCellNode.length : cardinal;
  begin
    result := 1;
  end;
  
  constructor GRing.GClaspNode.create;
    begin
      self.nextlink := self;
      self.prevlink := self;
    end;
  
  function GRing.GClaspNode.is_clasp : boolean;
    begin
      result := true;
    end;
  
  function GRing.GClaspNode.length : cardinal;
    begin
      result := 0;
    end;
  
  constructor GRing.GRingNode.create;
    begin
      inherited create;
      items := SRingOfT.create;
    end;
  
  function GRing.GRingNode.length : cardinal;
    begin
      result := items.length;
    end;
    { -- list cursor ( internal type ) -- }
  
  constructor GRing.GRingCursor.Create( lis : SRingOfT );
    begin
      _ring := lis;
      //  todo: use a dynamically resizable stack
      _path := SNodeStack.Create( kMaxDepth );
      self.reset;
    end;
  
  procedure GRing.GRingCursor.reset;
    begin
      _cell := _ring._clasp;
      _idx := 0;
    end;
  
  function GRing.GRingCursor.nextCell : GCellNode;
    begin
      _ring.FindNext( _cell, _path, result )
    end;
  
  function GRing.GRingCursor.prevCell : GCellNode;
    begin
      _ring.FindPrev( _cell, _path, result )
    end;
  
  function GRing.GRingCursor.move_next : boolean;
    begin
      if _ring.is_empty then result := false
      else begin
        _cell := self.nextcell;
        inc( _idx );
        result := ( _cell <> _ring._clasp );
      end
    end;
  
  function GRing.GRingCursor.next( out t : t ) : boolean;
    begin
      result := self.move_next;
      if result then t := _cell.value;
    end;
  
  { this is only here to allow 'for..in' loops }
  function GRing.GRingCursor.movenext : boolean; inline;
    begin result := self.move_next
    end;
  
  function GRing.GRingCursor.move_prev : boolean;
    begin
      if _ring.is_empty then result := false
      else begin
        _cell := self.prevcell;
        if _idx = 0 then _idx := _ring.length else dec( _idx );
        result := ( _cell <> _ring._clasp );
      end
    end; { GRing.cursor.move_prev }
  
  function GRing.GRingCursor.prev( out t : t ) : boolean;
    begin
      result := self.move_prev;
      if result then t := _cell.value;
    end; { GRing.cursor.prev }
  
  procedure GRing.GRingCursor.to_top;
    begin
      if _ring.is_empty then raise Exception.create('no top item to go to')
      else begin
        self.reset;
        self.move_next
      end
    end;
  
    procedure GRing.GRingCursor.to_end;
    begin
      if _ring.is_empty then raise Exception.create('no end item to go to')
      else begin
        self.reset;
        self.move_prev
      end
    end;
  
    function GRing.GRingCursor.at_top : boolean;
    begin
      result := (self.prevcell = _ring._clasp) and not _ring.is_empty;
    end;
  
    function GRing.GRingCursor.at_end : boolean;
    begin
      result := (self.nextcell = _ring._clasp) and not _ring.is_empty;
    end;
  
    function GRing.GRingCursor.at_clasp : boolean;
    begin
      result := (self._cell = _ring._clasp);
    end;
  
    procedure GRing.GRingCursor.move_to( other : GRingCursor );
    begin
      _cell := other._cell;
      _idx := other._idx;
      _ring := other._ring;
    end;
  function GRing.GRingCursor._get_value : t;
  begin
    if _cell = _ring._clasp then
      raise Exception.create(
              'can''t get value at the clasp. move the cursor.' )
    else result := _cell.value
  end;
    
  procedure GRing.GRingCursor._set_value( v : t );
  begin
    if _cell = _ring._clasp then
      raise Exception.create(
              'can''t set value at the clasp. move the cursor.' )
    else _cell.value := v
  end;
    
  function GRing.GRingCursor._get_index : cardinal;
  begin
    result := _idx;
  end;
  procedure GRing.GRingCursor.inject_prev( const val : T );
    var ln : GLinkNode;
  begin
    inc( self._ring._count );
    inc( self._idx );
    ln := GCellNode.Create( val );
    ln.nextlink := self._cell;
    ln.prevlink := self._cell.prevlink;
    self._cell.prevlink.nextlink := ln;
    self._cell.prevlink := ln;
  end; { GRing.cursor.inject_prev }
    
  procedure GRing.GRingCursor.inject_next( const val : T );
    var ln : GLinkNode;
  begin
    // we don't increase the index here because we're injecting *after*
    inc( self._ring._count );
    ln := GCellNode.Create( val );
    ln.prevlink := self._cell;
    ln.nextlink := self._cell.nextlink;
    self._cell.nextlink.prevlink := ln;
    self._cell.nextlink := ln;
  end; { GRing.cursor.inject_next }
  //  this is probably leaking memory. how to deal with pointers?
  procedure GRing.GRingCursor.delete_next;
    var temp : GLinkNode;
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
  
  
  constructor GRing.create;
    begin
      _clasp := GClaspNode.Create;
      _count := 0;
    end;
  
  function GRing.make_cursor : GRingCursor;
    begin
      result := GRingCursor.Create( self )
    end;
  
  { this allows 'for .. in' in the fpc / delphi compilers }
  function GRing.getenumerator: GRingCursor;
    begin
      result := self.make_cursor
    end;
  
  
  function GRing.length : cardinal;
    var ln : GLinkNode;
    begin
      result := 0;
      ln := _clasp;
      repeat
        inc( result, ln.length );
        ln := ln.nextlink;
      until ln = _clasp;
    end;
  
  
  function GRing.find( pred : GNodePredicate ) : t;
    var cur : GRingCursor; found : boolean = false;
    begin
      cur := self.make_cursor;
      cur.to_top;
      repeat
        found := pred( cur.value )
      until found or not cur.move_next;
      if found then result := cur.value
    end; { find }
  
  procedure GRing.foreach( action : GNodeAction );
    var item : T;
    begin
      for item in self do action( item );
    end;
  
  { insert : add to the start of the list, right after the clasp }
  procedure GRing.insert( val : T );
    var ln : GCellNode;
  begin
    inc(_count);
    ln := GCellNode.Create( val );
    ln.prevlink := _clasp;
    ln.nextlink := _clasp.nextlink;
    _clasp.nextlink.prevlink := ln;
    _clasp.nextlink := ln;
  end; { insert }
    
  procedure GRing.insert_at( val : T; at_index : cardinal );
    var cur : GRingCursor;
  begin
    cur := self.make_cursor;
    if at_index >= length then cur.to_end
    else while cur.index < at_index do cur.move_next;
    cur.inject_next( val );
  end; { insert_at }
    
  { append : add to the end of the list, right before the clasp }
  procedure GRing.append( val : T );
    var ln : GLinkNode;
  begin
    inc(_count);
    ln := GCellNode.Create( val );
    ln.nextlink := _clasp;
    ln.prevlink := _clasp.prevlink;
    _clasp.prevlink.nextlink := ln;
    _clasp.prevlink := ln;
  end; { append }
  procedure GRing.remove( val : T );
    var c : GRingCursor; found : boolean = false;
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
  
  procedure GRing.drop;
      var temp : GLinkNode;
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
    
  function GRing.is_empty : boolean;
    begin result := _count = 0
    end;
  
  function GRing.FindNext( const start : GCellNode; var p : SNodeStack;
                           out v : GCellNode ) : boolean;
    var ln : GLinkNode;
    begin
      result := false;
      ln := start;
      repeat
        ln := ln.nextlink;
        if ( ln is GCellNode ) then with ln as GCellNode do begin
          p.push( ln as GRingNode );
          if items.length = 0 then ln := ln.nextlink
          else ln := items._clasp
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
  
  { should be exactly the same as above but s/next/prev/g }
  function GRing.FindPrev(
      const start : GCellNode; var p : SNodeStack; out v : GCellNode ) : boolean;
      var ln : GLinkNode;
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
  
  function GRing.FirstCell : GCellNode;
    var p : SNodeStack;
    begin
      p := SNodeStack.Create( kMaxDepth );
      if self.is_empty then
        raise Exception.create('empty list has no first member.')
      else if not FindNext( _clasp, p, result ) then
        raise Exception.create('nested empty list has no first member.')
    end;
  
  function GRing.First: t;
    begin
      result := self.FirstCell.value;
    end;
  
  function GRing.LastCell : GCellNode;
    var p : SNodeStack;
    begin
      p := SNodeStack.Create( kMaxDepth );
      if is_empty then
        raise Exception.create('empty list has no last member.')
      else if not FindPrev( _clasp, p, result ) then
        raise Exception.create('nested empty list has no last member.')
    end;
  
  function GRing.last: T;
    begin
      result := self.lastcell.value;
    end; { last }
initialization
end.
