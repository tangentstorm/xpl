{$mode delphi}
{$i test_gridterm.def }
implementation uses kvm;

var term : TGridTerm;

procedure setup;
  begin
    if assigned(term) then term.free;
    term := TGridTerm.Create(16,16);
  end;

procedure test_accessors;
  var ch : char;
  begin
    with term do
      begin
	bg(8);
	fg(15);
	clrscr;
	gotoxy(0,0);
	for ch in 'hello world' do emit(ch);
      end;
  end;

finalization
  if assigned(term) then term.free;
end.
