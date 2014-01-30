{$i xpc.inc}{$mode delphi}{$h+}
unit uapp;
interface uses xpc, cx, kvm, ukm, custapp, sysutils, classes;

type
  ESetupFailure = class (Exception) end;
  TCustomApp = class (TComponent)
    private _quit : TNotifyEvent;
  public
    procedure keys(km : ukm.TKeyMap); virtual;
    procedure init; virtual;
    procedure step; virtual;
    procedure draw; virtual;
    procedure done; virtual;
    procedure quit;
  published
    property OnQuit : TNotifyEvent read _quit write _quit;
  end;
  CCustomApp = class of TCustomApp;

  procedure run(appClass : CCustomApp);

implementation

type
  TAppRunner = class (custapp.TCustomApplication)
    app : TCustomApp;
    km : TKeyMap;
    procedure DoRun; override;
  end;
  
procedure TAppRunner.DoRun;
  begin
    km.HandleKeys;
    app.step;
  end;
  
procedure run(appClass : CCustomApp);
  var run : TAppRunner;
  begin
    run := TAppRunner.Create(Nil);
    run.app := appClass.Create(run);
    with run do
      try app.init;
          km := TKeyMap.Create(app); app.keys(km);
          app.draw; run; app.done;
          fg('w'); bg('k'); clrscr; showcursor;
      except
        on e:ESetupFailure do writeln(e.message);
      end;
    run.free;
  end;
  
procedure TCustomApp.init;
  begin
    pass
  end;

procedure TCustomApp.keys(km : ukm.TKeyMap);
  begin
    km.cmd[ ^C ] := self.quit;
  end;

procedure TCustomApp.step;
  begin
    pass
  end;

procedure TCustomApp.draw;
  begin
    pass
  end;

procedure TCustomApp.done;
  begin
    pass
  end;

procedure TCustomApp.quit;
  begin
    if assigned(_quit) then _quit(self) else halt;
  end;

begin
end.
