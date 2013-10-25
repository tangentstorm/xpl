unit cli;
interface uses xpc, cw, kvm, kbd;

  procedure HitAKey;
  function YesNo : Boolean;

implementation


procedure HitAKey;
  var tc : word;
  begin
    tc := kvm.textAttr;
    cwrite( '|!k|r(|R(|Y(|W Hit a Key|G! |Y)|R)|r)' );
    while KeyPressed do ReadKey;
    ReadKey;
    cwrite( '' );
    kvm.textAttr := tc;
  end; { HitAKey }


function YesNo : Boolean;
  begin
    yesno := upCase( readkey ) = 'Y';
  end; { YesNo }

end.
