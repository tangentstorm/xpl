{$i xpc.inc }
unit sq;{ sequences }
interface uses xpc, ll;

  type
    nodefunc = function( i : int32 ) : pnode ;
    nodes    = array of pnode;
  
  type			      

    (* exception hierarchy *)
    exception	  = class
    end;

    stopiteration = class ( exception )
    end;

    (* gen is a way to define python-style generators using a state machine *)
    gen	= class
      func : nodefunc;
      curr : cardinal;
      finished : boolean;
      constructor create( f : nodefunc );
      procedure send( msg : pnode );
      function next : pnode;
      function to_list : ll.list;
    end;

    (* iter is a base class for iterable objects. *)
    iter = class
      function first : pnode; virtual;
      function after( item : pnode ): pnode; virtual;
      function to_array : nodes;
    end;

    (* Seq is like an Iter but allows moving forward or backward. *)
    seq = class ( iter )
      function final : pnode;
      function prior( item : pnode) : pnode; virtual;
      function offset( item : pnode; k : integer ) : pnode;
      function keyed( key : integer ) : pnode;
      function length : integer;
    end;

    (* IterSeq wraps an Iter, and can itself be iterated over. *)
    iterseq = class ( seq )
      data : nodes;
      constructor create( it : iter );
      function first  : pnode; override;
      function after( item : pnode ): pnode; override;
      function final  : pnode; virtual;
      function prior( item : pnode ) : pnode; override;
      function offset( item : pnode; k : integer ) : pnode; virtual;
      function keyed( key : integer ) : pnode; virtual;
    end;		  

implementation

  constructor gen.create( f : nodefunc );
  begin
    func := f;
    curr := 0;
  end;

  function gen.next : pnode;
  begin
    inc( self.curr );
    result := self.func( self.curr );
  end; { gen.next }
  
  procedure gen.send( msg : pnode );
  begin
    writeln( ' sq.gen.send does nothing yet.' );
  end;

  function gen.to_list : ll.list;
  begin
    result.init;
    while not self.finished do result.append( self.next );
  end;

  (* TODO : Example generator : count() *)
  {
      count = -> new Gen (curr, prev, ctx, msg) ->
      switch curr
      when 0 then next= 0
      when 1 then next= prev + 1; goto = 1
      else throw new StopIteration
      result := [goto ? curr + 1, next , ctx]
      gen	  = count()
      check.type(gen, Gen)

    check.equal( gen.next(), 0 )
    check.equal( gen.next(), 1 )
    check.equal( gen.next(), 2 )
    }

  function iter.first : pnode;
  begin
    writeln( ' error! iter.first not defined in sq.pas' );
    result := nil; {  TODO }
  end;

  function iter.after( item : pnode ) : pnode;
  begin
    writeln( ' error! iter.after not defined in sq.pas' );
    result := nil; {  TODO }
  end; { iter.after }

  function iter.to_array : nodes;
  begin
    writeln( ' error! iter.to_array not defined in sq.pas' );
    setlength( result, 0 );
  end;


  {  TODO finish porting this example generator (  Count from seq.cf )
  begin new Gen (curr, prev, ctx, msg);
    try switch curr
      when 0 then next = self.first
      when 1 then next = self.after(prev); goto = 1
    else throw new StopIteration
    except SequenceError
      throw new new StopIteration
      result := [goto ? curr + 1, next , ctx]
    end
  end;
  }
  
  function seq.final : pnode;
  begin
    writeln( ' error! seq.final not defined in sq.pas' );
    result := nil; {  TODO }
  end;

  function seq.prior( item : pnode ): pnode;
  begin
    writeln( ' error! seq.prior not defined in sq.pas' );
    result := nil; {  TODO }
  end;

  function seq.offset( item : pnode;  k : integer ): pnode;
  begin
    writeln( ' error! seq.offset not defined in sq.pas' );
    result := nil; {  TODO }
  end;

  function seq.keyed( key : integer ) : pnode;
  begin
    writeln( ' error! seq.keyed not defined in sq.pas' );
    result := nil; {  TODO }
  end;
  
  function seq.length : integer;
  begin
    writeln( ' error! seq.keyed not defined in sq.pas' );
    result := 0; {  TODO }
  end;

  constructor iterseq.create( it : iter );
  begin
    self.data := it.to_array;
  end;

{  function iterseq.to_gen : gen;
  begin new Iter(self.data)
  end; }

  function iterseq.first: pnode;
  begin
    result := self.data[ 0 ]
  end;

  function iterseq.final: pnode;
  begin
    result := self.data[ system.length( self.data ) - 1 ];
  end;

  function iterseq.after( item : pnode ): pnode;
  begin
    writeln( ' iterseq.after not implemented' );
    result := self.data[ 0 ];
  end;

  function iterseq.prior( item : pnode ): pnode;
  begin
    writeln( ' iterseq.prior not implemented' );
    result := self.data[ 0 { item - 1 } ];
  end;

  function iterseq.offset( item	: pnode; k :integer ) : pnode;
  begin
    writeln( ' iterseq.offset not implemented' );
    result := nil ; { self.data.at (self.data.indexOf item) + k }
  end;

  function iterseq.keyed( key : integer ) : pnode;
  begin
    result := self.data[ key ];
  end;

end.
