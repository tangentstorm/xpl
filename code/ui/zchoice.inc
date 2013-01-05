

constructor zchoice.createXY(
  a, b : Byte; s, s2 : String; ison : Boolean;
  shortcut : Char; value : Word; submen : zObj; tail : zChoice );
begin
  zText.create( a, b, s, s2 );
  self.st1  := s;
  self.st2  := s2;
  self.on   := isOn;
  self.sc   := upCase( shortcut );
  self.v    := value;
  if submen = nil then
    self.sub := nil
  else
    self.sub := submen;
  (* self.next := tail; *)
end;

constructor zchoice.create(
  s, s2 : String; ison : Boolean;
  shortcut : Char; value : Word; submen : zObj; tail : zChoice );
begin
  self.createXY( 0, 0, s, s2, ison, shortcut, value, submen, tail );
end;


procedure zchoice.draw( high : Boolean );
begin
  if high then showInvert else showNormal
end;

function zchoice.enabled : boolean;
begin
  result := self.on;
end;