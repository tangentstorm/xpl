
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
          constructor Create;
          function Length : cardinal; virtual;
        end;
        GCellNode = class( GNode )
        protected
          _val : t;
          procedure _set( v : T );
          function _get : T;
         public
          property value : T read _get write _set;
          constructor Create( v : T );
          function Length : cardinal; override;
          function IsClasp : boolean; virtual;
        end;
        { allow creation of nested lists (trees) }
        GRingNode = class ( GNode )
           items : GRing<T>;
           constructor Create;
           function Length : cardinal; override;
         end;
        { list.TClaspNode : a special node that joins the ends of the list }
        { It's only a cell node because that made the implementation of
          the cursor simpler. Probably there's a better design involving
          nterfaces, though. }
        //  TODO : refactor the node class hierarchy
        GClaspNode = class( GCellNode )
          parent : GNode;
          constructor Create;
          function Length : cardinal; override;
          function IsClasp : boolean; override;
        end;
        GNodeStack = GStack<GNode>;
        { tracks a position in the list, even through Inserts/deletes }
        type GCursor = class
          private type GNodeStack = GStack<GNode>;
          protected
            _ring  : GRing<T>; // the main list
            _cell  : GCellNode;
            _idx  : cardinal;
            _path : GNodeStack;
            function GetValue : T;
            procedure SetValue( v : T );
            function GetIndex : cardinal;
            function NextCell : GCellNode; virtual;
            function PrevCell : GCellNode; virtual;
          public
            constructor Create( lis : GRing<T> );
            procedure Reset;
            procedure ToTop;
            procedure ToEnd;
            function AtTop : boolean;
            function AtEnd : boolean;
            function AtClasp : boolean;
            procedure MoveTo( other : GCursor );
            function Next( out t : T ) : boolean;
            function Prev( out t : T ) : boolean;
            procedure InjectPrev( const val : T );
            procedure InjectNext( const val : T );
            procedure delete_Next;
            property value : T read GetValue write SetValue;
            property index : cardinal read GetIndex;
          public  { for..in loop interface }
            property current  : T read GetValue;
            function MoveNext : boolean;
            function MovePrev : boolean; // just for symmetry
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
      function FirstCell: GCellNode;
      function LastCell: GCellNode;
     public
      constructor Create;
      procedure Append( val : T );
      procedure Insert( val : T );
      procedure InsertAt( val : T;  at_index : cardinal = 0 );
      procedure Remove( val : T );
      procedure Drop;
      procedure ForEach( action : GNodeAction );
      function Find( pred : GNodePredicate ) : T;
      function IsEmpty: boolean;
      function First : T;
      function Last : T;
      function MakeCursor : GCursor;
      function Length : cardinal;
  
      { -- interface for for..in loops -- }
     public
          function GetEnumerator : GCursor;
  
    end;

implementation
  { -- link ( internal type ) -- }
  
  constructor GRing<T>.GNode.Create;
  begin
    self.Nextlink := nil;
    self.Prevlink := nil;
  end;
  
  function GRing<T>.GNode.Length : cardinal;
  begin
    result := 0;
  end;
  
  constructor GRing<T>.GCellNode.Create( v : T );
    begin
    inherited Create;
    self.value := v;
  end;
  
  procedure GRing<T>.GCellNode._set( v : T );
  begin self._val := v;
  end;
  
  function GRing<T>.GCellNode._get : T;
  begin result := self._val;
  end;
  
  function GRing<T>.GCellNode.IsClasp : boolean;
  begin
    result := false;
  end;
  
  function GRing<T>.GCellNode.Length : cardinal;
  begin
    result := 1;
  end;
  
  constructor GRing<T>.GClaspNode.Create;
    begin
      self.Nextlink := self;
      self.Prevlink := self;
    end;
  
  function GRing<T>.GClaspNode.IsClasp : boolean;
    begin
      result := true;
    end;
  
  function GRing<T>.GClaspNode.Length : cardinal;
    begin
      result := 0;
    end;
  
  constructor GRing<T>.GRingNode.Create;
    begin
      inherited Create;
      items := GRing<T>.Create;
    end;
  
  function GRing<T>.GRingNode.Length : cardinal;
    begin
      result := items.Length;
    end;
    { -- list cursor ( internal type ) -- }
  
  constructor GRing<T>.GCursor.Create( lis : GRing<T> );
    begin
      _ring := lis;
      //  todo: use a dynamically resizable stack
      _path := GNodeStack.Create( kMaxDepth );
      self.Reset;
    end;
  
  procedure GRing<T>.GCursor.Reset;
    begin
      _cell := _ring._clasp;
      _idx := 0;
    end;
  
  function GRing<T>.GCursor.NextCell : GCellNode;
    begin
      _ring.FindNext( _cell, _path, result )
    end;
  
  function GRing<T>.GCursor.PrevCell : GCellNode;
    begin
      _ring.FindPrev( _cell, _path, result )
    end;
  
  function GRing<T>.GCursor.MoveNext : boolean;
    begin
      if _ring.IsEmpty then result := false
      else begin
        _cell := self.NextCell;
        inc( _idx );
        result := ( _cell <> _ring._clasp );
      end
    end;
  
  function GRing<T>.GCursor.Next( out t : T ) : boolean;
    begin
      result := self.MoveNext;
      if result then t := _cell.value;
    end;
  
  function GRing<T>.GCursor.MovePrev : boolean;
    begin
      if _ring.IsEmpty then result := false
      else begin
        _cell := self.PrevCell;
        if _idx = 0 then _idx := _ring.Length else dec( _idx );
        result := ( _cell <> _ring._clasp );
      end
    end; { GRing<T>.cursor.MovePrev }
  
  function GRing<T>.GCursor.Prev( out t : T ) : boolean;
    begin
      result := self.MovePrev;
      if result then t := _cell.value;
    end; { GRing<T>.cursor.Prev }
  
  procedure GRing<T>.GCursor.ToTop;
    begin
      if _ring.IsEmpty then raise Exception.Create('no top item to go to')
      else begin
        self.Reset;
        self.MoveNext
      end
    end;
  
    procedure GRing<T>.GCursor.ToEnd;
    begin
      if _ring.IsEmpty then raise Exception.Create('no end item to go to')
      else begin
        self.Reset;
        self.MovePrev
      end
    end;
  
    function GRing<T>.GCursor.AtTop : boolean;
    begin
      result := (self.PrevCell = _ring._clasp) and not _ring.IsEmpty;
    end;
  
    function GRing<T>.GCursor.AtEnd : boolean;
    begin
      result := (self.NextCell = _ring._clasp) and not _ring.IsEmpty;
    end;
  
    function GRing<T>.GCursor.AtClasp : boolean;
    begin
      result := (self._cell = _ring._clasp);
    end;
  
    procedure GRing<T>.GCursor.MoveTo( other : GCursor );
    begin
      _cell := other._cell;
      _idx := other._idx;
      _ring := other._ring;
    end;
  function GRing<T>.GCursor.GetValue : t;
  begin
    if _cell = _ring._clasp then
      raise Exception.Create(
              'can''t get value at the clasp. move the cursor.' )
    else result := _cell.value
  end;
  
  procedure GRing<T>.GCursor.SetValue( v : T );
  begin
    if _cell = _ring._clasp then
      raise Exception.Create(
              'can''t set value at the clasp. move the cursor.' )
    else _cell.value := v
  end;
  
  function GRing<T>.GCursor.GetIndex : cardinal;
  begin
    result := _idx;
  end;
  procedure GRing<T>.GCursor.InjectPrev( const val : T );
    var ln : GNode;
  begin
    inc( self._ring._count );
    inc( self._idx );
    ln := GCellNode.Create( val );
    ln.Nextlink := self._cell;
    ln.Prevlink := self._cell.Prevlink;
    self._cell.Prevlink.Nextlink := ln;
    self._cell.Prevlink := ln;
  end; { GRing<T>.cursor.InjectPrev }
  
  procedure GRing<T>.GCursor.InjectNext( const val : T );
    var ln : GNode;
  begin
    // we don't increase the index here because we're injecting *after*
    inc( self._ring._count );
    ln := GCellNode.Create( val );
    ln.Prevlink := self._cell;
    ln.Nextlink := self._cell.Nextlink;
    self._cell.Nextlink.Prevlink := ln;
    self._cell.Nextlink := ln;
  end; { GRing<T>.cursor.InjectNext }
  //  this is probably leaking memory. how to deal with pointers?
  procedure GRing<T>.GCursor.delete_Next;
    var temp : GNode;
  begin
    temp := self._cell.Nextlink;
    if temp <> self._ring._clasp then
    begin
      self._cell.Nextlink := temp.Nextlink;
      self._cell.Nextlink.Prevlink := self._cell;
      temp.Nextlink := nil;
      temp.Prevlink := nil;
      // todo: temp.free
    end
  end;
  
  
  constructor GRing<T>.Create;
    begin
      _clasp := GClaspNode.Create;
      _count := 0;
    end;
  
  function GRing<T>.MakeCursor : GCursor;
    begin
      result := GCursor.Create( self )
    end;
  
  { this allows 'for .. in' in the fpc / delphi compilers }
  function GRing<T>.GetEnumerator: GCursor;
    begin
      result := self.MakeCursor
    end;
  
  
  function GRing<T>.Length : cardinal;
    var ln : GNode;
    begin
      result := 0;
      ln := _clasp;
      repeat
        inc( result, ln.Length );
        ln := ln.Nextlink;
      until ln = _clasp;
    end;
  
  
  function GRing<T>.Find( pred : GNodePredicate ) : t;
    var cur : GCursor; found : boolean = false;
    begin
      cur := self.MakeCursor;
      cur.ToTop;
      repeat
        found := pred( cur.value )
      until found or not cur.MoveNext;
      if found then result := cur.value
    end; { Find }
  
  procedure GRing<T>.ForEach( action : GNodeAction );
    var item : T;
    begin
      for item in self do action( item );
    end;
  
  { Insert : add to the start of the list, right after the clasp }
  procedure GRing<T>.Insert( val : T );
    var ln : GCellNode;
  begin
    inc(_count);
    ln := GCellNode.Create( val );
    ln.Prevlink := _clasp;
    ln.Nextlink := _clasp.Nextlink;
    _clasp.Nextlink.Prevlink := ln;
    _clasp.Nextlink := ln;
  end; { Insert }
  
  procedure GRing<T>.InsertAt( val : T; at_index : cardinal );
    var cur : GCursor;
  begin
    cur := self.MakeCursor;
    if at_index >= Length then cur.ToEnd
    else while cur.index < at_index do cur.MoveNext;
    cur.InjectNext( val );
  end; { InsertAt }
  
  { Append : add to the end of the list, right before the clasp }
  procedure GRing<T>.Append( val : T );
    var ln : GNode;
  begin
    inc(_count);
    ln := GCellNode.Create( val );
    ln.Nextlink := _clasp;
    ln.Prevlink := _clasp.Prevlink;
    _clasp.Prevlink.Nextlink := ln;
    _clasp.Prevlink := ln;
  end; { Append }
  procedure GRing<T>.Remove( val : T );
    var c : GCursor; found : boolean = false;
    begin
      if not self.IsEmpty then pass
      else begin
        c := self.MakeCursor;
        repeat
          c.MoveNext;
          found := c.value = val;
        until found or c.AtEnd;
        if found then begin
          c.MovePrev;
          c.delete_Next
        end
      end
    end; { Remove }
  
  procedure GRing<T>.Drop;
      var temp : GNode;
    begin
      if IsEmpty then raise Exception.Create('attempted to drop from empty list')
      else begin
        temp := _clasp.Prevlink;
        _clasp.Prevlink := _clasp.Prevlink.Prevlink;
        temp.Prevlink := nil;
        temp.Nextlink := nil;
        temp.free;
      end
    end;
  
  function GRing<T>.IsEmpty : boolean;
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
          with ln as GCellNode do ln := ln.Nextlink;
        if ( ln is GRingNode ) then
          with ln as GRingNode do begin
            p.push( ln );
            if items.Length = 0 then ln := ln.Nextlink
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
  
  { should be exactly the same as above but s/Next/Prev/g }
  function GRing<T>.FindPrev(
      const start : GCellNode; var p : GNodeStack; out v : GCellNode ) : boolean;
      var ln : GNode;
    begin
      result := false;
      ln := start;
      repeat
        ln := ln.Prevlink;
        if ( ln is GRingNode ) then with (ln as GRingNode) do begin
          p.push( ln as GRingNode );
          if ( items.Length = 0 ) then ln := ln.Prevlink
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
      if self.IsEmpty then
        raise Exception.Create('empty list has no first member.')
      else if not FindNext( _clasp, p, result ) then
        raise Exception.Create('nested empty list has no first member.')
    end;
  
  function GRing<T>.First : T;
    begin
      result := self.FirstCell.value;
    end;
  
  function GRing<T>.LastCell : GCellNode;
    var p : GNodeStack;
    begin
      p := GNodeStack.Create( kMaxDepth );
      if IsEmpty then
        raise Exception.Create('empty list has no last member.')
      else if not FindPrev( _clasp, p, result ) then
        raise Exception.Create('nested empty list has no last member.')
    end;
  
  function GRing<T>.Last: T;
    begin
      result := self.LastCell.value;
    end; { Last }
initialization
end.
