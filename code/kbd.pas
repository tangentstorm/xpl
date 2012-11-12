unit kbd; { keyboard constants }

interface

const
  UP        = #72;
  LEFT      = #75;
  DOWN      = #80;
  RIGHT     = #77;
  // k_HOME = #71 and #73  - probably one is control/alt?
  // k_END  = #79 and #81
  ESC       = #27;
  ENTER     = #13;

  sArrows = [ kbd.UP, kbd.RIGHT, kbd.DOWN, kbd.LEFT ];
  sCursorKeys = sArrows + [ #71, #73, #79, #81 ];
  
implementation
begin
end.

