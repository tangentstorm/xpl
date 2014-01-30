{$i xpc.inc}{$mode delphi}{$h+}
unit uapp;
interface uses xpc, cx, cli, kvm, ukm, custapp, sysutils, classes;

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
    procedure fail(why:string);
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
    procedure AppQuit(Sender:TObject);
  published
    procedure DoRun; override;
  end;

procedure TAppRunner.DoRun;
  begin
    km.HandleKeys;
    app.step;
  end;

procedure TAppRunner.AppQuit(Sender:TObject);
  begin
    self.terminate;
  end;

procedure run(appClass : CCustomApp);
  var runner : TAppRunner; ca : TCustomApp;
  begin
    runner := TAppRunner.Create(Nil);
    with runner do
      try app := appClass.Create(runner);
          app.init; app.OnQuit := AppQuit;
          km := TKeyMap.Create(app); app.keys(km);
          app.draw; while not terminated do dorun; app.done;
          fg('w'); bg('k'); clrscr; showcursor;
      except
        on e:ESetupFailure do writeln(e.message);
      end;
    runner.free;
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

procedure TCustomApp.fail(why:string);
  begin
    raise ESetupFailure.Create(why);
  end;

procedure TCustomApp.quit;
  begin
    if assigned(_quit) then _quit(self)
    else customapplication.terminate;
  end;

begin
end.
