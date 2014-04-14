{$mode delphiunicode}{$i xpc.inc}
unit ui;
interface uses classes, xpc, cw, kvm, mou, kbd, ustr,
  fx, num, cli, sysutils, utv, ukm, rings;

{ note : this module considers (0,0) to be the top left corner! }

type
  { a clickable rectangle onscreen }
  ZObj  = class ( TView )
    public
      x2, y2 : Byte; { TODO : mX, mY, etc }
    published
      constructor Create( aOwner : TComponent ); override; overload;
      constructor create( a, b, a2, b2 : Byte ); overload;
      procedure show; virtual; deprecated 'use .Render';
      procedure Render; override;
      procedure showNormal; virtual;
      procedure showInvert; virtual;
      function mouseover : Boolean; virtual;
      function pressed : Boolean; virtual;
      function click : Boolean; virtual;
      procedure Keys( km : ukm.TKeyMap ); virtual;
      procedure OnKey( ext : boolean; ch : char );
      procedure handle( ch : Char ); virtual;
      procedure handlestripped( ch : Char ); virtual;
    public { legacy interface }
      property is_dirty : boolean
	read _dirty write _dirty; deprecated 'use .dirty';
    end;

  zText = class ( zObj )
    protected
      st1, st2 : TStr;
    published
      constructor Create( a, b : Byte; s, s2 : TStr );
      procedure ShowNormal; override;
      procedure showInvert; override;
    end;

  zchoice = class ( zText )
    protected
      sub : zObj;            { sumbmenus }
      on  : Boolean;         { active? } { TODO : rename to enabled }
      sc  : Char;            { shortcut character }
      v   : Byte;            { return value }
    published
      constructor createXY( a, b : Byte; s, s2 : TStr; ison : Boolean;
                        shortcut : char;
                        value : word;
                        submen : zObj );
      constructor create( s, s2 : TStr; ison : Boolean;
                        shortcut : char;
                        value : word;
                        submen : zObj );
      procedure draw( high : Boolean ); virtual;
      function enabled : Boolean;
  end;

  zMenu = class( zObj )
    public
      tx, ty, height, width : Byte;
      { updated constantly in reformatting loop }
      topmenu, endloop, escexits, altexits, subactive,
      usetempscreen : boolean;
    published
      constructor create( esc, alt, usetemp : Boolean; head : zChoice );
      procedure insert( z : zchoice ); virtual;
      procedure add( z : zchoice ); virtual;
      procedure Render; override;
      { TODO: what's the seton/setto difference? clarify or eliminate! }
      procedure seton( z : zchoice );
      procedure setto( z : zchoice );
      procedure setOnFirst;
      procedure setToFirst;
      procedure handle( ch : Char ); override;
      procedure handlestripped( ch : Char ); override;
      procedure Reset; virtual;
      procedure domousestuff; virtual;
      procedure dowhilelooping; virtual;
      procedure format( choice : zChoice ); virtual;
      function normalstr( s : TStr ) : TStr; virtual;
      function invertstr( s : TStr ) : TStr; virtual;
      function submenu : zMenu;
      function shortcut( ch : Char ) : zchoice;
      function valuecut( v : Word ) : zchoice;
      function value : Byte;
      function get : Byte;
    protected type
      choicelist = GRing<zChoice>;
      choicecursor = IRingCursor<zChoice>;
    protected
      mChoices : choicelist;
      mCurrent : choicecursor;
    public
      function firstChoice : zChoice;
      function lastChoice : zChoice;
      function thisChoice : zChoice;
    end;


  zBounceMenu = class ( zMenu )
    public
      constructor create( x_, y_, w : Byte; p : String;
                          e, a : Boolean; head : zchoice );
    published
      procedure format( choice : zChoice ); override;
      procedure Render; override;
      function normalstr( s : String ) : String; override;
      function invertstr( s : String ) : String; override;
      function top : String; virtual;
      function sepbar : String; virtual;
      function bottom : String; virtual;
    end;

  zMenuBar = class ( zMenu )
    public
      constructor create( x_, y_ : Byte; p : String;
                          e, a : Boolean; head : zChoice );
    published
      procedure handle( ch : Char ); override; { � menu - #32 }
      procedure handlestripped( ch : Char ); override;
      { uses alt keys, plus the up+right are reversed for submenus }
      procedure format( choice : zChoice ); override;
    end;


    ICmdPrompt = interface
      procedure SetOnAccept( e : TStrEvent );
      function GetOnAccept : TStrEvent;
      property OnAccept : TStrEvent read GetOnAccept write SetOnAccept;
    end;

    zInput = class ( ZObj, ICmdPrompt )
    public { todo: encapsulate these... }
      tcol,                 { text color  }
      acol,                 { arrow color (scroller) }
      maxlen,               { max text length }
      d1st,                 { first display char position }
      cpos :   cardinal;    { cursor position }
      back,                 { backup copy }
      work :   String;      { actual string }
      escexits, tovr,       { type over toggle }
      frst,                 { first key to be pressed }
      isdone : Boolean;     { end-loop flag }
    public
      constructor create( aOwner : TComponent ); override; overload;
      constructor create( a, b, tl, dl, tc, ac : integer; esc : Boolean;
		       start : String ); overload;
      constructor default( a, b, tl, dl : integer; start : String='' );
      procedure reset;
      procedure Render; override;
      function get : String;
      procedure handle( ch : Char ); override;
      procedure handlestripped( ch : Char ); override;
      property value : string read work write work;

    public { string editing interface }
      procedure fw_token;
      procedure bw_token;
      procedure bw_del_token;
      procedure fw_del_token;
      procedure del_to_end;
      function str_to_end : string;
      procedure accept;
      procedure cancel;
      procedure del;
      procedure backspace;
      procedure movecursor( newpos : cardinal );
      procedure Setovr( p : Boolean );
      procedure insert( ch : Char );
      procedure finish;
      procedure to_start;
      procedure to_end;
      procedure left;
      procedure right;
      function at_end : boolean;
    protected
      _OnAccept : xpc.TStrEvent;
      function GetOnAccept : TStrEvent;
      procedure SetOnAccept( e : TStrEvent );
    published
      property OnAccept : TStrEvent read GetOnAccept write SetOnAccept;
    end;

  zPassword = class ( zInput )
    protected
      pwchar : Char;
    published
      constructor create( a, b, tl, dl, tc, ac : integer; pwc : Char; start : String );
      constructor default( a, b, tl, dl : integer; start : String );
      procedure Render; override;
    end;

  zCounter = class ( zObj )
    protected
      acol, tcol : Byte;
      value, start, min, max : Word;
      endloop :    Boolean;
    published
      constructor create( a, b, tc, ac : Byte; minVal, maxVal, strt : Word );
      procedure Render; override;
      procedure handle( ch : Char ); override;
      procedure domousestuff;
      function get : Word;
      function showstring : String; virtual;
    end;

  zHexCounter = class ( zCounter )
    published
      constructor create( a, b, tc, ac : Byte;
			  minVal, maxVal, strt : Word );
      function ShowString : String; override;
    end;

  zColor = class ( zCounter )
    protected
      truecol : Byte;
    published
      constructor Create( a, b, tc, ac, strt : Byte );
      function ShowString : String; override;
    end;


  zToggle = class ( zObj )
    public
      tcol : Byte;
      start, value, endloop : Boolean;
      truestr, falsestr : String;
      constructor Create( a, b, tc : Byte; ts, fs : String; startval : Boolean );
    published
      procedure Render; override;
      procedure Handle( ch : Char ); override;
      function Toggle : Boolean;
      function Get : boolean;
    end;

  zYesNo = class ( ztoggle )
    public
      constructor create( a, b, tc : Byte; startval : Boolean );
    end;

  zConfirmBox = class ( zObj )
    public
      bcol : Byte;
      str1, str2 : String;
      constructor create( a, b, border : Byte; s1, s2 : String );
      constructor default( a, b : Byte; s1, s2 : String );
      function get : Boolean;
    end;

  zInputbox = class ( zConfirmbox )
    public
      i : zInput;
      constructor create( a, b, border : Byte; s1, s2 : String; l : Byte );
      constructor default( a, b : Byte; s1, s2 : String; l : Byte );
      function get : String;
    end;

  zVScroller = class ( zObj )
    public
      bch, hch : Char;
      bat, hat : Byte;
      min, max, value : Byte;
    published
      constructor create( a, b, _min, _max, strt : Byte;
                        bc, hc : Char; ba, ha : Byte );
      constructor default( a, b, _min, _max, strt : Byte );
      procedure domousestuff;
      procedure Render; override;
      procedure handle( ch : Char ); override;
    end;

{ module level functions }

  function newSepBar( ) : zChoice;
  function newChoiceXY(
    x, y : Byte; s1, s2 : String; on : Boolean;
    sc : Char; v : Word; sub : zMenu ) : zChoice;
  function newChoice(
    s1, s2 : String; on : Boolean; sc : Char; v : Word;
    sub : zMenu ) : zChoice;
  function newbouncemenu(
    x, y, w : Byte; p : String; e, a : Boolean;
    head : zChoice ) : zBounceMenu;
  function newMenu( e, a : Boolean; head : zchoice ) : zMenu;
  function newMenuBar( x, y : Byte; p : String; e, a : Boolean;
                       head: zchoice ) : zMenubar;




implementation

  var
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
  end; { setpal }




  {$I ui/zobj.inc }
    {$I ui/zchoice.inc }
    {$I ui/zconfirmbox.inc }
      {$I ui/zinputbox.inc }
    {$I ui/zcounter.inc }
      {$I ui/zcolor.inc }
      {$I ui/zhexcounter.inc }
    {$I ui/zinput.inc }
      {$I ui/zpassword.inc }
    {$I ui/ztext.inc }
    {$I ui/ztoggle.inc }
      {$I ui/zyesno.inc }
    {$I ui/zvscroller.inc }
  {$I ui/zmenu.inc }
    {$I ui/zbouncemenu.inc }
    {$I ui/zmenubar.inc }


  function newChoiceXY(
    x, y : Byte; s1, s2 : String; on : Boolean;
    sc : Char; v : Word; sub : zMenu ) : zChoice;
  begin
    result := zChoice.createXY( x, y, s1, s2, on, sc, v, sub );
  end;

  function newChoice(
    s1, s2 : String; on : Boolean; sc : Char; v : Word;
    sub : zMenu ) : zchoice;
  begin
    result := newChoiceXY( 0, 0, s1, s2, on, sc, v, sub );
  end;

  function newSepBar( ) : zChoice;
  begin
    result := newChoiceXY( 0, 0, '', '', off, #255, 0, nil );
  end;

  function newMenu( e, a : Boolean; head: zChoice ) : zMenu;
  begin
    result := zMenu.create( e, a, true, head );
  end;

  function newBounceMenu(
    x, y, w : Byte; p : String; e, a : Boolean; head : zchoice ) : zbouncemenu;
  begin;
    result := zbouncemenu.create( x, y, w, p, e, a, head );
    result.add( head );
  end;

  function newMenuBar(
    x, y : Byte; p : String; e, a : Boolean;
    head : zChoice ) : zMenubar;
  begin
    result := zMenubar.create( x, y, p, e, a, head );
  end;


begin
end.
