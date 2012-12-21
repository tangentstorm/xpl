{
| object oriented programming for concurrent programming.
}
unit oo;

interface

type  
  
  pMsg = ^tMsg; { so we can put objects on heap or stack }
  tMsg = object
    {
    | Abstract base class for all messages.
    |
    | It makes more sense for this to be a record, but
    | records don't allow inheritance in pascal.
    }
  end;


  pObj = ^tObj;
  tObj = object
    {
    | Abstract base class for all objects.
    |
    | Fundamentally, an object is a stateful machine that
    | sends and receives messages:
    |
    |   type Object = Msg -> State -> State Msg
    |
    | In the voruati model, this coresponds to protocol 'ti'
    | However, it seems convenient to provide the other three
    | fundamental messages.
    }
    vo : procedure;
    ru : procedure( msg : pMsg );
    na : function : pMsg;
    ti : function ( msg : pMsg ): pMsg;
  end;
  
implementation

begin
end.
