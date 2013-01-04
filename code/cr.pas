{$i xpc.inc}
unit cr; { cursors }
interface uses xpc, sq, ll, stacks;

  type

    (**
      * A Cursor does the actual work of navigating back and
      * forth along a Sequence. A Sequence can have any number
      * of cursors moving around on it.
      *
      * TODO: cur.py  needs self.key and self.val to match cur.cf and cr.pas
     *)
    cursor = class
      seq : sq.seq;
      focus : node;
      constructor create( aseq : seq );
      procedure to_head;
      procedure to_next;
      procedure to_prev;
      procedure to_foot;
      procedure mark;
      procedure back;
    private
      marks : Stack;
      pos   : integer;
    end;

implementation

  constructor cursor.create( aseq : sq.seq );
  begin
    self.seq := aseq;
    self.to_head()
  end;

  procedure cursor.to_head;
  begin
    self.focus := self.seq.first();
    self.pos := 0;
  end;

  procedure cursor.to_next;
  begin
    self.focus := self.seq.after( self.focus );
    inc( self.pos );
  end;

  procedure cursor.to_prev;
  begin
    self.focus := self.seq.prior( self.focus );
    dec( self.pos );
  end;

  procedure cursor.to_foot;
  begin
    self.focus := self.seq.final;
    self.pos := self.seq.length - 1;
  end;

  procedure cursor.mark;
  begin
    self.marks.push( self.pos )
  end;

  procedure cursor.back;
  begin
    self.pos := self.marks.pop;
    self.focus := self.seq.keyed( self.pos );
  end;

begin
end.
