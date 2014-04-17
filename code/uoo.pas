{
| an object oriented programming system
| with concurrency and message passing
}
{$mode delphi}{$i xpc.inc}
unit uoo;
interface uses xpc, classes;
type
  tBuf = class (TComponent)
    {
    | Base class for typed data.
    }
  end;

  tObj = class (tBuf)
    {
    | Base class for objects.
    |
    | Fundamentally, an object is a stateful machine
    | that sends and receives messages.
    }
    function  eval( buf : tBuf ) : tBuf;
    procedure exec( buf : tBuf );
  end;

  { really there are four generic signatures }
  tVoMeth = procedure of object;
  tRuMeth = procedure ( buf : tBuf ) of object;
  tNaMeth = function : tBuf of object;
  tTiMeth = function ( buf : tBuf ) : tBuf of object;

implementation

begin
end.
