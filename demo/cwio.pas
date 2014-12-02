{ ┌───────────────────────────────────────────────────────────┐
  │cwio: cwrite i/o wrapper for child programs.               │
  ├───────────────────────────────────────────────────────────┤
  │copyright 2014 michal j wallace. all rights reserved.      │
  │available for use under the terms of the MIT/X11 license.  │
  └───────────────────────────────────────────────────────────┘ }
{$mode delphiunicode}{$i xpc.inc}
program cwio;
uses
  process, processlinetalk,
  xpc, kvm, kbd, cw, lined,
  sysutils;

function BuildProcess : TProcessLineTalk;
  begin
    result := TProcessLineTalk.Create(Nil);
    result.Executable := u2a(xpc.paramline);
    result.Execute;
  end;

procedure SendReadKey(cmd : TProcessLineTalk);
  var s : TStr = ''; ch : TChr;
  begin
    s := a2u(IntToStr(Ord(kbd.ReadKey(ch))));
    if ch = #0 then s := s+' '+a2u(IntToStr(Ord(kbd.ReadKey(ch))));
    cmd.WriteLine(u2a(s));
  end;

procedure SendReadLn(cmd : TProcessLineTalk; prompt:TStr);
  var s : TStr = ' 0!:0 <''demo.ijs'' ';
  begin
    lined.prompt(prompt, s); writeln;
    cmd.WriteLine(u2a(s));
  end;


{ write string s, passing it through cwrite.
  but if string ends with ^K or ^E, suppress the newline
  and instead read a key or line of text, respectively. }
procedure cwioln(cmd :TProcessLineTalk; s : TStr);
  var ch:TChr;
  begin
    if length(s) = 0 then writeln
    else begin
      ch := s[length(s)];
      case ch of
        ^E : sendReadLn(cmd,copy(s,1,length(s)-1));
        ^K : begin
               cwrite(copy(s,1,length(s)-1));
               sendReadKey(cmd);
             end;
        else cwriteln(s)
      end
    end
  end;

var cmd : TProcessLineTalk;
begin
  cw.trg := ^F; // ^F=ACK. I'd use ^T, but j uses ^P..^Z for box drawing.
  cmd := BuildProcess;
  repeat cwioln(cmd,a2u(cmd.ReadLine))
  until cmd.Eof
end.
