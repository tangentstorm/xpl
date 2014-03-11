
{-- code generated from rings.pas.org --}

{$mode delphi}{$i xpc.inc}
unit rings;
interface uses xpc, sysutils, stacks, dicts;

  const kMaxDepth = 16;
  { GNode : link class with .nextLink, .prevLink }
  type GNode<T> = class
    public
      nextLink, prevLink : GNode<T>;
      constructor Create;
      function Length : cardinal; virtual;
    end;
  type GCellNode<T> = class( GNode<T> )
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
  { list.TClaspNode : a special node that joins the ends of the list }
  { It's only a cell node because that made the implementation of
    the cursor simpler. Probably there's a better design involving
    nterfaces, though. }
  //  TODO : refactor the node class hierarchy
  type GClaspNode<T> = class( GCellNode<T> )
    public
      parent : GNode<T>;
      constructor Create;
      function Length : cardinal; override;
      function IsClasp : boolean; override;
    end;
  type IRingCursor<T> = interface
    procedure Reset;
    procedure ToTop;
    procedure ToEnd;
    function AtTop : boolean;
    function AtEnd : boolean;
    function AtClasp : boolean;
    procedure MoveTo( other : IRingCursor<T> ); overload;
    procedure MoveTo( position : cardinal ); overload;
    function Next( out t : T ) : boolean;
    function Prev( out t : T ) : boolean;
    procedure InjectPrev( const val : T );
    procedure InjectNext( const val : T );
    procedure DeleteNext;
    function GetValue : T;
    procedure SetValue( v : T );
    function GetIndex : cardinal;
    function MoveNext : boolean;
    function MovePrev : boolean;
    property value : T read GetValue write SetValue;
    property index : cardinal read GetIndex;
    property current  : T read GetValue;
  end;
  type GRing<T> = class(GNode<T>)
    private type
      GNodeT         = GNode<T>;
      GNodeStack     = GStack<GNodeT>;
    public type { procedure types used by foreach, find }
      GNodeAction = procedure( var n : T ) is nested;
      GNodePredicate = function( n : T ) : Boolean is nested;
      /////////////////////////////////////////////////////////////
      // !! i don't see any way to move gcursor out of GRing yet :/
      { tracks a position in the list, even through Inserts/deletes }
      type TCursor = class (TInterfacedObject, IRingCursor<T>)
        private type
          GNodeT     = GNode<T>;
          GNodeStack = GStack<GNodeT>;
        protected
          _ring  : GRing<T>; // the main list
          _cell  : GCellNode<T>;
          _idx  : cardinal;
          _path : GNodeStack;
          function NextCell : GCellNode<T>; virtual;
          function PrevCell : GCellNode<T>; virtual;
        public
          constructor Create( lis : GRing<T> );
          procedure Reset;
          procedure ToTop;
          procedure ToEnd;
          function AtTop : boolean;
          function AtEnd : boolean;
          function AtClasp : boolean;
          procedure MoveTo( other : IRingCursor<T> ); overload;
          procedure MoveTo( position : cardinal ); overload;
          function Next( out t : T ) : boolean;
          function Prev( out t : T ) : boolean;
          procedure InjectPrev( const val : T );
          procedure InjectNext( const val : T );
          procedure DeleteNext;
          function GetValue : T;
          procedure SetValue( v : T );
          function GetIndex : cardinal;
          property value : T read GetValue write SetValue;
          property index : cardinal read GetIndex;
        public  { for..in loop interface }
          property current  : T read GetValue;
          function MoveNext : boolean;
          function MovePrev : boolean; // not part of for..in
        end;
      /////////////////////////////////////////////////////////////
    protected
      _clasp : GClaspNode<T>; // holds the two ends together
      _count : cardinal;
      function FindNext( const start : GCellNode<T>;
                         var p : GNodeStack;
                         out v : GCellNode<T> ) : boolean;
      function FindPrev( const start : GCellNode<T>;
                         var p : GNodeStack;
                         out v : GCellNode<T> ) : boolean;
      function FirstCell: GCellNode<T>;
      function LastCell: GCellNode<T>;
    public
      constructor Create;
    public { interface for adding nodes }
      procedure Append( n : GNode<T> ); overload;
      procedure Insert( n : GNode<T> ); overload;
      // TODO: procedure InsertAt( i : cardinal; val : GNode<T> ); overload;
    public { interface for adding / removing values }
      procedure Append( val : T ); overload;
      procedure Insert( val : T ); overload;
      procedure InsertAt( i : cardinal; val : T );
      procedure DeleteAt( i : cardinal );
      procedure Remove( val : T );
      procedure Drop;
      procedure ForEach( action : GNodeAction );
      function Find( pred : GNodePredicate ) : T;
      function IsEmpty: boolean;
      function First : T;
      function Last : T;
      function Length : cardinal; override;
      function MakeCursor : IRingCursor<T>;
      function GetItem(position: cardinal) : T;
      procedure SetItem(position: cardinal; val : T);
      property items[at:cardinal] : T
        read GetItem write SetItem; default;
  
    { -- interface for for..in loops -- }
    public
      function GetEnumerator : IRingCursor<T>;
    end;
  // !! The meta-data might not be the same type as the
  // actual data. (For example, you may want to represent
  // a mapping of keys of one type to data of another).
  //
  // It may make sense to use a second type parameter here,
  // but for now, I'm just going to use variants.
  type
     GElement<T> = class( GRing<T> )
       protected
         _tag  : variant;
         _attr : TVarDict;
       public
         constructor Create; overload;
         constructor Create( aTag : variant ); overload;
         procedure SetTag( val: variant );
         function GetTag : variant;
         procedure SetAttr( key : string; val: variant );
         function GetAttr( key : string ) : variant;
         property Attrs[ key : string ] : variant
           read GetAttr write SetAttr; default; // use .items for values
         property tag : variant
           read GetTag write SetTag;
     end;

implementation
  { -- link ( internal type ) -- }
  
  constructor GNode<T>.Create;
  begin
    self.NextLink := nil;
    self.PrevLink := nil;
  end;
  
  function GNode<T>.Length : cardinal;
  begin
    result := 0;
  end;
  
  constructor GCellNode<T>.Create( v : T );
    begin
    inherited Create;
    self.value := v;
  end;
  
  procedure GCellNode<T>._set( v : T );
  begin self._val := v;
  end;
  
  function GCellNode<T>._get : T;
  begin result := self._val;
  end;
  
  function GCellNode<T>.IsClasp : boolean;
  begin
    result := false;
  end;
  
  function GCellNode<T>.Length : cardinal;
  begin
    result := 1;
  end;
  
  constructor GClaspNode<T>.Create;
    begin
      self.NextLink := self;
      self.PrevLink := self;
    end;
  
  function GClaspNode<T>.IsClasp : boolean;
    begin
      result := true;
    end;
  
  function GClaspNode<T>.Length : cardinal;
    begin
      result := 0;
    end;
  
  
  
  constructor GRing<T>.Create;
    begin
      _clasp := GClaspNode<T>.Create;
      _count := 0;
    end;
  
  function GRing<T>.MakeCursor : IRingCursor<T>;
    begin
      result := TCursor.Create( self );
    end;
  
  function GRing<T>.GetItem(position: cardinal) : T;
    begin
      with MakeCursor do
        begin
          MoveTo(position);
          result := value;
        end
    end;
  
  procedure GRing<T>.SetItem(position: cardinal; val : T);
    begin
      with MakeCursor do
        begin
          MoveTo(position);
          value := val;
        end
    end;
  
  { this allows 'for .. in' in the fpc / delphi compilers }
  function GRing<T>.GetEnumerator: IRingCursor<T>;
    begin
      result := self.MakeCursor
    end;
  
  
  function GRing<T>.Length : cardinal;
    var ln : GNode<T>;
    begin
      result := 0;
      ln := _clasp;
      repeat
        inc( result, ln.Length );
        ln := ln.NextLink;
      until ln = _clasp;
    end;
  
  
  function GRing<T>.Find( pred : GNodePredicate ) : T;
    var cur : IRingCursor<T>; found : boolean = false;
    begin
      cur := self.MakeCursor;
      cur.ToTop;
      repeat
        found := pred( cur.value )
      until found or not cur.MoveNext;
      if found then result := cur.value
    end; { Find }
  
  procedure GRing<T>.ForEach( action : GNodeAction );
    var item, ref : T;
    begin // without ref, we get this error in recent 2.7.1 builds...
         // Error:Illegal assignment to for-loop variable "item"
      for item in self do begin ref := item; action( ref ) end;
    end;
  
  
  { Insert : add to the start of the list, right after the clasp }
  procedure GRing<T>.Insert( n : GNode<T> );
    begin
      inc(_count);
      n.PrevLink := _clasp;
      n.NextLink := _clasp.NextLink;
      _clasp.NextLink.PrevLink := n;
      _clasp.NextLink := n;
    end;
  
  { Append : add to the end of the list, right before the clasp }
  procedure GRing<T>.Append( n : GNode<T> );
    begin
      inc(_count);
      n.NextLink := _clasp;
      n.PrevLink := _clasp.PrevLink;
      _clasp.PrevLink.NextLink := n;
      _clasp.PrevLink := n;
    end;
  
  { Insert : add to the start of the list, right after the clasp }
  procedure GRing<T>.Insert( val : T );
    begin
      self.Insert(GCellNode<T>.Create( val ));
    end;
  
  procedure GRing<T>.InsertAt( i : cardinal; val : T );
    var cur : IRingCursor<T>;
    begin
      cur := self.MakeCursor;
      if i >= Length then cur.ToEnd
      else while cur.index < i do cur.MoveNext;
      cur.InjectNext( val );
    end; { InsertAt }
  
  procedure GRing<T>.DeleteAt( i : cardinal );
    var c : IRingCursor<T>; n : cardinal;
    begin
      c := self.MakeCursor;
      if i = 0 then
        c.DeleteNext
      else
        begin
          c.MoveTo(i);
          c.ToTop;
          for n := 1 to i do c.MoveNext;
          c.MovePrev;
          c.DeleteNext;
        end;
    end; { DeleteAt }
  
  { Append : add to the end of the list, right before the clasp }
  procedure GRing<T>.Append( val : T );
    begin
      self.Append(GCellNode<T>.Create( val ));
    end;
  procedure GRing<T>.Remove( val : T );
    var c : IRingCursor<T>; found : boolean = false;
    begin
      if not self.IsEmpty then ok
      else begin
        c := self.MakeCursor;
        repeat
          c.MoveNext;
          found := c.value = val;
        until found or c.AtEnd;
        if found then begin
          c.MovePrev;
          c.DeleteNext
        end
      end
    end; { Remove }
  
  procedure GRing<T>.Drop;
      var temp : GNode<T>;
    begin
      if IsEmpty then raise Exception.Create('attempted to drop from empty list')
      else begin
        temp := _clasp.PrevLink;
        _clasp.PrevLink := _clasp.PrevLink.PrevLink;
        temp.PrevLink := nil;
        temp.NextLink := nil;
        temp.free;
      end
    end;
  
  function GRing<T>.IsEmpty : boolean;
    begin result := _count = 0
    end;
  
  function GRing<T>.FindNext(const start : GCellNode<T>;
                               var p     : GNodeStack;
                               out v     : GCellNode<T>) : boolean;
    var ln : GNode<T>;
    begin
      result := false;
      ln := start;
      repeat
        if ( ln is GCellNode<T> ) then
          with ln as GCellNode<T> do ln := ln.NextLink;
        if ( ln is GRing<T> ) then
          with ln as GRing<T> do begin
            p.push( ln );
            if Length = 0 then ln := ln.NextLink
            else ln := _clasp
          end
        else if ln is GClaspNode<T> then
          if p.count > 0 then ln := p.pop
          else ln := _clasp
        else if ln is GCellNode<T> then
          begin
            result := true;
            v := ln as GCellNode<T>;
          end
      until result or ( ln = _clasp );
      v := ln as GCellNode<T>;
    end;
  
  { should be exactly the same as above but s/Next/Prev/g }
  function GRing<T>.FindPrev(
                     const start : GCellNode<T>;
                       var p     : GNodeStack;
                       out v     : GCellNode<T> ) : boolean;
      var ln : GNode<T>;
    begin
      result := false;
      ln := start;
      repeat
        ln := ln.PrevLink;
        if ( ln is GRing<T> ) then
          with (ln as GRing<T>) do begin
            p.push( ln as GRing<T> );
            if ( Length = 0 ) then ln := ln.PrevLink
            else result := FindPrev(_clasp, p, v )
          end
        else if ln is GClaspNode<T> then begin
          if p.count > 0 then ln := p.pop
          else ln := _clasp
        end
        else if ln is GCellNode<T> then begin
          result := true;
          v := ln as GCellNode<T>;
        end
      until result or ( ln = _clasp );
      v := ln as GCellNode<T>;
    end;
  
  function GRing<T>.FirstCell : GCellNode<T>;
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
  
  function GRing<T>.LastCell : GCellNode<T>;
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
  
  constructor GRing<T>.TCursor.Create( lis : GRing<T> );
    begin
      _ring := lis;
      //  todo: use a dynamically resizable stack
      _path := GNodeStack.Create( kMaxDepth );
      self.Reset;
    end;
  
  procedure GRing<T>.TCursor.Reset;
    begin
      _cell := _ring._clasp;
      _idx := 0;
    end;
  
  function GRing<T>.TCursor.NextCell : GCellNode<T>;
    begin
      _ring.FindNext( _cell, _path, result )
    end;
  
  function GRing<T>.TCursor.PrevCell : GCellNode<T>;
    begin
      _ring.FindPrev( _cell, _path, result )
    end;
  
  function GRing<T>.TCursor.MoveNext : boolean;
    begin
      if _ring.IsEmpty then result := false
      else begin
        _cell := self.NextCell;
        inc( _idx );
        result := ( _cell <> _ring._clasp );
      end
    end;
  
  function GRing<T>.TCursor.Next( out t : T ) : boolean;
    begin
      result := self.MoveNext;
      if result then t := _cell.value;
    end;
  
  function GRing<T>.TCursor.MovePrev : boolean;
    begin
      if _ring.IsEmpty then result := false
      else begin
        _cell := self.PrevCell;
        if _idx = 0 then _idx := _ring.Length else dec( _idx );
        result := ( _cell <> _ring._clasp );
      end
    end;
  
  function GRing<T>.TCursor.Prev( out t : T ) : boolean;
    begin
      result := self.MovePrev;
      if result then t := _cell.value;
    end;
  
  procedure GRing<T>.TCursor.ToTop;
    begin
      if _ring.IsEmpty then raise Exception.Create('no top item to go to')
      else begin
        self.Reset;
        self.MoveNext
      end
    end;
  
    procedure GRing<T>.TCursor.ToEnd;
    begin
      if _ring.IsEmpty then raise Exception.Create('no end item to go to')
      else begin
        self.Reset;
        self.MovePrev
      end
    end;
  
    function GRing<T>.TCursor.AtTop : boolean;
    begin
      result := (self.PrevCell = _ring._clasp) and not _ring.IsEmpty;
    end;
  
    function GRing<T>.TCursor.AtEnd : boolean;
    begin
      result := (self.NextCell = _ring._clasp) and not _ring.IsEmpty;
    end;
  
    function GRing<T>.TCursor.AtClasp : boolean;
    begin
      result := (self._cell = _ring._clasp);
    end;
  
    procedure GRing<T>.TCursor.MoveTo( other : IRingCursor<T> );
    begin
      with other as GRing<T>.TCursor do
        begin
          self._cell := _cell;
          self._idx  := _idx;
          self._ring := _ring;
        end;
    end;
  
    procedure GRing<T>.TCursor.MoveTo( position : cardinal );
    var i : cardinal;
    begin
      if position < _ring.length then
        begin
          self.ToTop;
          if position > 0 then
            for i := 1 to position do self.MoveNext
        end
      else raise Exception.Create('out of bounds: '
                                  + IntToStr(position))
    end;
  function GRing<T>.TCursor.GetValue : t;
  begin
    if _cell = _ring._clasp then
      raise Exception.Create(
              'can''t get value at the clasp. move the cursor.' )
    else result := _cell.value
  end;
  
  procedure GRing<T>.TCursor.SetValue( v : T );
  begin
    if _cell = _ring._clasp then
      raise Exception.Create(
              'can''t set value at the clasp. move the cursor.' )
    else _cell.value := v
  end;
  
  function GRing<T>.TCursor.GetIndex : cardinal;
  begin
    result := _idx;
  end;
  procedure GRing<T>.TCursor.InjectPrev( const val : T );
    var ln : GNode<T>;
  begin
    inc( self._ring._count );
    inc( self._idx );
    ln := GCellNode<T>.Create( val );
    ln.NextLink := self._cell;
    ln.PrevLink := self._cell.PrevLink;
    self._cell.PrevLink.NextLink := ln;
    self._cell.PrevLink := ln;
  end;
  
  procedure GRing<T>.TCursor.InjectNext( const val : T );
    var ln : GNode<T>;
  begin
    // we don't increase the index here because we're injecting *after*
    inc( self._ring._count );
    ln := GCellNode<T>.Create( val );
    ln.PrevLink := self._cell;
    ln.NextLink := self._cell.NextLink;
    self._cell.NextLink.PrevLink := ln;
    self._cell.NextLink := ln;
  end;
  //  this is probably leaking memory. how to deal with pointers?
  procedure GRing<T>.TCursor.DeleteNext;
    var temp : GNode<T>;
  begin
    temp := self._cell.NextLink;
    if temp <> self._ring._clasp then
    begin
      self._cell.NextLink := temp.NextLink;
      self._cell.NextLink.PrevLink := self._cell;
      temp.NextLink := nil;
      temp.PrevLink := nil;
      // todo: temp.free
    end
  end;
  
  
  constructor GElement<T>.Create;
    begin
      inherited Create;
      _attr := TVarDict.Create;
    end;
  
  constructor GElement<T>.Create( aTag : variant );
    begin
      self.Create;
      self.tag := aTag;
    end;
  
  
  procedure GElement<T>.SetTag( val: variant );
    begin
      _tag := val
    end;
  
  function GElement<T>.GetTag : variant;
    begin
      result := _tag
    end;
  
  
  procedure GElement<T>.SetAttr( key : string; val: variant );
    begin
      _attr[ key ] := val
    end;
  
  function GElement<T>.GetAttr( key : string ) : variant;
    begin
      result := _attr[ key ]
    end;
  
initialization
end.
