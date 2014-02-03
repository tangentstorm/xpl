{$i xpc.inc}{$mode delphi}
program run_tests;
uses xpc, cw, cx, sysutils {$i run-tests.use }; // includes test_*.pas

type
  outcome  = ( pass, fail, err );
  problem  = record
	       test_name : string;
	       result	 : outcome;
	       error	 : string;
	     end;
  testcase = procedure;
const
  colors : array[ outcome ] of string[ 2 ] = ( '|g', '|y', '|r' );

var
  overall  : outcome;
  passed,  
  failed,  
  broken   : integer;
  problems : array of problem;
  trace	   : boolean = false;

procedure setup;
begin
  if (paramstr( 1 ) = '--trace')
  or (paramstr( 1 ) = '-t') then trace := true;
  setlength( problems, 0 );
  writeln( 'running tests' );
  writeln;
end;



procedure run( unit_name, test_name : string; to_test : testcase );
var result : outcome = pass;  p : problem;  e : exception;
begin
  //  chk.reset;
  if trace then cwrite( '|K' + unit_name + '.|w' + test_name + '|K: ' );
  try to_test
  except
    on exception do begin
      e := ExceptObject as exception;
      if e is EAssertionFailed then result := fail
      else result := err;
      p.error := cx.stacktrace( e );
      p.test_name := unit_name + '.' + test_name;
      p.result := result;
      setlength( problems, length( problems ) + 1 );
      problems[ length( problems ) - 1 ] := p;
    end;
  end;
  case result of
    pass : begin inc( passed ); cwrite( '|g.' ) end;
    fail : begin inc( failed ); cwrite( '|y!' ) end;
    err  : begin inc( broken ); cwrite( '|rX' ) end;
  end; { case }
  if trace then writeln;
end;

procedure report;
  var total : integer; p : problem;
begin
  if length( problems ) > 0 then begin
    cwriteln( '|K');
    writeln('----------------------------------------------' );
    writeln;
  end;

  for p in problems do begin
    cwriteln( '|K[ ' + colors[ p.result ] + p.test_name + ' |K]');
    cwriteln( '|w' + p.error );
  end;
  cwriteln( '|K');
  writeln('----------------------------------------------' );
  total := passed + failed + broken;
  cwriteln([ '|K', 'results: ', '|w', total, ' tests run. ',
	     passed, ' tests passed; ',
             failed, ' failed; ',
             broken, ' broken.' ]);
  writeln;
end;


begin
  setup;
  {$i run-tests.run }
  report;
end.
