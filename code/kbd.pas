{$mode objfpc}{$i xpc.inc}
unit kbd; { keyboard constants }
interface uses xpc, keyboard, num;

  procedure getenter;
  function keypressed : boolean;
  function alt2normal( ch : Char ) : Char;
  function shiftstate : Byte;
  function enterpressed : Boolean;

  {-- interface > keyboard --}
type
  { a set of symbols for the common physical keys ( on USA keyboards ) }
  keycode     = (
    key_unknown, { just in case something is missing }
    key_f1, key_f2, key_f3, key_f4, key_f5, key_f6, key_f7, key_f8,
    key_f9, key_f10, key_f11, key_f12, key_print, key_scroll,
    key_pause, key_0, key_1, key_2, key_3, key_4, key_5, key_6,
    key_7, key_8, key_9, key_backquote, key_esc, key_lbrack,
    key_rbrack, key_bs, key_tab, key_apos, key_comma, key_period,
    key_p, key_y, key_f, key_g, key_c, key_r, key_l, key_fslash,
    key_equal, key_bslash, key_a, key_o, key_e, key_u, key_i, key_d,
    key_h, key_t, key_n, key_s, key_minus, key_enter, key_semi,
    key_q, key_j, key_k, key_x, key_b, key_m, key_w, key_v, key_z,
    key_ctrl, key_os, key_alt, key_space, key_menu, key_shift,
    key_left, key_right, key_up, key_down, key_ins, key_del,
    key_home, key_end, key_pgup, key_pgdn );

  tKeyState = set of keycode;
  function kbstate : tKeyState;
  function readkey : char;
  function readkey( out ch : char ) : char;

  // these are thes standardized keyboard codes from:
  // http://www.freepascal.org/docs-html/rtl/keyboard/kbdscancode.html
  // (that page uses hex though)
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
  F1	      = #$3B;
  F2	      = #$3C;
  F3	      = #$3D;
  F4	      = #$3E;
  F5	      = #$3F;
  F6	      = #$40;
  F7	      = #$41;
  F8	      = #$42;
  F9	      = #$43;
  F10	      = #$44;
  F11	      = #$45;
  F12	      = #$46;
  sArrows     = [ kbd.UP, kbd.RIGHT, kbd.DOWN, kbd.LEFT ];
  sCursorKeys = sArrows + [ #71, #73, #79, #81 ];

  const    { altkeys }
    {  these alt keys constants should move to the
      kvm unit, and you should realy only deal with
      some kind of abstraction. }
    alt16to25 : string = 'QWERTYUIOP';
    alt30to38 : string = 'ASDFGHJKL';
    alt44to50 : string = 'ZXCVBNM';

    { keyboard shift states }
    rshiftpressed = $01;
    lshiftpressed = $02;
    shiftpressed  = $03;
    ctrlpressed	  = $04;
    altpressed	  = $08;
    scrolllockon  = $10;
    numlockon	  = $20;
    capslockon	  = $40;
    inserton	  = $80;



{ -- implementation > keyboard --------------------------- }

implementation

var
  have_cached : boolean = false;
  cached_key  : char = #0;

function readkey : char;
  var
    evt	: keyboard.TKeyEvent;
    ch	: char;
begin
  if have_cached then
    begin
      have_cached := false;
      result := cached_key;
      cached_key := #0;
    end
  else
    begin
      evt := TranslateKeyEvent(GetKeyEvent);
      case GetKeyEventFlags(evt) of
	kbUniCode  : begin
		       Writeln('Unicode keys not yet handled. :/');
		       result := '?';
		     end;
	kbFnKey :
	  begin
	    { TODO: should be able to replace all this with chr(key.scancode) here }
	    case GetKeyEventCode(evt) of
	      kbdUp    : ch := kbd.UP;
	      kbdDown  : ch := kbd.DOWN;
	      kbdLeft  : ch := kbd.LEFT;
	      kbdRight : ch := kbd.RIGHT;
	      kbdF1    : ch := kbd.F1;
	      kbdF2    : ch := kbd.F2;
	      kbdF3    : ch := kbd.F3;
	      kbdF4    : ch := kbd.F4;
	      kbdF5    : ch := kbd.F5;
	      kbdF6    : ch := kbd.F6;
	      kbdF7    : ch := kbd.F7;
	      kbdF8    : ch := kbd.F8;
	      kbdF9    : ch := kbd.F9;
	      kbdF10   : ch := kbd.F10;
	      kbdF11   : ch := kbd.F11;
	      kbdF12   : ch := kbd.F12;
	      else ch := chr(lo(GetKeyEventCode(evt)))
	    end;
	    cached_key := ch;
	    have_cached := true;
	    result := #0;
	  end;
	kbASCII,
	kbPhys	   : result := chr(lo(GetKeyEventCode(evt)));  //GetKeyEventChar(evt);
	kbReleased : result := ReadKey(); // recurse
      end
  end;
end; { readkey }

function readkey( out ch : char ) : char;
begin
  ch := readkey();
  result := ch;
end; { readkey }

function keypressed : boolean;
begin
  if have_cached then result := true
  else result := keyboard.PollKeyEvent <> 0;
end;


function kbstate : tKeyState;
begin
  result := [];
end; { kbstate }


  function alt2normal( ch : Char ) : Char;
    const
      set1 = 'QWERTYUIOP';
      set2 = 'ASDFGHJKL';
      set3 = 'ZXCVBNM';
      set4 = '1234567890-=';
  begin
    case ord( ch ) of
      16  ..  25 : alt2normal := set1[ ord( ch ) - 15 ];
      30  ..  38 : alt2normal := set2[ ord( ch ) - 29 ];
      44  ..  50 : alt2normal := set3[ ord( ch ) - 43 ];
      120 .. 131 : alt2normal := set4[ ord( ch ) - 119 ];
      otherwise
        alt2normal := #255
    end { case }
  end;


  //   -- sdl keypress event?
  function shiftstate : Byte;
    // var   rgs : registers;
  begin
    result := 0;
    {
      rgs.AH := $02;
      intr( $16, rgs );
      shiftstate := rgs.al;
      }
  end; { shiftstate }


  function enterpressed : Boolean;
    var
      ch : Char;
  begin
    ch := ' ';
    if KeyPressed then begin
      ch := Readkey;
    end;
    enterPressed := ch = #13;
  end; { enterpressed }


  procedure getEnter;
  begin
    repeat
    until enterPressed;
  end; { getEnter }



initialization
  keyboard.initkeyboard;
finalization
  keyboard.donekeyboard;
end.
