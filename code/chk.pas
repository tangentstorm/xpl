{$mode delphiunicode}{$i xpc.inc}
unit chk;
interface uses sysutils, num, xpc;
type int = integer;

procedure fail( const msg : TStr );
procedure that( pred : boolean; const msg : TStr );
procedure equal( a, b : TStr; msg : TStr = 'strings did not match' ); overload;
procedure equal( a, b : int; msg : TStr = 'numbers did not match' ); overload;
procedure report;

implementation

var count : int = 0;

procedure pass; inline;
begin
end;

procedure fail ( const msg : TStr );
begin
  raise EAssertionFailed.create( Utf8Encode( msg ));
end;

function peek( pred : boolean ) : boolean;
begin
  inc( count );
  if pred then pass;
  peek := pred;
end;

procedure that( pred : boolean; const msg : TStr );
begin
  if not peek( pred ) then fail( msg );
end;

procedure equal( a, b : TStr; msg : TStr = 'strings did not match' );
begin
  if not peek( a = b ) then
    fail( msg + lineending + 'a = ' + a + lineending + 'b = '+ b );
end;

procedure equal( a, b : int; msg : TStr = 'numbers did not match' );
begin
  if not peek( a = b ) then
    fail( msg + ': ' + n2s(a) + ' <> '+ n2s(b) );
end;

procedure report;
begin
  writeln;
  write( count );
  writeln( ' tests passed.' );
end;

initialization
end.
