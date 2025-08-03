program term_size;
uses uterm;

procedure OnResize( const w, h : byte );
  begin
    WriteLn( 'The terminal size is: ', w, ' x ', h, '.' );
  end;

var w,h : byte;
begin
  uterm.GetWH(w,h);
  WriteLn('Initial term size is ', w, ' x ', h, ' characters.');
  uterm.OnResize := @OnResize;
  Writeln('On some platforms, we can get notified of size changes.');
  WriteLn('Resize Terminal, or press enter to exit.' );
  ReadLn;
end.
