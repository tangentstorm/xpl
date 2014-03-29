{$i xpc.inc}{$mode delphiunicode}
unit udc;
interface uses xpc, classes, sqldb, udb, num;
type
  TDbCursor = class (TComponent) // TODO : ICursor
    protected
      _rs : udb.TRecordSet;
      _kf : TStr;
      _mk : integer; // can't really use bookmarks because they disappear on refresh :/
      _hr : boolean; // allow hiding rows?
      _hf : TStr; // if so, use this field as a flag
      fMarkChanged : TNotifyEvent;
    public
      constructor Create(aOwner : TComponent = Nil); override;
      function Attach(rs : udb.TRecordSet; key : TStr) : TDbCursor;
      procedure ToTop;
      procedure ToEnd;
      function AtTop : boolean;
      function AtEnd : boolean;
      procedure Next;
      procedure Prev;
      function  AtMark : boolean;
      function  RowIsVisible : boolean;
      procedure ToMark;
      procedure SetMark(id : integer);
      procedure SetItem(key : TStr; value: variant);
      function  GetItem(key : TStr): variant;
   published
      property OnMarkChanged : TNotifyEvent read fMarkChanged write fMarkChanged;
      property RecordSet : udb.TRecordSet read _rs write _rs;
      property KeyField : TStr  read _kf write _kf;
      property canHideRows : boolean  read _hr write _hr;
      property hideFlag : TStr  read _hf write _hf;
      property Mark : integer read _mk write SetMark;
      property Item[ key : TStr ] : variant
         read GetItem write SetItem; default;
    end;

implementation
{---------------------------------------------------------------}
{ TDbCursor                                                     }
{---------------------------------------------------------------}
constructor TDbCursor.Create(aOwner : TComponent = Nil);
  begin
    inherited Create(aOwner);
  end;

function TDbCursor.Attach(rs : TRecordSet;  key: TStr) : TDbCursor;
  begin
    self.RecordSet := rs; self.KeyField := key; self.Mark := rs[key];
    result := self;
  end;

procedure TDbCursor.SetMark(id : integer );
  begin
    _mk := id;
    if assigned(fMarkChanged) then fMarkChanged(self);
  end;

procedure TDbCursor.ToMark;
  begin
    _rs.locate(utf8encode(keyField), _mk, [])
  end;

procedure TDbCursor.ToTop;
  begin
    ToMark; _rs.First; SetMark(_rs[keyField]);
  end;

procedure TDbCursor.ToEnd;
  begin
    ToMark; _rs.Last; SetMark(_rs[keyField]);
  end;

function TDbCursor.AtTop : boolean;
  begin
    ToMark; result := _rs.BOF;
  end;

function TDbCursor.AtEnd : boolean;
  begin
    ToMark; result := _rs.EOF;
  end;

function TDBCursor.RowIsVisible : boolean;
  begin
    result := (not CanHideRows) or (_rs[hideFlag]=0)
  end;

procedure TDbCursor.Next;
  begin
    ToMark;
    repeat _rs.Next until _rs.EOF or RowIsVisible;
    if RowIsVisible then SetMark(_rs[keyField]);
  end;

procedure TDbCursor.Prev;
  begin
    ToMark;
    repeat _rs.Prior until _rs.BOF or RowIsVisible;
    if RowIsVisible then SetMark(_rs[keyField]);
  end;

function TDbCursor.AtMark : boolean;
  begin
    result := _rs[keyField] = _mk;
  end;

procedure TDbCursor.SetItem(key : TStr; value: variant);
  begin
    ToMark; _rs.Edit; _rs[key] := value; _rs.Post;
  end;

function TDbCursor.GetItem(key : TStr): variant;
  begin
    ToMark; result := _rs[key];
  end;

begin
  RegisterClass(TDbCursor);
end.
