// range extension for sqlite;
//
// $ fpc -fPIC sqlrange.pas && mv libsqlrange.so sqlrange.so
// $ sqlite3
// sqlite> .load ./sqlrange
// sqlite> create virtual table range using range;
// sqlite> select i from range;
// i
// ----------
// 0
// 1
// 2
// 3
// 4

{$mode delphi}
library sqlrange;
uses ctypes, sqlite3, sqlite3ext;


// virtual table : lifecycle methods

function vtCreate(db:pDBh; var pAux:pointer; argc:cint; argv:Ppcchar;
		  out ppVTab:Psqlite3_vtab; pzErr:PPcchar):cint; cdecl;
  begin
    gSqlite.declare_vtab(db, 'create table range (i INT)');
    ppVTab := new(Psqlite3_vtab);
    result := SQLITE_OK;
  end;

function vtConnect(db:pDBh; var pAux:pointer; argc:cint; argv:Ppcchar;
		  out ppVTab:Psqlite3_vtab; ppzErr:PPcchar):cint; cdecl;
  begin
    result := vtCreate(db, pAux, argc, argv, ppVTab, ppzErr)
  end;

function vtDestroy (pVTab:psqlite3_vtab):cint;cdecl;
  begin
    dispose(pVTab); result := SQLITE_OK;
  end;

function vtDisconnect(pVTab:psqlite3_vtab):cint;cdecl;
  begin
    result := vtDestroy(pVTab);
  end;


// virtual table 'best index' query

function vtBestIndex(var pVTab:sqlite3_vtab;
                     var ixifo:sqlite3_index_info) : cint; cdecl;
  begin
    result := SQLITE_OK; // just use whatever the defaults are
  end;



// virtual table : cursor movement

type
  PVTCursor = ^TVTCursor;
  TVTCursor = record
		base : sqlite3_vtab_cursor;
		idx : integer;
	      end;

function vtOpen (var pVTab    : sqlite3_vtab;
                 out ppCursor : Psqlite3_vtab_cursor):cint;cdecl;
  begin
    new(ppCursor); result := SQLITE_OK;
  end;

function vtClose (pCur:Psqlite3_vtab_cursor):cint;cdecl;
  begin
    result := SQLITE_OK;
  end;

function vtFilter (pCur:Psqlite3_vtab_cursor; idxNum:cint; idxStr:pcchar;
                        argc:cint; argv:ppsqlite3_value) : cint; cdecl;
  begin
    PVtCursor(pCur).idx := 0; result := SQLITE_OK;
  end;

function vtNext (pCur:Psqlite3_vtab_cursor) : cint; cdecl;
  begin
    inc(PVtCursor(pCur).idx); result := SQLITE_OK;
  end;

function vtEof (pCur:Psqlite3_vtab_cursor) : cint; cdecl;
  begin
    if PVtCursor(pCur).idx >= 5
      then result := CInt(true)
      else result := CInt(false)
  end;


// virtual table : data retrieval

function vtColumn (pCur : Psqlite3_vtab_cursor;
		   pCtx : Psqlite3_context; _3:cint) : cint; cdecl;
  begin
    gSQLite.result_int(pCtx, PVTCursor(pCur).idx);
    result := SQLITE_OK;
  end;

function vtRowid (pCur : Psqlite3_vtab_cursor;
		  out rowid : sqlite3_int64) : cint; cdecl;
  begin
    rowid := PVTCursor(pCur).idx;
    result := SQLITE_OK;
  end;




// virtual table - optional methods

{function vtUpdate (_1 : Psqlite3_vtab; _2:cint;
		  _3 : PPsqlite3_value; _4:Psqlite3_int64):cint;cdecl;
  begin
  end;}

{function vtBegin (var pVTab:sqlite3_vtab):cint;cdecl;
  begin
  end;}

{function vtSync (var pVTab:sqlite3_vtab):cint;cdecl;
  begin
  end;}

{function vtCommit (var pVTab:sqlite3_vtab):cint;cdecl;
  begin
  end;}

{function vtRollback (var pVTab:sqlite3_vtab):cint;cdecl;
  begin
  end;}

{function vtFindFunction (var pVtab  : sqlite3_vtab; nArg:cint; zName:pcchar;
			    pxFunc : txFindFuncCb; var ppArg:pointer):cint;cdecl;
  begin
  end;}

{function vtRename (var pVtab:sqlite3_vtab; zNew:pcchar):cint;cdecl;
  begin
  end;}

{function vtSavepoint (var pVTab:sqlite3_vtab; _2:cint):cint;cdecl;
  begin
  end;}

{function vtRelease (var pVTab:sqlite3_vtab; _2:cint):cint;cdecl;
  begin
  end;}

{function vtRollbackTo (var pVTab:sqlite3_vtab; _2:cint):cint;cdecl;
  begin
  end;}



// -- virtual table -- methods
const
  SqlVtRange : sqlite3_module = (
    iVersion: 1;
    xCreate: vtCreate;
    xConnect: vtConnect;
    xBestIndex: vtBestIndex;
    xDisconnect: vtDisconnect;
    xDestroy: vtDestroy;
    xOpen: vtOpen;
    xClose: vtClose;
    xFilter: vtFilter;
    xNext: vtNext;
    xEof: vtEof;
    xColumn: vtColumn;
    xRowid: vtRowid;
    xUpdate: nil; // vtUpdate;
    xBegin: nil; // vtBegin;
    xSync: nil; // vtSync;
    xCommit: nil; // vtCommit;
    xRollback: nil; // vtRollback;
    xFindFunction: nil; // vtFindFunction;
    xRename: nil; // vtRename;
    xSavepoint: nil; // vtSavepoint;
    xRelease: nil; // vtRelease;
    xRollbackTo: nil; // vtRollbackTo
  );



// entry point to register the above object with sqlite

function sqlite3_sqlrange_init(
	       dbh : pDBh; var errmsg:PChar;
	   var api :  SQLite3_api_routines) : CInt; cdecl;
begin
  gSQLite := @api;
  gSQLite.create_module(dbh, 'range', @SqlVtRange, nil);
  result := SQLITE_OK;
end;

exports
  sqlite3_sqlrange_init;
end.
