{$i xpc.inc}{$mode delphi}{$h+}
unit uapp;
interface uses xpc, sysutils, classes, custapp, cx, cli, kvm, ukm, utv, rings;

type
  ESetupFailure = class (Exception) end;
  TCustomApp = class (utv.TView)
    protected
      _OnQuit : TNotifyEvent;
      keymap  : TKeyMap;
      _focusables : GRing<TView>;
      _focus : IRingCursor<TView>;   { which child is focused ? }
    published { TView interface }
      procedure Render; override;
      procedure Update; override;
    public { interface for users }
      constructor Create( aOwner : TComponent ); override;
      destructor Destroy; override;
      procedure keys(km : ukm.TKeyMap); virtual;
      procedure init; virtual;
      procedure step; virtual;
      procedure draw; virtual;
      procedure done; virtual;
      procedure quit;
      procedure fail(why:string);
    published
      property OnQuit : TNotifyEvent read _OnQuit write _OnQuit;
    end;
  CCustomApp = class of TCustomApp;

  procedure run(appClass : CCustomApp);

implementation

type
  TAppRunner = class (custapp.TCustomApplication)
    app : TCustomApp;
    procedure AppQuit(Sender:TObject);
  published
    procedure DoRun; override;
  end;

procedure TAppRunner.DoRun;
  begin
    app.keymap.HandleKeys;
    app.step; // step before update, so step can smudge subviews
    app.update;
  end;

procedure TAppRunner.AppQuit(Sender:TObject);
  begin self.terminate;
  end;

procedure run(appClass : CCustomApp);
  var runner : TAppRunner;
  begin
    runner := TAppRunner.Create(Nil);
    with runner do
      try app := appClass.Create(runner);
          app.init; app.OnQuit := AppQuit;
          app.keymap := TKeyMap.Create(app); app.keys(app.keymap);
          app.draw; while not terminated do dorun; app.done;
      except
        on e:ESetupFailure do writeln(e.message);
      end;
    runner.free;
  end;

constructor TCustomApp.Create( aOwner : TComponent );
  begin
    inherited Create( aOwner );
    resize( kvm.width, kvm.height );
    _focusables := GRing<TView>.Create;
    _focus := _focusables.MakeCursor;
  end;

destructor TCustomApp.Destroy;
  begin _focusables.free; inherited;
  end;

procedure TCustomApp.Update;
  begin inherited;
    if _focus.atClasp then ok
    else _focus.value.RestoreCursor;
  end;

procedure TCustomApp.Render;
  begin self.draw
  end;

procedure TCustomApp.init;
  begin
  end;

procedure TCustomApp.keys(km : ukm.TKeyMap);
  begin km.cmd[ ^C ] := self.quit;
  end;

procedure TCustomApp.step;
  begin
  end;

procedure TCustomApp.draw;
  begin
  end;

procedure TCustomApp.done;
  begin fg('w'); bg('k'); clrscr; showcursor;
  end;

procedure TCustomApp.fail(why:string);
  begin raise ESetupFailure.Create(why);
  end;

procedure TCustomApp.quit;
  begin
    if assigned(_OnQuit) then _OnQuit(self)
    else customapplication.terminate;
  end;

begin
end.
