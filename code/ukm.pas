{$i xpc.inc}{$mode delphiunicode}
unit ukm;
interface uses classes, xpc, kbd, umsg;

//  TODO : improve the keyboard handling
//    - probably should use use sparse arrays
//    - allow each control to have its own sparse array
//    - update kbd module to use widechars.
//    - set up state transitions to allow emacs-style sequences
type
  TKeyEvtKind = ( keNil, keCmd, keNfy, keCRT, keMsg );
  TCommandEvent = procedure of object;
  TCrtKeyEvent  = procedure (ext : boolean; ch : char) of object;
  TKeyboardEvent = record
    case kind : TKeyEvtKind of
      keNil : (eNil: pointer);
      keCmd : (eCmd: TCommandEvent);
      keNfy : (eNfy: TNotifyEvent);
      keCrt : (eCrt: TCrtKeyEvent);
      keMsg : (eMsg: umsg.TMsg);
    end;

const
  DoNothing : TKeyboardEvent = (kind: keNil; eNil : NIL);

type
  TKeyMap = class (TComponent)
    private
      _key, _ext : array[ char ] of TKeyboardEvent;
      procedure SetKeyEvt( ch : widechar; e : TKeyboardEvent );
      procedure SetKeyCmd( ch : widechar; e : TCommandEvent );
      procedure SetKeyNfy( ch : widechar; e : TNotifyEvent );
      procedure SetKeyCrt( ch : widechar; e : TCrtKeyEvent );
      procedure SetKeyMsg( ch : widechar; e : umsg.TMsg );
    public
      constructor Create( aOwner : TComponent ); override;
      property cmd[ ch : widechar ] : TCommandEvent write SetKeyCmd;
      property nfy[ ch : widechar ] : TNotifyEvent  write SetKeyNfy;
      property crt[ ch : widechar ] : TCrtKeyEvent  write SetKeyCrt;
      property msg[ ch : widechar ] : umsg.TMsg     write SetKeyMsg;
      procedure HandleKeys;
      procedure CopyTo( other : TKeyMap );
    end;

implementation

{---------------------------------------------------------------}
{ TKeyMap                                                       }
{---------------------------------------------------------------}
constructor TKeyMap.Create( aOwner : TComponent );
  var ch : widechar;
  begin
    inherited Create( aOwner );
    for ch := #0 to #$FF do _key[ch] := DoNothing;
    for ch := #0 to #$FF do _ext[ch] := DoNothing;
  end;

procedure TKeyMap.SetKeyEvt( ch : widechar; e : TKeyboardEvent );
  begin
    if ch > #255 then _ext[ char(ord(ch) and $ff) ] := e
    else _key[ch] := e;
  end;

procedure TKeyMap.SetKeyCmd( ch : widechar; e : TCommandEvent );
  var kbe : TKeyboardEvent;
  begin
    kbe.kind := keCmd; kbe.eCmd := e; SetKeyEvt(ch, kbe);
  end;

procedure TKeyMap.SetKeyNfy( ch : widechar; e : TNotifyEvent );
  var kbe : TKeyboardEvent;
  begin
    kbe.kind := keNfy; kbe.eNfy := e; SetKeyEvt(ch, kbe);
  end;

procedure TKeyMap.SetKeyCrt( ch : widechar; e : TCrtKeyEvent );
  var kbe : TKeyboardEvent;
  begin
    kbe.kind := keCrt; kbe.eCrt := e; SetKeyEvt(ch, kbe);
  end;

procedure TKeyMap.SetKeyMsg( ch : widechar; e : umsg.TMsg );
  var kbe : TKeyboardEvent;
  begin
    kbe.kind := keMsg; kbe.eMsg := e; SetKeyEvt(ch, kbe);
  end;

procedure TKeyMap.HandleKeys;
  var ch : TChr;
  procedure send(ext : boolean; e : TKeyboardEvent);
    begin
      case e.kind of
        keNil : ok;
        keCmd : e.eCmd();
        keNfy : e.eNfy( self );
        keCrt : e.eCrt( ext, ch );
	keMsg : umsg.Send(e.eMsg);
      end;
    end;
  begin
    if kbd.KeyPressed then
      begin
        if kbd.ReadKey(ch) = #0
          then send(true,  _ext[kbd.ReadKey])
          else send(false, _key[ch])
      end
  end;

procedure TKeyMap.CopyTo( other : TKeyMap );
  var ch : char;
  begin
    for ch in char do begin
      other._key[ch] := self._key[ ch ];
      other._ext[ch] := self._ext[ ch ];
    end;
  end;

begin
  RegisterClass(TKeyMap);
end.
