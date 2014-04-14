// utv : termview components
//
// Copyright © 2014 Michal J Wallace http://tangentstorm.com/
// Available for use under the MIT license. See LICENSE.txt

{$i xpc.inc}{$mode delphi}
unit utv;
interface uses xpc, classes, sysutils,
  kvm, arrays, cli, ug2d, num, cw, math, ustr, chk;
type
  TView = class(ug2d.TBounds2D)
    protected
      _bg, _fg : byte;
      _dirty : boolean; _visible : boolean;
      _ioctx : ITerm; // kvm parent term
      _views : GArray<TView>; // subviews
      _focused : boolean;
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
    published
      property visible : boolean read _visible write _visible;
    end;

  // A class with its own video ram buffer:
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
    _x := 0; _y := 0; _w := 30; _h := 10;
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

procedure TView.GainFocus;
  begin _focused := true; smudge;
  end;

procedure TView.LoseFocus;
  begin _focused := false; smudge;
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
end.
