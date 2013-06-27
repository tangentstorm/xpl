{$mode delphi}
unit sprout;
interface

type
  TCmd = class
    end;
  TCharMap = class
    private
      jmps : array [char] of byte;
      cmds : array of TCmd;
    public
      constructor Create;
      function AddCmd(cmd : TCmd):byte;
      function GetCmd(ch : char):TCmd;
      property handle[ch : char]:TCmd read GetCmd; default;
  end;

var
  cmdFail : TCmd;

implementation

constructor TCharMap.Create;
  begin
    FillByte(jmps[#0], 256, 0);
    SetLength(cmds, 1);
    cmds[0] := cmdFail;
  end;

function TCharMap.GetCmd(ch:char):TCmd;
  begin
    result := cmds[jmps[ch]];
  end;

function TCharMap.AddCmd(cmd:TCmd):byte;
  begin
    result := Length(cmds);
    SetLength(cmds, result+1);
    cmds[result] := cmd;
  end;

{

procedure LiftCmd; // antlr ^
  var head : Node;
  begin
    head := cons(last, mark.next);
    mark.next := head;
  end;
}

begin
  cmdFail := TCmd.Create;
end.
