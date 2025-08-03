{$mode objfpc}
unit uterm_video;
interface
uses video;

procedure GetXY( out x, y : byte );
procedure GetWH( out w, h : byte );
procedure SetRawMode(b:boolean);

implementation

procedure GetXY( out x, y : byte );
  begin
    x := video.cursorX;
    y := video.cursorY;
  end;

procedure GetWH( out w, h : byte );
  var mode : video.TVideoMode;
  begin
    video.GetVideoMode(mode);
    w := mode.col;
    h := mode.row;
  end;

procedure SetRawMode(b:boolean);
  begin
  end;

end.