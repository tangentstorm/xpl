{$IFDEF FPC}{$mode objfpc}{$modeswitch nestedprocvars}{$ENDIF}

unit ui;
interface uses cw, ll;

{ note : this module considers (0,0) to be the top left corner! }

type

  pzObj = ^zObj;
  ZObj  = object ( ll.Node ) { a clickable rectangle onscreen }
    x, y, x2, y2 : Byte; { TODO : mX, mY, etc }
    constructor init( a, b, a2, b2 : Byte );
    procedure showNormal; virtual;
    procedure showInvert; virtual;
    function mouseover : Boolean; virtual;
    function pressed : Boolean; virtual;
    function click : Boolean; virtual;
  end;

  pzText = ^zText;
  zText = object ( zObj )
    st1, st2 : String;
    constructor Init( a, b : Byte; s, s2 : String );
    procedure ShowNormal; virtual; { override; }
    procedure showInvert; virtual; { override; }
  end;

  pzchoice = ^zchoice;
  zchoice = object ( zText )
    protected
      sub : pzObj;                  { sumbmenus }
      on  : Boolean;                { active? } { TODO : rename to enabled }
    public
      sc  : Char;                   { shortcut character }
      v   : Byte;                   { return value }
      constructor createXY( a, b : Byte; s, s2 : String; ison : Boolean;
                        shortcut : char;
                        value : word;
                        submen : pzObj;
                        tail : pzChoice );
      constructor create( s, s2 : String; ison : Boolean;
                        shortcut : char;
                        value : word;
                        submen : pzObj;
                        tail : pzChoice );
      procedure draw( high : Boolean ); virtual;
      function enabled : Boolean;
  end;

  pzMenu = ^zMenu;
  zMenu = object( zObj )
    tx, ty, height, width : Byte; { updated constantly in reformatting loop }
    topmenu, endloop, escexits, altexits, subactive, usetempscreen : boolean;
    constructor init( esc, alt, usetemp : Boolean; head : pzChoice );
    procedure insert( z : pzchoice ); virtual;
    procedure add( z : pzchoice ); virtual;
    procedure show; virtual;
    { TODO: what's the seton/setto difference? clarify or eliminate! }
    procedure seton( z : pzchoice );
    procedure setto( z : pzchoice );
    procedure setOnFirst;
    procedure setToFirst;
    procedure handle( ch : Char ); virtual;
    procedure handlestripped( ch : Char ); virtual;
    procedure Reset; virtual;
    procedure domousestuff; virtual;
    procedure dowhilelooping; virtual;
    procedure format( choice : pzChoice ); virtual;
    function normalstr( s : String ) : String; virtual;
    function invertstr( s : String ) : String; virtual;
    function submenu : pzMenu;
    function shortcut( ch : Char ) : pzchoice;
    function valuecut( v : Word ) : pzchoice;
    function value : Byte;
    function get : Byte;
  protected
    mChoices : ll.List;
    mCurrent : pzChoice;
  public
    function firstChoice : pZChoice;
    function lastChoice : pZChoice;
    function thisChoice : pZChoice;
  end;

  pzbouncemenu = ^zbouncemenu;
  zBounceMenu = object ( zMenu )
    constructor init( x_, y_, w : Byte; p : String;
                      e, a : Boolean; head : pzchoice );
    procedure show; virtual; { override; }
    procedure format( choice : pzChoice ); virtual; { override; }
    function normalstr( s : String ) : String; virtual; { override; }
    function invertstr( s : String ) : String; virtual; { override; }
    function top : String; virtual;
    function sepbar : String; virtual;
    function bottom : String; virtual;
  end;

  pzMenuBar = ^zMenuBar;
  zMenuBar = object ( zMenu )
    constructor init( x_, y_ : Byte; p : String; e, a : Boolean; head : pzChoice );
    procedure handle( ch : Char ); virtual; { override; } { � menu - #32 }
    procedure handlestripped( ch : Char ); virtual; { override; }
    { uses alt keys, plus the up+right are reversed for submenus }
    procedure format( choice : pzChoice ); virtual; { override; }
  end;

  zInput = object ( ZObj )
    tcol,                 { text color  }
    acol,                 { arrow color (scroller) }
    tlen,                 { max text length }
    dlen,                 { length of display }
    d1st,                 { first display char position }
    cpos :   Byte;        { cursor position }
    back,                 { backup copy }
    strg :   String;      { actual string }
    escexits, tovr,       { type over toggle }
    frst,                 { first key to be pressed }
    isdone : Boolean;     { end-loop flag }
    constructor init( a, b, tl, dl, tc, ac : Byte; esc : Boolean;
                      start : String );
    constructor default( a, b, tl, dl : Byte; start : String );
    procedure Reset;
    procedure show; virtual;
    procedure del;
    procedure backspace;
    procedure movecursor( newpos : Byte );
    procedure Setovr( p : Boolean );
    procedure getkey( ch : Char );
    procedure handle( ch : Char ); virtual;
    procedure handlestripped( ch : Char ); virtual;
    procedure finish;
    function value : String;
    function get : String;
  end;

  zPassword = object ( zInput )
    pwchar : Char;
    constructor init( a, b, tl, dl, tc, ac : Byte; pwc : Char; start : String );
    constructor default( a, b, tl, dl : Byte; start : String );
    procedure Show; virtual; { override; }
  end;

  zCounter = object ( zObj )
    acol, tcol : Byte;
    value, start, min, max : Word;
    endloop :    Boolean;
    constructor init( a, b, tc, ac : Byte; minVal, maxVal, strt : Word );
    procedure show;
    procedure handle( ch : Char );
    procedure domousestuff;
    function get : Word;
    function showstring : String; virtual;
  end;

  zHexCounter = object ( zCounter )
    constructor init( a, b, tc, ac : Byte; minVal, maxVal, strt : Word );
    function ShowString : String; virtual; { override; }
  end;

  zColor = object ( zCounter )
    truecol : Byte;
    constructor Init( a, b, tc, ac, strt : Byte );
    function ShowString : String; virtual; { override; }
  end;

  zToggle = object ( zObj )
    tcol : Byte;
    start, value, endloop : Boolean;
    truestr, falsestr : String;
    constructor Init( a, b, tc : Byte; ts, fs : String; startval : Boolean );
    procedure Show;
    procedure Handle( ch : Char );
    function Toggle : Boolean;
    function Get : boolean;
  end;

  zYesNo = object ( ztoggle )
    constructor init( a, b, tc : Byte; startval : Boolean );
  end;

  zConfirmBox = object ( zObj )
    bcol : Byte;
    str1, str2 : String;
    constructor init( a, b, border : Byte; s1, s2 : String );
    constructor default( a, b : Byte; s1, s2 : String );
    function get : Boolean;
  end;

  zInputbox = object ( zConfirmbox )
    i : zInput;
    constructor init( a, b, border : Byte; s1, s2 : String; l : Byte );
    constructor default( a, b : Byte; s1, s2 : String; l : Byte );
    function get : String;
  end;

  zVScroller = object ( zObj )
    bch, hch : Char;
    bat, hat : Byte;
    min, max, value : Byte;
    constructor init( a, b, _min, _max, strt : Byte;
                      bc, hc : Char; ba, ha : Byte );
    constructor default( a, b, _min, _max, strt : Byte );
    procedure domousestuff;
    procedure show; virtual;
    procedure handle( ch : Char );
  end;


  function newSepBar( tail : pzChoice ) : pzChoice;
  function newChoiceXY(
    x, y : Byte; s1, s2 : String; on : Boolean;
    sc : Char; v : Word; sub : pzMenu; tail: pzChoice ) : pzChoice;
  function newChoice(
    s1, s2 : String; on : Boolean; sc : Char; v : Word;
    sub : pzMenu; tail : pzChoice ) : pzChoice;
  function newbouncemenu(
    x, y, w : Byte; p : String; e, a : Boolean;
    head : pzChoice ) : pzBounceMenu;
  function newMenu( e, a : Boolean; head : pzchoice ) : pzMenu;
  function newMenuBar( x, y : Byte; p : String; e, a : Boolean;
                       head: pzchoice ) : pzMenubar;

implementation

  uses crt, ms, hz, kbd;

  const
    zbmb : Char = 'k';
    zbmf : Char = 'K';
    zbmt : Char = 'w';
    zbhb : Char = 'r';
    zbhf : Char = 'Y';

  procedure setpal( palstr : String );
  begin
    if length( palstr ) <> 5 then
    begin
      zbmb := 'k';
      zbmf := 'K';
      zbmt := 'w';
      zbhb := 'r';
      zbhf := 'Y';
    end
    else begin
      zbmb := palstr[ 1 ];
      zbmf := palstr[ 2 ];
      zbmt := palstr[ 3 ];
      zbhb := palstr[ 4 ];
      zbhf := palstr[ 5 ];
    end;
  end;

  {$I ui.zobj.p }
    {$I ui.zchoice.p }
    {$I ui.zconfirmbox.p }
      {$I ui.zinputbox.p }
    {$I ui.zcounter.p }
      {$I ui.zcolor.p }
      {$I ui.zhexcounter.p }
    {$I ui.zinput.p }
      {$I ui.zpassword.p }
    {$I ui.ztext.p }
    {$I ui.ztoggle.p }
      {$I ui.zyesno.p }
    {$I ui.zvscroller.p }
  {$I ui.zmenu.p }
    {$I ui.zbouncemenu.p }
    {$I ui.zmenubar.p }


  function newChoiceXY(
    x, y : Byte; s1, s2 : String; on : Boolean;
    sc : Char; v : Word; sub : pzMenu; tail: pzChoice ) : pzChoice;
  begin
    new( result, createXY( x, y, s1, s2, on, sc, v, sub, tail ));
  end;


  function newChoice(
    s1, s2 : String; on : Boolean; sc : Char; v : Word;
    sub : pzMenu; tail: pzchoice ) : pzchoice;
  begin
    result := newChoiceXY( 0, 0, s1, s2, on, sc, v, sub, tail );
  end;


  function newSepBar( tail : pzChoice ) : pzChoice;
  begin
    result := newChoiceXY( 0, 0, '', '', off, #255, 0, nil, tail );
  end;


  function newMenu( e, a : Boolean; head: pzChoice ) : pzMenu;
  begin
    newmenu := new( pzMenu, init( e, a, true, head ));
  end;


  function newBounceMenu(
    x, y, w : Byte; p : String; e, a : Boolean; head : pzchoice ) : pzbouncemenu;
  begin
    result := new( pzbouncemenu, init( x, y, w, p, e, a, head ));
    result^.add( head );
  end;


  function newMenuBar(
    x, y : Byte; p : String; e, a : Boolean;
    head : pzChoice ) : pzMenubar;
  begin
    result := new( pzMenubar, init( x, y, p, e, a, head ));
  end;

begin
end.
