unit kbd; { keyboard constants }

interface

const
  UP	      = #72;
  LEFT	      = #75;
  DOWN	      = #80;
  RIGHT	      = #77;
  HOME	      = #71;  // k_HOME = #71 and #73  - probably one is control/alt?
  END_	      = #79;  // k_END    = #79 and #81
  ESC	      = #27;
  ENTER	      = #13;
  INS	      = #82;
  DEL	      = #83;
  BKSP	      = #8;
  C_LEFT      = #115;
  C_RIGHT     = #116;
  C_END	      = #117;
  C_BKSP      = #127;
  sArrows     = [ kbd.UP, kbd.RIGHT, kbd.DOWN, kbd.LEFT ];
  sCursorKeys = sArrows + [ #71, #73, #79, #81 ];

implementation
begin
end.

