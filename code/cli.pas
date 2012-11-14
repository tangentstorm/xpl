unit cli;
interface uses xpc, cw, crt;

  procedure hitakey;
  function yesno : Boolean;

implementation


  procedure HitAKey;
    var
      tc : Byte;
  begin
    tc := crt.textAttr;
    cwrite( '|r(|R(|Y(|W Hit a Key|G! |Y)|R)|r)' );
    while KeyPressed do ReadKey;
    ReadKey;
    cwrite( '' );
    txpos  := 1;
    crt.textAttr := tc;
  end; { HitAKey }


  function yesno : Boolean;
  begin
    yesno := upCase( readkey ) = 'Y';
  end; { yesno }

 
end.