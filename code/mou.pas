unit mou; { mouse stuff }

{ TODO: replace this whole unit. it uses ancient MS-DOS/BIOS interrupts. }

{$IFDEF FPC}{$asmmode intel}{$ENDIF}

interface

  type
    GCursor = record
		screenmask,
		cursormask : array [0..15] of WORD;
		hotx, hoty : INTEGER;
	      end;

  var
    mvisible			    : BOOLEAN; { TODO : rename to isMouseVisible }
    mpresent			    : BOOLEAN;
    mstatus			    : BOOLEAN;
    nb				    : INTEGER;
    state, mx, my, lstate, lmx, lmy : INTEGER;
    KbdIntVec			    : procedure;

  function mousethere : BOOLEAN;
  procedure resetmouse( var status : BOOLEAN; var numbtns : INTEGER );

  procedure showmouse( yn : BOOLEAN ); deprecated;
  procedure show;
  procedure hide;
  procedure show_if( cond : boolean );

  procedure mouseon;
  procedure getmpos;
  procedure gettextmpos;
  procedure setmpos( a, b : INTEGER );
  procedure setmwin( a1, b1, a2, b2 : INTEGER );
  procedure setgcurs( gcurs : gcursor );
  procedure settcurson( ch : CHAR; at : BYTE ); { uses special cursor }
  procedure settcursoff; { goes back to default }
  procedure setmaccel( t : INTEGER );
  function mousemoved : BOOLEAN;
  (*  { magicmouse : erases mouse while key is pressed }
  procedure magicmouse; interrupt; {NEVER CALL THIS DIRECTLY!!!}
  procedure installmagicmouse;
  proecdure removemagicmouse; *)


implementation uses cw, dos;

var
  regs : registers;


  function mousethere : BOOLEAN;
    {>> var dOff, DSEG : INTEGER; <<}
  begin
    mousethere := false;
    {>>
      dOff := MemW[ 0000:0204 ];
      dSeg := MemW[ 0000:0206 ];
      if ( ( DSEG = 0 ) or ( dOff = 0 ) ) then  mousethere := FALSE;
   else mousethere := mem[ dSeg:dOff ] <> 207;
      <<}
  end;


  procedure resetmouse( var status : BOOLEAN; var numbtns : INTEGER );
  begin
    (*
      regs.ax := $00;
      intr( $33, regs );
      status  := regs.ax <> 0;
      numbtns := regs.bx;
      *)
  end;


  procedure show; begin end;
  procedure hide; begin end;
  procedure show_if( cond : boolean ); begin end;
  
  procedure showmouse( yn : BOOLEAN );
  begin
    if not mpresent then begin
      EXIT;
    end;
    (*
    if yn and not mvisible then begin
      regs.ax  := $01;
      mvisible := TRUE;
      intr( $33, Regs );
    end else if mvisible and not yn then begin
      regs.ax  := $02;
      mvisible := FALSE;
      intr( $33, regs );
    end;
      *)
  end;


  procedure mouseon;
  begin
    mvisible := FALSE;
    mpresent := mousethere;
    if mpresent then begin
      resetmouse( mstatus, nb );
      showmouse( TRUE );
      getmpos;
      getmpos; { initializes mx, my, lmx, lmy }
    end;
  end;


  procedure getmpos;
  begin
    if not mpresent then begin
      EXIT;
    end;
    (*
    lstate     := state;
    lmx     := mx;
    lmy     := my;
    regs.ax := $03;
    intr( $33, regs );
    state := Regs.bx;
    mx := regs.cx;
    my := regs.dx;
    *)
  end;


  procedure gettextmpos;
  begin
    getmpos;
    mx := mx div 8 + 1;
    my := my div 8 + 1;
  end;


  procedure setmpos( a, b : INTEGER );
  begin
    if not mpresent then begin
      EXIT;
    end;
  (*
    regs.ax := $04;
    regs.cx := a;
    regs.dx := b;
    intr( $33, regs );
    mx := a;
    my := b;
  *)
  end;


  procedure setmwin( a1, b1, a2, b2 : INTEGER );
  begin
    if not mpresent then begin
      EXIT;
    end;
  (*
    regs.ax := $07;
    regs.cx := min( a1, a2 );
    regs.dx := max( a1, a2 );
    intr( $33, regs );
    regs.ax := $08;
    regs.cx := min( b1, b2 );
    regs.dx := max( b1, b2 );
    intr( $33, regs );
  *)
  end;


  procedure setgcurs( gcurs : gcursor );
    var
      o, s : WORD;
  begin
    if not mpresent then begin
      EXIT;
    end;
    (*
      o := OFS( gcurs.screenmask );
      s := SEG( gcurs.screenmask );
      asm
        MOV     AX, $09
        MOV     BX, gcurs.hotx
        MOV     CX, gcurs.hoty
        MOV     DX, o
        MOV     ES, s
        INT     33h
      end;
    *)
  end;


  procedure settcurson( ch : CHAR; at : BYTE ); { uses special cursor }
    var
      w : WORD;
  begin
    w := ORD( ch ) + ( at shl 8 );
  (*
    asm
      MOV     AX, $0A
      MOV     BX, 0 {software}
      MOV     CX, $F000
      MOV     DX, w
      INT     33h
    end;
  *)
  end; { settcurson }


  procedure settcursoff; { goes back to default }
  begin
  (*
    asm
      MOV     AX, $0A
      MOV     BX, 1 // hardware
      MOV     CX, 6
      MOV     DX, 7
      INT     33h
    end;
  *)
  end;


  procedure setmaccel( t : INTEGER );
  begin
    if not mpresent then begin
      EXIT;
    end;
  (*
    asm
      MOV     AX, 13h
      MOV     DX, t
      INT     33h
    end;
  *)
  end;


  function mousemoved : BOOLEAN;
  begin
    mousemoved := ( lmx <> mx ) or ( lmy <> my );
  end;

begin
  mpresent := FALSE;
  mvisible := FALSE;
  mx  := 0;
  my  := 0;
  state  := 0;
  lmx := 0;
  lmy := 0;
  lstate := 0;
end.
