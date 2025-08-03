{$mode objfpc}
unit uterm_windows;
interface uses windows;

procedure GetXY( out x, y : byte );
procedure GetWH( out w, h : byte );
procedure SetRawMode(b:boolean);

implementation

var
  OriginalInputMode: DWORD = 0;
  OriginalOutputMode: DWORD = 0;
  ConsoleInputHandle: THandle = 0;
  ConsoleOutputHandle: THandle = 0;

procedure GetXY(out x, y: byte);
var
  csbi: TConsoleScreenBufferInfo;
begin
  if ConsoleOutputHandle = 0 then
    ConsoleOutputHandle := GetStdHandle(STD_OUTPUT_HANDLE);

  if GetConsoleScreenBufferInfo(ConsoleOutputHandle, csbi) then
  begin
    x := csbi.dwCursorPosition.X;
    y := csbi.dwCursorPosition.Y;
  end
  else
  begin
    x := 0;
    y := 0;
  end;
end;

procedure GetWH(out w, h: byte);
var
  csbi: TConsoleScreenBufferInfo;
begin
  if ConsoleOutputHandle = 0 then
    ConsoleOutputHandle := GetStdHandle(STD_OUTPUT_HANDLE);

  if GetConsoleScreenBufferInfo(ConsoleOutputHandle, csbi) then
  begin
    w := csbi.srWindow.Right - csbi.srWindow.Left + 1;
    h := csbi.srWindow.Bottom - csbi.srWindow.Top + 1;
  end
  else
  begin
    w := 80; // Default
    h := 25; // Default
  end;
end;

procedure SetRawMode(b: boolean);
const
  ENABLE_VIRTUAL_TERMINAL_PROCESSING = $0004;
var
  dwMode: DWORD;
begin
  if ConsoleInputHandle = 0 then
  begin
    ConsoleInputHandle := GetStdHandle(STD_INPUT_HANDLE);
    GetConsoleMode(ConsoleInputHandle, OriginalInputMode);
  end;
  if ConsoleOutputHandle = 0 then
  begin
    ConsoleOutputHandle := GetStdHandle(STD_OUTPUT_HANDLE);
    GetConsoleMode(ConsoleOutputHandle, OriginalOutputMode);
  end;

  if b then
  begin
    // Set input mode for raw
    dwMode := OriginalInputMode;
    dwMode := dwMode and not (ENABLE_PROCESSED_INPUT or ENABLE_LINE_INPUT or ENABLE_ECHO_INPUT);
    SetConsoleMode(ConsoleInputHandle, dwMode);

    // Set output mode for virtual terminal processing
    dwMode := OriginalOutputMode;
    dwMode := dwMode or ENABLE_VIRTUAL_TERMINAL_PROCESSING;
    SetConsoleMode(ConsoleOutputHandle, dwMode);
  end
  else
  begin
    // Restore original modes
    SetConsoleMode(ConsoleInputHandle, OriginalInputMode);
    SetConsoleMode(ConsoleOutputHandle, OriginalOutputMode);
  end;
end;

end.