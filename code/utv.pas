// utv : termview components
//
// Copyright © 2014 Michal J Wallace http://tangentstorm.com/
// Available for use under the MIT license. See LICENSE.txt
//
{$i xpc.inc}{$mode delphi}
unit utv;
interface uses xpc, classes, kvm, arrays, cli, ug2d, num, cw, math, ustr;

type
  TView = class(TComponent, IPoint2D, ISize2D, IBounds2D)
    protected
      _x, _y : integer;
      _w, _h : cardinal;
      _bg, _fg : byte;
      _dirty : boolean;
      _views : GArray<TView>; // subviews
      function GetX : integer;  procedure SetX(value : integer);
      function GetY : integer;  procedure SetY(value : integer);
      function GetW : cardinal; procedure SetW(value : cardinal);
      function GetH : cardinal; procedure SetH(value : cardinal);
    public
      constructor Create( aOwner : TComponent ); override;
      destructor Destroy; override;
      procedure Update;
      procedure Smudge;
      property dirty : boolean read _dirty write _dirty;
    published
      property x : integer read _x write SetX;
      property y : integer read _y write SetY;
      property w : cardinal read _w write SetW;
      property h : cardinal read _h write SetH;
      procedure Nudge(dx, dy : integer);
      procedure Render(term :  ITerm); virtual;
      procedure Resize(new_w, new_h : cardinal); virtual;
    end;

  // A class with its own video ram buffer:
  TTermView = class (TView, ITerm)
    protected
      _gridterm : TGridTerm;
    published
      property term : TGridTerm read _gridterm implements ITerm;
      constructor Create( aOwner : TComponent ); override;
      procedure Render(term :  ITerm); override;
      procedure Resize(new_w, new_h : cardinal); override;
    end;

  TStepper = class (TComponent)
    protected
      fstep : TNotifyEvent;
      procedure DoStep; virtual;
    public
      procedure Step(times:cardinal=1);
    published
      property OnStep : TNotifyEvent read fStep write fStep;
    end;


implementation

constructor TView.Create( aOwner : TComponent );
  begin
    inherited Create( aOwner );
    _x := 0; _y := 0; _w := 30; _h := 10;
    _bg := $FC; _fg := $0; _dirty := true;
    _views := GArray<TView>.Create();
  end;

destructor TView.Destroy;
  begin
    _views.Free; // members are TViews, so owners will free
    inherited Destroy;
  end;

procedure TView.SetX(value : integer); begin _x := value; end;
procedure TView.SetY(value : integer); begin _y := value; end;
procedure TView.SetW(value : cardinal); begin _w := value; end;
procedure TView.SetH(value : cardinal); begin _h := value; end;

function TView.GetX : integer; begin result := _x end;
function TView.GetY : integer; begin result := _y end;
function TView.GetW : cardinal; begin result := _w end;
function TView.GetH : cardinal; begin result := _h end;

procedure TView.Nudge(dx, dy : integer);
  begin
    _x += dx; _y += dy;
  end;

procedure TView.Update;
  var child : TView;
  begin
    kvm.SubTerm(_x, _y, _w, _h);
    try bg(_bg); fg(_fg);
      if _dirty then Render(kvm.work);
      for child in _views do child.Update;
    finally kvm.PopTerm end;
  end;

procedure TView.Smudge;
  begin _dirty := true;
  end;
  
procedure TView.Render(term : ITerm);
  begin term.ClrScr
  end;

procedure TView.Resize(new_w, new_h : cardinal);
  begin _w := new_w; _h := new_h; Smudge;
  end;

constructor TTermView.Create( aOwner : TComponent );
  begin
    inherited Create( aOwner );
    _gridterm := TGridTerm.Create(1, 1);
  end;

procedure TTermView.Resize(new_w, new_h : cardinal);
  begin
    inherited Resize(new_w, new_h);
    _gridterm.Resize(new_w, new_h);
  end;

procedure TTermView.Render(term : ITerm);
  var endy, endx, x, y : byte; cell : TTermCell;
  begin
    endy := min(_h-1, term.yMax);
    endx := min(_w-1, term.xMax);
    for y := 0 to endy do
      begin
	term.gotoxy(_x, _y+y);
        for x := 0 to endx do
          begin
            cell := _gridterm[x,y];
	    term.emit(cell.ch);
          end;
      end;
  end;

procedure TStepper.DoStep;
  begin
  end;

procedure TStepper.Step(times:cardinal=1);
  var i : integer;
  begin
    if times > 0 then for i := 0 to times do
      begin
        DoStep;
        if Assigned(fStep) then fStep(self);
      end;
  end;

initialization
  RegisterClass(TView);
  RegisterClass(TTermView);
  RegisterClass(TStepper);
end.
