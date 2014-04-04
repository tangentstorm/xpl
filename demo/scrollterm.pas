// Program to show off scrolling and line wrapping
// in 256-color terminal subwindows using the kvm unit.
//
// Available for free pascal under the MIT license here:
// https://github.com/tangentstorm/xpl/blob/master/demo/scrollterm.pas
//
{$mode delphi}{$i xpc.inc}
program scrollterm;
uses xpc, chk, kvm, kbd, ustr, sysutils;
var
  win, sub : kvm.ITerm;
  i,j : integer;
begin
  randomize; hidecursor; bg('k'); clrscr;

  // generate a background of randomly colored ascii
  // characters. kvm will wrap the text automatically.
  for j := 0 to kvm.ymax do begin
    for i := 0 to kvm.xmax do begin
      chk.equal( wherex mod kvm.width, i );
      fg(random(256)); write(chr(random(95) + 32));
    end;
    chk.equal( wherey, j );
  end;

  sub := TSubTerm.create( kvm.work, 3, 4, 68, 18 ); sub.clrscr;
  sub := TSubTerm.create( kvm.work, 5, 5, 64, 16 ); sub.gotoxy(0,0);

  // the next line redirects output to the subwindow.
  win := kvm.work; kvm.work := sub;
  repeat
    fg(255-random(16)); write('scroll'); sleep(1);
  until keypressed;

  readkey; readkey; // pause for screenshot
  kvm.work := win; // restore the main window for the clrscr
  showcursor; clrscr;
end.
