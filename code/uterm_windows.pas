{$mode objfpc}
unit uterm_windows;
interface

procedure GetXY( out x, y : byte );
procedure GetWH( out w, h : byte );
procedure SetRawMode(b:boolean);

implementation

procedure GetXY( out x, y : byte );
begin
  x := 0;
  y := 0;
end;

procedure GetWH( out w, h : byte );
begin
  w := 0;
  h := 0;
end;

procedure SetRawMode(b:boolean);
begin
end;

end.
