

constructor zchoice.createXY(
  a, b : Byte; s, s2 : String; ison : Boolean;
  shortcut : Char; value : Word; submen : zObj );
begin
  inherited create( a, b, s, s2 );
  self.on   := isOn;
  self.sc   := upCase( shortcut );
  self.v    := value;
  self.sub := submen;
end;

constructor zchoice.create(
  s, s2 : String; ison : Boolean;
  shortcut : Char; value : Word; submen : zObj );
begin
  self.createXY( 0, 0, s, s2, ison, shortcut, value, submen );
end;

procedure zchoice.draw( high : Boolean );
begin
  if high then showInvert else showNormal
end;

function zchoice.enabled : boolean;
begin
  result := self.on;
end;