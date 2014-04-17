{ a simple dynamic message system }
{$mode delphi}{$i xpc.inc}
unit umsg;
interface uses xpc, arrays, uoo;

type
  TMsg = class (uoo.tBuf)
    public
      chan, code : word;
      x, y : integer
    end;
  TMsgHandler = procedure( m : TMsg ) of object;

function newChan : word;
function newCode : word;

function Msg( chan, code : word ) : TMsg;

procedure Send( msg : TMsg );
procedure Subscribe( chan : word; handler : TMsgHandler );

implementation


{ internal variables }
type THandlerArray = GArray<TMsgHandler>;

var
  nextCode : word = 0;
  nextChan : word = 0;
  channels : GArray<THandlerArray>;



{ code / channel numbering }

function NewCode : word;
  begin result := nextCode; inc(nextCode);
  end;

function NewChan : word;
  begin
    result := nextChan; inc(nextChan);
    channels.append(ThandlerArray.Create);
  end;

{ message constructors }

function Msg( chan, code : word ) : TMsg; inline;
  begin
    result := TMsg.Create(Nil);
    result.chan := chan;
    result.code := code;
  end;


{ message dispatch }

procedure Send( msg : TMsg );
  var handler : TMsgHandler;
  begin
    assert(msg.chan < nextChan);
    assert(msg.code < nextCode);
    for handler in channels[ msg.chan ] do handler(msg);
  end;

procedure Subscribe( chan : word; handler : TmsgHandler );
  begin assert(chan < nextChan); channels[chan].append(handler);
  end;


{ lifecycle management }

var chan : THandlerArray;
initialization
  channels := GArray<THandlerArray>.Create;
finalization
  for chan in channels do chan.free;
  channels.free;
end.
