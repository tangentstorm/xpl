// simple dynamic message system
{$mode delphi}{$i xpc.inc}
unit umsg;
interface uses xpc, arrays;
 
type
  TMsg = record chan, code, arg1, arg2 : word end;
  TMsgHandler = procedure( m : TMsg ) of object;

function Msg( chan, code, arg1, arg2 : word ) : TMsg;
function NewChan : word;
function NewCode : word;
procedure Send( msg : TMsg );
procedure Subscribe( chan : word; handler : TMsgHandler );

implementation

type THandlerArray = GArray<TMsgHandler>;

var
  nextCode : word = 0;
  nextChan : word = 0;
  channels : GArray<THandlerArray>;

function NewCode : word;
  begin result := nextCode; inc(nextCode);
  end;

function NewChan : word;
  begin result := nextChan; inc(nextChan);
    channels.append(ThandlerArray.Create);
  end;

function Msg( chan, code, arg1, arg2 : word ) : TMsg;
  inline; begin
    result.chan := chan;
    result.code := code;
    result.arg1 := arg1;
    result.arg2 := arg2;
  end;

procedure Send( msg : TMsg );
  var handler : TMsgHandler;
  begin
    assert(msg.chan < nextChan);
    assert(msg.code < nextCode);
    for handler in channels[ msg.chan ] do handler(msg);
  end;

procedure Subscribe( chan : word; handler : TmsgHandler );
  begin assert(chan < nextChan);
    channels[chan].append(handler);
  end;


var chan : THandlerArray;
initialization
  channels := GArray<THandlerArray>.Create;
finalization
  for chan in channels do chan.free;
  channels.free;
end.
