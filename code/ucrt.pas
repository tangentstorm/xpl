{ --- warning!! generated file. edit ../text/kvm.pas.org instead!! --- }


{$mode objfpc}
unit crt;
interface uses kvm;

{ helpers }
function crt_get_textattr : byte;
procedure crt_set_textattr( value : byte );

{ window / cursor managament }
var WindMaxX, WindMaxY, WindMinX, WindMinY : byte;
procedure GotoXY( x, y : word );
function  WhereX : byte;
function  WhereY : byte;
procedure Window( x1, y1, x2, y2 : Byte );
procedure ClrEol;
procedure ClrScr;
procedure DelLine; { delete line at cursor }
procedure InsLine; { insert line at cursor }

{ color }
procedure TextColor( c : byte );
procedure TextBackground( c : byte );
procedure HighVideo;
procedure LowVideo;
procedure NormVideo; { restores color from startup }
property TextAttr : byte
  read  crt_get_textattr
  write crt_set_textattr;

{ interaction }
function  KeyPressed : boolean;
function  ReadKey : char;
procedure Delay;
procedure Sound( hz : word );
procedure NoSound;
{ TODO:
property CheckBreak : boolean }

implementation
  var _textattr : kvm.TTextAttr;
  type TCrtColor  = $0 .. $f;
  
  procedure crt_set_textattr( value : byte );
  begin
    _textattr.bg := hi( value );
    _textattr.fg := lo( value );
  end;
  
  function crt_get_textattr : byte;
  begin
    result := (_textattr.bg shl 8) + _textattr.fg;
  end;
  
  procedure TextColor( c : byte );
  begin
    _textattr.fg := TCrtColor( c );
  end;
  
  procedure TextBackground( c : byte );
  begin
    _textattr.bg := TCrtColor( c );
  end;
  
  
  var _x, _y : byte;
  procedure GotoXY( x, y : word );
  begin
    _x := x;
    _y := y;
  end;
  
  function WhereX:byte;
    begin
      result := _X;
    end;
  
  function WhereY:byte;
    begin
      result := _y;
    end;
  
  
  
  procedure window(x1,y1,x2,y2:byte);
    begin
      // TODO: i don't think this is right behavior
      windMinX := x1;
      windMinY := y1;
      windMaxX := x2;
      windMaxY := y2;
    end;
  
  procedure clreol;
    begin
    end;
  
  procedure clrscr;
    begin
    end;
  
  procedure delline; begin end;
  procedure insline; begin end;
  procedure highvideo; begin end;
  procedure lowvideo; begin end;
  procedure normvideo; begin end;
  function keypressed:boolean; begin result := false end;
  function readkey:char; begin result := #255 end;
  procedure delay; begin end;
  procedure sound( hz : word); begin end;
  procedure nosound; begin end;
  
end.
