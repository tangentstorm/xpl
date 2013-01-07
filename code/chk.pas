unit chk;
interface uses sysutils, num;
type int = integer;
type str = string[ 255 ];

procedure fail( const msg : str );
procedure that( pred : boolean; const msg : str );
procedure equal( a, b : str );
procedure equal( a, b : integer );
procedure report;

implementation

var count : int = 0;

procedure pass; inline;
begin
end;

procedure fail ( const msg : str );
begin
  raise EAssertionFailed.create( msg );
end;

function peek( pred : boolean ) : boolean;
begin
  inc( count );
  if pred then pass;
  peek := pred;
end;

procedure that( pred : boolean; const msg : str );
begin
  if not peek( pred ) then fail( msg );
end;

procedure equal( a, b : str );
begin
  if not peek( a = b ) then
    fail( 'strings did not match: "' + a + '" <> "' + b + '"' );
end;

procedure equal( a, b : integer );
begin
  if not peek( a = b ) then
    fail( 'numbers did not match: ' + n2s(a) + ' <> '+ n2s(b) );
end;

procedure report;
begin
  writeln;
  write( count );
  writeln( ' tests passed.' );
end;

initialization
end.
