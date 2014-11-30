{ ┌───────────────────────────────────────────────────────────┐
  │cwio: cwrite i/o wrapper for child programs.               │
  ├───────────────────────────────────────────────────────────┤
  │copyright 2014 michal j wallace. all rights reserved.      │
  │available for use under the terms of the MIT/X11 license.  │
  └───────────────────────────────────────────────────────────┘ }
{$mode delphiunicode}{$i xpc.inc}
program cwio;
uses
  process,
  processlinetalk in 'lib/processlinetalk.pas',
  xpc, kvm, kbd, cw, lined,
  sysutils;

function BuildProcess : TProcessLineTalk;
  begin
    result := TProcessLineTalk.Create(Nil);
    result.Executable := u2a(xpc.paramline);
    result.Execute;
  end;

function SendReadKey(cmd : TProcessLineTalk) : TChr;
  var s : TStr = '';
  begin
    //cwriteln('|_|gsending readkey|w');
    s := IntToStr(Ord(kbd.ReadKey(result)));
    if result = #0 then s := s+' '+IntToStr(Ord(kbd.ReadKey(result)));
    cmd.WriteLine(u2a(s));
  end;

function SendReadLn(cmd : TProcessLineTalk) : TChr;
  var s : TStr = '(default input)';
  begin
    writeln;
    lined.prompt('> ', s);
    cmd.WriteLine(s);
  end;

var ch : TChr; s : TStr = ''; cmd : TProcessLineTalk;
begin
  cmd := BuildProcess;
  repeat
    s := cmd.ReadLine;
    // cwriteln(['|bgot line:|c',s,'|w']);
    for ch in s do
      case ch of
	#0 .. ^D,
	^F .. ^J,
	^L .. #31 :  cwrite(['|!w|k^',chr(64+ord(ch)),'|!k|w']);
	^E : sendReadLn(cmd);
	^K : sendReadKey(cmd);
	else cwrite(ch);
      end;
    writeln;
  until cmd.Eof
end.
