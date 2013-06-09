program termsize;
uses kvm, terminal;

procedure OnResize( const w, h : byte );
  begin
    WriteLn( 'The terminal size is: ', w, ' x ', h, '.' );
  end;

begin
  terminal.OnResize := @OnResize;
  WriteLn( 'Resize Terminal, or press enter to exit.' );
  ReadLn;
  kvm.GotoXy( terminal.startX, terminal.startY );
end.
