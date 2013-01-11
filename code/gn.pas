{$i xpc.inc}
unit gn; {python style generators. work in progress. }
interface uses xpc, sysutils, ll;

  type
    (* exception hierarchy *)
    exception = sysutils.exception;
			 
    stopiteration = class ( exception )
    end;		 
			 
    (* python-style generators using a state machine *)
    generic generator<t> = class
      type t_list = specialize ll.list<t>;
    public
      curr : cardinal;
      finished : boolean;
      function next : t;
      function as_list : t_list;
    end;
      
    generic coroutine<m,t> = class ( specialize generator<t> )
      type msgfunc = function( msg : m ) : t is nested;
    public
      send : msgfunc;
      constructor create( f : msgfunc );
      end;


implementation

  constructor generator.create;
  begin
    curr := 0;
  end;
  
  function generator.next : t;
  begin
    inc( self.curr );
    result := self.func( self.curr );
  end; { generator.next }

  procedure generator.send( msg : t );
  begin
    writeln( ' sq.generator.send does nothing yet.' );
  end;

  function generator.to_list : specialize ll.list<t>;
  begin
    result.create;
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

  function iter.first : t;
  begin
    writeln( ' error! iter.first not defined in sq.pas' );
    result := nil; {  TODO }
  end;

  function iter.after( item : t ) : t;
  begin
    writeln( ' error! iter.after not defined in sq.pas' );
    result := nil; {  TODO }
  end; { iter.after }

  function iter.to_array : iter.brx.dynarray;
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
