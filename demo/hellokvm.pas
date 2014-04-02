{$mode delphi}
program hellokvm;
uses kvm;

procedure out(s : string);
  begin
    writeln(kvm.stdout, s);
  end;

begin
  writeln(stdout);
  out('--------------------------------------------------------------');
  out('The kvm unit intercepts pascal''s default "Output"');
  out('file, and filters it through kvm.emit().');
  writeln(stdout);
  out('You can produce unfiltered output by explicitly writing');
  out('to the provided (var kvm.stdout : Text)');
  writeln(stdout);
  out('This file demonstrates the effects of various calls:');
  writeln(stdout);
  writeln(stdout, '  writeln(stdout, ...)  { raw output } ');
  kvm.emit(       '  kvm.emit(...)         { explicit call to kvm }');
  out('');
  writeln(        '  writeln(...)          { implicit use of kvm } ');
  write(          '  write(...)            { same, without newline }');
  out('');
  writeln(output, '  writeln(output, ...)  { same, using "output" }  ');
  out('');
  out('--------------------------------------------------------------');
  writeln(stdout);
end.
