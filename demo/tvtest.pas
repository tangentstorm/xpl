{$mode delphiunicode}{$i xpc.inc}
program tvtest;
uses uapp, utv, ukm, kvm, xpc, sysutils, cw,cli,ugrid2d,chk;

type
  TApp1 = class (uapp.TCustomApp)
    procedure init; override;
    procedure step; override;
    procedure keys(km : ukm.TKeyMap); override;
    procedure OnKey(ext	: boolean; ch : char );
  private
    view : utv.TTermView;
    term : kvm.ITerm;
    count :integer;
  end;

procedure TApp1.init;
  begin
    view := utv.TTermView.Create(self);
    term := view.term;
    view.resize(64, 32);
    _views.append(view);
    count := 0;
  end;


procedure TApp1.OnKey( ext : boolean; ch : char );
  begin
    term.emit(ch); view.smudge;
  end;
procedure TApp1.keys(km : ukm.TKeyMap);
  var ch : char;
  begin
    km.cmd[ ^C ] := quit;
    km.cmd[ ^L ] := view.smudge;
    for ch in [#32 .. #127] do km.crt[ch] := onkey;
  end;

procedure TApp1.step;
  begin
  end;
  
begin
  uapp.Run(TApp1);
end.
