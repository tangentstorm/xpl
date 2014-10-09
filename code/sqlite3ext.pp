{$mode objfpc}
unit sqlite3ext;
interface uses ctypes, sqlite3;

// --part 1-------------------------------------------------
//
// these are definitions from sqlite3ext.h , for creating
// extension modules.
//
// part 2 contains definitions for creating virtual tables
// that were not included in the sqlite3 header conversion
// that ships with free pascal.
// ---------------------------------------------------------
{
  Automatically converted by H2Pas 1.0.0 from sqlite3ext.h
  The following command line parameters were used:
    -d
    -lsqlite3
    -C
    -c
    -v
    -S
    sqlite3ext.h
}

type
  PDBh = pointer;
  ppsqlite3_value = ^psqlite3_value;
  psqlite3_value = ^sqlite3_value;
  sqlite3_value = record end;
  TSqlValues = array [0..1024] of PSQlite3_Value;
  PSqlValues = ^TSqlValues;
    Plongint  = ^longint;
    Psqlite3  = pointer;
    Psqlite3_backup  = psqlite3backup;//^sqlite3_backup;
    Psqlite3_blob  = ^sqlite3_blob;
    Psqlite3_context  = ^sqlite3_context;
    TSqlCtx =sqlite3_context;
    PSqlCtx =^sqlite3_context;
    Psqlite3_module  = ^sqlite3_module;
    Psqlite3_mutex  = ^sqlite3_mutex;
    Psqlite3_stmt  = ^sqlite3_stmt;
    Psqlite3_vfs  = ^sqlite3_vfs;
{$IFDEF FPC}
{$PACKRECORDS C}
{$ENDIF}

const
  SQLITE_OK=0;
  SQLITE_UTF8=1;

type

 TProc		       = procedure (_1:pointer);cdecl;
 TPLFunc	       = function (_1:pointer; _2:longint):longint;
 XCommit	       = sqlite3.commit_callback;
  sqlite3_api_routines = record
			   aggregate_context : function (_1:Psqlite3_context; nBytes:longint):pointer;cdecl;
      aggregate_count : function (_1:Psqlite3_context):longint;cdecl;
      bind_blob : function (_1:Psqlite3_stmt; _2:longint; _3:pointer; n:longint; _5:TProc):longint;cdecl;
      bind_double : function (_1:Psqlite3_stmt; _2:longint; _3:double):longint;cdecl;
      bind_int : function (_1:Psqlite3_stmt; _2:longint; _3:longint):longint;cdecl;
      bind_int64 : function (_1:Psqlite3_stmt; _2:longint; _3:sqlite_int64):longint;cdecl;
      bind_null : function (_1:Psqlite3_stmt; _2:longint):longint;cdecl;
      bind_meter_count : function (_1:Psqlite3_stmt):longint;cdecl;
      bind_meter_index : function (_1:Psqlite3_stmt; zName:Pchar):longint;cdecl;
      bind_meter_name : function (_1:Psqlite3_stmt; _2:longint):Pchar;cdecl;
      bind_text : function (_1:Psqlite3_stmt; _2:longint; _3:Pchar; n:longint; _5:TProc):longint;cdecl;
      bind_text16 : function (_1:Psqlite3_stmt; _2:longint; _3:pointer; _4:longint; _5:TProc):longint;cdecl;
      bind_value : function (_1:Psqlite3_stmt; _2:longint; _3:Psqlite3_value):longint;cdecl;
      busy_handler : function (_1:Psqlite3; _2:TPLFunc; _3:pointer):longint;cdecl;
      busy_timeout : function (_1:Psqlite3; ms:longint):longint;cdecl;
      changes : function (_1:Psqlite3):longint;cdecl;
      close : function (_1:Psqlite3):longint;cdecl;
      collation_needed : function (_1:Psqlite3; _2:pointer; _3:xCompare):longint;cdecl;
      collation_needed16 : function (_1:Psqlite3; _2:pointer; _3:xCompare):longint;cdecl;
      column_blob : function (_1:Psqlite3_stmt; iCol:longint):pointer;cdecl;
      column_bytes : function (_1:Psqlite3_stmt; iCol:longint):longint;cdecl;
      column_bytes16 : function (_1:Psqlite3_stmt; iCol:longint):longint;cdecl;
      column_count : function (var pStmt:sqlite3_stmt):longint;cdecl;
      column_database_name : function (_1:Psqlite3_stmt; _2:longint):Pchar;cdecl;
      column_database_name16 : function (_1:Psqlite3_stmt; _2:longint):pointer;cdecl;
      column_decltype : function (_1:Psqlite3_stmt; i:longint):Pchar;cdecl;
      column_decltype16 : function (_1:Psqlite3_stmt; _2:longint):pointer;cdecl;
      column_double : function (_1:Psqlite3_stmt; iCol:longint):double;cdecl;
      column_int : function (_1:Psqlite3_stmt; iCol:longint):longint;cdecl;
      column_int64 : function (_1:Psqlite3_stmt; iCol:longint):sqlite_int64;cdecl;
      column_name : function (_1:Psqlite3_stmt; _2:longint):Pchar;cdecl;
      column_name16 : function (_1:Psqlite3_stmt; _2:longint):pointer;cdecl;
      column_origin_name : function (_1:Psqlite3_stmt; _2:longint):Pchar;cdecl;
      column_origin_name16 : function (_1:Psqlite3_stmt; _2:longint):pointer;cdecl;
      column_table_name : function (_1:Psqlite3_stmt; _2:longint):Pchar;cdecl;
      column_table_name16 : function (_1:Psqlite3_stmt; _2:longint):pointer;cdecl;
      column_text : function (_1:Psqlite3_stmt; iCol:longint):PChar;cdecl;
      column_text16 : function (_1:Psqlite3_stmt; iCol:longint):pointer;cdecl;
      column_type : function (_1:Psqlite3_stmt; iCol:longint):longint;cdecl;
      column_value : function (_1:Psqlite3_stmt; iCol:longint):Psqlite3_value;cdecl;
      commit_hook : function (_1:Psqlite3; _2:xCommit; _3:pointer):pointer;cdecl;
      complete : function (sql:Pchar):longint;cdecl;
      complete16 : function (var sql:pointer):longint;cdecl;
      create_collation : function (_1:Psqlite3; _2:Pchar; _3:longint; _4:pointer; _5:xCompare):longint;cdecl;
      create_collation16 : function (_1:Psqlite3; _2:pointer; _3:longint; _4:pointer; _5:XCompare):longint;cdecl;
      create_function : function (_1:Psqlite3; _2:Pchar; _3:longint; _4:longint; _5:pointer;
                   aXFunc:XFunc; aXStep:XStep; aXFinal:XFinal):longint;cdecl;
      create_function16 : function (_1:Psqlite3; _2:pointer; _3:longint; _4:longint; _5:pointer;
                   axFunc:xFunc; aXStep:xStep; axFinal:xFinal):longint;cdecl;
      create_module : function (_1:Psqlite3; _2:Pchar; _3:Psqlite3_module; _4:pointer):longint;cdecl;
      data_count : function (var pStmt:sqlite3_stmt):longint;cdecl;
      db_handle : function (_1:Psqlite3_stmt):Psqlite3;cdecl;
      declare_vtab : function (_1:Psqlite3; _2:Pchar):longint;cdecl;
      enable_shared_cache : function (_1:longint):longint;cdecl;
      errcode : function (var db:pDBh):longint;cdecl;
      errmsg : function (var db:pDBh):Pchar;cdecl;
      errmsg16 : function (_1:Psqlite3):pointer;cdecl;
      exec : function (_1:Psqlite3; _2:Pchar; _3:sqlite3_callback; _4:pointer; _5:PPchar):longint;cdecl;
      expired : function (_1:Psqlite3_stmt):longint;cdecl;
      finalize : function (var pStmt:sqlite3_stmt):longint;cdecl;
      free : TProc;
      free_table : procedure (result:PPchar);cdecl;
      get_autocommit : function (_1:Psqlite3):longint;cdecl;
      get_auxdata : function (_1:Psqlite3_context; _2:longint):pointer;cdecl;
      get_table : function (_1:Psqlite3; _2:Pchar; _3:PPPchar; _4:Plongint; _5:Plongint;
                   _6:PPchar):longint;cdecl;
      global_recover : function :longint;cdecl;
      interruptx : procedure (_1:Psqlite3);cdecl;
      last_insert_rowid : function (_1:Psqlite3):sqlite_int64;cdecl;
      libversion : function :Pchar;cdecl;
      libversion_number : function :longint;cdecl;
      malloc : function (_1:longint):pointer;cdecl;
      mprintf : function (_1:Pchar; args:array of const):Pchar;cdecl;
      open : function (_1:Pchar; _2:PPsqlite3):longint;cdecl;
      open16 : function (_1:pointer; _2:PPsqlite3):longint;cdecl;
      prepare : function (_1:Psqlite3; _2:Pchar; _3:longint; _4:PPsqlite3_stmt; _5:PPchar):longint;cdecl;
      prepare16 : function (_1:Psqlite3; _2:pointer; _3:longint; _4:PPsqlite3_stmt; _5:Ppointer):longint;cdecl;
      profile : function (_1:Psqlite3; _2:xProfile; _3:pointer):pointer;cdecl;
      progress_handler : procedure (_1:Psqlite3; _2:longint; _3:progress_callback; _4:pointer);cdecl;
      realloc : function (_1:pointer; _2:longint):pointer;cdecl;
      reset : function (var pStmt:sqlite3_stmt):longint;cdecl;
      result_blob : procedure (_1:Psqlite3_context; _2:pointer; _3:longint; _4:TProc);cdecl;
      result_double : procedure (_1:Psqlite3_context; _2:double);cdecl;
      result_error : procedure (_1:Psqlite3_context; _2:Pchar; _3:longint);cdecl;
      result_error16 : procedure (_1:Psqlite3_context; _2:pointer; _3:longint);cdecl;
      result_int : procedure (_1:Psqlite3_context; _2:longint);cdecl;
      result_int64 : procedure (_1:Psqlite3_context; _2:sqlite_int64);cdecl;
      result_null : procedure (_1:Psqlite3_context);cdecl;
      result_text : procedure (_1:Psqlite3_context; _2:Pchar; _3:longint; _4:TProc);cdecl;
      result_text16 : procedure (_1:Psqlite3_context; _2:pointer; _3:longint; _4:TProc);cdecl;
      result_text16be : procedure (_1:Psqlite3_context; _2:pointer; _3:longint; _4:TProc);cdecl;
      result_text16le : procedure (_1:Psqlite3_context; _2:pointer; _3:longint; _4:TProc);cdecl;
      result_value : procedure (_1:Psqlite3_context; _2:Psqlite3_value);cdecl;
      rollback_hook : function (_1:Psqlite3; _2:TProc; _3:pointer):pointer;cdecl;
      set_authorizer : function (_1:Psqlite3; _2:xAuth; _3:pointer):longint;cdecl;
      set_auxdata : procedure (_1:Psqlite3_context; _2:longint; _3:pointer; _4:TProc);cdecl;
      snprintf : function (_1:longint; _2:Pchar; _3:Pchar; args:array of const):Pchar;cdecl;
      step : function (_1:Psqlite3_stmt):longint;cdecl;
      table_column_metadata : function (_1:Psqlite3; _2:Pchar; _3:Pchar; _4:Pchar; _5:PPchar;
                   _6:PPchar; _7:Plongint; _8:Plongint; _9:Plongint):longint;cdecl;
      thread_cleanup : procedure ;cdecl;
      total_changes : function (_1:Psqlite3):longint;cdecl;
      trace : function (_1:Psqlite3; _2:xTrace; _3:pointer):pointer;cdecl;
      transfer_bindings : function (_1:Psqlite3_stmt; _2:Psqlite3_stmt):longint;cdecl;
      update_hook : function (_1:Psqlite3; _2:update_callback; _3:pointer):pointer;cdecl;
      user_data : function (_1:Psqlite3_context):pointer;cdecl;
      value_blob : function (_1:Psqlite3_value):pointer;cdecl;
      value_bytes : function (_1:Psqlite3_value):longint;cdecl;
      value_bytes16 : function (_1:Psqlite3_value):longint;cdecl;
      value_double : function (_1:Psqlite3_value):double;cdecl;
      value_int : function (_1:Psqlite3_value):longint;cdecl;
      value_int64 : function (_1:Psqlite3_value):sqlite_int64;cdecl;
      value_numeric_type : function (_1:Psqlite3_value):longint;cdecl;
      value_text : function (_1:Psqlite3_value):PChar;cdecl;
      value_text16 : function (_1:Psqlite3_value):pointer;cdecl;
      value_text16be : function (_1:Psqlite3_value):pointer;cdecl;
      value_text16le : function (_1:Psqlite3_value):pointer;cdecl;
      value_type : function (_1:Psqlite3_value):longint;cdecl;
      vmprintf : function (_1:Pchar; _2:array of const):Pchar;cdecl;
      overload_function : function (_1:Psqlite3; zFuncName:Pchar; nArg:longint):longint;cdecl;
      prepare_v2 : function (_1:Psqlite3; _2:Pchar; _3:longint; _4:PPsqlite3_stmt; _5:PPchar):longint;cdecl;
      prepare16_v2 : function (_1:Psqlite3; _2:pointer; _3:longint; _4:PPsqlite3_stmt; _5:Ppointer):longint;cdecl;
      clear_bindings : function (_1:Psqlite3_stmt):longint;cdecl;
      create_module_v2 : function (_1:Psqlite3; _2:Pchar; _3:Psqlite3_module; _4:pointer; xDestroy:TProc):longint;cdecl;
      bind_zeroblob : function (_1:Psqlite3_stmt; _2:longint; _3:longint):longint;cdecl;
      blob_bytes : function (_1:Psqlite3_blob):longint;cdecl;
      blob_close : function (_1:Psqlite3_blob):longint;cdecl;
      blob_open : function (_1:PDBh; _2:Pchar; _3:Pchar; _4:Pchar; _5:sqlite3_int64;
                   _6:longint; _7:PPsqlite3_blob):longint;cdecl;
      blob_read : function (_1:Psqlite3_blob; _2:pointer; _3:longint; _4:longint):longint;cdecl;
      blob_write : function (_1:Psqlite3_blob; _2:pointer; _3:longint; _4:longint):longint;cdecl;
      create_collation_v2 : function (_1:Psqlite3; _2:Pchar; _3:longint; _4:pointer; _5:xCompare;
                   _6:TProc):longint;cdecl;
      file_control : function (_1:Psqlite3; _2:Pchar; _3:longint; _4:pointer):longint;cdecl;
      memory_highwater : function (_1:longint):sqlite3_int64;cdecl;
      memory_used : function :sqlite3_int64;cdecl;
      mutex_alloc : function (_1:longint):Psqlite3_mutex;cdecl;
      mutex_enter : procedure (_1:Psqlite3_mutex);cdecl;
      mutex_free : procedure (_1:Psqlite3_mutex);cdecl;
      mutex_leave : procedure (_1:Psqlite3_mutex);cdecl;
      mutex_try : function (_1:Psqlite3_mutex):longint;cdecl;
      open_v2 : function (_1:Pchar; _2:PPsqlite3; _3:longint; _4:Pchar):longint;cdecl;
      release_memory : function (_1:longint):longint;cdecl;
      result_error_nomem : procedure (_1:Psqlite3_context);cdecl;
      result_error_toobig : procedure (_1:Psqlite3_context);cdecl;
      sleep : function (_1:longint):longint;cdecl;
      soft_heap_limit : procedure (_1:longint);cdecl;
      vfs_find : function (_1:Pchar):Psqlite3_vfs;cdecl;
      vfs_register : function (_1:Psqlite3_vfs; _2:longint):longint;cdecl;
      vfs_unregister : function (_1:Psqlite3_vfs):longint;cdecl;
      xthreadsafe : function :longint;cdecl;
      result_zeroblob : procedure (_1:Psqlite3_context; _2:longint);cdecl;
      result_error_code : procedure (_1:Psqlite3_context; _2:longint);cdecl;
      test_control : function (_1:longint; args:array of const):longint;cdecl;
      randomness : procedure (_1:longint; _2:pointer);cdecl;
      context_db_handle : function (_1:Psqlite3_context):Psqlite3;cdecl;
      extended_result_codes : function (_1:Psqlite3; _2:longint):longint;cdecl;
      limit : function (_1:Psqlite3; _2:longint; _3:longint):longint;cdecl;
      next_stmt : function (_1:Psqlite3; _2:Psqlite3_stmt):Psqlite3_stmt;cdecl;
      sql : function (_1:Psqlite3_stmt):Pchar;cdecl;
      status : function (_1:longint; _2:Plongint; _3:Plongint; _4:longint):longint;cdecl;
      backup_finish : function (_1:Psqlite3_backup):longint;cdecl;
      backup_init : function (_1:Psqlite3; _2:Pchar; _3:Psqlite3; _4:Pchar):Psqlite3_backup;cdecl;
      backup_pagecount : function (_1:Psqlite3_backup):longint;cdecl;
      backup_remaining : function (_1:Psqlite3_backup):longint;cdecl;
      backup_step : function (_1:Psqlite3_backup; _2:longint):longint;cdecl;
      compileoption_get : function (_1:longint):Pchar;cdecl;
      compileoption_used : function (_1:Pchar):longint;cdecl;
      create_function_v2 : function (_1:Psqlite3; _2:Pchar; _3:longint; _4:longint; _5:pointer;
                   _6:xFunc; _7:xStep; _8:xFinal; _9:xDestroy):longint; cdecl;
      db_config : function (_1:Psqlite3; _2:longint; args:array of const):longint;cdecl;
      db_mutex : function (_1:Psqlite3):Psqlite3_mutex;cdecl;
      db_status : function (_1:Psqlite3; _2:longint; _3:Plongint; _4:Plongint; _5:longint):longint;cdecl;
      extended_errcode : function (_1:Psqlite3):longint;cdecl;
      log : procedure (_1:longint; _2:Pchar; args:array of const);cdecl;
      soft_heap_limit64 : function (_1:sqlite3_int64):sqlite3_int64;cdecl;
      sourceid : function :Pchar;cdecl;
      stmt_status : function (_1:Psqlite3_stmt; _2:longint; _3:longint):longint;cdecl;
      strnicmp : function (_1:Pchar; _2:Pchar; _3:longint):longint;cdecl;
      unlock_notify : function (_1:Psqlite3; _2:xNotifycb; _3:pointer):longint;cdecl;
      wal_autocheckpoint : function (_1:Psqlite3; _2:longint):longint;cdecl;
      wal_checkpoint : function (_1:Psqlite3; _2:Pchar):longint;cdecl;
      wal_hook : function (_1:Psqlite3; _2:wal_hook_cb; _3:pointer):pointer;cdecl;
      blob_reopen : function (_1:Psqlite3_blob; _2:sqlite3_int64):longint;cdecl;
      vtab_config : function (_1:Psqlite3; op:longint; args:array of const):longint;cdecl;
      vtab_on_conflict : function (_1:Psqlite3):longint;cdecl;
      close_v2 : function (_1:Psqlite3):longint;cdecl;
      db_filename : function (_1:Psqlite3; _2:Pchar):Pchar;cdecl;
      db_readonly : function (_1:Psqlite3; _2:Pchar):longint;cdecl;
      db_release_memory : function (_1:Psqlite3):longint;cdecl;
      errstr : function (_1:longint):Pchar;cdecl;
      stmt_busy : function (_1:Psqlite3_stmt):longint;cdecl;
      stmt_readonly : function (_1:Psqlite3_stmt):longint;cdecl;
      stricmp : function (_1:Pchar; _2:Pchar):longint;cdecl;
      uri_boolean : function (_1:Pchar; _2:Pchar; _3:longint):longint;cdecl;
      uri_int64 : function (_1:Pchar; _2:Pchar; _3:sqlite3_int64):sqlite3_int64;cdecl;
      uri_meter : function (_1:Pchar; _2:Pchar):Pchar;cdecl;
      vsnprintf : function (_1:longint; _2:Pchar; _3:Pchar; _4:array of const):Pchar;cdecl;
      wal_checkpoint_v2 : function (_1:Psqlite3; _2:Pchar; _3:longint; _4:Plongint; _5:Plongint):longint;cdecl;
    end;
   PSQliteAPI = ^sqlite3_api_routines;

var gSQLite : PSQLiteAPI;
{
const
  sqlite3_aggregate_context = sqlite3_api^.aggregate_context;
  sqlite3_aggregate_count = sqlite3_api^.aggregate_count;
  sqlite3_bind_blob = sqlite3_api^.bind_blob;
  sqlite3_bind_double = sqlite3_api^.bind_double;
  sqlite3_bind_int = sqlite3_api^.bind_int;
  sqlite3_bind_int64 = sqlite3_api^.bind_int64;
  sqlite3_bind_null = sqlite3_api^.bind_null;
  sqlite3_bind_parameter_count = sqlite3_api^.bind_parameter_count;
  sqlite3_bind_parameter_index = sqlite3_api^.bind_parameter_index;
  sqlite3_bind_parameter_name = sqlite3_api^.bind_parameter_name;
  sqlite3_bind_text = sqlite3_api^.bind_text;
  sqlite3_bind_text16 = sqlite3_api^.bind_text16;
  sqlite3_bind_value = sqlite3_api^.bind_value;
  sqlite3_busy_handler = sqlite3_api^.busy_handler;
  sqlite3_busy_timeout = sqlite3_api^.busy_timeout;
  sqlite3_changes = sqlite3_api^.changes;
  sqlite3_close = sqlite3_api^.close;
  sqlite3_collation_needed = sqlite3_api^.collation_needed;
  sqlite3_collation_needed16 = sqlite3_api^.collation_needed16;
  sqlite3_column_blob = sqlite3_api^.column_blob;
  sqlite3_column_bytes = sqlite3_api^.column_bytes;
  sqlite3_column_bytes16 = sqlite3_api^.column_bytes16;
  sqlite3_column_count = sqlite3_api^.column_count;
  sqlite3_column_database_name = sqlite3_api^.column_database_name;
  sqlite3_column_database_name16 = sqlite3_api^.column_database_name16;
  sqlite3_column_decltype = sqlite3_api^.column_decltype;
  sqlite3_column_decltype16 = sqlite3_api^.column_decltype16;
  sqlite3_column_double = sqlite3_api^.column_double;
  sqlite3_column_int = sqlite3_api^.column_int;
  sqlite3_column_int64 = sqlite3_api^.column_int64;
  sqlite3_column_name = sqlite3_api^.column_name;
  sqlite3_column_name16 = sqlite3_api^.column_name16;
  sqlite3_column_origin_name = sqlite3_api^.column_origin_name;
  sqlite3_column_origin_name16 = sqlite3_api^.column_origin_name16;
  sqlite3_column_table_name = sqlite3_api^.column_table_name;
  sqlite3_column_table_name16 = sqlite3_api^.column_table_name16;
  sqlite3_column_text = sqlite3_api^.column_text;
  sqlite3_column_text16 = sqlite3_api^.column_text16;
  sqlite3_column_type = sqlite3_api^.column_type;
  sqlite3_column_value = sqlite3_api^.column_value;
  sqlite3_commit_hook = sqlite3_api^.commit_hook;
  sqlite3_complete = sqlite3_api^.complete;
  sqlite3_complete16 = sqlite3_api^.complete16;
  sqlite3_create_collation = sqlite3_api^.create_collation;
  sqlite3_create_collation16 = sqlite3_api^.create_collation16;
  sqlite3_create_function = sqlite3_api^.create_function;
  sqlite3_create_function16 = sqlite3_api^.create_function16;
  sqlite3_create_module = sqlite3_api^.create_module;
  sqlite3_create_module_v2 = sqlite3_api^.create_module_v2;
  sqlite3_data_count = sqlite3_api^.data_count;
  sqlite3_db_handle = sqlite3_api^.db_handle;
  sqlite3_declare_vtab = sqlite3_api^.declare_vtab;
  sqlite3_enable_shared_cache = sqlite3_api^.enable_shared_cache;
  sqlite3_errcode = sqlite3_api^.errcode;
  sqlite3_errmsg = sqlite3_api^.errmsg;
  sqlite3_errmsg16 = sqlite3_api^.errmsg16;
  sqlite3_exec = sqlite3_api^.exec;
  sqlite3_expired = sqlite3_api^.expired;
  sqlite3_finalize = sqlite3_api^.finalize;
  sqlite3_free = sqlite3_api^.free;
  sqlite3_free_table = sqlite3_api^.free_table;
  sqlite3_get_autocommit = sqlite3_api^.get_autocommit;
  sqlite3_get_auxdata = sqlite3_api^.get_auxdata;
  sqlite3_get_table = sqlite3_api^.get_table;
  sqlite3_global_recover = sqlite3_api^.global_recover;
  sqlite3_interrupt = sqlite3_api^.interruptx;
  sqlite3_last_insert_rowid = sqlite3_api^.last_insert_rowid;
  sqlite3_libversion = sqlite3_api^.libversion;
  sqlite3_libversion_number = sqlite3_api^.libversion_number;
  sqlite3_malloc = sqlite3_api^.malloc;
  sqlite3_mprintf = sqlite3_api^.mprintf;
  sqlite3_open = sqlite3_api^.open;
  sqlite3_open16 = sqlite3_api^.open16;
  sqlite3_prepare = sqlite3_api^.prepare;
  sqlite3_prepare16 = sqlite3_api^.prepare16;
  sqlite3_prepare_v2 = sqlite3_api^.prepare_v2;
  sqlite3_prepare16_v2 = sqlite3_api^.prepare16_v2;
  sqlite3_profile = sqlite3_api^.profile;
  sqlite3_progress_handler = sqlite3_api^.progress_handler;
  sqlite3_realloc = sqlite3_api^.realloc;
  sqlite3_reset = sqlite3_api^.reset;
  sqlite3_result_blob = sqlite3_api^.result_blob;
  sqlite3_result_double = sqlite3_api^.result_double;
  sqlite3_result_error = sqlite3_api^.result_error;
  sqlite3_result_error16 = sqlite3_api^.result_error16;
  sqlite3_result_int = sqlite3_api^.result_int;
  sqlite3_result_int64 = sqlite3_api^.result_int64;
  sqlite3_result_null = sqlite3_api^.result_null;
  sqlite3_result_text = sqlite3_api^.result_text;
  sqlite3_result_text16 = sqlite3_api^.result_text16;
  sqlite3_result_text16be = sqlite3_api^.result_text16be;
  sqlite3_result_text16le = sqlite3_api^.result_text16le;
  sqlite3_result_value = sqlite3_api^.result_value;
  sqlite3_rollback_hook = sqlite3_api^.rollback_hook;
  sqlite3_set_authorizer = sqlite3_api^.set_authorizer;
  sqlite3_set_auxdata = sqlite3_api^.set_auxdata;
  sqlite3_snprintf = sqlite3_api^.snprintf;
  sqlite3_step = sqlite3_api^.step;
  sqlite3_table_column_metadata = sqlite3_api^.table_column_metadata;
  sqlite3_thread_cleanup = sqlite3_api^.thread_cleanup;
  sqlite3_total_changes = sqlite3_api^.total_changes;
  sqlite3_trace = sqlite3_api^.trace;
  sqlite3_transfer_bindings = sqlite3_api^.transfer_bindings;
  sqlite3_update_hook = sqlite3_api^.update_hook;
  sqlite3_user_data = sqlite3_api^.user_data;
  sqlite3_value_blob = sqlite3_api^.value_blob;
  sqlite3_value_bytes = sqlite3_api^.value_bytes;
  sqlite3_value_bytes16 = sqlite3_api^.value_bytes16;
  sqlite3_value_double = sqlite3_api^.value_double;
  sqlite3_value_int = sqlite3_api^.value_int;
  sqlite3_value_int64 = sqlite3_api^.value_int64;
  sqlite3_value_numeric_type = sqlite3_api^.value_numeric_type;
  sqlite3_value_text = sqlite3_api^.value_text;
  sqlite3_value_text16 = sqlite3_api^.value_text16;
  sqlite3_value_text16be = sqlite3_api^.value_text16be;
  sqlite3_value_text16le = sqlite3_api^.value_text16le;
  sqlite3_value_type = sqlite3_api^.value_type;
  sqlite3_vmprintf = sqlite3_api^.vmprintf;
  sqlite3_overload_function = sqlite3_api^.overload_function;
  sqlite3_prepare_v2 = sqlite3_api^.prepare_v2;
  sqlite3_prepare16_v2 = sqlite3_api^.prepare16_v2;
  sqlite3_clear_bindings = sqlite3_api^.clear_bindings;
  sqlite3_bind_zeroblob = sqlite3_api^.bind_zeroblob;
  sqlite3_blob_bytes = sqlite3_api^.blob_bytes;
  sqlite3_blob_close = sqlite3_api^.blob_close;
  sqlite3_blob_open = sqlite3_api^.blob_open;
  sqlite3_blob_read = sqlite3_api^.blob_read;
  sqlite3_blob_write = sqlite3_api^.blob_write;
  sqlite3_create_collation_v2 = sqlite3_api^.create_collation_v2;
  sqlite3_file_control = sqlite3_api^.file_control;
  sqlite3_memory_highwater = sqlite3_api^.memory_highwater;
  sqlite3_memory_used = sqlite3_api^.memory_used;
  sqlite3_mutex_alloc = sqlite3_api^.mutex_alloc;
  sqlite3_mutex_enter = sqlite3_api^.mutex_enter;
  sqlite3_mutex_free = sqlite3_api^.mutex_free;
  sqlite3_mutex_leave = sqlite3_api^.mutex_leave;
  sqlite3_mutex_try = sqlite3_api^.mutex_try;
  sqlite3_open_v2 = sqlite3_api^.open_v2;
  sqlite3_release_memory = sqlite3_api^.release_memory;
  sqlite3_result_error_nomem = sqlite3_api^.result_error_nomem;
  sqlite3_result_error_toobig = sqlite3_api^.result_error_toobig;
  sqlite3_sleep = sqlite3_api^.sleep;
  sqlite3_soft_heap_limit = sqlite3_api^.soft_heap_limit;
  sqlite3_vfs_find = sqlite3_api^.vfs_find;
  sqlite3_vfs_register = sqlite3_api^.vfs_register;
  sqlite3_vfs_unregister = sqlite3_api^.vfs_unregister;
  sqlite3_threadsafe = sqlite3_api^.xthreadsafe;
  sqlite3_result_zeroblob = sqlite3_api^.result_zeroblob;
  sqlite3_result_error_code = sqlite3_api^.result_error_code;
  sqlite3_test_control = sqlite3_api^.test_control;
  sqlite3_randomness = sqlite3_api^.randomness;
  sqlite3_context_db_handle = sqlite3_api^.context_db_handle;
  sqlite3_extended_result_codes = sqlite3_api^.extended_result_codes;
  sqlite3_limit = sqlite3_api^.limit;
  sqlite3_next_stmt = sqlite3_api^.next_stmt;
  sqlite3_sql = sqlite3_api^.sql;
  sqlite3_status = sqlite3_api^.status;
  sqlite3_backup_finish = sqlite3_api^.backup_finish;
  sqlite3_backup_init = sqlite3_api^.backup_init;
  sqlite3_backup_pagecount = sqlite3_api^.backup_pagecount;
  sqlite3_backup_remaining = sqlite3_api^.backup_remaining;
  sqlite3_backup_step = sqlite3_api^.backup_step;
  sqlite3_compileoption_get = sqlite3_api^.compileoption_get;
  sqlite3_compileoption_used = sqlite3_api^.compileoption_used;
  sqlite3_create_function_v2 = sqlite3_api^.create_function_v2;
  sqlite3_db_config = sqlite3_api^.db_config;
  sqlite3_db_mutex = sqlite3_api^.db_mutex;
  sqlite3_db_status = sqlite3_api^.db_status;
  sqlite3_extended_errcode = sqlite3_api^.extended_errcode;
  sqlite3_log = sqlite3_api^.log;
  sqlite3_soft_heap_limit64 = sqlite3_api^.soft_heap_limit64;
  sqlite3_sourceid = sqlite3_api^.sourceid;
  sqlite3_stmt_status = sqlite3_api^.stmt_status;
  sqlite3_strnicmp = sqlite3_api^.strnicmp;
  sqlite3_unlock_notify = sqlite3_api^.unlock_notify;
  sqlite3_wal_autocheckpoint = sqlite3_api^.wal_autocheckpoint;
  sqlite3_wal_checkpoint = sqlite3_api^.wal_checkpoint;
  sqlite3_wal_hook = sqlite3_api^.wal_hook;
  sqlite3_blob_reopen = sqlite3_api^.blob_reopen;
  sqlite3_vtab_config = sqlite3_api^.vtab_config;
  sqlite3_vtab_on_conflict = sqlite3_api^.vtab_on_conflict;

  sqlite3_close_v2 = sqlite3_api^.close_v2;
  sqlite3_db_filename = sqlite3_api^.db_filename;
  sqlite3_db_readonly = sqlite3_api^.db_readonly;
  sqlite3_db_release_memory = sqlite3_api^.db_release_memory;
  sqlite3_errstr = sqlite3_api^.errstr;
  sqlite3_stmt_busy = sqlite3_api^.stmt_busy;
  sqlite3_stmt_readonly = sqlite3_api^.stmt_readonly;
  sqlite3_stricmp = sqlite3_api^.stricmp;
  sqlite3_uri_boolean = sqlite3_api^.uri_boolean;
  sqlite3_uri_int64 = sqlite3_api^.uri_int64;
  sqlite3_uri_parameter = sqlite3_api^.uri_parameter;
  sqlite3_uri_vsnprintf = sqlite3_api^.vsnprintf;
  sqlite3_wal_checkpoint_v2 = sqlite3_api^.wal_checkpoint_v2;
}
(* error
# define SQLITE_EXTENSION_INIT1     const sqlite3_api_routines *sqlite3_api=0;
in declaration at line 461 *)
(* error
# define SQLITE_EXTENSION_INIT2(v)  sqlite3_api=v;
in declaration at line 462 *)
(* error
    extern const sqlite3_api_routines *sqlite3_api;
in declaration at line 464 *)


// ----------- part 2 : virtual tables ---------------------------

type

  Psqlite3_int64  = ^sqlite3_int64;
  sqlite3_int64 = Int64;

  Psqlite3_vtab  = ^sqlite3_vtab;
  sqlite3_vtab = record
    pModule : ^sqlite3_module;
    nRef : cint;
    zErrMsg : ^cchar;
  end;

  Psqlite3_vtab_cursor  = ^sqlite3_vtab_cursor;
  sqlite3_vtab_cursor = record
    pVtab : ^sqlite3_vtab;
  end;

  TConstraint = record
    iColumn : cint;
    op : cuchar;
    usable : cuchar;
    iTermOffset : cint;
  end;

  TOrderBy = record
    iColumn : cint;
    desc : cuchar;
  end;

  TConstraintUsage = record
    argvIndex : cint;
    omit : cuchar;
  end;

  Psqlite3_index_info  = ^sqlite3_index_info;
  sqlite3_index_info = record
    nConstraint : cint;
    aConstraint : ^TConstraint;
    nOrderBy : cint;
    aOrderBy : ^TOrderBy;
    aConstraintUsage : TConstraintUsage;
    idxNum : cint;
    idxStr : ^cchar;
    needToFreeIdxStr : cint;
    orderByConsumed : cint;
    estimatedCost : double;
    estimatedRows : sqlite3_int64; // sqlite 3.8 and later only
  end;

  PPCChar = ^PCChar;

  TxFindFuncCb =
    procedure (_para1:Psqlite3_context; _para2:longint; _para3:PPsqlite3_value);

  const
    SQLITE_INDEX_CONSTRAINT_EQ = 2;
    SQLITE_INDEX_CONSTRAINT_GT = 4;
    SQLITE_INDEX_CONSTRAINT_LE = 8;
    SQLITE_INDEX_CONSTRAINT_LT = 16;
    SQLITE_INDEX_CONSTRAINT_GE = 32;
    SQLITE_INDEX_CONSTRAINT_MATCH = 64;



type
  TVTab = sqlite3_vtab;
  sqlite3_module = record
    iVersion : cint;
    xCreate :
      function (_1:Psqlite3; var pAux:pointer; argc:cint; argv:Ppcchar;
                out ppVTab:Psqlite3_vtab; _6:PPcchar):cint; cdecl;
    xConnect :
      function (_1:Psqlite3; var pAux:pointer; argc:cint; argv:Ppcchar;
                out ppVTab:Psqlite3_vtab; _6:PPcchar):cint; cdecl;
    xBestIndex :
      function (var pVTab:sqlite3_vtab; var ixifo:Psqlite3_index_info):cint;cdecl;
    xDisconnect : function (pVTab:psqlite3_vtab):cint;cdecl;
    xDestroy : function (pVTab:psqlite3_vtab):cint;cdecl;
    xOpen : function (var pVTab:sqlite3_vtab;
                      out ppCursor:Psqlite3_vtab_cursor):cint;cdecl;
    xClose : function (_1:Psqlite3_vtab_cursor):cint;cdecl;
    xFilter : function (_1:Psqlite3_vtab_cursor; idxNum:cint; idxStr:pcchar;
                        argc:cint; var argv:Psqlite3_value):cint;cdecl;
    xNext : function (_1:Psqlite3_vtab_cursor):cint;cdecl;
    xEof : function (_1:Psqlite3_vtab_cursor):cint;cdecl;
    xColumn : function (_1:Psqlite3_vtab_cursor;
                        _2:Psqlite3_context; _3:cint):cint;cdecl;
    xRowid : function (_1:Psqlite3_vtab_cursor;
                       var pRowid:sqlite3_int64):cint;cdecl;
    xUpdate : function (_1:Psqlite3_vtab; _2:cint;
                        _3:PPsqlite3_value; _4:Psqlite3_int64):cint;cdecl;
    xBegin : function (var pVTab:sqlite3_vtab):cint;cdecl;
    xSync : function (var pVTab:sqlite3_vtab):cint;cdecl;
    xCommit : function (var pVTab:sqlite3_vtab):cint;cdecl;
    xRollback : function (var pVTab:sqlite3_vtab):cint;cdecl;
    xFindFunction : function (var pVtab:sqlite3_vtab; nArg:cint; zName:pcchar;
                              pxFunc:txFindFuncCb; var ppArg:pointer):cint;cdecl;
    xRename : function (var pVtab:sqlite3_vtab; zNew:pcchar):cint;cdecl;
    xSavepoint : function (var pVTab:sqlite3_vtab; _2:cint):cint;cdecl;
    xRelease : function (var pVTab:sqlite3_vtab; _2:cint):cint;cdecl;
    xRollbackTo : function (var pVTab:sqlite3_vtab; _2:cint):cint;cdecl;
  end;



implementation


end.
