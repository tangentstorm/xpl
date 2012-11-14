{$ifdef fpc}{$mode delphi}{$asmmode intel}{$endif}

unit hz; { sound synth }

interface

TYPE
   sbiset = ( modmult, modlev, modAtt, modDec, modSus, modRel,
      carmult, carlev, carAtt, carDec, carSus, carRel );
   sbimember = sbiset;
   sbi = ARRAY[sbiset] OF BYTE;

   SoundSystem = OBJECT
      {      soundbuffer : ARRAY[ 1 .. 1024 ] OF note;}
      sboctave : BYTE; { FOR speaker emulation }
      SndOn, SbPresent, SbOn : BOOLEAN;
      PROCEDURE Init;
      PROCEDURE sbSetReg( reg, VAL : BYTE );
      PROCEDURE sbSetLeftReg( reg, VAL : BYTE );
      PROCEDURE sbSetRightReg( reg, VAL : BYTE );
      PROCEDURE sbiset( voice : BYTE; ins : sbi );
      FUNCTION sbdetected : BOOLEAN;
      PROCEDURE sbInit;
      PROCEDURE Sound( Hz : WORD );
      PROCEDURE SoundC( Hz : WORD; c : BYTE ); {use a different channel}
      PROCEDURE SoundLeft( Hz : WORD );
      PROCEDURE SoundRight( Hz : WORD );
      PROCEDURE NoSound;
      PROCEDURE Click;
      PROCEDURE SilverSound;
      PROCEDURE Beep;
      PROCEDURE Pop;
      PROCEDURE Zap;
      PROCEDURE Slide;
      PROCEDURE Ding;
      PROCEDURE Ansiplay( SndC : STRING );
      PROCEDURE On;
      PROCEDURE Off;
   END;

CONST
   idefault : sbi = ( $01, $10, $F, $0, $7, $7,
      $01, $00, $F, $0, $7, $7 );
   imarimba : sbi = ( $0c, $27, $f, $5, $0, $7,
      $02, $00, $f, $4, $f, $7 );

VAR
   Spkr :  SoundSystem;
   Spkr2 : SoundSystem; { TO access BOTH soundblaster AND speaker }

implementation uses crt {$IFDEF GPC}, system{$ENDIF}; { for Lo/Hi }

VAR
   Vari, Octave, Numb : INTEGER;
   Test, Dly, Intern, DlyKeep : LONGINT;
   Flager, ChartoPlay : CHAR;
   Typom, Min1, Adder : REAL;


PROCEDURE AnsiPlay( SoundC : STRING );  {from PC magazine}


   FUNCTION IsNumber( ch : CHAR ) : BOOLEAN;
   BEGIN
      IsNumber := ( CH >= '0' ) AND ( CH <= '9' );
   END;

   {Converts a string TO an integer}
   FUNCTION value( s : STRING ) : INTEGER;
   VAR
      ss, sss : INTEGER;
   BEGIN
      VAL( s, ss, sss );
      value := ss;
   END;

   {Plays the selected note}
   PROCEDURE sounder( key : CHAR; flag : CHAR );
   VAR
      old, NEW, new2 : REAL;
   BEGIN
      adder  := 1;
      old    := dly;
      NEW    := dly;
      intern := POS( key, 'C D EF G A B' ) - 1;
      IF ( flag = '+' ) AND ( key <> 'E' ) AND ( key <> 'B' )
      {See IF note} THEN BEGIN
         INC( intern );
      END;                              {is sharped }
      IF ( flag = '-' ) AND ( key <> 'F' ) AND ( key <> 'C' ) THEN BEGIN
         DEC( intern );
      END;                              {OR a flat. }
      WHILE SoundC[vari + 1] = '.' DO BEGIN
         INC( vari );
         adder := adder / 2;
         NEW   := NEW + ( old * adder );
      END;
      new2 := ( NEW / typom ) * ( 1 - typom );
      spkr.sound( ROUND( EXP( ( octave + intern / 12 ) * LN( 2 ) ) ) ); {Play the note}
      Delay( TRUNC( NEW ) );
      spkr.Nosound;
      Delay( TRUNC( new2 ) );
   END;

   {Calculate delay FOR a specified note length}
   FUNCTION delayer1 : INTEGER;
   BEGIN
      numb     := value( SoundC[vari + 1] );
      delayer1 := TRUNC( ( 60000 / ( numb * min1 ) ) * typom );
   END;

   {Used as above, except reads a number >10}

   FUNCTION delayer2 : INTEGER;
   BEGIN
      numb     := value( SoundC[vari + 1] + SoundC[vari + 2] );
      delayer2 := TRUNC( ( 60000 / ( numb * min1 ) ) * typom );
   END;

BEGIN                           {Play}
   SoundC := SoundC + ' ';
   FOR vari := 1 TO LENGTH( SoundC ) DO BEGIN
      {Go through entire string}
      SoundC[vari] := UPCASE( SoundC[vari] );
      CASE SoundC[vari] OF
         {Check TO see}    'C', 'D', 'E',
         {IF char is a}    'F', 'G', 'A',
         {note}            'B' : BEGIN
            flager     := ' ';
            dlykeep    := dly;
            chartoplay := SoundC[vari];
            IF ( SoundC[vari + 1] = '-' ) OR
               ( SoundC[vari + 1] = '+' ) THEN
               {Check FOR flats & sharps}    BEGIN
               flager := SoundC[vari + 1];
               INC( vari );
            END;
            IF IsNumber( SoundC[vari + 1] ) THEN BEGIN
               IF IsNumber( SoundC[vari + 2] ) THEN BEGIN
                  test := delayer2;
                  {Make sure # is legal}                 IF numb < 65 THEN BEGIN
                     dly := test;
                  END;
                  INC( vari, 2 );
               END ELSE BEGIN
                  test := delayer1;
                  {Make sure # is legal}                 IF numb > 0 THEN BEGIN
                     dly := test;
                  END;
                  INC( vari );
               END;
            END;
            sounder( chartoplay, flager );
            dly := dlykeep;
         END;
         {Check FOR}       'O' : BEGIN
            {octave change}            INC( vari );
            CASE SoundC[vari] OF
               '-' : BEGIN
                  IF octave > 1 THEN BEGIN
                     DEC( octave );
                  END;
               END;
               '+' : BEGIN
                  IF octave < 7 THEN BEGIN
                     INC( octave );
                  END;
               END;
               '1', '2', '3',
               '4', '5', '6',
               '7' : BEGIN
                  octave := value( SoundC[vari] ) + 4;
               END;
            ELSE BEGIN
               DEC( vari );
            END;
            END;
         END;
         {Check FOR a}     'L' : BEGIN
            IF IsNumber( SoundC[vari + 1] ) THEN {change IN length} BEGIN
               {FOR notes}                   IF IsNumber( SoundC[vari + 2] ) THEN BEGIN
                  test := delayer2;
                  IF numb < 65 THEN {Make sure # is legal} BEGIN
                     dly := test;
                  END;
                  INC( vari, 2 );
               END ELSE BEGIN
                  test := delayer1;
                  IF numb > 0 THEN {Make sure # is legal} BEGIN
                     dly := test;
                  END;
                  INC( vari );
               END;
            END;
         END;
         {Check FOR pause} 'P' : BEGIN
            IF IsNumber( SoundC[vari + 1] ) THEN {AND it's length} BEGIN
               IF IsNumber( SoundC[vari + 2] ) THEN BEGIN
                  test := delayer2;
                  IF numb < 65 THEN {Make sure # is legal} BEGIN
                     Delay( test );
                  END;
                  INC( vari, 2 );
               END ELSE BEGIN
                  test := delayer1;
                  IF numb > 0 THEN {Make sure # is legal} BEGIN
                     Delay( test );
                  END;
                  INC( vari );
               END;
            END;
         END;
         {Check FOR}       'T' : BEGIN
            IF IsNumber( SoundC[vari + 1] ) AND
               {tempo change}             IsNumber( SoundC[vari + 2] ) THEN BEGIN
               IF IsNumber( SoundC[vari + 3] ) THEN BEGIN
                  min1 :=
                     value( SoundC[vari + 1] + SoundC[vari + 2] +
                     SoundC[vari + 3] );
                  INC( vari, 3 );
                  IF min1 > 255 THEN {Make sure # isn't too big} BEGIN
                     min1 := 255;
                  END;
               END ELSE BEGIN
                  min1 :=
                     value( SoundC[vari + 1] + SoundC[vari + 2] );
                  IF min1 < 32 THEN {Make sure # isn't too small} BEGIN
                     min1 := 32;
                  END;
               END;
               min1 := min1 / 4;
            END;
         END;
         {Check FOR music} 'M' : BEGIN
            {TYPE}                     INC( vari );
            CASE UPCASE( SoundC[vari] ) OF
               {Normal}                      'N' : BEGIN
                  typom := 7 / 8;
               END;
               {Legato}                      'L' : BEGIN
                  typom := 1;
               END;
               {Staccato}                    'S' : BEGIN
                  typom := 3 / 4;
               END;
            END;
         END;
      END;
   END;
END;

{=====}

PROCEDURE soundsystem.sbSetReg( reg, VAL : BYTE );
VAR
   sbcounter, sbnothing : BYTE;
BEGIN
  {
   port[$0388] := reg;
   FOR sbcounter := 1 TO 6 DO BEGIN
      sbnothing := port[$0388];
   END;
   port[$0389] := VAL;
   FOR sbcounter := 1 TO 35 DO BEGIN
      sbnothing := port[$0388];
   END;
  }
END;


PROCEDURE soundsystem.sbSetleftReg( reg, VAL : BYTE );
VAR
   sbcounter, sbnothing : BYTE;
BEGIN
  {
   port[$0220] := reg;
   FOR sbcounter := 1 TO 6 DO BEGIN
      sbnothing := port[$0388];
   END;
   port[$0221] := VAL;
   FOR sbcounter := 1 TO 35 DO BEGIN
      sbnothing := port[$0388];
   END;
  }
END;


PROCEDURE soundsystem.sbSetRightReg( reg, VAL : BYTE );
VAR
   sbcounter, sbnothing : BYTE;
BEGIN
  {
   port[$0222] := reg;
   FOR sbcounter := 1 TO 6 DO BEGIN
      sbnothing := port[$0388];
   END;
   port[$0223] := VAL;
   FOR sbcounter := 1 TO 35 DO BEGIN
      sbnothing := port[$0388];
   END;
  }
END;


PROCEDURE soundsystem.sbiset( voice : BYTE; ins : sbi );
BEGIN
   sbSetReg( $20 + voice, ins[modmult] );
   sbSetReg( $40 + voice, ins[modlev] );
   sbSetReg( $60 + voice, ins[modAtt] * 16 + ins[modDec] );
   sbSetReg( $80 + voice, ins[modSus] * 16 + ins[modRel] );
   sbSetReg( $23 + voice, ins[carMult] );
   sbSetReg( $43 + voice, ins[carlev] );
   sbSetReg( $63 + voice, ins[carAtt] * 16 + ins[carDec] );
   sbSetReg( $83 + voice, ins[carSus] * 16 + ins[carRel] );
END;


FUNCTION soundsystem.sbdetected : BOOLEAN;
VAR
   sbstatus1, sbstatus2 : BYTE;
BEGIN
  (*
   sbSetReg( $04, $60 ); {RESET timers}
   sbSetReg( $04, $80 ); {turn interrupts on}
   sbstatus1 := port[$0388];
   sbSetReg( $02, $FF ); {SET timer 1}
   sbSetReg( $04, $21 ); {start timer 1}
   delay( 8 );
   sbstatus2  := port[$0388];
   sbdetected := ( sbstatus1 AND $E0 = 00 ) AND ( sbstatus2 AND $E0 = $C0 );
  *)
  result := false;
END;


PROCEDURE soundsystem.sbInit;
VAR
   sbcounter : BYTE;
BEGIN
   FOR sbcounter := $01 TO $F5 DO BEGIN
      sbSetReg( sbcounter, 0 );
   END;
   sbiset( 0, idefault );
END;


PROCEDURE SoundSystem.Init; {û's FOR sb & sets up : called by this unit}
BEGIN
   sboctave  := 5;
   sbpresent := sbdetected;
   IF sbpresent THEN BEGIN
      sbinit;
   END;
   sbon := sbpresent;
   on;
   nosound;
END;


PROCEDURE SoundSystem.Sound( Hz : WORD );
BEGIN
   IF SndOn THEN BEGIN
      IF SbOn THEN BEGIN
         sbSetreg( $A0, LO( hz ) );
         sbSetreg( $B0, 32 + sboctave SHL 2 + ( HI( hz ) AND $03 ) );
      END ELSE BEGIN
         CRT.Sound( Hz );
      END;
   END;
END;


PROCEDURE SoundSystem.SoundC( Hz : WORD; c : BYTE );
BEGIN
   IF SndOn THEN BEGIN
      IF SbOn THEN BEGIN
         sbSetreg( $A0 + c, LO( hz ) );
         sbSetreg( $B0 + c, 32 + sboctave SHL 2 + ( HI( hz ) AND $03 ) );
      END ELSE BEGIN
         CRT.Sound( Hz );
      END;
   END;
END;


PROCEDURE SoundSystem.SoundLeft( Hz : WORD );
BEGIN
   IF SndOn THEN BEGIN
      IF SbOn THEN BEGIN
         sbSetLeftreg( $A0, LO( hz ) );
         sbSetLeftreg( $B0, 32 + sboctave SHL 2 + ( HI( hz ) AND $03 ) );
      END ELSE BEGIN
         CRT.Sound( Hz );
      END;
   END;
END;


PROCEDURE SoundSystem.SoundRight( Hz : WORD );
BEGIN
   IF SndOn THEN BEGIN
      IF SbOn THEN BEGIN
         sbSetRightreg( $A0, LO( hz ) );
         sbSetRightreg( $B0, 32 + sboctave SHL 2 + ( HI( hz ) AND $03 ) );
      END ELSE BEGIN
         CRT.Sound( Hz );
      END;
   END;
END;


PROCEDURE SoundSystem.NoSound;
BEGIN
   IF sbon THEN BEGIN
      sbsetreg( $B0, $00 );
   END ELSE BEGIN
      CRT.NoSound;
   END;
END;


PROCEDURE SoundSystem.Click;
BEGIN
   Sound( 400 );
   Delay( 2 );
   NoSound;
END;


PROCEDURE SoundSystem.SilverSound;
BEGIN
   sound( 3300 );
   delay( 50 );
   sound( 1200 );
   delay( 90 );
   sound( 945 );
   delay( 80 );
   sound( 1469 );
   delay( 74 );
   nosound;
END;


PROCEDURE SoundSystem.Beep;
BEGIN
   sound( 900 );
   delay( 300 );
   nosound;
END;


PROCEDURE Soundsystem.Pop;
VAR
   c : BYTE;
BEGIN
   FOR c := 1 TO 50 DO BEGIN
      Sound( c * 50 );
      delay( 1 );
   END;
   Nosound;
END;


PROCEDURE SoundSystem.Zap;
VAR
   c : BYTE;
BEGIN
   FOR c := 1 TO 50 DO BEGIN
      sound( c * 150 );
      delay( 1 );
      sound( $FFFF - ( C * 150 ) );
      delay( 1 );
   END;
END;


PROCEDURE SoundSystem.Slide;
BEGIN
   sound( 50 );
   delay( 100 );
   nosound;
END;


PROCEDURE Soundsystem.Ding;
BEGIN
END;


PROCEDURE SoundSystem.Ansiplay( SndC : STRING );
BEGIN
   IF SndOn THEN BEGIN
      hz.Ansiplay( sndc );
   END;
END;


PROCEDURE SoundSystem.On;
BEGIN
   SndOn := TRUE;
END;


PROCEDURE SoundSystem.Off;
BEGIN
   SndOn := FALSE;
END;

BEGIN
   {init ansi stuff}
   Octave := 4;
   ChartoPlay := 'N';
   Typom := 7 / 8;
   Min1 := 120;
   ansiplay( 't280 o3 p2 l4' );
   {init my stuff}
   Spkr.Init;
   Spkr2.Init;
   Spkr2.SbOn  := FALSE;
   Spkr2.Sndon := TRUE;
END.

