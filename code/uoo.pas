{
| an object oriented programming system
| with concurrency and message passing
}
{$mode delphi}{$i xpc.inc}
unit uoo;
interface uses xpc, classes;
type
  tTypId = int32;

  tBuf = class (TComponent)
    {
    | Base class for typed data.
    }
    public
      typ : tTypId;
    end;

  {
  | there are four basic signatures, but for message
  | passing we will mostly deal with with (Na,Ti)
  }
  tVoMethod = procedure of object;
  tRuMethod = procedure ( buf : tBuf ) of object;
  tNaMethod = function : tBuf of object;
  tTiMethod = function ( buf : tBuf ) : tBuf of object;

  tObj = class (tBuf)
    {
    | Base class for objects.
    |
    | Fundamentally, an object is a stateful machine
    | that sends and receives messages.
    }
    protected
      _OnNext : tNaMethod;
      _OnSend : tTiMethod;
    published
      function  eval( buf : tBuf ) : tBuf; virtual;
      procedure exec( buf : tBuf ); virtual;
      property OnNext : tNaMethod read _OnNext write _OnNext;
      property OnSend : tTiMethod read _OnSend write _OnSend;
    end;


implementation

function tObj.eval( buf : tBuf ) : tBuf;
  begin result := tBuf.Create(Nil);
  end;

procedure tObj.exec( buf : tBuf );
  begin
  end;

begin
end.
