// utv : termview components
//
// Copyright © 2014 Michal J Wallace http://tangentstorm.com/
// Available for use under the MIT license. See LICENSE.txt

{$mode delphiunicode}{$i xpc.inc}
unit utv;
interface uses xpc, classes, sysutils, umsg,
  kvm, arrays, cli, ug2d, num, cw, math, ustr, chk;


const
  k_nav_up  = 1; k_nav_dn  = 2;
  k_nav_lf  = 3; k_nav_rt  = 4;
  k_nav_top = 5; k_nav_end = 6;
  k_cmd_tog = 8; k_cmd_del = 9;

var
  chan_nav,
  chan_cmd: word;
  msg_nav_up, msg_nav_dn,
  msg_nav_lf, msg_nav_rt,
  msg_nav_top, msg_nav_end,
  msg_cmd_toggle,
  msg_cmd_delete : umsg.TMsg;

var // default background colors for lines
  hibar	: byte = $08; // ansi dark gray
  lobar	: byte = $ea; // ever darker dgray
  nobar	: byte = $00; // black


type
  TView = class(ug2d.TBounds2D)
    protected
      _bg, _fg : byte;
      _dirty : boolean; _visible : boolean;
      _ioctx : ITerm; // kvm parent term
      _views : GArray<TView>; // subviews
      _focused : boolean; { do we, or one of our children have focus? }
    public
      constructor Create( aOwner : TComponent ); override;
      function Init( x, y : integer ; w, h : cardinal ) : TView; reintroduce;
      destructor Destroy; override;
      procedure Update; virtual;
      procedure Smudge;
      procedure SetVisible( val : boolean ); virtual;
      procedure Show; procedure Hide;
      property dirty : boolean read _dirty write _dirty;
      procedure Render; virtual;
      procedure Resize(new_w, new_h : cardinal); override;
      procedure dump; virtual;
      procedure GainFocus; virtual;
      procedure LoseFocus; virtual;
      procedure RestoreCursor; virtual; { after drawing other widgets }
    published
      property visible : boolean read _visible write _visible;
      procedure Handle( msg : TMsg ); virtual;
    end;


type // TGridView : a scrolling 2d grid of text cells (like a spreadsheet)
  TGridThunk = procedure (gx, gy: word) of object;
  TGridStrFn = function (gx, gy: word) : TStr of object;
  TWordFn = function : word of object;
  TGridView = class (TView)
    protected
      _cellh : TBytes;
      _cellw : TBytes;
      _gw, _gh : byte;
      _igx, _igy : cardinal; // cursor position
      _vgx, _vgy : cardinal; // grid cell in upper left of scrolled view
      _DeleteAt   : TGridThunk;
      _RenderCell : TGridStrFn;
      _GetRowCount : TWordFn;
    public
      constructor Create(aOwner : TComponent); override;
      procedure Render; override;
      procedure LoadData; virtual;
      procedure Handle(msg : umsg.TMsg); override;
      function GetRowCount : word;
      procedure UpdateCamera;
      procedure RestoreCursor; override;
    published
      property OnRenderCell : TGridStrFn read _RenderCell write _RenderCell;
      property RowCount : word read GetRowCount;
    end;

type // A class with its own video ram buffer:
  TTermView = class (TView, ITerm)
    protected
      _hookterm : IHookTerm;
      _gridterm : IGridTerm;
      procedure _OnGridChange( msg : TTermMessage; args : array of variant );
    public
      constructor Create( aOwner : TComponent ); override;
      function Init( x, y : integer ; w, h : cardinal ) : TTermView;
        reintroduce;
      destructor Destroy; override;
      function asTerm : ITerm;
      property term : ITerm read asTerm implements ITerm;
    published
      procedure Render; override;
      procedure Resize(new_w, new_h : cardinal); override;
      procedure dump; override;
    end;


implementation

constructor TView.Create( aOwner : TComponent );
  begin
    inherited Create( aOwner );
    _x := 0; _y := 0; _w := kvm.width; _h := kvm.height;
    _bg := $FC; _fg := $0; _dirty := true;
    _views := GArray<TView>.Create();
    _visible := true;
  end;

function TView.Init( x, y : integer ; w, h : cardinal ) : TView;
  begin inherited; result := self;
  end;

destructor TView.Destroy;
  begin
    _views.Free; // members are TViews, so owners will free
    inherited Destroy;
  end;

procedure TView.Handle( msg : TMsg );
  begin
  end;

procedure TView.GainFocus;
  begin _focused := true; smudge;
  end;

procedure TView.LoseFocus;
  begin _focused := false; smudge;
  end;

procedure TView.RestoreCursor;
  begin
  end;


procedure TView.Update;
  var child : TView;
  begin
    if _visible then begin
      _ioctx := kvm.asTerm;
      kvm.pushSub(_x, _y, _w, _h);
      try kvm.bg(_bg); kvm.fg(_fg);
        if _dirty then begin Render; _dirty := false; end;
        for child in _views do child.Update;
      finally kvm.PopTerm; _ioctx := nil end
    end;
  end;


procedure tview.dump;
  begin
    trace(['TView', self.classname]);
    indent; begin
      trace(['x:', x, ' ', 'y:', y]);
      trace(['w:', w, ' ', 'h:', h]);
    end; dedent;
  end; { tview.dump }

procedure ttermview.dump;
begin
  assert( self <> nil );
  trace('--[ utv.pas::ttermview.dump ]-------');
  trace(['TERMVIEW[', self.classname, ']']);
  indent;
  { }trace(['_gridterm:']); indent; _gridterm.dump; dedent;
  { }trace(['_hookterm:']); indent; _hookterm.dump; dedent;
  dedent;
  trace('--[ done with termview.dump ]-------');
end;


{ display management }

procedure TView.Smudge;
  begin _dirty := true;
  end;

procedure TView.SetVisible( val : boolean );
  begin _visible := val; smudge;
  end;

procedure TView.Show;
  begin SetVisible( true );
  end;

procedure TView.Hide;
  begin SetVisible( false )
  end;

procedure TView.Render;
  begin ClrScr
  end;

procedure TView.Resize(new_w, new_h : cardinal);
  begin inherited; Smudge;
  end;

{ TGridView - event handling }

constructor TGridView.Create( aOwner : TComponent );
  begin inherited;
    _w := 31; _h := 8;  _gw := 1;
    _igx := 0; _igy := 0; _vgx := 0; _vgy := 0;
  end;

procedure TGridView.LoadData;
  begin
  end;

function TGridView.GetRowCount : word;
  begin if assigned(_GetRowCount) then result := _GetRowCount else result := 0
  end;

procedure TGridView.Handle(msg : umsg.TMsg);
  begin
    case msg.code of
      k_nav_up	: if _igy > 0 then dec(_igy) else ok;
      k_nav_dn	: if _igy < rowCount-1 then inc(_igy) else ok;
      k_nav_top	: _igy := 0;
      k_nav_end	: if rowCount > 0 then _igy := rowCount - 1 else _igy := 0;
      k_cmd_tog	: _igx := (_igx + 1) mod _gw;
      k_cmd_del	: if assigned(_DeleteAt) then _DeleteAt(_igx, _igy) else ok;
      else ok;
    end;
    if msg.code in [k_nav_up, k_nav_dn, k_nav_top, k_nav_end] then UpdateCamera
    else ok;
    smudge;
  end;

procedure TGridView.UpdateCamera;
  var yCam : word;
  begin
    while _vgy > _igy do dec(_vgy);
    yCam := _igy - _vgy;
    if ( yCam < 5 ) and ( _vgy > 1 ) then
      begin
        dec(_vgy)
        //  scrolldown1(1,80,y1,y2,nil);
        //  scrolldown1(1,80,14,25,nil);
      end
    else if ( yCam > self.h - 5 )
      and ( self._vgy < self.RowCount ) then
      begin
	inc( _vgy );
	//  scrollup1(1,80,y1,y2,nil);
	//  scrollup1(1,80,14,25,nil);
      end;
    smudge;
  end;


{ TGridView - Rendering }

function prepstr(s : string; len : byte) : TStr;
  begin result := rfit(replace(replace(cstrip(s), ^M, ''), ^J, ''), len)
  end;

procedure TGridView.Render;
  var gy : word; bar : byte; gh : word = 0;
  begin bg(0); fg('w'); clrscr;
    if assigned(_RenderCell) then begin
      if _focused then bar := hibar else bar := lobar;
      LoadData; gh := self.rowCount;
      if gh = 0 then _igy := 0 else _igy := xpc.min(_igy, gh-1);
      if gh > 0 then for gy := 0 to gh-1 do begin
        gotoxy(0,gy); if gy = _igy then bg(bar) else bg(0);
        write(prepstr(_RenderCell(0,gy), _cellw[0]));
        fg('k'); emit('│'); fg('w');
        write(prepstr(_RenderCell(1,gy), _cellw[1]));
      end;
      if gh = 0 then begin
        bg(bar); clreol; fg('k');
        write(chntimes(' ', _cellw[0]), '|');
      end
    end
  end;

procedure TGridView.RestoreCursor;
  var i : word; cx : word = 0;
  begin { show the cursor on the current cell }
    if _igx > 0 then for i:= 0 to _igx-1 do inc(cx, _cellw[i]);
    if rowCount > 0 then begin
      gotoxy(_x+cx, _y+_igy); ShowCursor;
    end
  end;


constructor TTermView.Create( aOwner : TComponent );
  begin
    inherited Create( aOwner );
    _gridterm := GridTerm(1, 1);
    _gridterm.bg(8);
    _gridterm.fg(7);
    resize(32, 16);
    _hookterm := HookTerm(_gridterm);
    _hookterm.callback := _OnGridChange;
  end;

function TTermView.Init( x, y : integer ; w, h : cardinal ) : TTermView;
  begin inherited; result := self
  end;

function TTermView.asTerm : ITerm;
  begin result := _hookterm
  end;

destructor TTermView.Destroy;
  begin
    _hookterm.subject := nil;
    _hookterm := nil;
    _gridterm := nil;
    inherited;
  end;


procedure TTermView._OnGridChange( msg : TTermMessage; args : array of variant );
  begin self.smudge;
  end;

procedure TTermView.Resize(new_w, new_h : cardinal);
  begin
    inherited Resize(new_w, new_h);
    _gridterm.Resize(new_w, new_h);
  end;

procedure TTermView.Render;
  var yEnd, xEnd, x, y : byte; cell : TTermCell;
  begin
    assert(assigned(_ioctx));
    yEnd := min(yMax, _ioctx.yMax);
    xEnd := min(_w-1, _ioctx.xMax);
    for y := 0 to yEnd do
      begin
	_ioctx.gotoxy(_x,_y+y);
	for x := 0 to xEnd do
          begin
	    cell := _gridterm.GetCell(x,y);
	    _ioctx.textattr := attrtoword(cell.attr);
	    _ioctx.emit(cell.ch);
          end;
      end;
  end;

initialization

  RegisterClass(TView);
  RegisterClass(TTermView);

  chan_nav := umsg.NewChan;
  msg_nav_up  := Msg( chan_nav, k_nav_up );
  msg_nav_dn  := Msg( chan_nav, k_nav_dn );
  msg_nav_lf  := Msg( chan_nav, k_nav_lf );
  msg_nav_rt  := Msg( chan_nav, k_nav_rt );
  msg_nav_top := Msg( chan_nav, k_nav_top );
  msg_nav_end := Msg( chan_nav, k_nav_end );

  chan_cmd  := umsg.NewChan;
  msg_cmd_toggle  := Msg( chan_cmd, k_cmd_tog );
  msg_cmd_delete  := Msg( chan_cmd, k_cmd_del );

finalization
  msg_nav_up.free;  msg_nav_dn.free;
  msg_nav_lf.free;  msg_nav_rt.free;
  msg_nav_top.free; msg_nav_end.free;
  msg_cmd_toggle.free;
  msg_cmd_delete.free;
end.
