// Terminal sensors for various platforms.
{$mode objfpc}
unit uterm;
interface
{$macro on}
{$if defined(VIDEO_FALLBACK)}{$define SUBUNIT:=uterm_video}
{$elseif defined(UNIX)}{$define SUBUNIT:=uterm_unix}
{$elseif defined(WINDOWS)}{$define SUBUNIT:=uterm_windows}
{$else}{$define SUBUNIT:=uterm_video}{$endif}

  procedure GetXY( out x, y : byte );
  procedure GetWH( out w, h : byte );
  procedure SetRawMode(b:boolean);

  var
    w, h : byte; { initial terminal width and height }
    startX, startY : byte; { initial cursor x and y coordinates }
    OnResize : procedure ( const w, h : byte );

implementation
uses SUBUNIT;

procedure OnResizeIgnore (const w, h : byte );
begin
  { do nothing }
end;

procedure GetWH( out w, h : byte ); inline;
begin SUBUNIT.GetWH( w, h )
end;

procedure GetXY( out x, y : byte ); inline;
begin SUBUNIT.GetXY( x, y )
end;

procedure SetRawMode(b:boolean); inline;
begin SUBUNIT.SetRawMode( b )
end;

initialization
  GetWH( w, h );
  OnResize := @OnResizeIgnore;

  SetRawMode( true );
  GetXY( startX, startY );
  SetRawMode( false );
end.
