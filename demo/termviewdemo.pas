{$mode objfpc}{$i xpc.inc}
program termviewdemo;
uses utv, kvm, kbd, custapp;

type
  TTermViewApp	= class(TCustomApplication)
    private
      sprite : TTermView;
    public
      procedure Initialize; override;
      procedure DoRun; override;
    end;

procedure TTermViewApp.Initialize;
  begin
    sprite := TTermView.Create(self);
    sprite.resize(8,16);
    with sprite.term do
      begin
        bg(0);
        fg(7);
        clrscr;
        gotoxy(0,0);
	emit('hello')
      end;
  end;

procedure TTermViewApp.DoRun;
  var ch : char;
  begin
    ClrScr;
    sprite.Redraw;
    case readkey(ch) of
      ^C : terminate;
      ^H : sprite.term.clrscr;
      //'.','w',
      ^P : sprite.nudge(0, -1); // up
      //'a',
      ^B : sprite.nudge(-1, 0); // left
      // 'o','s',
      ^N : sprite.nudge(0, +1); // down
      // 'e','d'
      ^F : sprite.nudge(+1, 0); // right
    else
      sprite.term.emit(ch);
    end;
  end;

begin
  CustomApplication := TTermViewApp.Create(nil);
  with CustomApplication do
    begin
      Initialize;
      Run;
      Free;
    end;
end.