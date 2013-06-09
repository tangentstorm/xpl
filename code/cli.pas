unit cli;
interface uses xpc, cw, kvm, kbd;

  procedure hitakey;
  function yesno : Boolean;

implementation


  procedure HitAKey;
    var
      tc : Byte;
  begin
    tc := kvm.textAttr;
    cwrite( '|r(|R(|Y(|W Hit a Key|G! |Y)|R)|r)' );
    while KeyPressed do ReadKey;
    ReadKey;
    cwrite( '' );
    kvm.textAttr := tc;
  end; { HitAKey }


  function yesno : Boolean;
  begin
    yesno := upCase( readkey ) = 'Y';
  end; { yesno }

end.