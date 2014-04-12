{$mode objfpc}{$i xpc.inc}
program termviewdemo;
uses utv, kvm, kbd, custapp, chk, cx;

type
  TTermViewApp	= class(TCustomApplication)
    private
      sprite : TTermView;
    public
      procedure Initialize; override;
      procedure DoRun; override;
    end;

procedure TTermViewApp.Initialize;
  var s : ITerm;
  begin
    
    sprite := TTermView.Create(self);
    sprite.dump;
    sprite.Init(0, 0, 16, 8);
    sprite.center(kvm.width div 2, kvm.height div 2);
    chk.equal(16, sprite.w);
    chk.equal(8, sprite.h);
    s := sprite.asTerm;
    s.clrscr; s.gotoxy(0,0); s.emit('hello');
  end;

procedure TTermViewApp.DoRun;
  var ch : char;
  begin
    bg(7); ClrScr; sprite.update;
    write('.');
    case readkey(ch) of
      ^C : terminate;
      ^H : sprite.term.clrscr;
      //'.','w',
      ^P : sprite.MoveBy(0, -1); // up
      //'a',
      ^B : sprite.MoveBy(-1, 0); // left
      // 'o','s',
      ^N : sprite.MoveBy(0, +1); // down
      // 'e','d'
      ^F : sprite.MoveBy(+1, 0); // right
    else
      sprite.term.emit(ch);
    end; { case }
    sprite.smudge;
  end;

begin
  CustomApplication := TTermViewApp.Create(nil);
  with CustomApplication do
    begin Initialize; Run; Free;
    end;
end.