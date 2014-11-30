// example client for cwio;
{$mode delphi}{$i xpc}
program cwio_eg;
var s: string;
begin
  writeln('|Rred |Ggreen and |Bblue |wtext');
  writeln('press a key.'); writeln(^K); flush(output);
  ReadLn(s);
  writeln('your key was chr(',s,')');
  writeln;
  writeln('enter a line of text:'); writeln(^E); flush(output);
  ReadLn(s);
  writeln;
  writeln('|Gyour line was:|w',s);
  writeln('|rgoodbye.|w');
  writeln;
end.
