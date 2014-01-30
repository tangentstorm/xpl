//-----------------------------------------------------------------------
//
// classes to make working with SqlDb nicer outside of lazarus.
//
//-----------------------------------------------------------------------
{$mode delphi}{$i xpc.inc}
unit udb;
interface
uses xpc, db, sqldb, sqlite3conn,
  sysutils, // for exceptions
  classes; // for TStringList

type
  TRecordSet = class (TSqlQuery)
    constructor Create(dbc : TSqlConnection;  query : string); reintroduce;
    function Execute(q : string) : TRecordSet;
    function Open: TRecordSet; reintroduce;
    function First: TRecordSet; reintroduce;
  end;
  TDatabase = class (TSqlite3Connection)
  private
    _trace : boolean;
    function PrepRs(sql : string; args : array of variant ) : TRecordSet;
  public
    function Query(sql : string) : TRecordSet; overload;
    function Query(sql : string; args : array of variant) : TRecordSet; overload;
    procedure RunSQL(sql : string); overload;
    procedure RunSQL(sql : string; args : array of variant); overload;
    property trace : boolean read _trace write _trace;
  end;
  function connect(const path : string) : TDatabase;

implementation

//- - [ TRecordSet ]  - - - - - - - - - - - - - - - - - - - - - - - - - -

constructor TRecordSet.Create(dbc : TSQLConnection; query : string);
  begin
    inherited Create(dbc);
    self.database := dbc;
    self.sql.text := query;
  end;

function TRecordSet.Open : TRecordSet;
  begin
    inherited open; result := self;
  end;

function TRecordSet.First : TRecordSet;
  begin
    inherited first; result := self;
  end;

function TRecordSet.Execute(q : string) : TRecordSet;
  begin
    self.sql.text := q;
    self.open;
    result := self;
  end;

//- - [ TDatabase ] - - - - - - - - - - - - - - - - - - - - - - - - - - -

function TDatabase.PrepRs(sql : string; args : array of variant ) : TRecordSet;
  var c, i : cardinal;
  begin
    result := TRecordSet.Create(self, sql);
    result.Transaction := self.Transaction;
    result.ParseSQL := true;
    c := result.params.count;
    if c <> length(args) then
      raise Exception('query expects ' + IntToStr(c)
		      +' but ' + IntToStr(length(args)) + ' were supplied');
    if c > 0 then for i := 0 to (c-1) do result.params[i].AsString := args[i];
    if _trace then
      begin write(sql);
	if c > 0 then for i := 0 to (c-1) do write(' ',args[i]); writeln
      end
    else pass;
  end;

function TDatabase.Query(sql : string) : TRecordSet;
  begin
    result := self.Query(sql, []);
  end;

function TDatabase.Query(sql : string; args : array of variant) : TRecordSet;
  begin
    result := PrepRs(sql, args); result.Open;
  end;

procedure TDatabase.RunSQL(sql : string);
  begin
    self.RunSQL(sql, []);
  end;

procedure TDatabase.RunSQL(sql : string; args : array of variant);
  var  rs : TRecordSet;
  begin
    rs := PrepRs(sql, args); rs.ExecSQL;
    self.transaction.commit;
    rs.Free;
  end;

//- - [ misc routines ] - - - - - - - - - - - - - - - - - - - - - - - - -

function connect(const path : string) : TDatabase;
  begin
    result := TDatabase.Create(Nil);
    result.DatabaseName := path;
    result.Transaction := TSqlTransaction.Create(result);
    result.Open;
  end;

initialization
end.
