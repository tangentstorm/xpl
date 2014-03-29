//-----------------------------------------------------------------------
//
// classes to make working with SqlDb nicer outside of lazarus.
//
//-----------------------------------------------------------------------
{$mode delphiunicode}{$i xpc.inc}
unit udb;
interface
uses xpc, db, sqldb, sqlite3conn,
  sysutils, // for exceptions
  classes; // for TStringList

type
  IDatabase = interface;
  TRecordSet = class (TSqlQuery)
    public
      dbc : IDatabase;
    published
      constructor Create(adbc : TSqlConnection;  query : TStr); reintroduce;
      function Execute(q : TStr) : TRecordSet;
      function Open: TRecordSet; reintroduce;
      function First: TRecordSet; reintroduce;
      function GetItem( key : TStr ) : variant;
      procedure SetItem( key : TStr; value : variant);
      property items[key : TStr] : variant read GetItem write SetItem; default;
    end;
  IDatabase = interface
    function Query(sql : string; args : array of variant) : TRecordSet;
    procedure RunSQL(sql : string; args : array of variant);
  end;
  TDatabase = class (TSqlite3Connection, IDatabase)
    private
      _trace : boolean;
      function PrepRs(sql : TStr; args : array of variant ) : TRecordSet;
    public
      function Query(sql : TStr) : TRecordSet; overload;
      function Query(sql : TStr; args : array of variant) : TRecordSet; overload;
      procedure RunSQL(sql : TStr); overload;
      procedure RunSQL(sql : TStr; args : array of variant); overload;
      property trace : boolean read _trace write _trace;
    end;

  function connect(const path : TStr) : TDatabase;

implementation

//- - [ TRecordSet ]  - - - - - - - - - - - - - - - - - - - - - - - - - -

constructor TRecordSet.Create(adbc : TSQLConnection; query : TStr);
  begin
    inherited Create(adbc);
    self.database := adbc;
    self.sql.text := utf8encode( query );
  end;

function TRecordSet.Open : TRecordSet;
  begin
    inherited open; result := self;
  end;

function TRecordSet.First : TRecordSet;
  begin
    inherited first; result := self;
  end;

function TRecordSet.Execute(q : TStr) : TRecordSet;
  begin
    self.sql.text := Utf8Encode(q);
    self.open;
    result := self;
  end;

function TRecordSet.GetItem( key : TStr ) : variant;
  begin
    result := FieldByName(Utf8Encode(key)).AsVariant
  end;

procedure TRecordSet.SetItem( key : TStr; value : variant);
  begin
    FieldByName(Utf8Encode(key)).AsVariant := value;
  end;

//- - [ TDatabase ] - - - - - - - - - - - - - - - - - - - - - - - - - - -

function TDatabase.PrepRs(sql : TStr; args : array of variant ) : TRecordSet;
  var c, i : cardinal;
  begin
    result := TRecordSet.Create(self, sql);
    result.dbc := self;
    result.Transaction := self.Transaction;
    result.ParseSQL := true;
    c := result.params.count;
    if c <> length(args) then
      raise Exception('query expects ' + Utf8Decode(IntToStr(c))
		      +' but ' + Utf8Decode(IntToStr(length(args)))
		      + ' were supplied');
    if c > 0 then for i := 0 to (c-1) do result.params[i].AsString := args[i];
    if _trace then
      begin write(sql);
	if c > 0 then for i := 0 to (c-1) do write(' ',args[i]); writeln
      end
    else ok;
  end;

function TDatabase.Query(sql : TStr) : TRecordSet;
  begin
    result := self.Query(sql, []);
  end;

function TDatabase.Query(sql : TStr; args : array of variant) : TRecordSet;
  begin
    result := PrepRs(sql, args); result.Open;
  end;

procedure TDatabase.RunSQL(sql : TStr);
  begin
    self.RunSQL(sql, []);
  end;

procedure TDatabase.RunSQL(sql : TStr; args : array of variant);
  var  rs : TRecordSet;
  begin
    rs := PrepRs(sql, args); rs.ExecSQL;
    self.transaction.commit;
    rs.Free;
  end;

//- - [ misc routines ] - - - - - - - - - - - - - - - - - - - - - - - - -

function connect(const path : TStr) : TDatabase;
  begin
    result := TDatabase.Create(Nil);
    result.DatabaseName := UTF8Encode(path);
    result.Transaction := TSqlTransaction.Create(result);
    result.Open;
  end;

initialization
end.
