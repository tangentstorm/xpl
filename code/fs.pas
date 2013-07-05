{$mode objfpc}{$i xpc.inc}
unit fs;   { file system routines }
interface uses stri
  {$IFDEF FPC}, sysutils{$ENDIF};

  function exists( path : string ) : boolean;

  {  IDEA: general purpose file opener }
  //  TODO: http://www.freepascal.org/docs-html/rtl/sysutils/fileopen.html
  //  type fileobj = class
  //    private _file : file;
  //    constructor from(var f : file );
  //    procedure seek( pos	: int32 );
  // end;
  // type flag = ( r, w, b ); flags = set of flag;
  // function open( path : string; mode : flags = [ r ]) : fileobj;

  { explicit versions. }
  procedure review( var f : file; path : string );
  procedure create( var f : file; path : string );
  procedure update( var f : file; path : string );
  procedure append( var f : file; path : string );

  procedure filereset  ( var f : file; path : string ); deprecated;
  procedure filerewrite( var f : file; path : string ); deprecated;
  procedure fileappend ( var f : file; path : string ); deprecated;

  { write data to binary files }
  procedure savebyte( var f : file; b : byte );
  procedure saveshortint( var f : file; s : shortint );
  procedure saveboolean( var f : file; b : boolean );
  procedure saveword( var f : file; w : word );
  procedure saveinteger( var f : file; i : integer );
  procedure savelongint( var f : file; l : longint );
  procedure savestring ( var f : file; s : string );
  procedure savetext ( var f: file; s : string );
  procedure savevar ( var f : file; var v; size : word );

  { read binary files }
  procedure nextvar( var f : file; var v );
  function nextbyte( var f : file ) : byte;
  function nextshortint( var f : file ) : shortint;
  function nextboolean( var f : file ) : boolean;
  function nextword( var f : file ) : word;
  function nextinteger( var f : file ) : integer;
  function nextlongint( var f : file ) : longint;
  function nextstring( var f : file ) : string;

  { indexed files for fast access to variable length strings }
  procedure idxinit( var f : file; tenchars : string; num : longint );
  procedure idxsave( var f : file; index : longint; var v; size : word );
  procedure idxload( var f : file; index : longint; var v );
  function idxcount( var f : file ) : longint;

  function errormsg : string;


const
  fileok		= 0;
  filenotfound		= 2;
  pathnotfound		= 3;
  toomanyopenfiles	= 4;
  fileaccessdenied	= 5;
  invalidfilehandle	= 6;
  invalidfileaccesscode	= 7;

  var error : word;

implementation


  procedure review( var f : file; path : string );
  begin
    {$I-}
    system.assign( f, path );
    system.reset( f, sizeof( byte ));
    {$I+}
    error := ioresult;
  end;

  procedure create(var f : file; path : string );
  begin
    {$I-}
    system.assign( f, path );
    system.rewrite( f, 1 );
    {$I+}
    error := ioresult;
  end;

  {  todo: update and create are the same. all of these
    should call a generic open(), but do some extra assertions. }
  procedure update(var f : file; path : string );
  begin
    {$I-}
     { http://stackoverflow.com/questions/14428556/is-it-possible-to-read-and-write-from-to-file-opening-it-only-once }
    system.FileMode := fmOpenReadWrite;
    system.assign( f, path );
    system.reset( f );
    {$I+}
    error := ioresult;
  end;

  procedure append ( var f : file; path : string );
  begin
    {$I-}
    system.assign( f, path );
    system.rewrite( f, 1 );
    seek( f, filesize( f ));
    {$I+}
    error := ioresult;
  end;

  procedure filereset( var f : file; path : string );
    inline; begin review( f, path ); end;
  procedure filerewrite(var f : file; path : string );
    inline; begin update( f, path ); end;
  procedure fileappend ( var f : file; path : string );
    inline; begin append( f, path ); end;


  procedure savebyte( var f : file; b : byte );
  begin
    blockwrite( f, b, 1 );
  end;

  procedure saveshortint( var f : file; s : shortint );
  begin
    blockwrite( f, s, 1 );
  end;

  procedure saveboolean( var f : file; b : boolean );
  begin
    blockwrite( f, b, 1 );
  end;

  procedure saveword( var f : file; w : word );
  begin
    blockwrite( f, w, 2 );
  end;

  procedure saveinteger( var f : file; i : integer );
  begin
    blockwrite( f, i, 2 );
  end;

  procedure savelongint( var f : file; l : longint );
  begin
    blockwrite( f, l, 4 );
  end;

  procedure savestring ( var f : file; s : string );
    var i : word;
  begin
    i := length( s );
    blockwrite( f, i, sizeof( i ));
    blockwrite( f, s, length( s ));
  end;

  procedure savetext( var f : file; s : string );
  begin
    blockwrite( f, s[1], length( s ));
  end;


  procedure savevar( var f : file; var v; size : word );
  begin
    saveword( f, size );
    blockwrite( f, v, size );
 end;

  procedure nextvar( var f : file; var v );
    var s : word;
  begin
    s := nextword( f );
    blockread( f, v, s );
  end;


  procedure idxinit( var f : file; tenchars : string; num : longint );
    var z : longint;
  begin
    tenchars := stri.pad( tenchars, 10, ' ' );
    blockwrite( f, tenchars[1], 10 ); { file header }
    savelongint( f, num ); { number of entries }
    for z := 0 to num do savelongint( f, 0 ); { num # of zeroes }
  end;

  procedure idxsave( var f : file; index : longint; var v; size : word );
    var idxpos : longint;
  begin
    idxpos := filepos( f );
    seek( f, 10 + ( succ( index ) * sizeof( longint )));
    savelongint( f, idxpos );
    seek( f, idxpos );
    savevar( f, v, size );
  end;

  procedure idxload( var f : file; index : longint; var v );
    var idxpos : longint;
  begin
    seek( f, 10 + ( succ( index ) * sizeof( longint )));
    idxpos := nextlongint( f );
    seek( f, idxpos );
    nextvar( f, v );
  end;

  function idxcount( var f : file ) : longint;
  begin
    seek( f, 10 );
    idxcount := nextlongint( f );
  end;

  function  exists ( path : string ) : boolean;
  {$IFDEF FPC}
  begin
    result := sysutils.fileexists( path )
  end;
  {$ELSE}
  var t : file;
  begin
    {$I-}
    filereset( t, path );
    close( t );
    {$I+}
    fileexists := (ioresult = 0) and (s <> '');
  end;
  {$ENDIF}

  function nextbyte( var f : file ) : byte;
  begin
    blockread( f, result, 1 );
  end;

  function nextshortint( var f : file ) : shortint;
  begin
    blockread( f, result, 1 );
  end;

  function nextboolean( var f : file ) : boolean;
  begin
    blockread( f, result, 1 );
  end;


  function nextword( var f : file ) : word;
  begin
    blockread( f, result, 2 );
  end;

  function nextinteger( var f : file ) : integer;
  begin
    blockread( f, result, 2 );
  end;

  function nextlongint( var f : file ) : longint;
  begin
    blockread( f, result, 4 );
  end;

  function nextstring( var f : file ) : string;
    var
      n	: string;
      b	: byte;
  begin
    blockread( f, b, 1 );
    blockread( f, n, b );
    nextstring := n;
  end;

  function errormsg : string;
  begin
    case error of
      fileok		    : result := 'No problems...';
      filenotfound	    : result := 'File not found.';
      pathnotfound	    : result := 'Path not found.';
      toomanyopenfiles	    : result := 'Too many open files.';
      fileaccessdenied	    : result := 'File access denied.';
      invalidfilehandle	    : result := 'Invalid file handle.';
      invalidfileaccesscode : result := 'Invalid file access code.';
    end;
  end;

begin
  fs.error := fileok;
end.
