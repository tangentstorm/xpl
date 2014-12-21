//
// demonstration of terminal windows in kvm
//
{$mode delphiunicode}
program rndscr;
uses xpc, kvm, kbd, cw, num;

const colors = 16;
var x,y : integer; ch : char = #0; term, main, win : ITerm; palette : string;
begin
  hidecursor;
  term := kvm.asTerm;
  main := SubTerm(term, 0, 1, kvm.xMax, kvm.yMax-1);
  win := main;

  clrscr; gotoxy(0,kvm.yMax);
  cwritexy(0, yMax, '|!K|wkeys: |Wa123|k=|wthemes |WkrgybmcwKRGYBMCW|k=|wmonochrome |Wx|k=|wClrScr |Wn|wew window |Wf|wull screen |%');

  palette := 'wKW'; ch := 'n';
  repeat
    case ch of
      'a' : palette := ccolors;
      '1' : palette := 'wKW';
      '2' : palette := 'ryRyMm';
      '3' : palette := 'gcbGCB';
      'x' : main.clrscr;
      'n' : win := SubTerm(main,
		     random(main.width-30)+2, random(22)+1,
		     random(main.height-30)+2, random(22)+1);
      'f' : win := main;
      else if ch in ccolset then palette := ch;
    end; { case }
    cwritexy(0, 0, '|!K|kterm w|w,|kh |w:= |W' +
	     n2s( kvm.width ) + '|w, |W' + n2s( kvm.height ));
    clrEol;
    cwritexy(30,0, '|kwind w|w,|kh |w:= |W' +
	     n2s( win.width ) + '|w, |W' + n2s( win.height ));
    bg('k');
    kvm.PushTerm(win);
    if ch <> 'x' then
      for y := 0 to yMax do
        begin
	  gotoxy(0,y);
	  for x := 0 to xMax do
            begin
	      fg(palette[random(length(palette)-1)+1]);
	      emit(TChr(random(94)+33));
	    end;
	end;
    popterm;
  until ReadKey(ch) in ['q', ^C];
  ShowCursor;
end.
