{$mode objfpc}{$i xpc.inc}
unit kbd; { keyboard constants }
interface uses keyboard;

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

  // these are thes standardized keyboard codes for special keys from:
  // http://www.freepascal.org/docs-html/rtl/keyboard/kbdscancode.html
  // (I have the numbers ascending in left-to-right order instead of
  // top to bottom though. I found it easier to to see the structure):
  const
    NoKey	= #$00;
    A_Esc	= #$01; A_Space    = #$02; C_Ins      = #$04;
    S_Ins	= #$05; C_Del      = #$06; S_Del      = #$07;
    A_Back	= #$08; A_S_Back   = #$09; S_Tab      = #$0F;

    // control-letter and shift-letter codes are all standard
    // characters, so only the alts appear in this table :
    A_Q		= #$10; A_W        = #$11; A_E        = #$12;
    A_R		= #$13; A_T        = #$14; A_Y        = #$15;
    A_U		= #$16; A_I        = #$17; A_O        = #$18;
    A_P		= #$19; A_LftBrack = #$1A; A_RgtBrack = #$1B;
    A_A		= #$1E; A_S        = #$1F; A_D        = #$20;
    A_F		= #$21; A_G        = #$22; A_H        = #$23;
    A_J		= #$24; A_K        = #$25; A_L        = #$26;
    A_SemiCol	= #$27; A_Quote    = #$28; A_OpQuote  = #$29;
    A_BkSlash	= #$2B; A_Z        = #$2C; A_X        = #$2D;
    A_C		= #$2E; A_V        = #$2F; A_B        = #$30;
    A_N		= #$31; A_M        = #$32; A_Comma    = #$33;
    A_Period	= #$34; A_Slash    = #$35; A_GreyAst  = #$37;

    // function keys and arrows (f11 and f12 appear later on)
    F1		= #$3B; F2         = #$3C; F3         = #$3D;
    F4		= #$3E; F5         = #$3F; F6         = #$40;
    F7		= #$41; F8         = #$42; F9         = #$43;
    F10		= #$44; Home       = #$47; UP         = #$48;
    PgUp	= #$49; LEFT       = #$4B; Center     = #$4C;
    RIGHT	= #$4D; A_GrayPlus = #$4E; End_       = #$4F;
    DOWN	= #$50; PgDn       = #$51; Ins        = #$52;
    Del		= #$53; S_F1       = #$54; S_F2       = #$55;
    S_F3	= #$56; S_F4       = #$57; S_F5       = #$58;
    S_F6	= #$59; S_F7       = #$5A; S_F8       = #$5B;
    S_F9	= #$5C; S_F10      = #$5D; C_F1       = #$5E;
    C_F2	= #$5F; C_F3       = #$60; C_F4       = #$61;
    C_F5	= #$62; C_F6       = #$63; C_F7       = #$64;
    C_F8	= #$65; C_F9       = #$66; C_F10      = #$67;
    A_F1	= #$68; A_F2       = #$69; A_F3       = #$6A;
    A_F4	= #$6B; A_F5       = #$6C; A_F6       = #$6D;
    A_F7	= #$6E; A_F8       = #$6F; A_F9       = #$70;
    A_F10	= #$71; C_PrtSc    = #$72; C_Left     = #$73;
    C_Right	= #$74; C_end      = #$75; C_PgDn     = #$76;
    C_Home	= #$77;

    {                 } A_1	   = #$78; A_2        = #$79;
    A_3		= #$7A; A_4        = #$7B; A_5        = #$7C;
    A_6		= #$7D; A_7        = #$7E; A_8        = #$7F;
    A_9		= #$80; A_0        = #$81; A_Minus    = #$82;
    A_Equal	= #$83; C_PgUp     = #$84; F11        = #$85;
    F12		= #$86; S_F11      = #$87; S_F12      = #$88;
    C_F11	= #$89; C_F12      = #$8A; A_F11      = #$8B;
    A_F12	= #$8C; C_Up       = #$8D; C_Minus    = #$8E;
    C_Center	= #$8F; C_GreyPlus = #$90; C_Down     = #$91;
    C_Tab	= #$94; A_Home     = #$97; A_Up       = #$98;
    A_PgUp	= #$99; A_Left     = #$9B; A_Right    = #$9D;
    A_end	= #$9F; A_Down     = #$A0; A_PgDn     = #$A1;
    A_Ins	= #$A2; A_Del      = #$A3; A_Tab      = #$A5;

    ESC		= #27;
    ENTER	= #13;
    BKSP	= #8;

    sArrows	= [ kbd.UP, kbd.RIGHT, kbd.DOWN, kbd.LEFT ];
    sCursorKeys	= sArrows + [ #71, #73, #79, #81 ];

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
              kbdPgUp  : ch := kbd.PgUp;
              kbdPgDn  : ch := kbd.PgDn;
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
    enterPressed := ch = ENTER;
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
