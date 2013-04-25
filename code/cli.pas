unit cli;
interface uses xpc, cw, vt, kbd;

  procedure hitakey;
  function yesno : Boolean;

implementation


  procedure HitAKey;
    var
      tc : Byte;
  begin
    tc := vt.textAttr;
    cwrite( '|r(|R(|Y(|W Hit a Key|G! |Y)|R)|r)' );
    while KeyPressed do ReadKey;
    ReadKey;
    cwrite( '' );
    vt.textAttr := tc;
  end; { HitAKey }


  function yesno : Boolean;
  begin
    yesno := upCase( readkey ) = 'Y';
  end; { yesno }

end.