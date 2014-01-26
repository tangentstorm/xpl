{$i xpc.inc}{$mode delphi}{$h+}
unit uapp;
interface uses xpc, cx, kvm, ukm, custapp;

type
  TCustomApp = class (TCustomApplication)
  public
    err: string;
    constructor Create; reintroduce;
    function  init : boolean; virtual;
    procedure keys(km : ukm.TKeyMap); virtual;
    procedure step; virtual;
    procedure draw; virtual;
    procedure quit; virtual;
    procedure done; virtual;
  protected {  todo: hide these inside uapp }
    km : TKeyMap;
    procedure Initialize; override;
    procedure DoRun; override;
  end;

  procedure run(app : TCustomApp);

implementation


procedure run(app : TCustomApp);
  begin
    app.Initialize;
    if app.init then
      begin
	app.km := TKeyMap.Create(app); app.keys(app.km);
	app.draw; app.Run; app.done;
	fg('w'); bg('k'); clrscr; showcursor;
      end
    else if app.err <> '' then writeln(app.err)
    else pass;
    app.Free
  end;

function TCustomApp.init : boolean;
  begin
    result := true // meaning 'success'
  end;

procedure TCustomApp.keys(km : ukm.TKeyMap);
  begin
    km.cmd[ ^C ] := self.quit;
  end;

procedure TCustomApp.step;
  begin
  end;

procedure TCustomApp.draw;
  begin
  end;

procedure TCustomApp.done;
  begin
  end;

procedure TCustomApp.quit;
  begin
    self.Terminate
  end;

constructor TCustomApp.Create;
  begin
    inherited Create(Nil);
  end;

procedure TCustomApp.Initialize;
  begin
  end;

procedure TCustomApp.DoRun;
  begin
    km.HandleKeys;
    self.step;
  end;

begin
end.
