// This demonstrates scrolling and line wrapping
// in subwindows using the kvm module.
// 
{$mode delphi}
program scrollterm;
uses xpc, chk, kvm, kbd, ustr, sysutils;

const
  hexits = '0123456789ABCDEF';
var
  sub : kvm.ITerm;
  i,j : integer;
begin
  randomize;
  bg('k'); clrscr;
  for j := 0 to kvm.ymax do begin
    for i := 0 to kvm.xmax do begin
      chk.equal( wherex mod kvm.width, i );
      fg(random(256)); write(chr(random(95) + 32));
    end;
    chk.equal( wherey, j );
  end;
  fg('w');
  sub := TSubTerm.create( kvm.work, 3, 4, 68, 18 ); sub.clrscr;
  sub := TSubTerm.create( kvm.work, 5, 5, 64, 16 ); sub.gotoxy(0,0);
  kvm.work := sub;
  repeat
    fg(255-random(16)); write('hello'); sleep(10);
  until keypressed;
end.
