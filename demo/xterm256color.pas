{ mjw ported from 256colors2.pl : }
// Author: Todd Larason <jtl@molehill.org>
// $XFree86: xc/programs/xterm/vttests/256colors2.pl,v 1.2 2002/03/26 01:46:43 dickey Exp $

{$mode delphiunicode}{$i xpc.inc }
program xterm256color;
  uses xpc, ustr, sysutils;

  procedure esc(s : TStr); begin  write(#27, '[', s) end;
  procedure ClrScr; begin esc('H'); esc('J') end;
  procedure Fg(b : byte); begin esc('38;5;' + IntToStr(b) + 'm') end;
  procedure Bg(b : byte); begin esc('48;5;' + IntToStr(b) + 'm') end;


  procedure ResetColor;
  begin
    fg(7); bg(0);
  end;

  function hexbyte( b : byte ) : string;
  begin
    result := rpad( hex( b ), 2, '0' )
  end;

  { the original looked a lot nicer because it used two spaces of background
    and thus showed solid blocks... but: i was testing both foreground and
    background, and the brackets still kind of look cool. :) }
  procedure showcolor( color :  byte );
  begin
    resetcolor;
    fg( color );
    write(':');
    bg( color );
    fg( 0 );
    write('-');
  end;


procedure section(msg : TStr);
  begin
    ResetColor;
    Writeln; Writeln;
    Writeln(msg);
    Writeln; Writeln;
  end;

var
  red, green, blue, gray, color, level, x,y : byte;
begin

  ClrScr;

  { -- configure the palette --------------------- }

  // use the resources for colors 0-15 - usually more-or-less a
  // reproduction of the standard ANSI colors, but possibly more
  // pleasing shades.

  for red := 0 to 5 do
    for green := 0 to 5 do
      for blue := 0 to 5 do
      begin
        write(#27, ']4;'); write(16 + (red * 36) + (green * 6) + blue, 'rgb:' );
        if red <> 0 then write(hexbyte( red * 40 + 55 ))
        else write( '00' );
        write('/');
        if green <> 0 then write(hexbyte( green * 40 + 55 ))
        else write('00' );
        write('/');
        if blue <> 0 then write(hexbyte( blue * 40 + 55 ))
        else write('00' );
        write(#27, '\' );
      end;

  // colors 232-255 are a grayscale ramp, intentionally leaving out
  // black and white
  for gray := 0 to 23 do
  begin
    level := (gray * 10) + 8;
    write( #27, ']4;'); write( 232 + gray, 'rgb:' );
    write( hexbyte( level ), '/', hexbyte( level ), '/', hexbyte( level ));
    write( #27, '\' );
  end;


  // display the colors

  // first the system ones:
  section( 'System colors:');
  for color := 0 to 7 do showcolor( color );
  resetcolor; writeln;
  for color := 8 to 15 do showcolor( color );
  resetcolor;  writeln;

  // now the color cube
  section( 'Color cube, 6x6x6:' );
  for green := 0 to 5 do begin
    for red := 0 to 5 do begin
      for blue := 0 to 5 do showcolor( 16 + (red * 36) + (green * 6) + blue );
      resetcolor; { to draw the spaces between layers of the cube }
      write('  ');
    end;
    writeln;
  end;

  // now the grayscale ramp
  section( 'Grayscale ramp:' );
  for color := 232 to 255 do showcolor( color );

  section( 'Hex Codes on Dark and Light backgrounds:' );
  // now show the colors on dark and light backgrounds:
  for y := 0 to 15 do begin
    bg(0);
    for x := 0 to 15 do begin
      color := y*16+x; fg(color); write(hexbyte(color));
    end;
    write('  '); bg(15);
    for x := 0 to 15 do begin
      color := y*16+x; fg(color); write(hexbyte(color));
    end;
    resetcolor; writeln;
  end;

  resetcolor; writeln;
end.
