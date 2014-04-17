{
| object oriented programming based on concurrency and message passing
}
{$mode delphi}{$i xpc.inc}
unit uoo;
interface uses xpc, classes;
type
  tMsg<a> = class
    {
    | Base class for messages.
    }
  end;

  tVoMeth = procedure of object;
  tRuMeth = procedure ( msg : tMsg ) of object;
  tNaMeth = function : tMsg of object;
  tTiMeth = function ( msg : tMsg ) : tMsg of object;

  tObj = class (TComponent)
    {
    | Base class for all other objects.
    |
    | Fundamentally, an object is a stateful machine
    | that sends and receives messages:
    |
    |   type Obj = Obj a -> Msg b -> (Obj c, Msg d)
    |
    | This corresponds to vorunati protocol 'ti'.
    | However, it seems convenient to provide the other three
    | fundamental messages.
    }
  end;

implementation

begin
end.
