{
 status: sq.pas does not compile.
 experimental translation of a coffeescript module i wrote.
}
{$i xpc.inc}
unit sq;{ sequences }
interface uses xpc, ll, stacks, li; { todo: gn}

  type
      (* iter is a base class for iterable objects. *)
    generic iter<t> = class
      type tarray = array of t;
    public
      function first : t; virtual;
      function after( item : t ): t; virtual;
      function as_array : tarray;
    end;
  
    (* Seq is like an Iter but allows moving forward or backward. *)
    generic seq<t> = class ( specialize iter<t> )
      function final : t;
      function prior( item : t) : t; virtual;
      function offset( item : t; k : integer ) : t;
      function keyed( key : integer ) : t;
      function length : integer;
    end;

    (* IterSeq wraps an Iter, and can itself be iterated over. *)
    generic iterseq<t> = class ( specialize seq<t> )
    private
      type t_iter = specialize iter<t>;
    public
      constructor create( it : t_iter );
      function first  : t; override;
      function after( item : t ): t; override;
      function final  : t; virtual;
      function prior( item : t ) : t; override;
      function offset( item : t; k : integer ) : t; virtual;
      function keyed( key : integer ) : t; virtual;
    end;

implementation


  function seq.final : t;
  begin
    writeln( ' error! seq.final not defined in sq.pas' );
    result := nil; {  TODO }
  end;

  function seq.prior( item : t ): t;
  begin
    writeln( ' error! seq.prior not defined in sq.pas' );
    result := nil; {  TODO }
  end;

  function seq.offset( item : t;  k : integer ): t;
  begin
    writeln( ' error! seq.offset not defined in sq.pas' );
    result := nil; {  TODO }
  end;

  function seq.keyed( key : integer ) : t;
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

  function iterseq.first: t;
  begin
    result := self.data[ 0 ]
  end;

  function iterseq.final: t;
  begin
    result := self.data[ system.length( self.data ) - 1 ];
  end;

  function iterseq.after( item : t ): t;
  begin
    writeln( ' iterseq.after not implemented' );
    result := self.data[ 0 ];
  end;

  function iterseq.prior( item : t ): t;
  begin
    writeln( ' iterseq.prior not implemented' );
    result := self.data[ 0 { item - 1 } ];
  end;

  function iterseq.offset( item	: t; k :integer ) : t;
  begin
    writeln( ' iterseq.offset not implemented' );
    result := nil ; { self.data.at (self.data.indexOf item) + k }
  end;

  function iterseq.keyed( key : integer ) : t;
  begin
    result := self.data[ key ];
  end;

end.
