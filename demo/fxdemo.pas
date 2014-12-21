{$mode delphiunicode}{$i xpc.inc}
program fxdemo;
uses kvm, fx, cw;

const
  green	  = 2; yellow  = 3; blue = 4; magenta = 5;
  subw	  = 24; subh = 4;

procedure sub(x,y : cardinal);
  begin
    kvm.PushSub(x, y, subw, subh);
    kvm.bg('k'); kvm.fg('w'); clrscr;
  end;

procedure pop;
  begin kvm.PopTerm;
  end;

begin
  fx.fillscreen( $0004, '▒');

  sub(2, 1); cwritexy(0, 0, '|wtxtline');
  fx.txtline( 0, 1, 16, 1, yellow);
  fx.txtline(18, 0, 18, 3, magenta);
  pop;

  sub(30, 1); fx.rectangle(0, 0, subw-1, subh-1, green);
  cwritexy(2, 1, '|wrectangle');
  pop;

  sub(2, 7);
  fx.metalbox(0, 0, subw-2, subh-1);
  cwritexy(2, 1, '|!k|w metalbox');
  pop;

  sub(30, 7);
  fx.button(0, 0, subw-1, subh-1);
  cwritexy(2, 1, '|!w|k button');
  pop;

  sub(2, 13);
  fx.bar(0, 0, subw-1, subh-1, $0c04);
  cwritexy(2, 1, '|!B|k bar (filled rect)');
  pop;

  gotoxy(0, kvm.ymax-3); fg('w'); bg('k');
end.
